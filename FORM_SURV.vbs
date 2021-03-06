' Форма ввода - Вид изысканий
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2017 г.

USE "CMD_S_DLL"
USE "CMD_SS_TRANSACTION"

Sub Form_BeforeShow(Form, Obj)
  form.Caption = form.Description
  ' CMD_PROJECT_STAGE_SEL, CMD_PROJECT_STAGE_DEL
  With Form.Controls
    .Item("CMD_PROJECT_STAGE_SEL").Enabled = _
      ThisApplication.ExecuteScript("CMD_SS_LIB", "EnableContractStageEdit", Obj)
    .Item("CMD_PROJECT_STAGE_DEL").Enabled = _
      .Item("CMD_PROJECT_STAGE_SEL").Enabled
  End With
End Sub
Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
  If Attribute.AttributeDefName = "ATTR_SUBCONTRACTOR_WORK" Then
    If Obj.Attributes("ATTR_S_SURV_TYPE").Empty Then
        Msgbox "Заполните обязательные поля!",vbExclamation
        Cancel = True
        Exit Sub
      End If
    If Attribute.Value = False Then
      Key = Msgbox("Это действие приведет к потере данных," &_
      " указанных на вкладке Субподрядчик. Продолжить?", vbQuestion+vbYesNo)
      If Key = vbYes Then
        If Obj.Attributes.Has("ATTR_SUBCONTRACTOR_CLS") Then
          Obj.Attributes("ATTR_SUBCONTRACTOR_CLS").Object = Nothing
        End If
        If Obj.Attributes.Has("ATTR_SUBCONTRACTOR_DOC_CODE") Then
          Obj.Attributes("ATTR_SUBCONTRACTOR_DOC_CODE").Value = ""
        End If
        If Obj.Attributes.Has("ATTR_SUBCONTRACTOR_DOC_INF") Then
          Obj.Attributes("ATTR_SUBCONTRACTOR_DOC_INF").Value = ""
        End If
        If Obj.Attributes.Has("ATTR_SUBCONTRACTOR_DOC_NAME") Then
          Obj.Attributes("ATTR_SUBCONTRACTOR_DOC_NAME").Value = ""
        End If
      Else
        Cancel = True
        Exit Sub
      End If
    Else
      Key = Msgbox("Хотите заполнить данные по субподрядчику?",vbQuestion+vbYesNo)
      If Key = vbYes Then Obj.Dictionary.Item("FormActive") = True
    End If
    Obj.Update
  End If
  
  If Attribute.AttributeDefName = "ATTR_CONTRACT_STAGE" Then
    If vbNo = ThisApplication.ExecuteScript(_
      "CMD_MESSAGE", "ShowWarning", vbQuestion+VbYesNo, _
      1702, Attribute.Object.Description, Obj.Description) Then Exit Sub
      
    ' wrap in transaction
    Dim t
    Set t = New Transaction
    Obj.Update
    SetAttrToContentAll Obj, "ATTR_CONTRACT_STAGE", Attribute.Object
    t.Commit
  End If
End Sub

' Кнопка - Выбрать этап
Sub CMD_PROJECT_STAGE_SEL_OnClick()
  Dim stage, t
  Set stage = PickContractStage(ThisObject)
  If stage Is Nothing Then Exit Sub
  
  Set t = New Transaction
  ThisObject.Attributes("ATTR_CONTRACT_STAGE").Object = stage
  SetAttrToContentAll ThisObject, "ATTR_CONTRACT_STAGE", stage
  t.Commit
End Sub

' Удалить этап
Sub CMD_PROJECT_STAGE_DEL_OnClick()
  Dim t
  Set t = New Transaction
  ThisObject.Attributes("ATTR_CONTRACT_STAGE").Empty = True
  SetAttrToContentAll ThisObject, "ATTR_CONTRACT_STAGE", Nothing
  t.Commit
End Sub


