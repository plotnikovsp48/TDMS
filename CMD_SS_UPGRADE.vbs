Option Explicit

USE CMD_SS_TRANSACTION
USE CMD_SS_PROGRESS

Go

Private Sub Go()
  
  Dim upgradeMethods
  upgradeMethods = Array( _
    Array("Case4483", "Добавить к ИО Раздел/Подраздел признак выполнения Субподрядчиком, форму Субподрядчик"), _
    Array("Case4773", "Том/Основной комплект. Готово к отправке") _
  )
  
  Dim i, pg, item
  Set pg = New CProgress
  pg.SetRange LBound(upgradeMethods), UBound(upgradeMethods) + 1
  For i = LBound(upgradeMethods) To UBound(upgradeMethods)
    If pg.Cancel Then _
      Err.Raised vbObjectError, "Upgrade", "Прервано пользователем"
    
    item = upgradeMethods(i)
    pg.Text = item(1)
    ExecuteSingleStep item(0)
    pg.Step
  Next
  
  ThisApplication.MsgBox "Процедура обновления завершена успешно"
End Sub

Private Sub ExecuteSingleStep(method)
  Dim tr
  Set tr = New Transaction
  Execute method
  tr.Commit
End Sub

Private Sub Case4773()

  Dim list
  list = Array("ATTR_READY_TO_SEND")
  
  Dim defs
  Set defs = ThisApplication.ObjectDefs
  
  AppendAttributes list, defs("OBJECT_VOLUME").Objects
  AppendAttributes list, defs("OBJECT_WORK_DOCS_SET").Objects
End Sub


Private Sub Case4483()

  Dim list
  list = Array("ATTR_SUBCONTRACTOR_WORK" _
                , "ATTR_SUBCONTRACTOR_CLS" _
                , "ATTR_CONTRACT_SUBCONTRACTOR" _
                , "ATTR_SUBCONTRACTOR_DOC_CODE" _
                , "ATTR_SUBCONTRACTOR_DOC_NAME" _
                , "ATTR_SUBCONTRACTOR_DOC_INF" _
                , "ATTR_TENDER_OUT_REQUIRED")
                
  Dim defs
  Set defs = ThisApplication.ObjectDefs
  
  AppendAttributes list, defs("OBJECT_PROJECT_SECTION").Objects
  AppendAttributes list, defs("OBJECT_PROJECT_SECTION_SUBSECTION").Objects
End Sub

Private Sub AppendAttributes(list, collection)
  
  Dim o, att, i
  For Each o In collection
    Set att = o.Attributes
    For i = LBound(list) To UBound(list)
      If Not att.Has(list(i)) Then att.Create list(i)
    Next
  Next
End Sub

Private Sub RemoveAttributes(list, collection)

  Dim o, att, i
  For Each o In collection
    Set att = o.Attributes
    For i = LBound(list) To UBound(list)
      If att.Has(list(i)) Then att(list(i)).Erase
    Next
  Next
End Sub