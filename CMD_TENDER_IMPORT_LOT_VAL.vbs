' Команда - Импортировать состав лота
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

Call Main(ThisObject)

Sub Main(Obj)
  ThisScript.SysAdminModeOn
'_________________________________________________________________________  
Dim ExcelFDef, FDefs
        
        'Получить ссылку на коллекцию типов файлов приложения
        Set FDefs = ThisApplication.FileDefs
        
        'Если в системе не существует такого типа, создать его и задать значения свойств    
        If Not FDefs.Has("FILE_EXCEL") Then
                Set ExcelFDef = FDefs.Create
                With ExcelFDef     
                        .SysName = "FILE_EXCEL"
                        .Description = "Рабочая книга Excel"
                        .Extensions = "*.xlsx"
                        .Icon = ThisApplication.Icons(0)
                End With
        Else 
                Set ExcelFDef = FDefs.Item("FILE_EXCEL")
        End If

  'Запрос файла XLSX
  Fname = ThisApplication.ExecuteScript("CMD_DIALOGS","SelectFileDlg","FILE_EXCEL")
  If Fname = " " Then
    'Msgbox "Вы не выбрали ни одного файла.", vbExclamation
    Exit Sub
  End If
  FShortName = Right(FName, Len(Fname) - InStrRev(FName, "\"))
  ThisApplication.Utility.WaitCursor = True
  
  'Инициализация формы
  Set Rows = Thisobject.Attributes("ATTR_LOT_DETAIL").Rows
  ThisApplication.Utility.WaitCursor = False
  'Заполнение таблицы из файла
  If TableSyncFill(Rows,Fname) = False Then Exit Sub

 End Sub

'Функция формирования таблицы закупок из файла
Function TableSyncFill(Rows,Fname)
  TableSyncFill = False
 Set Clfs = ThisApplication.Classifiers.Find("Ставка НДС")
 If not Clfs is Nothing Then 
 Set Clf0 = Clfs.Classifiers.Find("Без НДС")
 Set Clf18 = Clfs.Classifiers.Find("НДС 18%")
 Set Clf10 = Clfs.Classifiers.Find("НДС 10%")
 End if

 'Запуск Excel
  Set ExcelApp = CreateObject("Excel.Application")
  Set WrkBook = ExcelApp.Workbooks.Open(Fname)
'  Set List = WrkBook.ActiveSheet
  Set Sheet = WrkBook.Worksheets(1)
  ExcelApp.Application.Visible = False
  
  If ExcelApp is Nothing or WrkBook is Nothing or Sheet is Nothing Then
    Call ParamsClear(ExcelApp,WrkBook,Sheet)
  End If
  'Заполнение таблицы состава
   'Взять массив с листа, начиная с ячейки A1
  DataArray = Sheet.Range("B5").CurrentRegion.Value
  StrTxt = ""
  StrCls = ""
  StrTxtOKEI = ""
  StrClsOKEI = ""
  StrTxtCOR = ""
  StrClsCOR = ""    
  checkBound = UBound (DataArray, 1) 
  checkBound1 = UBound (DataArray, 2)    
  For i = 3 to checkBound
  
  Set NewRow = Rows.Create 
    For j = 1 to 11 'checkBound1 -1
    k = j-1 
    If k = 11 Then k = 0
      'Отработка ошибок обращения к ячейке с денежным значением
'        If j > 7 Then k = j - 2
         Val = DataArray(i,j)
      Set attr = NewRow.attributes
'      msgbox NewRow.attributes.Count
'        msgbox k
      If attr(k).AttributeDefName = "ATTR_LOT_ITEM_NUM" Then  
       attr("ATTR_LOT_ITEM_NUM").value = DataArray(i,1)
      ElseIf attr(k).AttributeDefName = "ATTR_NAME" Then  
       attr("ATTR_NAME").value = DataArray(i,2) 
      ElseIf attr(k).AttributeDefName = "ATTR_TENDER_LOT_POS_DEVELOPER" Then 
        Val = DataArray(i,3)
        a = "'" &RTrim(Val)&"'" 
       Guid = FndCor(Val)
       Set objt = ThisApplication.GetObjectByGUID(Guid) 
       
       If objt is Nothing Then
        If StrTxtCOR <> "" Then
        StrTxtArrCOR = Split(StrTxtCOR,";;")
        StrClsArrCOR = Split(StrClsCOR,";;")
         If IsEmpty(StrTxtArrCOR) = false then
         For m = 0 to Ubound(StrTxtArrCOR)
          if StrTxtArrCOR(m) <> "" then
           if StrTxtArrCOR(m) = a then
           b = StrClsArrCOR(m)

           Set objt = ThisApplication.GetObjectByGUID(b) 
           End If
          End If
         next
         End If    
        End If 
       End If    
         
       If objt is Nothing Then  
        set selDlg = ThisApplication.Dialogs.SelectDlg
        set Qr = ThisApplication.Queries("QUERY_KORREESPONDENTES")
        selDlg.SelectFrom = Qr.Sheet
        SelDlg.Caption = "Выбор производителя"
        SelDlg.Prompt = "Производитель " &Val & " неизвестен, или задан некорректно. Выберите производителя:"
         if selDlg.Show = true then
         Set objt = selDlg.Objects.Objects(0)
         ' Добавлем выбор в словарь
         a = RTrim(Val)
         StrTxtCOR = StrTxtCOR & ";;" &a
         StrClsCOR = StrClsCOR & ";;" &objt.GUID
         end if
       End If

       If not objt is Nothing Then attr("ATTR_TENDER_LOT_POS_DEVELOPER").value = objt
       If objt is Nothing Then MsgBox  "Производитель позиции N " & i-2  & " не задан" 

      ElseIf attr(k).AttributeDefName = "ATTR_TENDER_COUNTRIES" Then
       Val = DataArray(i,4)  
       If StrComp(Val,"Российская Федерация",vbTextCompare) = 0 Then  Val = "Россия"
       Set Clfs = ThisApplication.Classifiers.Find("Страны")
       If not Clfs is Nothing Then 
       a = RTrim(Val)
       Set Clfs1 = Clfs.Classifiers.Find(a)
       If not Clfs1 is Nothing Then
       attr(k) = Clfs1
       Else 
 
       If StrTxt <> "" Then
       StrTxtArr = Split(StrTxt,",")
       StrClsArr = Split(StrCls,",")
       
        If IsEmpty(StrTxtArr) = false then
        For m = 0 to Ubound(StrTxtArr)
         if StrTxtArr(m) <> "" then 
          if StrTxtArr(m) = a then
          b = StrClsArr(m)
          Set Clfs1 = Clfs.Classifiers.Find(b)
          attr(k) = Clfs1
          End If
         End If
        next
        End If    
       End If 
      End If  
       
       If Clfs1 is Nothing Then
       Set SelectClassifDlg = ThisApplication.Dialogs.SelectClassifierDlg
       SelectClassifDlg.Caption = "Страна происхождения " &a &" задана некорректно. Задайте правильное значение" 
       SelectClassifDlg.Root = ThisApplication.Classifiers("Страны")
       RetVal = SelectClassifDlg.Show
       If RetVal Then
       attr(k) = SelectClassifDlg.Classifier
       ' Добавлем выбор в словарь
       StrTxt = StrTxt & "," &a
       StrCls = StrCls & "," &SelectClassifDlg.Classifier.Description
       End If
       If RetVal <> True Then MsgBox  "Страна происхождения позиции N " & i-2  & " не задана" 
       End if
     End if 
     
     ElseIf attr(k).AttributeDefName = "ATTR_TENDER_OKEI_NAME" Then  
     Val = DataArray(i,5)   
      If StrComp(Val,"Шт.",vbTextCompare) = 0 or StrComp(Val,"Шт",vbTextCompare) = 0 Then  Val = "Штука"
       Set Clfs = ThisApplication.Classifiers.Find("ОКЕИ")
       If not Clfs is Nothing Then 
       a = RTrim(Val)
       Set Clfs1 = Clfs.Classifiers.Find(a)
       If not Clfs1 is Nothing Then
       attr("ATTR_TENDER_OKEI_NAME") = Clfs1
       Else 
 
       If StrTxtOKEI <> "" Then
       StrTxtArrOKEI = Split(StrTxtOKEI,",")
       StrClsArrOKEI = Split(StrClsOKEI,",")
       
        If IsEmpty(StrTxtArrOKEI) = false then
        For m = 0 to Ubound(StrTxtArrOKEI)
         if StrTxtArrOKEI(m) <> "" then 
          if StrTxtArrOKEI(m) = a then
          b = StrClsArrOKEI(m)
          Set Clfs1 = Clfs.Classifiers.Find(b)
          attr(k) = Clfs1
          End If
         End If
        next
        End If    
       End If 
      End If  
       
       If Clfs1 is Nothing Then
       Set SelectClassifDlg = ThisApplication.Dialogs.SelectClassifierDlg
       SelectClassifDlg.Caption = "Единица измерения " &a &" задана некорректно. Задайте правильное значение" 
       SelectClassifDlg.Root = ThisApplication.Classifiers("ОКЕИ")
       RetVal = SelectClassifDlg.Show
       If RetVal Then
       attr(k) = SelectClassifDlg.Classifier
       ' Добавлем выбор в словарь
       StrTxtOKEI = StrTxtOKEI & "," &a
       StrClsOKEI = StrClsOKEI & "," &SelectClassifDlg.Classifier.Description
       
       End If
       If RetVal <> True Then
       MsgBox  "Единица измерения позиции N " & i-2  & " не задана" 'SelectClassifDlg.Classifier.Description, vbInformation
       End If   
       End if
      End if       
     ElseIf attr(k).AttributeDefName = "ATTR_LOT_ITEM_VALUE" Then    
     attr("ATTR_LOT_ITEM_VALUE").value = DataArray(i,6) 
     ElseIf attr(k).AttributeDefName = "ATTR_TENDER_LOT_UNIT_PRICE" Then    
     attr("ATTR_TENDER_LOT_UNIT_PRICE").value = DataArray(i,7) 
     
     ElseIf attr(k).AttributeDefName = "ATTR_TENDER_PRICE" Then 
    Val = DataArray(i,8)  
     attr("ATTR_TENDER_PRICE").value = Round(Val,2)
   
    ElseIf attr(k).AttributeDefName = "ATTR_TENDER_SUM_NDS" Then   
'    Val = DataArray(i,9) 
'     attr("ATTR_TENDER_SUM_NDS").value = DataArray(i,8)  
'    msgbox k 
     If StrComp(Val,"НДС не облагается",vbTextCompare) = 0 Then attr("ATTR_TENDER_SUM_NDS").value = 0
     
     
     ElseIf attr(k).AttributeDefName = "ATTR_NDS_VALUE" Then 
     
      Val = DataArray(i,9)
        If StrComp(Val,"НДС не облагается",vbTextCompare) = 0 Then 
        attr("ATTR_NDS_VALUE").value = Clf0
        attr("ATTR_TENDER_SUM_NDS").value = 0
        Else 
        on error resume next
        attr("ATTR_TENDER_SUM_NDS").value = Round(Val,2)
         on error goto 0
        Delta = DataArray(i,10) - DataArray(i,8)
        If Delta = 0 then NewRow.attributes("ATTR_NDS_VALUE").value = Clf0
         If Delta <> 0 then
         Delta = 100*Delta/DataArray(i,10)
         If (17 < Abs(Delta) < 19) Then NewRow.attributes("ATTR_NDS_VALUE").value = Clf18
         If (11 > Abs(Delta) > 9) Then  NewRow.attributes("ATTR_NDS_VALUE").value = Clf10
         End if
        End if 
'        msgbox NewRow.attributes("ATTR_NDS_VALUE").value
      ElseIf attr(k).AttributeDefName = "ATTR_TENDER_NDS_PRICE" Then
      Val = DataArray(i,10)
      attr("ATTR_TENDER_NDS_PRICE").value = Round(Val,2)  
      End if   
     Next
  Next
 
  set DataArray = Nothing
  TableSyncFill = True 
End Function

'Функция поиска корреспондента по имени
Function FndCor(Nam)
   Nam = "'" & RTrim(Nam) & "'"
'   msgbox Nam
      AttrName = "ATTR_CORDENT_NAME"
      Tipe = "OBJECT_CORRESPONDENT"
 Set q = ThisApplication.CreateQuery
            q.Permissions = sysadminpermissions
            q.AddCondition tdmQueryConditionObjectDef, "'OBJECT_CORRESPONDENT'"
            q.AddCondition tdmQueryConditionAttribute,  Nam, "ATTR_CORDENT_NAME"
            If q.Objects.Count = 1 Then
            'Отсеиваем с потерянным атрибутом
            For i = 0 to q.Objects.Count - 1 
            If q.Objects(i).attributes.Has(AttrName) then
            set o=q.Objects(i).attributes(AttrName)
             If Not o Is Nothing Then FndCor = q.Objects(i).GUID
            End If
            Next 
           End If    
'        'Находим с ИНН, если есть выбор
           If q.Objects.Count > 1 Then 
            For i = 0 to q.Objects.Count - 1 
            If q.Objects(i).attributes.Has(AttrName) then
            set o=q.Objects(i).attributes(AttrName)
             If Not o Is Nothing Then 
              If q.Objects(i).attributes.Has("ATTR_S_JPERSON_TIN") then
               If not q.Objects(i).attributes("ATTR_S_JPERSON_TIN").empty = true then
               FndCor = q.Objects(i).GUID
               End If
              End If 
             End If
            End If
            Next  
           End If               
End Function
