' Автор: Чернышов Д.С.
'
' Команда - Добавить вид изысканий
'------------------------------------------------------------------------------------------------------
' Авторское право © ЗАО «СиСофт», 2017 г.

Call Main(ThisObject)

Sub Main(Obj)
  ThisScript.SysAdminModeOn
  Set Form = ThisApplication.InputForms("FORM_SURVS_CREATE_TREE")
  Set Dict = ThisApplication.Dictionary("SurvTree")
  Dict.Item("Handle") = Obj.Handle
  Form.Show
End Sub