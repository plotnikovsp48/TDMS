' $Workfile: COMMAND.SCRIPT.CMD_WORK_DOCS_SET_BACK_IN_WORK.scr $ 
' $Date: 10.10.08 15:57 $ 
' $Revision: 3 $ 
' $Author: Oreshkin $ 
'
' Вернуть комплект в разработку
'------------------------------------------------------------------------------
' Авторское право © ЗАО «НАНОСОФТ», 2008 г.

Call Main(ThisObject)

Function Main(Obj)
  Main = False
  Dim result
  
  'Проверка возможности создать версию объекта
  if Not Obj.ObjectDef.VersionsEnabled then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, 1256, Obj.ObjectDef.Description  
  Else
    ' Подтверждение
    result = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning", vbYesNo, 1126, Obj.Description)    
    If result <> vbYes Then
      Exit Function
    End If 
    
    'Запрос причины
    result = ThisApplication.ExecuteScript("CMD_KD_COMMON_LIB","GetComment","Укажите причину возврата комплекта:")
    If IsEmpty(result) Then
      Exit Function 
    ElseIf trim(result) = "" Then
      msgbox "Невозможно вернуть комплект не указав причину." & vbNewLine & _
          "Пожалуйста, введите причину возврата.", vbCritical, "Не задана причина возврата!"
      Exit Function
    End If
          
    ' Создание рабочей версии
    Obj.Versions.Create ,result
  End If                        
    
  Call Run(Obj)
  Main = True
  
  ' Изменение статуса прилагаемых документов  
  For Each oDoc In Obj.Objects.ObjectsByDef("OBJECT_DOCUMENT")
    Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",oDoc,"STATUS_DOC_IS_FIXED",oDoc,"STATUS_DOC_IS_ADDED") 
  Next
  
  For Each oDoc In Obj.Objects.ObjectsByDef("OBJECT_DOC_DEV")
    Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",oDoc,"STATUS_DOCUMENT_FIXED",oDoc,"STATUS_DOCUMENT_CREATED")  
  Next
  
  For Each oDoc In Obj.Objects.ObjectsByDef("OBJECT_DRAWING")
    Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",oDoc,"STATUS_DOCUMENT_FIXED",oDoc,"STATUS_DOCUMENT_CREATED") 
  Next
    
  ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, 1128, Obj.Description    
End Function

Sub Run(Obj)
  'Статус, устанавливаемый в результате выполнения команды
  Dim NextStatus
  NextStatus ="STATUS_WORK_DOCS_SET_IS_DEVELOPING"
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,NextStatus)  
End Sub
