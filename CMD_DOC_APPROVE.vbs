' Команда - Утвердить документ
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

USE "CMD_PROJECT_DOCS_LIBRARY"

Res = Run(ThisObject)

Function Run(Obj)
  Run = False
  Set CU = ThisApplication.CurrentUser
  
  'Проверка состояния
  If Obj.Status is Nothing Then Exit Function
  
  'Подтверждение
  result = Msgbox("Утвердить документ """&Obj.Description&"""?",vbQuestion+vbYesNo) 
  If result = vbNo Then Exit Function
  
  'Заполнение строки проверяющего
  Set Row = GetRowCheckList(Obj,"approve",CU,Nothing,Nothing)
  If not Row is Nothing Then
    Row.Attributes("ATTR_RESOLUTION").Classifier = ThisApplication.Classifiers.FindBySysId("NODE_ACCEPT")
    Row.Attributes("ATTR_DATA").Value = Date
  End If
  
  ' Закрываем поручение
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_KD_APROVER")
'  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrders",Obj,"NODE_KD_APROVER")
  
  'Поиск следующего утверждающего
  Set Row = GetRowCheckList(Obj,"approve",Nothing,CU,Nothing)
  Set User = Nothing
  If not Row is Nothing Then
    Set User = Row.Attributes("ATTR_USER").User
  End If
  
  'Если следующий утверждающий пользователь не найден, то меняем статус
  If User is Nothing Then
    'Изменение статуса
    StatusName = "STATUS_DOCUMENT_FIXED"
    RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
    If RetVal = -1 Then
      Obj.Status = ThisApplication.Statuses(StatusName)
    End If
    
    'Оповещение 
    Call SendOrder(Obj)
    Call SendMessage(Obj)
  Else
    Call ThisApplication.ExecuteScript("CMD_DOC_SENT_TO_APPROVE","SetApproveUser",Obj,User)
  End If
  
  Run = True
  Call ToApprove(Obj)
End Function

Sub ToApprove(Obj)
  ' проверяем, можно ли перевести комплект или том в состояние на утверждении
  Select Case Obj.Parent.ObjectDefName
    Case "OBJECT_VOLUME"
      Scr = "CMD_VOLUME_APPROVE"
      txt = "В составе тома больше нет неутвержденных документов. Утвердить том "
    Case "OBJECT_WORK_DOCS_SET"
      Scr = "CMD_VOLUME_APPROVE"
      txt = "В составе комплекта больше нет неутвержденных документов. Утвердить комплект "
  End Select
  If Scr = "" Then Exit Sub
  ' Если все документы утверждены - предлагаем утвердить комплект или Том
  RetVal = ThisApplication.ExecuteScript(Scr,"CheckStatusTransition",Obj.Parent)
  If RetVal = 0 Then
    ans = msgbox(txt & """" & Obj.Parent.Description & """?",vbQuestion+vbYesNo)
    If ans <> vbYes Then Exit Sub
    ' переводим комплект в утвержденное состояние
    Call ThisApplication.ExecuteScript(Scr,"Run",Obj.Parent)
  End If 
End Sub

'==============================================================================
' Отправка оповещения об утверждении документа всем разработчикам
' и соавторам
'------------------------------------------------------------------------------
' o_:TDMSObject - утвержденный документ
'==============================================================================
Private Sub SendMessage(o_)
  Dim u
  Set CU = ThisApplication.CurrentUser
  For Each r In o_.RolesByDef("ROLE_DOC_DEVELOPER")
    If Not r.User Is Nothing Then
      Set u = r.User
    End If
    If Not r.Group Is Nothing Then
      Set u = r.Group
    End If
    ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1009, u, o_, Nothing, o_.Description, CU.Description
  Next
End Sub

Sub SendOrder(Obj)
  Set uToUser = Obj.Attributes("ATTR_RESPONSIBLE").User
  If uToUser Is Nothing Then Exit Sub
  Set uFromUser = ThisApplication.CurrentUser
  resol = "NODE_CORR_REZOL_INF"
  txt = "Документ утвержден: """ & Obj.Description & """"
  ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,"OBJECT_KD_ORDER_NOTICE",uToUser,uFromUser,resol,txt,""
End Sub
