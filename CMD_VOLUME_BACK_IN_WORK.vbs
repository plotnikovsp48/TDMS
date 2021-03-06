' $Workfile: COMMAND.SCRIPT.CMD_VOLUME_BACK_IN_WORK.scr $ 
' $Date: 10.10.08 15:57 $ 
' $Revision: 3 $ 
' $Author: Oreshkin $ 
'
' Вернуть том на комплектацию
'------------------------------------------------------------------------------
' Авторское право © ЗАО «НАНОСОФТ», 2008 г.

Call Main(ThisObject)

Sub Main(o_)
    'Запрос причины
    result = ThisApplication.ExecuteScript("CMD_KD_COMMON_LIB","GetComment","Укажите причину возврата тома:")
    If IsEmpty(result) Then
      Exit Sub 
    ElseIf trim(result) = "" Then
      msgbox "Невозможно вернуть том не указав причину." & vbNewLine & _
          "Пожалуйста, введите причину возврата.", vbCritical, "Не задана причина возврата!"
      Exit Sub
    End If                              
  ' Создание рабочей версии
  o_.Versions.Create ,result

  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o_,o_.Status,o_,"STATUS_VOLUME_IS_BUNDLING")   
  ' Изменение статуса прилагаемых документов  
  For Each oDoc In o_.Objects.ObjectsByDef("OBJECT_DOCUMENT")
    Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",oDoc,"STATUS_DOC_IS_FIXED",oDoc,"STATUS_DOC_IS_ADDED") 
  Next
  
  ' Отправка уведомления
  Call SendMessage (o_, result)
End Sub


'==============================================================================
' Отправка оповещения ответственному о возврате тома нормоконтролером
'------------------------------------------------------------------------------
' o_:TDMSObject - завизированный комплект
' str_:Коментарий версии Тома
'==============================================================================
Private Sub SendMessage(o_,str_)
  Dim u
  For Each r In o_.RolesByDef("ROLE_VOLUME_COMPOSER")
    If Not r.User Is Nothing Then
      Set u = r.User
    End If
    If Not r.Group Is Nothing Then
      Set u = r.Group
    End If
    ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1510, u, o_, Nothing, o_.Description, ThisApplication.CurrentUser.Description, str_
  Next
End Sub
