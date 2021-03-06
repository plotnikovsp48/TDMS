' Команда - Импортировать из xml
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

Call Main(ThisObject)

Sub Main(Obj)
  ThisScript.SysAdminModeOn
  
  'Запрос файла XML
  Fname = ThisApplication.ExecuteScript("CMD_DIALOGS","SelectFileDlg","FILE_XML")
  If Fname = " " Then
    'Msgbox "Вы не выбрали ни одного файла.", vbExclamation
    Exit Sub
  End If
  FShortName = Right(FName, Len(Fname) - InStrRev(FName, "\"))
  ThisApplication.Utility.WaitCursor = True
  
  'Инициализация формы
  Set Form = ThisApplication.InputForms("FORM_TENDER_OUT_IMPORT")
  Form.Controls("XMLname").Value = "Будут созданы следующие закупки:"
  Set Rows = Form.Attributes("ATTR_TENDER_OUT_IMPORT_TBL").Rows
  ThisApplication.Utility.WaitCursor = False
  'Заполнение таблицы из файла
  If TableSyncFill(Rows,Fname) = False Then Exit Sub
  'Сортировка таблицы по цене
  Call TableRowsSortNum(Rows,"ATTR_TENDER_FIRST_PRICE")
  'Call ThisApplication.ExecuteScript("CMD_DLL","TableRowsSort",Rows,"")
  
  If Form.Show and Rows.Count > 0 Then
    ThisApplication.Utility.WaitCursor = True
    Set Progress = ThisApplication.Dialogs.ProgressDlg
    Progress.Start
    Progress.Position = 0
    Count = Rows.Count
    pStep = 100 / Count
    i = 0
    'Создание закупок
    For Each Row in Rows
      Progress.Position = pStep * i
      Progress.Text = "Создание закупок...(" & i+1 & " из " & Count & ")"
      Set NewObj = Obj.Objects.Create("OBJECT_PURCHASE_OUTSIDE")
      For Each Attr in Row.Attributes
        If NewObj.Attributes.Has(Attr.AttributeDefName) Then
          Call ThisApplication.ExecuteScript("CMD_DLL","AttrValueCopy",Attr,NewObj.Attributes(Attr.AttributeDefName))
        End If
      Next
      'Дата получения информации
      AttrName = "ATTR_TENDER_INFO_GET_TIME"
      If NewObj.Attributes.Has(AttrName) Then
        NewObj.Attributes(AttrName).Value = Date
      End If
      'Ответственный за КП/НКП
      AttrName0 = "ATTR_TENDER_KP_DESI"
      AttrName1 = "ATTR_TENDER_PEO_CHIF"
      If NewObj.Attributes.Has(AttrName0) and NewObj.Attributes.Has(AttrName1) Then
        If NewObj.Attributes(AttrName1).Empty = False Then
          NewObj.Attributes(AttrName0).User = NewObj.Attributes(AttrName1).User
        End If
      End If
      i = i + 1
    Next
    Progress.Stop
    
    If i > 0 Then Msgbox "Импортировано " & i & " объектов",vbInformation
  End If
End Sub

'======================================================================================
'Процедура сортировки таблицы по численному столбцу
'--------------------------------------------------------------------------------------
'AttrName:String - Системное имя атрибута в таблице
'TableRows:Collection - Коллекция строк таблицы
'======================================================================================
Sub TableRowsSortNum(Rows,AttrName)
  Do
    Check = False
    For i = 0 to Rows.Count - 1
      Val0 = Rows(i).Attributes(AttrName).Value
      If i+1 <= Rows.Count - 1 Then
        Val1 = Rows(i+1).Attributes(AttrName).Value
        If Val0 > Val1 Then
          Rows.Move i, i+1
          Check = True
        End If
      End If
    Next
  Loop Until Check = False
End Sub

'Функция формирования таблицы закупок из файла
Function TableSyncFill(Rows,Fname)
  TableSyncFill = False
  
  'Чтение файла и формирование таблицы
  Set Clfs = ThisApplication.Classifiers.Find("Способы закупок")
  If not Clfs is Nothing Then
    Set Clf0 = Clfs.Classifiers.Find("05")
    Set Clf1 = Clfs.Classifiers.Find("01")
  End If
  set xmlDoc = CreateObject("MSXML2.DOMDocument")
  xmlDoc.async = False
  xmlDoc.load(Fname)
  If xmlDoc.parseError.errorCode Then
    Call ShowError(xmlDoc.parseError)
    set xmlDoc = Nothing
    Exit Function
  End If
  
  'Заказчик
  Set Customer = Nothing
  Set colNodes = xmlDoc.getElementsByTagName("ns2:customer")
  colNodes.reset
  Set nodeTitle = colNodes.nextNode
  Set ChildNode0 = nodeTitle.firstChild
  Set ChildNode1 = ChildNode0.firstChild
  Do While Not ChildNode1 Is Nothing
    Val = ChildNode1.nodeName
    If StrComp(Val,"inn",vbTextCompare) = 0 Then
      Set q = ThisApplication.CreateQuery
      q.Permissions = sysadminpermissions
      q.AddCondition tdmQueryConditionObjectDef, "OBJECT_CORRESPONDENT"
      q.AddCondition tdmQueryConditionAttribute, ChildNode1.text, "ATTR_S_JPERSON_TIN"
      Set Objects = q.Objects
      If Objects.Count > 0 Then
        Set Customer = Objects(0)
      End If
      Exit Do
    End If
    Set ChildNode1 = ChildNode1.nextSibling
  Loop
  
  'Организатор
  Set Organizer = Nothing
  Set colNodes = xmlDoc.getElementsByTagName("ns2:placer")
  colNodes.reset
  Set nodeTitle = colNodes.nextNode
  Set ChildNode0 = nodeTitle.firstChild
  Set ChildNode1 = ChildNode0.firstChild
  Do While Not ChildNode1 Is Nothing
    Val = ChildNode1.nodeName
    If StrComp(Val,"inn",vbTextCompare) = 0 Then
      Set q = ThisApplication.CreateQuery
      q.Permissions = sysadminpermissions
      q.AddCondition tdmQueryConditionObjectDef, "OBJECT_CORRESPONDENT"
      q.AddCondition tdmQueryConditionAttribute, ChildNode1.text, "ATTR_S_JPERSON_TIN"
      Set Objects = q.Objects
      If Objects.Count > 0 Then
        Set Organizer = Objects(0)
      End If
      Exit Do
    End If
    Set ChildNode1 = ChildNode1.nextSibling
  Loop
  
  'Перебор закупок
  Set Dict = ThisApplication.Dictionary("PurchaseImportFromXML")
  Set colNodes = xmlDoc.getElementsByTagName("ns2:purchasePlanItem")
  colNodes.reset
  Dict.RemoveAll
  Set nodeTitle = colNodes.nextNode
  While Not nodeTitle Is Nothing
    Set currNode = nodeTitle.firstChild
    Set ParentNode = nodeTitle.parentNode
    ParentName = ParentNode.nodeName
    Set Row = Rows.Create
    PublicDate = ""
    Handle = ""
    CheckSMSP = 0
    'Заказчик
    If not Customer is Nothing Then
      Row.Attributes("ATTR_TENDER_CLIENT").Object = Customer
    End If
    'Организатор
    If not Organizer is Nothing Then
      Row.Attributes("ATTR_TENDER_ORGANIZER").Object = Organizer
    End If
    While Not currNode Is Nothing
      Check = False
      If StrComp(ParentName,"ns2:purchasePlanItems",vbTextCompare) <> 0 Then Check = True
      Row.Attributes("ATTR_TENDER_SMALL_BUSINESS_FLAG").Value = Check
      Select Case currNode.nodeName
        'Guid
        Case "ns2:guid"
          Guid = currNode.childNodes(0).text
          If Dict.Exists(Guid) Then
            Handle = Dict.Item(Guid)
            If Check = True Then
              CheckSMSP = 1
            Else
              CheckSMSP = 2
            End If
          Else
            Dict.Add Guid, Row.Handle
          End If
        
        'Наименование
        Case "ns2:contractSubject"
          Row.Attributes("ATTR_NAME").Value = currNode.childNodes(0).text
          
        'Год публикации
        Case "ns2:purchasePeriodYear"
          PublicDate = currNode.childNodes(0).text
        
        'Месяц публикации
        Case "ns2:purchasePeriodMonth"
          Val = currNode.childNodes(0).text
          If Len(Val) = 1 Then
            Val = "0" & Val
          ElseIf Len(Val) > 2 Then
            Val = ""
          End If
          If Val <> "" and PublicDate <> "" Then 
            PublicDate = PublicDate & "." & Val & ".01"
          End If
        
        'Закупка в электронной форме
        Case "ns2:isElectronic"
          Row.Attributes("ATTR_TENDER_ONLINE").Value = currNode.childNodes(0).text
          
        'Лимитная цена, с НДС
        Case "ns2:maximumContractPrice"
          Row.Attributes("ATTR_TENDER_FIRST_PRICE").Value = currNode.childNodes(0).text
          
        'Способ закупки
        Case "ns2:purchaseMethodName"
          Val = currNode.childNodes(0).text
          If StrComp(Val, "37 (Газпром) Закупка у единственного поставщика (подрядчика, исполнителя)",vbTextCompare) = 0 Then
            Row.Attributes("ATTR_TENDER_METHOD_NAME").Classifier = Clf0
          ElseIf StrComp(Val, "29 (Газпром) Открытый запрос предложений в электронной форме",vbTextCompare) = 0 Then
            Row.Attributes("ATTR_TENDER_METHOD_NAME").Classifier = Clf1
          End If
        
      End Select
      
      'ThisApplication.AddNotify currNode.nodeName & " - " & currNode.childNodes(0).text
      Set currNode = currNode.nextSibling
    Wend
    
    'Дата публикации извещения о закупке
    If PublicDate <> "" and IsDate(PublicDate) Then
      Row.Attributes("ATTR_TENDER_INVITATION_DATA_EIS").Value = PublicDate
    End If
    
    'Проверка дублирования строк
    If CheckSMSP = 1 and Handle <> "" Then
      Rows.Remove Row
      For Each Row in Rows
        If Row.Handle = Handle Then
          Row.Attributes("ATTR_TENDER_SMALL_BUSINESS_FLAG").Value = True
          Exit For
        End If
      Next
    ElseIf CheckSMSP = 2 Then
      Row.Erase
    End If
    Set nodeTitle = colNodes.nextNode
  Wend
  
  Dict.RemoveAll
  set xmlDoc = Nothing
  TableSyncFill = True
End Function

'Функция отображения ошибки парсинга
Function ShowError(XMLDOMParseError)
  mess = _
  "parseError.errorCode: " & XMLDOMParseError.errorCode & vbCrLf & _
  "parseError.filepos: " & XMLDOMParseError.filepos & vbCrLf & _
  "parseError.line: " & XMLDOMParseError.line & vbCrLf & _
  "parseError.linepos: " & XMLDOMParseError.linepos & vbCrLf & _
  "parseError.reason: " & XMLDOMParseError.reason & vbCrLf & _
  "parseError.srcText: " & XMLDOMParseError.srcText & vbCrLf & _
  "parseError.url: " & XMLDOMParseError.url & vbCrLf
  Msgbox mess,VbCritical
End Function
