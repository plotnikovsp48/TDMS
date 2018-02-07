' Команда - Выгрузить файлы (Внешняя закупка)
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

USE "OBJECT_PURCHASE_OUTSIDE"

Call PurchaseFilesUpload(ThisObject,False)

Sub PurchaseFilesUpload(Obj,Result)
  ThisScript.SysAdminModeOn
  Count = 0
  Path = ""
  Call PurchaseDocsFilesUpload(Obj,Count,Path)
  If Count > 0 Then
    Key = Msgbox("Файлы выгружены в """ & Path & """. Пометить закупку как размещенную?",vbQuestion+vbYesNo)
    If Key = vbYes Then
    AttrName0 = "ATTR_TENDER_STATUS"
    If Obj.Attributes.Has(AttrName0) Then
    Obj.Attributes(AttrName0).Classifier = ThisApplication.Classifiers.FindBySysId("NODE_71722CD2_D229_477F_8C15_230972C2261D")
    End If
  
  '  AttrName1 = "ATTR_TENDER_GLOBAL_STATUS"
'  If Obj.Attributes.Has(AttrName0) Then
'    If Obj.Attributes(AttrName0).Empty = False Then
'      If not Obj.Attributes(AttrName0).Classifier is Nothing Then
'        AttrStatus = Obj.Attributes(AttrName0).Classifier.Code
'      End If
'    End If
'  End If
      'Маршрут
      StatusName = "STATUS_TENDER_OUT_PUBLIC"
      RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
      If RetVal = -1 Then
        Obj.Status = ThisApplication.Statuses(StatusName)
      End If
      Result = True
    End If
  End If
  ThisScript.SysAdminModeOff
End Sub


