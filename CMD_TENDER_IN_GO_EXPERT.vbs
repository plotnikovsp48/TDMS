' Команда - На рассмотрение (Внутренняя закупка)
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

Call Main(ThisObject)

Sub Main(Obj)
  ThisScript.SysAdminModeOn
  Set CU = ThisApplication.CurrentUser
  frm = false
'  AttrName = "ATTR_TENDER_PROTOCOL"
  AttrName = "ATTR_TENDER_RES_CHECK_METOD"
   If Obj.Attributes.Has(AttrName) Then
    set Doc = Obj.Attributes(AttrName).Object
'   End If

'   AttrName = "ATTR_TENDER_PROTOCOL"
'   If Obj.Attributes.Has(AttrName) Then
    If Obj.Attributes(AttrName).Empty = True Then
    Msgbox "Не выбран документ Методика оценки",vbExclamation
'     Msgbox "Не выбран Протокол подведения итогов",vbExclamation
     exit sub
    end if
   end if

  If Obj.Attributes.Has("ATTR_TENDER_EXPERT_LIST") = False Then
    If Obj.ObjectDef.AttributeDefs.Has("ATTR_TENDER_EXPERT_LIST") Then
      Obj.Attributes.Create ThisApplication.AttributeDefs("ATTR_TENDER_EXPERT_LIST")
      Obj.Update
    End If
  End If
  
  If Obj.Attributes.Has("ATTR_TENDER_EXPERT_LIST") = False Then Exit Sub
  Set Table =  Obj.Attributes("ATTR_TENDER_EXPERT_LIST")
  If Not Table Is Nothing Then
    set rows = Table.Rows
  End If
    
  str = ""
  resol = "NODE_CORR_REZOL_POD"
'  ObjType = "OBJECT_KD_ORDER_REP"
 set ObjType = thisApplication.ObjectDefs(thisApplication.ObjectDefs("OBJECT_KD_ORDER_REP").Description)
  txt = "Прошу подготовить экспертное заключение по результатам проведенной закупки"
  AttrName = "ATTR_TENDER_CHECK_END_TIME"
  PlanDate = ""
  If Obj.Attributes.Has(AttrName) Then
    PlanDate = Obj.Attributes(AttrName)
  End If
  If PlanDate = "" Then PlanDate = Data1
  
  'Если поле Оценочная комиссия заполнено
  
  If Not rows Is Nothing Then
    for each row in rows 
      If not row.Attributes("ATTR_TENDER_EXPERT").Empty = True then  frm = true
    next
  End If
  
  If frm = true then  
    Answer = MsgBox("Передать закупку для рассмотрения результатов членами оценочной комиссии?", vbQuestion + vbYesNo,"")
    if Answer <> vbYes then exit sub    
    for each row in rows  
    'Выдача поручений
      If row.Attributes.Has("ATTR_TENDER_EXPERT") Then
        If row.Attributes("ATTR_TENDER_EXPERT").Empty = False Then
          set user = row.Attributes("ATTR_TENDER_EXPERT").user
          If Not user Is Nothing Then
            If user.SysName <> CU.SysName Then
              Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",Obj,"ROLE_VIEW",User)
'              Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",Doc,"ROLE_TENDER_DOCS_RESP_DEVELOPER",User)
              ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Doc,ObjType,User,CU,resol,txt,PlanDate
'             ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,ObjType,user,CU,resol,txt,PlanDate
              If str <> "" Then
                str =   str & " - " & user.Description & chr(10) 
              Else
                str = " - " & user.Description & chr(10) 
              End If
            End If
          End If
        End If
      End If
    Next
  End If

'Если поле Оценочная комиссия не заполнено    
  If frm = false then
   'Подтверждение
  Answer = MsgBox("Члены оценочной комиссии не выбраны. Выбрать членов комиссии?", vbQuestion + vbYesNo,"")
  if Answer <> vbYes then exit sub
 
  'Выбор пользователей
  Set Dlg = ThisApplication.Dialogs.SelectDlg
   GroupName = "GROUP_TENDER_EXPERT"
   If ThisApplication.Groups.Has(GroupName) Then
   Dlg.SelectFrom = ThisApplication.Groups(GroupName).Users
   else
   Dlg.SelectFrom = ThisApplication.Users
   End If
   
  Dlg.Prompt = "Выберите пользователей  - членов оценочной комиссии"
  Dlg.Caption = "Выбор пользователей"
  If Dlg.Show Then
    Set Users = Dlg.Objects
    If Users.Count = 0 Then
      Msgbox "Не выбрано ни одного пользователя",vbExclamation
      Exit Sub
    End If
  Else
    Exit Sub
  End If

  ThisApplication.Utility.WaitCursor = True
  
  
  
'  set doc = thisObject.Attributes("ATTR_KD_DOCBASE").object
'  set cType = thisApplication.ObjectDefs(thisApplication.ObjectDefs("OBJECT_KD_ORDER_REP").Description)
''  call CreateTypeOrder(parOrder, doc, cType) ' EV всегда создаем в корне
'  call CreateTypeOrder(nothing, doc, cType)
'  CreateTree(thisObject)
  
  
  
  
  'Выдача поручений и заполнение поля Оценочная комиссия

  If PlanDate = "" Then PlanDate = Data1
  i=0
   For Each User in Users
      If User.SysName <> CU.SysName Then
       Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",Obj,"ROLE_VIEW",User)
'       Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",Doc,"ROLE_TENDER_DOCS_RESP_DEVELOPER",User)
       ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Doc,ObjType,User,CU,resol,txt,PlanDate
'      ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,ObjType,User,CU,resol,txt,PlanDate
      rows.Create
      rows(i).Attributes("ATTR_TENDER_EXPERT").user = User
      i=i+1
      If str <> "" Then
        str =  str & " - " & User.Description & chr(10) 
      Else
        str = " - " & User.Description & chr(10) 
      End If
    End If
  Next
 End If
  If str <> "" Then
    Msgbox "Закупка переведена в статус «На рассмотрении». Выдано поручение на экспертную оценку результатов закупки следующим пользователям:"&_ 
     chr(10)& chr(10)& str,vbInformation
  End If
  
'  Маршрут
  StatusName = "STATUS_TENDER_CHECK_RESULT"
  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
  If RetVal = -1 Then
    Obj.Status = ThisApplication.Statuses(StatusName)
  End If
  
  ThisApplication.Utility.WaitCursor = False
  ThisScript.SysAdminModeOff
End Sub
