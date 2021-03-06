' Команда - Закупка размещена (Внешняя закупка)
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

USE "OBJECT_PURCHASE_OUTSIDE"

Call PurchaseToPublic(ThisObject)

Sub PurchaseToPublic(Obj)
  ThisScript.SysAdminModeOn
  AttrName = "ATTR_TENDER_STATUS"
  
  Key = Msgbox("Пометить закупку как размещенную?",vbQuestion+vbYesNo)
  If Key = vbYes Then
    AttrName0 = "ATTR_TENDER_STATUS"
    If Obj.Attributes.Has(AttrName0) Then
    Obj.Attributes(AttrName0).Classifier = ThisApplication.Classifiers.FindBySysId("NODE_71722CD2_D229_477F_8C15_230972C2261D")
    End If
    'Маршрут
    StatusName = "STATUS_TENDER_OUT_PUBLIC"
    RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
    If RetVal = -1 Then
      Obj.Status = ThisApplication.Statuses(StatusName)
    End If
    
     'Дата подачи заявки
  Obj.Attributes("ATTR_TENDER_PUBLIC_TIME").Value = Date
   
    Key = Msgbox("Выгрузить файлы?",vbQuestion+vbYesNo)
 
    If Key = vbYes Then
      Count = 0
      Path = ""
      Call PurchaseDocsFilesUpload(Obj,Count,Path)
      If Count > 0 Then
        Msgbox "Файлы выгружены.", vbInformation
      End If
    End If
  End If
  
  ThisScript.SysAdminModeOff
End Sub
