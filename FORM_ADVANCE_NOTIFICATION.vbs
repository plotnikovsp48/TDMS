' $Workfile: FORM.SCRIPT.FORM_ADVANCE_NOTIFICATION.scr $ 
' $Date: 29.09.08 12:37 $ 
' $Revision: 2 $ 
' $Author: Oreshkin $ 
'
' Форма предварительного извещения
'------------------------------------------------------------------------------
' Авторское право © ЗАО «НАНОСОФТ», 2008 г.

Sub Form_BeforeShow(Form, Obj)
  form.Caption = form.Description
  ' Установка статуса контролов ReadOnly
  Dim sListAttrs ' Список системных идентификаторов атрибутов, поля которых на форме должны быть Read Only
  sListAttrs = "ATTR_ADVANCE_NOTIFICATION_NUM"
  Call ThisApplication.ExecuteScript("CMD_DLL","SetControlReadOnly",Form,sListAttrs)
End Sub
