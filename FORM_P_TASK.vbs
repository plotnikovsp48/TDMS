USE "OBJECT_P_TASK"
USE "CMD_DLL_COMMON_BUTTON"

Sub Form_BeforeShow(Form, Obj)
    ' Отображение заголовка окна
  form.Caption = form.Description
  
  Obj.Permissions = SysAdminpermissions
  Call SetControls(Form, Obj)
End Sub

Sub SetControls(Form, Obj)
  Set CU = ThisApplication.CurrentUser
  Obj.Permissions = SysAdminpermissions
  set linkObj = Obj.Attributes("ATTR_OBJECT").Object
  If linkObj Is Nothing Then Exit Sub
  
  isPln = isPlanner(linkObj,CU)
  isGIP = IsProjectGip(linkObj,CU) or IsProjectGipDep(linkObj,CU)
  isDvlp = IsDeveloper(linkObj,CU)
  isLckd = ObjectIsLockedByUser(Obj) 'ThisApplication.ExecuteScript("CMD_KD_REGNO_KIB", "SetLock", obj)
'  isLckd = (obj.Permissions.LockOwner <> true)
  Set cCtl = Form.Controls
  cCtl("TXT_VersionCreateTime").value = Obj.VersionCreateTime 
  cCtl("TXT_VersionCreateUser").value = Obj.VersionCreateUser.Description
  If Not Obj.Attributes("ATTR_P_TASK_FINISH_TYPE").Classifier Is Nothing Then
    cCtl("TXT_TASK_FINISH_TYPE").value = Obj.Attributes("ATTR_P_TASK_FINISH_TYPE").Classifier.Description
  Else
    cCtl("TXT_TASK_FINISH_TYPE").value = ""
  End If
  cCtl("ATTR_STARTDATE_PLAN").Readonly = not (isLckd And isPln And (Obj.Attributes("ATTR_STARTDATE_PLAN").Empty = True)) And _
                                                not ((Obj.Attributes("ATTR_STARTDATE_PLAN").Empty = True) And (isDvlp or isGIP)) 
                                                
  cCtl("ATTR_ENDDATE_PLAN").Readonly = not (isLckd And isPln And (Obj.Attributes("ATTR_ENDDATE_PLAN").Empty = True)) And _
                                                not ((Obj.Attributes("ATTR_ENDDATE_PLAN").Empty = True) And (isDvlp or isGIP))
                                                
  cCtl("ATTR_STARTDATE_ESTIMATED").Readonly = not (isLckd And isPln ) And (not (isDvlp or isGIP))
  cCtl("ATTR_ENDDATE_ESTIMATED").Readonly = not (isLckd And isPln) And (not (isDvlp or isGIP))
  
  List = "ATTR_TOPLATAN,ATTR_WORK_PLACE,ATTR_INF,ATTR_DOCS_TLINKS"
  
  Arr = Split(List,",")
  
  For each ar In Arr
    cCtl(ar).Readonly = not (Not isLckd And isPln)
  Next
  
  List = "CMD_DOC_ADD,CMD_DOC_DEL,BUTTON1,ATTR_TOPLATAN,ATTR_WORK_PLACE,ATTR_INF,ATTR_DOCS_TLINKS,CMD_TASK_REFRESH"
  
  Arr = Split(List,",")
  For each ar In Arr
    cCtl(ar).Enabled = (Not isLckd And isPln)
  Next
End Sub

Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
  ' Проверяем дату начала
  If Attribute.AttributeDefName = "ATTR_STARTDATE_PLAN" Then
    If Obj.Attributes("ATTR_ENDDATE_PLAN").Empty = false Then
      If Attribute.Value >  Obj.Attributes("ATTR_ENDDATE_PLAN").Value Then
        msgbox "Дата начала не может быть больше даты окончания: " & Obj.Attributes("ATTR_ENDDATE_PLAN").Value,vbExclamation
        Cancel = True
        If Cancel Then Exit Sub
      End If
    End If
  End If
  ' Проверяем дату окончания
  If Attribute.AttributeDefName = "ATTR_ENDDATE_PLAN" Then
    If Obj.Attributes("ATTR_STARTDATE_PLAN").Empty = false Then
      If Attribute.Value <  Obj.Attributes("ATTR_STARTDATE_PLAN").Value Then
        msgbox "Дата окончания не может быть меньше даты начала: " & Obj.Attributes("ATTR_STARTDATE_PLAN").Value,vbExclamation
        Cancel = True
        If Cancel Then Exit Sub
      End If
    End If
  End If
'----------------------------------------------------------------------------------------------------------------------------------
  ' Проверяем ожидаемую дату начала
  If Attribute.AttributeDefName = "ATTR_STARTDATE_ESTIMATED" Then
    If Obj.Attributes("ATTR_ENDDATE_ESTIMATED").Empty = false Then
      If Attribute.Value >  Obj.Attributes("ATTR_ENDDATE_PLAN").Value Then
        msgbox "Дата начала не может быть больше даты окончания: " & Obj.Attributes("ATTR_ENDDATE_ESTIMATED").Value,vbExclamation
        Cancel = True
        If Cancel Then Exit Sub
      End If
    End If
  End If
  ' Проверяем ожидаемую дату окончания
  If Attribute.AttributeDefName = "ATTR_ENDDATE_ESTIMATED" Then
    If Obj.Attributes("ATTR_STARTDATE_ESTIMATED").Empty = false Then
      If Attribute.Value <  Obj.Attributes("ATTR_STARTDATE_ESTIMATED").Value Then
        msgbox "Дата окончания не может быть меньше даты начала: " & Obj.Attributes("ATTR_STARTDATE_ESTIMATED").Value,vbExclamation
        Cancel = True
        If Cancel Then Exit Sub
      End If
    End If
  End If
'-----------------------------------------------------------------------------------------------------------------------------------------------
  '"Ожидаемая дата начала работ" = "Дата начала по плану"
  If Attribute.AttributeDefName = "ATTR_STARTDATE_PLAN" Then
    Obj.Attributes("ATTR_STARTDATE_ESTIMATED").Value = Attribute.Value
  End If
  '"Ожидаемая дата окончания работ" = "Дата окончания по плану"
  If Attribute.AttributeDefName = "ATTR_ENDDATE_PLAN" Then
    Obj.Attributes("ATTR_ENDDATE_ESTIMATED").Value = Attribute.Value
  End If
  

''добавление в базу платан
'____________________________________________________________________
  If Attribute.AttributeDefName = "ATTR_TOPLATAN" Then
     If Attribute.Value Then
        Set ObjRef = Obj.Attributes("ATTR_OBJECT").Object
        SetGuid = Obj.GUID
        SetName = Obj.Attributes("ATTR_P_TASK_CODE").value
        if not ObjRef is Nothing Then 
           Set Project = ObjRef.Attributes("ATTR_PROJECT").Object
        else
           msgbox("У Плановой задачи отсутствует ссылка на объект.")   
           Cancel = true
           Exit sub
        end if   
        SetCntr = Project.Attributes("ATTR_PROJECT_CODE").Value
        Call WriteToPlatan(SetGuid, SetName, SetCntr)
     End if
  End if
'____________________________________________________________________
End Sub


Sub WriteToPlatan(p1,p2,p3)
   ServerName = ThisApplication.ServerName
   Set con = CreateObject("ADODB.Connection")
   con.ConnectionString = "Provider=SQLOLEDB.1;Data Source="&ServerName&"; Initial Catalog=Platan; User ID=Platanuser;Password=platanuser"
   con.Open
   con.Execute("platan.dbo.[PL_AddNewSetExtended] "_
   &chr(34)&p1&chr(34)&","&chr(34)&p2&chr(34)&","&chr(34)&p3&chr(34))
   Set con = Nothing
End Sub 


Sub CMD_TASK_REFRESH_OnClick()
  Call SetTaskAttrs (ThisObject)
End Sub
