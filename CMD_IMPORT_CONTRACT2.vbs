' Команда загрузки контрагентов из выгрузки 1С (текстовый файл с разделителем табуляция)
'------------------------------------------------------------------------------
' Автор А.В.Орешкин

use CMD_S_NUMBERING

CONST WLOG = 1

dim ObjRoots
' получаем корневой каталог
Set ObjRoots = thisApplication.GetObjectByGUID("{519D5F9D-D680-4642-BAEE-573455D6778E}") ' Договоры
if ObjRoots is nothing then 
  msgbox "Не удалось найти папку Договоры!"
else
  Call main()
end if  
    



Sub main()
  Dim FName, app, wb, res
  Dim dic
  
  ' получаем файл
  FName = GetFile("Разделитель табуляция (*.txt)|*.txt||")
  If FName = "" Then Exit Sub
  
  ' читаем содержимое файла
  str = ReadAllFile(FName)
  
  ' создаем Договор
  Call CheckAndCopyData(str)

End Sub


'==============================================================================
' Функция возвращает имя файла с учетом фильтра
'------------------------------------------------------------------------------
' filter:String - фильтр
' GetFile:String - имя файла
'==============================================================================
Function GetFile(filter)
  
  Dim SelFileDlg, FName, RetVal
  
  GetFile = ""
  
  ' Открыть диалог выбора файла
  Set SelFileDlg = ThisApplication.Dialogs.FileDlg
  SelFileDlg.Filter = filter
  RetVal = SelFileDlg.Show
  
  'Если пользователь отменил диалог, выйти из подпрограммы
  If RetVal <> TRUE Then Exit Function    
  
  'Возвращаем имя первого выбранного файла
  arr = SelFileDlg.FileNames
  GetFile = arr(0)
End Function


'==============================================================================
' Функция возвращает содержимое файла в виде строки
'------------------------------------------------------------------------------
' FName_:String - полный путь к файлу
' ReadAllFile:String - строка = содержанию текстового файла
'==============================================================================
Function ReadAllFile(FName_)
  Dim fso
  ReadAllFile = ""
  Const ForReading = 1
  Set fso = CreateObject("Scripting.FileSystemObject")
  ' Прочитать содержимое файла
  Set ts = fso.OpenTextFile(FName_, ForReading)
  ReadAllFile = ts.ReadAll
  ts.Close
End Function


'==============================================================================
' Функция создает Договоры на основе передаваемой строки
'------------------------------------------------------------------------------
' str_:String - строка данных = содержанию текстового файла
'==============================================================================  
sub CheckAndCopyData(str_)
  Dim arr, carr,i ,count
  arr = Split(str_,chr(13))  
  count = UBound(arr)
  For i=1 to count-1
    carr = Split(arr(i),chr(9))
    Set ocor = CreateCor(carr)      ' проверить
    
    ' Добавляем роли
    If not ocor is nothing Then 
      ocor.SaveChanges 16384
      Call SetRoles(ocor)
      Call SetIcon(ocor)
    End If
  Next
End sub

'==============================================================================
' Функция создает Договоры на основе массива данных
'------------------------------------------------------------------------------
' arr_:Array - масив данных для создания договоров
' CreateCor:TDMSObject - Созданный договор
'==============================================================================  
Function CreateCor(arr_) 
   dim j, ccount, objType, CreateDocObject, a, opfarr, s 
   Set CreateCor = Nothing
   ccount = UBound(arr_)
   If ccount<24 Then Exit Function   
   
   
    
  ObjRoots.Permissions = SysAdminPermissions
  set objType = thisApplication.ObjectDefs("OBJECT_CONTRACT")
  Set OContract = ObjRoots.Objects.Create(objType)
  
'  WriteLog "--------------ДОГОВОР ="&arr_(1) &  "=" & arr_(24) &  "=" & OContract.GUID
  WriteLog arr_(1) &  chr(9) & arr_(24) &  chr(9) & OContract.GUID  &  "    1cGUID " &arr_(29) 
  
  val = GetContractDescription(OContract)
 ' If thisApplication.ObjectDefs("OBJECT_CONTRACT").Objects.has(val) then 
  '  ObjRoots.Erase
 '   exit Function
'  end if
  
  For j=0 to ccount
    Select Case j
      Case 0 ' ДатаДоговора
      arr_(0)=Replace(arr_(0), Chr(10) , "" )
        If  arr_(0)<>"" Then
          '  WriteLog "Дата!" & arr_(0) & "Дата!"
            Set a = SetAttr(OContract, "ATTR_DATA", "Строка", arr_(0))
        End If
      Case 1 'НомерДоговора
        Set a = SetAttr(OContract, "ATTR_REG_NUMBER", "Строка", arr_(1))
      Case 2 'НаименованиеДоговора
        Set a = SetAttr(OContract, "ATTR_CONTRACT_SUBJECT", "Строка", arr_(2))
      Case 3 'ИННЗаказчика
        inn = arr_(3)
        If inn = "2466091092" Then        
          cclass = "NODE_CONTRACT_EXP" ' расходный
        Else
          cclass = "NODE_CONTRACT_PRO" ' доходный
        End If
        Set a = SetAttr(OContract, "ATTR_CONTRACT_CLASS", "Классификатор", cclass)
        Set a = SetAttr(OContract, "ATTR_CUSTOMER", "Контрагент", inn)
      Case 4 'ИННИсполнителя
        Set a = SetAttr(OContract, "ATTR_CONTRACTOR", "Контрагент", arr_(4))
      Case 5 'НаименованиеЗаказчика       ??
      Case 6 'НаименованиеИсполнителя       ??
      Case 7 'КонтактноеЛицоКонтрагента
        Set a = SetAttr(OContract, "ATTR_CONTACT_PERSON_STR", "Строка", arr_(7))
      Case 8 'ДолжностьКонтактногоЛицаКонтрагента
      Case 9 'КураторДоговора
        Set a = SetAttr(OContract, "ATTR_CURATOR", "Пользователь", arr_(9))
        
      Case 10 'ДатаНачалаРаботПоПлану
        If  arr_(10)<>"" Then
          Set a = SetAttr(OContract, "ATTR_STARTDATE_PLAN", "Строка", arr_(10))
        End If
      Case 11 'ДатаОкончанияРаботПоПлану
        If  arr_(11)<>"" Then
          Set a = SetAttr(OContract, "ATTR_ENDDATE_PLAN", "Строка", arr_(11))
        End If
      Case 12 'ОжидаемаяДатаОкончанияРабот
        If  arr_(12)<>"" Then
          Set a = SetAttr(OContract, "ATTR_ENDDATE_ESTIMATED", "Строка", arr_(12))
        End If    
      Case 13 'СтоимостьРабот
        Set a = SetAttr(OContract, "ATTR_CONTRACT_VALUE", "Строка", arr_(13)) 
      Case 14 'ОсновнойДоговор
      Case 15 'ПроцентШтрафныхСанкцийВДень
        Set a = SetAttr(OContract, "ATTR_CONTRACT_PENALTY_PERCENT_PER_DAY", "Строка", arr_(15))
      Case 16 'СрокОплаты
        Set a = SetAttr(OContract, "ATTR_DUE_DATE", "Строка", arr_(16))
        Set a = SetAttr(OContract, "ATTR_DAY_TYPE", "Классификатор", "NODE_9F4137F2_E2B3_4CA1_B4BE_3F6F32A77017")
      Case 17 'КлассДоговора        ?? доходный расходный!!
      Case 18 'ОснованиеЗакупкиУЕП
        Set a = SetAttr(OContract, "ATTR_PURCHASE_BASIS", "Строка", arr_(18)) 
      Case 19 'СрокИсполненияДоговораПлан
        Set a = SetAttr(OContract, "ATTR_FULFILLDATE_PLAN", "Строка", arr_(19)) 
      Case 20 'ДатаПубликацииВЕИС 
        Set a = SetAttr(OContract, "ATTR_EIS_PUBLISH", "Строка", arr_(20))
    Case 21 'РеестровыйНомерВЕИС 
    Case 22 'Примечание 
        Set a = SetAttr(OContract, "ATTR_INF", "Строка", arr_(22))
    Case 23 '  КодПоОКПД2
' ATTR_TENDER_OKPD2
        
      Case 24 'ТипДоговора
        Set a = SetAttr(OContract, "ATTR_CONTRACT_TYPE", "Классификатор", arr_(24))
        
      Case 25 'ВалютаЗакупки
        Set a = SetAttr(OContract, "ATTR_TENDER_CURRENCY", "Классификатор", "RUB") 
     
      Case 26  'СтоимостьСНДС
         Set a = SetAttr(OContract, "ATTR_PRICE_W_VAT", "Строка", arr_(26))
         
      Case 27  'ДоговорДокументОснованиеИсполнения

      Case 28 'Статус
        on error resume next
        Set s = ThisApplication.Statuses(arr_(28))
        OContract.StatusName = s.sysname
'        WriteLog "Статус ="&OContract.StatusName
        on error goto 0
      Case 29 '

    End Select
    
   Next
       
   Set a = SetAttr(OContract, "ATTR_AUTOR", "Пользователь", "SYSADMIN")
   Set a = SetAttr(OContract, "ATTR_SIGNER", "Пользователь", "Теликова Раиса Сергеевна") 
   
   Set a = SetAttr(OContract, "ATTR_DESCRIPTION", "Строка", val) 
   OContract.Description = val
   
   Set CreateCor = OContract
End Function


'==============================================================================
' Метод записи лога
'------------------------------------------------------------------------------
' str:String - строка, которая пишется в лог
'==============================================================================  
Sub WriteLog(str)
  If WLOG = 0 Then Exit Sub
  ThisApplication.AddNotify str
End Sub


'==============================================================================
' Функция заполнения атрибутов информационного объекта
'------------------------------------------------------------------------------
' o_:TDMSObject - текущий объект
' sysid_:String - Заполняемый атрибут(системное имя)
' type_:String - тип атрибута
' val_:String - Значение атрибута
' SetAttr:TDMSAttribute - Ссылка на атрибут
'==============================================================================  
Function SetAttr(o_, sysid_, type_, val_)
    val_ = trim(val_)
    Set a = o_.Attributes(sysid_)
    Select Case type_
      Case "Строка"
        o_.Attributes(sysid_)=val_
      Case "Классификатор"
        on error resume next
        Set cls = ThisApplication.Classifiers.Find(val_)
        o_.Attributes(sysid_).Classifier=cls
        on error goto 0
      Case "Контрагент"
        on error resume next
        Set q = ThisApplication.Queries("QUERY_INN_SEARCH")
        q.Parameter("PARAM0") = val_
        set os = q.Objects
        If os.Count>0 Then o_.Attributes(sysid_) = os(0)
        on error goto 0
      Case "Пользователь"
        on error resume next
        Set u = Nothing
        Set u = ThisApplication.Users.Item(val_)
        o_.Attributes(sysid_) = u
        on error goto 0
    End Select 
'    WriteLog a.description&" ="&a
    Set SetAttr = a
End Function

'==============================================================================
' Функция устанавливает роли на информационный объект
'------------------------------------------------------------------------------
' o_:TDMSObject - текущий объект
'==============================================================================  
Private Sub SetRoles(o_)
  ThisScript.SysAdminModeOn
  Set CU = ThisApplication.CurrentUser
  Set uCur = ThisApplication.CurrentUser
  Set a1 = o_.attributes("ATTR_AUTOR")
  if a1 <> "" Then Set CU = o_.attributes("ATTR_AUTOR").User 
  Set a2 = o_.attributes("ATTR_CURATOR")
  if a2 <> "" Then Set uCur = o_.attributes("ATTR_CURATOR").User 
  
  
  Call ThisApplication.ExecuteScript("CMD_DLL","DelDefRole",o_,"ROLE_CONTRACT_AUTOR")
  Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",o_,"ROLE_CONTRACT_AUTOR",CU)
  
  Call ThisApplication.ExecuteScript("CMD_DLL","DelDefRole",o_,"ROLE_CONTRACT_RESPONSIBLE_DRAFT")
  Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",o_,"ROLE_CONTRACT_RESPONSIBLE_DRAFT",CU)
  
  If Not uCur Is Nothing Then
    Call ThisApplication.ExecuteScript("CMD_DLL", "DelDefRole",o_,"ROLE_CONTRACT_RESPONSIBLE")
    Call ThisApplication.ExecuteScript("CMD_DLL", "SetRole",o_,"ROLE_CONTRACT_RESPONSIBLE",uCur)
  End If
End Sub



' Устанавливаем иконки
'=================================
Sub SetIcon(Obj)
  Obj.Permissions = SysAdminPermissions ' задаем права 
'  If Obj.Status Is Nothing Then Exit Sub
  status = Obj.StatusName
  stArr =  Split(status,"_") 
  ind = Ubound(stArr)
  if ind < 0 then exit sub
   
  objDef = obj.ObjectDefName
  imgName = "IMG_" & objDef
  Select Case objDef
    Case "OBJECT_CONTRACT"
      Set cClassCls = Obj.Attributes("ATTR_CONTRACT_CLASS").Classifier
      If Not cClassCls Is Nothing Then
        cClass = Obj.Attributes("ATTR_CONTRACT_CLASS").Classifier.SysName
        clArr = Split(cClass,"_") 
        clInd = Ubound(clArr)
        if clInd > 0 then
          imgName = imgName & "_" & clArr(clInd)
        End If
      End If
      If status = "STATUS_CONTRACT_CLOSED" Then
        If Obj.Attributes("ATTR_CONTRACT_CLOSE_TYPE").Empty = False Then
          cClose = Obj.Attributes("ATTR_CONTRACT_CLOSE_TYPE").Classifier.SysName
          ctArr = Split(cClose,"_") 
          ctInd = Ubound(ctArr)
          if ctInd > 0 then
            imgName = imgName & "_" & ctArr(ctInd)
          End If
        End If
      End If
    Case "OBJECT_AGREEMENT"
    Case "OBJECT_CONTRACT_COMPL_REPORT"
   
  End Select
  imgName = imgName & "_" & stArr(ind)
  'thisApplication.AddNotify imgName  
  if ThisApplication.Icons.Has(imgName) then
    if not imgName = Obj.Icon.SysName then
      Obj.Icon = ThisApplication.Icons(imgName)
    end if
  else ' EV если не нашли ставим от объекта
'    if not obj.ObjectDef.Icon.SysName = Obj.Icon.SysName then
'      Obj.Icon = obj.ObjectDef.Icon
'    end if
'     
  end if
end sub



'==============================================================================
' Функция преобразования Фамилии в дательный падеж
'------------------------------------------------------------------------------
' lname_:String - Фамилия
' LNameConvert:String - Фамилия в дательном падеже
'==============================================================================  
Function LNameConvert(lname_)
  
  Dim AFIO  'измененное ФИО
  Dim Name, LastName, Patronymic 'Имя, фамилия и отчество
  Dim AName, ALastName, APatronymic 'Измененные имя, фамилия и отчество
  Dim echar 'Здесь будет последний символ
  
   SLetters = "цкнгшщзхфвпрлджчсмтб"
  
   LastName = lname_
  
   '{Анализируем фамилию}
   ALastName = LastName
   echar = Right(LastName, 1)
  
   if echar = "й" then
    ALastName = Left(LastName,len(LastName)-2)
    ALastName = ALastName + "ому"
   End If
   
   If Instr(SLetters,echar)>0 Then
    ALastName = ALastName + "у"
   End If
 
   LNameConvert = ALastName
end function

'==============================================================================
' Функция преобразования Имени в дательный падеж
'------------------------------------------------------------------------------
' name_:String - Имя
' NameConvert:String - Имя в дательном падеже
'==============================================================================  
Function NameConvert(name_)
  
  Dim AFIO  'измененное ФИО
  Dim Name, LastName, Patronymic 'Имя, фамилия и отчество
  Dim AName, ALastName, APatronymic 'Измененные имя, фамилия и отчество
  Dim echar 'Здесь будет последний символ
  
   SLetters = "цкнгшщзхфвпрлджчсмтб"
  
   Name = name_
  
   '{Анализируем имя}
   echar = Right(Name, 1)
   AName = Name
   
   if echar = "й" then
    AName = Left(AName,len(AName)-1)
    AName = AName + "ю"  
   end If
  
   If Instr(SLetters,echar)>0 Then
    AName = AName + "у"
   End If
  
   if echar = "а" then
    AName = Left(AName,len(AName)-1)
    AName = AName + "е"
   End If
   
    
   if echar = "я" then
    AName = Left(AName,len(AName)-1)
    AName = AName + "и" 
   end if
 
   NameConvert = AName
end function


'==============================================================================
' Функция преобразования Отчества в дательный падеж
'------------------------------------------------------------------------------
' patronymic_:String - ИОтчество
' PatronymicConvert:String - ИОтчество в дательном падеже
'==============================================================================  
Function PatronymicConvert(patronymic_)
  
  Dim AFIO  'измененное ФИО
  Dim Name, LastName, Patronymic 'Имя, фамилия и отчество
  Dim AName, ALastName, APatronymic 'Измененные имя, фамилия и отчество
  Dim echar 'Здесь будет последний символ
  
   SLetters = "цкнгшщзхфвпрлджчсмтб"
  
   Patronymic = Patronymic_
  
   '{Анализируем отчество}
   echar = Right(Patronymic, 1)
   APatronymic = Patronymic
   
   If Instr(SLetters,echar)>0 Then
    APatronymic = APatronymic + "у"
   end if
  
   PatronymicConvert = APatronymic
end function
