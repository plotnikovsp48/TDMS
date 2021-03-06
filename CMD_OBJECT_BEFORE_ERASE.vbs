' $Workfile: COMMAND.SCRIPT.CMD_OBJECT_BEFORE_ERASE.scr $ 
' $Date: 29.09.08 12:37 $ 
' $Revision: 5 $ 
' $Author: Oreshkin $ 
'
' Модуль обработки события ObjectBeforeErase
'------------------------------------------------------------------------------
' Авторское право © ЗАО «НАНОСОФТ», 2008 г.


'==============================================================================
' Функция проверяет наличие контента в составе удаляемого объекта
'------------------------------------------------------------------------------
' ПРИНИМАЕТ:
'   Obj:TDMSObject - Удаляемый объект
'==============================================================================
Function CheckContent(Obj)
  If Obj.ContentAll.Count > 0 Then 
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1102, Obj.Description
    CheckContent = True 
  Else
    CheckContent = False
  End If
End Function

'==============================================================================
' Функция проверяет ссылки на удаляемый объект
'------------------------------------------------------------------------------
' ПРИНИМАЕТ:
'   Obj:TDMSObject - Удаляемый объект
'==============================================================================
Function CheckReferencedBy(Obj)
  Dim cancel,o
  cancel = False
  If Obj.ReferencedBy.Count > 0 Then
    For Each o In Obj.ReferencedBy
      If (o.GUID <> Obj.GUID) And (o.ObjectDefName <> "OBJECT_P_TASK")Then
        cancel = True
        ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1103,Obj.ObjectDef.Description, Obj.ReferencedBy(0).Description 
        Exit For
      End If
    Next
  End If
  CheckReferencedBy = cancel
End Function

'==============================================================================
' Метод устанавливает отметку об удалении объекта из системы 
' в ThisApplication.Dictionary("EraseObjects")
' Отметка необходима для предотвращения удаления из состава т.к. нет прав
' разграничевающих удаление из системы и удаление из состава.
' Вызывается при событии объекта "Object_BeforeErase"
' Используется совместно с функцией "CheckEraseFlag"
'------------------------------------------------------------------------------
' o_:TDMSObject - Удаляемый из системы объект отметка о котором 
'     заносится в Dictionary
'==============================================================================
 Sub SetEraseFlag(o_)
  Dim dict   ' ThisApplication.Dictionary
  Dim sGUID 
  Set dict = ThisApplication.Dictionary("EraseObjects")
  sGUID = o_.GUID
  If Not dict.Exists(sGUID) Then 
    dict.Add sGUID, True
  End If  
End Sub


'==============================================================================
' Метод проверяет отметку об удалении объекта из системы 
' в ThisApplication.Dictionary("EraseObjects")
' Отметка необходима для предотвращения удаления из состава т.к. нет прав
' разграничевающих удаление из системы и удаление из состава
' Вызывается при событии объекта "Object_BeforeContentRemove"
' Используется совместно с функцией "SetEraseFlag"
'------------------------------------------------------------------------------
' os_:TDMSObjects - Удаляемые из состава объекты 
' CheckEraseFlag:Boolean - Результат проверки
'                TRUE - Объект не может быть удален
'                FALSE - Объект может быть удален
'==============================================================================
 Function CheckEraseFlag(os_)
  Dim dict 
  Dim sGUID
  CheckEraseFlag = False
  Set dict = ThisApplication.Dictionary("EraseObjects")
  For Each o In os_
    sGUID = o.GUID
    If Not dict.Exists(sGUID) Then 
      CheckEraseFlag = True
      Exit Function
    End If
  Next
End Function



