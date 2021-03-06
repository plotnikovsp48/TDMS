

' Команда загрузки контрагентов из выгрузки 1С (текстовый файл с разделителем табуляция)
'------------------------------------------------------------------------------
' Автор А.В.Орешкин

CONST WLOG = 1

dim ObjRoots
' получаем корневой каталог
msgbox "Не удалось найти папку Корреспонденты!"
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
   'If ccount<6 Then Exit Function
   
        arr_(0)=Replace(arr_(0), Chr(10) , "" )
        opfarr = Split(arr_(0),",")
         
'msgbox arr_(0)
   
 '  If Not CheckINN(arr_(6), opfarr(0)) Then Exit Function
   
   
    WriteLog "--------------КОНТРАГЕНТ = "&arr_(0)
    
  ObjRoots.Permissions = SysAdminPermissions
  set objType = thisApplication.ObjectDefs("OBJECT_CORRESPONDENT")
  Set orgObj = ObjRoots.Objects.Create(objType)
  
  
 
     ' Наименование
        ' Отделяем ОПФ
        arr_(0)=Replace(arr_(0), Chr(10) , "" )
       ' opfarr = Split(arr_(0),",")
        Set a = SetAttr(orgObj, "ATTR_CORDENT_NAME", "Строка", arr_(0))
        
       ' If UBound(opfarr)>0 Then 
          Set a = SetAttr(orgObj, "ATTR_S_JPERSON_ORG_TYPE", "Классификатор", "Военкомат")          
        'end if
 
  

 
   
   Set CreateCor = orgObj
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
