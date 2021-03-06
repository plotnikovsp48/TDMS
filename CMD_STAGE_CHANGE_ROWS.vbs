' Команда - Изменить сроки (Этап)
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2017 г.

Call Main(ThisObject)

Sub Main(Obj)
  ThisScript.SysAdminModeOn
  Set Form = ThisApplication.InputForms("FORM_STAGE_CHANGE_DATES")
  Set Dict = Form.Dictionary
  'Заполняем даты на форме и запоминаем старые значения
  Attr1 = "ATTR_STARTDATE_PLAN"
  Attr2 = "ATTR_ENDDATE_PLAN"
  Attr3 = "ATTR_ENDDATE_ESTIMATED"
  Attr4 = "ATTR_STARTDATE_FACT"
  Attr5 = "ATTR_ENDDATE_FACT"
  Attr6 = "ATTR_STARTDATE_ESTIMATED"
  Val1 = Obj.Attributes(Attr1).Value
  Dict.Item("Val1") = Val1
  Form.Attributes(Attr1).Value = Val1
  Val2 = Obj.Attributes(Attr2).Value
  Dict.Item("Val2") = Val2
  Form.Attributes(Attr2).Value = Val2
  Val3 = Obj.Attributes(Attr3).Value
  Dict.Item("Val3") = Val3
  Form.Attributes(Attr3).Value = Val3
  Val4 = Obj.Attributes(Attr4).Value
  Dict.Item("Val4") = Val4
  Form.Attributes(Attr4).Value = Val4
  Val5 = Obj.Attributes(Attr5).Value
  Dict.Item("Val5") = Val5
  Form.Attributes(Attr5).Value = Val5
  Val6 = Obj.Attributes(Attr6).Value
  Dict.Item("Val6") = Val6
  Form.Attributes(Attr6).Value = Val6
  Form.Attributes("ATTR_OBJECT") = Obj
    
  If Form.Show Then
    If Dict.Item("FORM_KEY_PRESSED") = True Then
      'Обновление атрибутов
      Reason = Form.Attributes("ATTR_INF").Value
      Set oDocRef = Form.Attributes("ATTR_DOC_REF").Object
      Str = ""
      Call ChangeDates(Obj,Form,Attr1,Dict.Item("Val1"),Reason,oDocRef,Str)
      Call ChangeDates(Obj,Form,Attr2,Dict.Item("Val2"),Reason,oDocRef,Str)
      Call ChangeDates(Obj,Form,Attr3,Dict.Item("Val3"),Reason,oDocRef,Str)
      Call ChangeDates(Obj,Form,Attr4,Dict.Item("Val4"),Reason,oDocRef,Str)
      Call ChangeDates(Obj,Form,Attr5,Dict.Item("Val5"),Reason,oDocRef,Str)
      Call ChangeDates(Obj,Form,Attr6,Dict.Item("Val6"),Reason,oDocRef,Str)
      
      'Отправка уведомлений
      If Str <> "" Then
        Call SendMessage(Obj,"ROLE_RESPONSIBLE",Str,Reason)
        Call SendMessage(Obj,"ROLE_COORDINATOR_2",Str,Reason)
        Call SendMessage(Obj,"ROLE_RESPONSIBLES_FOR_UNFINISHED",Str,Reason)
      End If
    End If
  End If
End Sub

'Процедура внесения изменений
Sub ChangeDates(Obj,Form,AttrSysName,OldVal,Reason,oDocRef,Str)
  Set TableRows = Obj.Attributes("ATTR_HISTORY_CHANGE_OF_TIMING").Rows
  Set Attr = Obj.Attributes(AttrSysName)
  OldVal = CDate(OldVal)
  NewVal = CDate(Form.Attributes(AttrSysName).Value)
  
  If OldVal <> NewVal Then
    Attr.Value = NewVal
    Str = Str & chr(10) & Attr.Description
    Set NewRow = TableRows.Create
    NewRow.Attributes("ATTR_DATA").Value = Date
    NewRow.Attributes("ATTR_ATTR").Value = Attr.Description
    NewRow.Attributes("ATTR_USER_CHANGE").Value = ThisApplication.CurrentUser
    NewRow.Attributes("ATTR_DATE_LAST").Value = OldVal
    'NewRow.Attributes("ATTR_DATE_NEW").Value = Attr.Value
    NewRow.Attributes("ATTR_INF").Value = Reason
    If oDocRef Is Nothing Then Exit Sub
    Call ThisApplication.ExecuteScript("CMD_DLL","SetAttr_F",NewRow,"ATTR_DOC_REF",oDocRef,True)
  End If
End Sub

Private Sub SendMessage(Obj,RoleDefName,Str,Reason)
  For Each Role In Obj.RolesByDef(RoleDefName)
    If Not Role.User Is Nothing Then
      Set u = Role.User
      If u.SysName = ThisApplication.CurrentUser.SysName Then Exit Sub
    End If
    If Not Role.Group Is Nothing Then
      Set u = Role.Group
    End If
    ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1608, u, Obj, Nothing, Obj.Description, Str, Reason
  Next
End Sub
