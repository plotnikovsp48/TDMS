' Автор: Стромков С.А.
'
' Сборка тома
'------------------------------------------------------------------------------------------------------
' Авторское право © ЗАО «СиСофт», 2016

'Статус, устанавливаемый в результате выполнения команды

USE "CMD_S_DLL"
USE "CMD_DLL_ROLES"


Call Main(ThisObject)

Sub Main(o_)
  '  Проверяем выполнение входных условий
  Dim result
  result=Not StartCondCheck (o_)
  If result Then Exit Sub
  
  ' Подтверждение
  result = ThisApplication.ExecuteScript ("CMD_MESSAGE", "ShowWarning", vbYesNo, 1185, o_.Description)
  If result <> vbYes Then
    Exit Sub
  End If 
  Call RunMain (o_)
  Call Run (o_)
End Sub

Sub RunMain (Obj)
  Obj.Permissions = SysAdminPermissions
  Dim NextStatus
  NextStatus ="STATUS_VOLUME_IS_BUNDLING"
  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,"STATUS_VOLUME_CREATED",Obj,NextStatus)  
  If RetVal = -1 Then
    Obj.Status = ThisApplication.Statuses(NextStatus)
  End If
End Sub

Sub Run (Obj)
 
'  ' Изменение статуса прилагаемых документов  
'  For Each oDoc In Obj.Objects.ObjectsByDef("OBJECT_DOCUMENT")
    'If oDoc.StatusName = "STATUS_DOC_IS_ADDED" Then
  '    Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",oDoc,"STATUS_DOC_IS_ADDED",oDoc,"STATUS_DOC_IS_FIXED") 
    'End If
'  Next
  For Each oDoc In Obj.Objects.ObjectsByDef("OBJECT_DRAWING")
    If oDoc.StatusName = "STATUS_DOC_IS_ADDED" Then
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",oDoc,"STATUS_DOC_IS_ADDED",oDoc,"STATUS_DOCUMENT_CREATED") 
    End If
  Next
  For Each oDoc In Obj.Objects.ObjectsByDef("OBJECT_DOC_DEV")
    If oDoc.StatusName = "STATUS_DOC_IS_ADDED" Then
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",oDoc,"STATUS_DOC_IS_ADDED",oDoc,"STATUS_DOCUMENT_CREATED") 
    End If
  Next
 
  'Call SetAttr(Obj,"ATTR_RESPONSIBLE",ThisApplication.CurrentUser)
  
  ' Устанавливаем роли
  Call UpdateAttrRole(Obj,"ATTR_RESPONSIBLE","ROLE_VOLUME_COMPOSER")
  Call UpdateAttrRole(Obj,"ATTR_RESPONSIBLE","ROLE_VOLUME_COMPLETED")
  
  ' Отправка сообщений ответственным проектировщикам раздела\подраздела
  Call SendMessage(Obj)
End Sub

'==============================================================================
' Отправка оповещения Ответственным проектировщикам Разделов\Подразделов
'------------------------------------------------------------------------------
' o_:TDMSObject - Том
'==============================================================================
Private Sub SendMessage(o_)
  Dim u
  For Each uObj In o_.Uplinks
    If uObj.ObjectDefName = "OBJECT_PROJECT_SECTION" Or uObj.ObjectDefName = "OBJECT_PROJECT_SECTION_SUBSECTION" Then
      For Each r In uObj.RolesByDef("ROLE_LEAD_DEVELOPER")
        If Not r.User Is Nothing Then
          Set u = r.User
        End If
        If Not r.Group Is Nothing Then
          Set u = r.Group
        End If
        If Not IsTheSameObj(u,ThisApplication.CurrentUser) Then
          ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1507, u, o_, Nothing, o_.Description, o_.Attributes("ATTR_RESPONSIBLE").User.Description, ThisApplication.CurrentTime
        End If
      Next
    End If
  Next
End Sub


'==============================================================================
' Проверка входных условий
'------------------------------------------------------------------------------
' o_:TDMSObject - Том
' StartCondCheck: Boolean   True - входные условия выполнены
'                           False - входные условия не выполнены
'==============================================================================
Private Function StartCondCheck(o_)
  StartCondCheck = False
  
  Set cu = ThisApplication.CurrentUser
  Set uResp = o_.Attributes("ATTR_RESPONSIBLE").User

  If uResp Is Nothing Then Exit Function
  Set p = o_.Parent
  If uResp.Handle <> cu.Handle And (Not o_.RolesForUser(cu).Has("ROLE_VOLUME_COMPOSER")) Then 
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1182, o_.Description, p.ObjectDef.Description, p.Status.Description
    Exit Function
  End If
  

'  If p Is Nothing Then Exit Function
  ' Проверяем состояние родительского раздела/подраздела
  ' Если раздел завершен, то переходим к сборке
'  If p.Status.Sysname = "STATUS_PROJECT_SECTION_FIXED" Or p.Status.Sysname = "STATUS_PROJECT_SECTION_IS_APPROVED" Then
'    StartCondCheck = True
'  Else
'    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1182, o_.Description, p.ObjectDef.Description, p.Status.Description
'  End If
  StartCondCheck = True
End Function
