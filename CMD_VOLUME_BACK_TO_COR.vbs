' $Workfile: COMMAND.SCRIPT.CMD_VOLUME_BACK_TO_COR.scr $ 
' $Date: 10.10.08 15:57 $ 
' $Revision: 3 $ 
' $Author: Oreshkin $ 
'
' Вернуть том на доработку
'------------------------------------------------------------------------------
' Авторское право © ЗАО «НАНОСОФТ», 2008 г.

Call Main(ThisObject)

Sub Main(Obj)
   
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
  Obj.Versions.Create ,result                    
  Res = Run(Obj)
    ' Изменение статуса прилагаемых документов  
    For Each oDoc In Obj.Objects.ObjectsByDef("OBJECT_DOCUMENT")
      oDoc.Permissions = SysAdminPermissions
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",oDoc,"STATUS_DOC_IS_FIXED",oDoc,"STATUS_DOCUMENT_CREATED") ' было "STATUS_DOC_IS_ADDED"
    Next
    ' Изменение статуса прилагаемых документов  
    For Each oDoc In Obj.Objects.ObjectsByDef("OBJECT_DRAWING")
      oDoc.Permissions = SysAdminPermissions
      If oDoc.StatusName = "STATUS_DOC_IS_FIXED" Then
        Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",oDoc,"STATUS_DOC_IS_FIXED",oDoc,"STATUS_DOCUMENT_CREATED") ' было "STATUS_DOC_IS_ADDED"
      End If
      If oDoc.StatusName = "STATUS_DOCUMENT_IS_TAKEN_NK" Then
        Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",oDoc,"STATUS_DOCUMENT_IS_TAKEN_NK",oDoc,"STATUS_DOCUMENT_CREATED") ' было "STATUS_DOC_IS_ADDED"
      End If
    Next
    ' Изменение статуса прилагаемых документов  
    For Each oDoc In Obj.Objects.ObjectsByDef("OBJECT_DOC_DEV")
      oDoc.Permissions = SysAdminPermissions
      If oDoc.StatusName = "STATUS_DOC_IS_FIXED" Then
        Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",oDoc,"STATUS_DOC_IS_FIXED",oDoc,"STATUS_DOCUMENT_CREATED") ' было "STATUS_DOC_IS_ADDED"
      End If
      If oDoc.StatusName = "STATUS_DOCUMENT_IS_TAKEN_NK" Then
        Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",oDoc,"STATUS_DOCUMENT_IS_TAKEN_NK",oDoc,"STATUS_DOCUMENT_CREATED") ' было "STATUS_DOC_IS_ADDED"
      End If
    Next
    ' Отправка уведомления
    Call SendMessage (Obj)
    
  If Res Then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, 1506, Obj.ObjectDef.Description, _
                                    Obj.Description
  End If
End Sub

Function Run(Obj)
  Run = False
  Dim NextStatus
  NextStatus ="STATUS_VOLUME_IS_BUNDLING"
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,NextStatus)   
  Run = True  
End Function
'==============================================================================
' Отправка оповещения ответственному о возврате тома утверждающим
'------------------------------------------------------------------------------
' Obj:TDMSObject - завизированный комплект
' str_:Коментарий версии Тома
'==============================================================================
Private Sub SendMessage(Obj)
  Dim u
  For Each r In Obj.RolesByDef("ROLE_VOLUME_COMPOSER")
    If Not r.User Is Nothing Then
      Set u = r.User
    End If
    If Not r.Group Is Nothing Then
      Set u = r.Group
    End If
    ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1506, u, Obj, Nothing, _
    Obj.ObjectDef.Description, Obj.Description, ThisApplication.CurrentUser.Description, Obj.VersionDescription
  Next
End Sub
