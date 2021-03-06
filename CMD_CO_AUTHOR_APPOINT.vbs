' $Workfile: COMMAND.SCRIPT.CMD_CO_AUTHOR_APPOINT.scr $ 
' $Date: 10.10.08 15:57 $ 
' $Revision: 3 $ 
' $Author: Oreshkin $ 
'
' Назначить соавтора
'------------------------------------------------------------------------------
' Авторское право © ЗАО «НАНОСОФТ», 2008 г.


Dim o
Set o = ThisObject
Call Main(o)

Sub Main(o_)
  Dim u
  ' Выбор пользователя
  Set u = ThisApplication.ExecuteScript("CMD_DIALOGS","SelectUsersDlg")
  If u Is Nothing Then Exit Sub
  ' Назначение на роль
  Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",o_,"ROLE_CO_AUTHOR",u.SysName)
  
  ' Оповещение
  Call SendMessage(o_,u)
  Call SendOrder(o_,u)
End Sub


'==============================================================================
' Отправка информационного поручения о назначении соразработчиком 
' ответственному за подготовку задания 
'------------------------------------------------------------------------------
' o_:TDMSObject - разработанное задание
'==============================================================================
Private Sub SendMessage(o_,u_)
  For Each r In o_.RolesForUser(u_)
    If r.RoleDefName = "ROLE_CO_AUTHOR" Then
      ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1539, u_, o_, Nothing, o_.ObjectDef.Description, o_.Description, ThisApplication.CurrentUser.Description, ThisApplication.CurrentTime
      Exit For
    End If
  Next
End Sub

'==============================================================================
' Отправка информационное поручение о назначении соразработчиком 
'------------------------------------------------------------------------------
' Obj:TDMSObject - документ
' u:TDMSUser - пользователь, назначенный соразработчиком
'==============================================================================
Private Sub SendOrder(Obj,u)
  Set uToUser = u
  Set uFromUser = ThisApplication.CurrentUser
  resol = "NODE_CORR_REZOL_INF"
  txt = "Вас назначили соразработчиком на """ & Obj.Description & """. Назначил: " & uFromUser.Description
  planDate = ""
  ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,"OBJECT_KD_ORDER_NOTICE",uToUser,uFromUser,resol,txt,planDate
End Sub