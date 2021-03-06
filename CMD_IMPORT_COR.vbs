' Команда загрузки контрагентов из выгрузки 1С (текстовый файл с разделителем табуляция)
'------------------------------------------------------------------------------
' Автор А.В.Орешкин

CONST WLOG = 1

dim ObjRoots
' получаем корневой каталог
set ObjRoots = thisApplication.GetObjectByGUID("{A60FEBB1-E4EF-4DC0-A8B6-32D720FEFBF2}") ' Корреспонденты
if ObjRoots is nothing then 
  msgbox "Не удалось найти папку Корреспонденты!"
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
  
  ' создаем контрагентов
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
' Функция создает Корреспорндентов и контактных лиц на основе передаваемой строки
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
  Next
End sub

'==============================================================================
' Функция создает Корреспорндента на основе массива данных
'------------------------------------------------------------------------------
' arr_:Array - масив данных для создания контрагента и контактного лица
' CreateCor:TDMSObject - Созданный контрагент
'==============================================================================  
Function CreateCor(arr_) 
   dim j, ccount, objType, CreateDocObject, a, opfarr 
   Set CreateCor = Nothing
   ccount = UBound(arr_)
   If ccount<6 Then Exit Function
   
        arr_(0)=Replace(arr_(0), Chr(10) , "" )
        opfarr = Split(arr_(0),",")
         
'msgbox opfarr(0)
   
   If Not CheckINN(arr_(6), opfarr(0)) Then Exit Function
   
   
   WriteLog "--------------КОНТРАГЕНТ = "&arr_(0)
    
  ObjRoots.Permissions = SysAdminPermissions
  set objType = thisApplication.ObjectDefs("OBJECT_CORRESPONDENT")
  Set orgObj = ObjRoots.Objects.Create(objType)
  
  
  For j=0 to ccount-1
    Select Case j
      Case 0 ' Наименование
        ' Отделяем ОПФ
        arr_(0)=Replace(arr_(0), Chr(10) , "" )
        opfarr = Split(arr_(0),",")
        Set a = SetAttr(orgObj, "ATTR_CORDENT_NAME", "Строка", opfarr(0))
        If UBound(opfarr)>0 Then 
          Set a = SetAttr(orgObj, "ATTR_S_JPERSON_ORG_TYPE", "Классификатор", opfarr(1))          
        end if
      Case 1 ' НаименованиеПолное
      Case 2 ' ДополнительноеОписание
      Case 3 ' ГоловнойКонтрагент
      Case 4 ' ИсточникИнформацииПриОбращении
      Case 5 ' КодПоОКПО
        Set a = SetAttr(orgObj, "ATTR_OKPO", "Строка", arr_(5))
        ' Set a = SetAttr(orgObj, "", "Строка", arr_())
      Case 6 ' ИНН
        Set a = SetAttr(orgObj, "ATTR_S_JPERSON_TIN", "Строка", arr_(6))
      Case 7 ' КПП
        Set a = SetAttr(orgObj, "ATTR_S_JPERSON_TRRC", "Строка", arr_(7))
      Case 8 ' ЮрФизЛицо
      Case 9 ' ОсновнойВидДеятельности
      Case 10 ' ДокументУдостоверяющийЛичность
      Case 11 ' Покупатель
      Case 12 ' Поставщик
      Case 13 ' РасписаниеРаботыСтрокой
      Case 14 ' СрокВыполненияЗаказаПоставщиком

      Case 18 ' НеЯвляетсяРезидентом
      Case 19 ' ОКОПФ
      Case 20 ' Регион
      Case 21 ' ГруппаДоступаКонтрагента
      Case 22 ' ОбособленноеПодразделение
      Case 23 ' ТелефонКонтрагента
        Set a = SetAttr(orgObj, "ATTR_CORDENT_TELEPHONE", "Строка", arr_(23))      
      Case 24 ' ФаксКонтрагента
        Set a = SetAttr(orgObj, "ATTR_CORDENT_FAX", "Строка", arr_(24))      
      Case 25 ' АдресЭлектроннойПочты
        Set a = SetAttr(orgObj, "ATTR_CORDENT_EMAIL", "Строка", arr_(25))      
      Case 26 ' АдресДоставки
      Case 27 ' ФактическийАдресКонтрагента
        Set a = SetAttr(orgObj, "ATTR_CORDENT_ADDRES", "Строка", arr_(27))      
      Case 28 ' ЮридическийАдресКонтрагента
'        Set a = SetAttr(orgObj, "ATTR_S_JPERSON_ADDRESS_ACTUAL", "Строка", arr_(28))      
      Case 29 ' ПочтовыйАдресКонтрагента
    End Select
   Next
  
  ' Наличие контактного лица
  If arr_(15)="" Then Exit Function
  set objType = thisApplication.ObjectDefs("OBJECT_CORR_ADDRESS_PERCON")
  Set persObj = orgObj.Objects.Create(objType)  
  
  WriteLog "------СОТРУДНИК = "&arr_(15)
  
'  Set persObj.Attributes("ATTR_COR_USER_CORDENT") = orgObj
  orgObj.Attributes("ATTR_CORDENT_USER").Object = persObj
   
  For j=15 to ccount-1
    Select Case j
      Case 15 ' ОсновноеКонтактноеЛицо
        arrpers = Split(arr_(15)," ")
        Set a = SetAttr(persObj, "ATTR_CORR_ADD_FIO", "Строка", arrpers(0))
        If UBound(arrpers)>1 Then 
          Set a = SetAttr(persObj, "ATTR_COR_USER_NAME", "Строка", arrpers(1)&" "&arrpers(2))
          Set a = SetAttr(persObj, "ATTR_COR_USER_SHORT", "Строка", Left(arrpers(1),1)&". "& Left(arrpers(2),1)&".")
          ' Дательный падеж Фамилия
          Set a = SetAttr(persObj, "ATTR_COR_USERNAME_DP", "Строка", LNameConvert(arrpers(0)))

        End If
      Case 16 ' ОсновноеКонтактноеЛицоДолжность
      Case 17 ' ОсновноеКонтактноеЛицоРольКонтактногоЛица
    End Select
   Next
   
   Set CreateCor = orgObj
End Function

'==============================================================================
' Функция проверки дубликата контрагента по ИНН
'------------------------------------------------------------------------------
' inn_:String - ИНН
' CheckINN:boolean - True - нет дубликата
'==============================================================================  
Function CheckINN(inn_, orgName)
  dim q, count
  CheckINN = False
  If inn_ <> "" Then 
      ' WriteLog("нет ИНН")
      ' Exit Function
  
    Set q = ThisApplication.Queries("QUERY_FIND_COR_INN")
    q.Parameter("INN") = inn_
    count = q.Objects.Count
    If count > 0 Then 
      if orgName= q.Objects(0).Description then
          WriteLog("дубликат ИНН и по наименованию ")
         ' msgbox 
        Exit Function
      End If
    End If
  End If
  CheckINN = True  
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
        Set cls = ThisApplication.Classifiers.Find(val_)
        o_.Attributes(sysid_).Classifier=cls
    End Select 
    WriteLog a.description&" = "&a
    Set SetAttr = a
End Function



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
