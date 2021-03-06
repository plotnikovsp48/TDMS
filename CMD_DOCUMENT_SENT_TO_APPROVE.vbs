' Автор: Стромков С.А.
'
' Библиотека функций стандартной версии
'------------------------------------------------------------------------------------------------------
' Авторское право © ЗАО «СиСофт», 2016

Call Main(ThisObject)

Public Function Main(Obj)
  Main = False
  Dim result
  'Статус, устанавливаемый в результате выполнения команды
  StatusName ="STATUS_DOCUMENT_IS_APPROVING"

  Obj.Permissions = SysAdminPermissions 
  ' Проверка наличия файла
  If Not CheckFiles(Obj) Then Exit Function
  
  ' Проверка заполнения обязательных полей
  List = "ATTR_DOCUMENT_CONF,ATTR_DOCUMENT_AN_TYPE,ATTR_DOCUMENT_NAME"
  res = ThisApplication.ExecuteScript("CMD_S_DLL","CheckRequedFields",Obj,List)
  
  If res <> "" Then
    Msgbox "Не заполнены обязательные атрибуты: " & chr(10) & res,vbExclamation,"Ошибка"
    Exit Function
  End If

  ' Подтверждение
  result = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning",vbQuestion+vbYesNo, 1214, Obj.Description)    
  If result = vbNo Then Exit Function
  
 
  ' Изменение статуса
  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
  If RetVal = -1 Then
    msgbox "Маршрут не найден. Обратитесь к администратору", vbCritical,"Ошибка маршрута"
    Exit Function
  End If
  
  ' Создаем роль Проверяющий
  Call ThisApplication.ExecuteScript("CMD_DLL_ROLES", "UpdateAttrRole",Obj,"ATTR_DOCUMENT_CONF","ROLE_CONFIRMATORY")
   
  ' Оповещение
  Call  SendOrder(Obj)
  Main = True
End Function

'==============================================================================
' Отправка поручение на проверку задания
' проверяющему 
'------------------------------------------------------------------------------
' Obj:TDMSObject - разработанное задание
'==============================================================================
Sub SendOrder(Obj)
  Set uToUser = Obj.Attributes("ATTR_DOCUMENT_CONF").User
  If uToUser Is Nothing Then Exit Sub
  Set uFromUser = ThisApplication.CurrentUser
  resol = "NODE_KD_APROVER"
  txt = "Документ """ & Obj.Description & """"
  planDate = DateAdd ("d", 1, Date) 'Date + 1
  ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,"OBJECT_KD_ORDER_SYS",uToUser,uFromUser,resol,txt,planDate
End Sub

'==============================================================================
' Проверка наличия файлов
'------------------------------------------------------------------------------
' Obj:TDMSObject - Документ
' CheckFiles:Boolean - Результат проверки
'==============================================================================
Private Function CheckFiles(Obj)
  CheckFiles = False
  ' Проверка наличия файла
  If Obj.Files.count<=0 Then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1117
    Exit Function
  End If  
  CheckFiles = True
End Function
