' Команда - Закрыть (Внешняя закупка)
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

USE "OBJECT_PURCHASE_OUTSIDE"

Call PurchaseClose(ThisObject,False)

Sub PurchaseClose(Obj,Result)
  ThisScript.SysAdminModeOn
  ThisApplication.Dictionary("CMD_TENDER_OUT_CLOSE").RemoveAll
  StatusName = ""
  AttrStatus = False
  AttrGlobalStatus = ""
  AttrName0 = "ATTR_TENDER_STATUS"
  AttrName1 = "ATTR_TENDER_GLOBAL_STATUS"
  Set Doc = Nothing
  Set Clf = Nothing
  Set Val = Nothing
  Set u0 = Nothing
  Set u1 = Nothing
  Set u2 = Nothing
  Set u3 = Nothing
  Code = 0
  Set CU = ThisApplication.CurrentUser
  If Obj.Attributes.Has(AttrName0) Then
    If Obj.Attributes(AttrName0).Empty = False Then
      If not Obj.Attributes(AttrName0).Classifier is Nothing Then
      Code = Obj.Attributes(AttrName0).Classifier.Code
        If Obj.Attributes(AttrName0).Classifier.Code = 2 Then AttrStatus = True
'        Arg = Obj.Attributes(AttrName0).Classifier.Code
      End If
    End If
  End If
  If Obj.Attributes.Has(AttrName1) Then
    If Obj.Attributes(AttrName1).Empty = False Then
      If not Obj.Attributes(AttrName1).Classifier is Nothing Then
        AttrGlobalStatus = Obj.Attributes(AttrName1).Classifier.SysName
      End If
    End If
  End If

  'Выбор сценария в зависимости от условий
  'Если атрибут "Укрупненное состояние закупки" не заполнен
  If AttrGlobalStatus = "" Then
    StatusName = "STATUS_TENDER_CLOSE"
    ans = msgbox("Закупка будет закрыта с пометкой ""Не участвуем"". Закрыть закупку?",vbQuestion+vbYesNo,"Закрытие закупки")
    If ans <> vbYes Then exit Sub
    If Obj.Attributes.Has(AttrName1) Then
      Obj.Attributes(AttrName1).Classifier = ThisApplication.Classifiers.FindBySysId("NODE_MAIN_TENDER_CONSDITION_NO")
    End If
'    Call PurchaseCloseBySelect(Obj,CU,u0,u1,u2,u3,StatusName,Clf,"ATTR_TENDER_STATUS_CLOSE")
    'Маршрут
'      Obj.Status = ThisApplication.Statuses(StatusName)
      msgbox "Закупка закрыта", vbInformation
      Result = True
    End If  
  
    'Если "Укрупненное состояние закупки" = "Не участвуем" 
  If AttrGlobalStatus = "NODE_MAIN_TENDER_CONSDITION_NO" Then
   ans = msgbox("Закрыть закупку?",vbQuestion+vbYesNo,"Закрытие закупки")
  If ans <> vbYes Then exit Sub
   StatusName = "STATUS_TENDER_CLOSE"
'   Call PurchaseCloseBySelect(Obj,CU,u0,u1,u2,u3,StatusName,Clf,"ATTR_TENDER_STATUS_CLOSE")
'      msgbox "Закупка закрыта", vbInformation
    'Маршрут
      Obj.Status = ThisApplication.Statuses(StatusName)
      msgbox "Закупка закрыта", vbInformation
      Result = True
      Exit Sub 
   End If 
       
   'Если "Укрупненное состояние закупки" = "Участвуем" и "Статус закупки" = "" или "На рассмотрении" 
 If AttrGlobalStatus = "NODE_MAIN_TENDER_CONSDITION_YES" and (Code = 1 or Code = 0 or Code = 3) Then
   If not (Obj.StatusName = "STATUS_TENDER_WIN" or Obj.StatusName = "STATUS_TENDER_LOST" or Obj.StatusName = "STATUS_TENDER_CLOSE") Then
    
  
   ans = msgbox("Закрыть закупку как отмененную?",vbQuestion+vbYesNo,"Закрытие закупки")
  If ans <> vbYes Then exit Sub
  
     ThisScript.SysAdminModeOn
    Set frmSetShelve = ThisApplication.InputForms("FORM_COMMENT")
    If frmSetShelve.Show  then 
      txt = trim(frmSetShelve.Attributes("ATTR_KD_TEXT").Value)
      if txt <> "" Then 
'        call AddComment(thisObject,"ATTR_TENDER_STATUS_FAIL_COMMENT",txt)
     'sub AddCommentTxt(obj, AttrName, newText)
      str =  txt & Chr(13) & Chr(10)& _
      thisApplication.CurrentUser.Description & " - " & cStr(Now)'& Chr(13) & Chr(10)& Chr(13) & Chr(10)        
      obj.Attributes("ATTR_TENDER_STATUS_FAIL_COMMENT").value =  str
      thisObject.Update
      end if  
    end if  
  
   Obj.Attributes(AttrName0).Classifier = ThisApplication.Classifiers.FindBySysId("NODE_2A102408_E255_493B_88C9_A67CB84FB50C")
   StatusName = "STATUS_TENDER_CLOSE"
    'Маршрут
      Obj.Status = ThisApplication.Statuses(StatusName)
      msgbox "Закупка закрыта", vbInformation
      Result = True
    Exit Sub 
   End If
  End If
'   
   'Если "Укрупненное состояние закупки" = "Участвуем" и "Статус закупки" = ""  Статус объекта Размещена на площадке
 If AttrGlobalStatus = "NODE_MAIN_TENDER_CONSDITION_YES" and Obj.Attributes(AttrName0).Empty = True Then
  If not (Obj.StatusName = "STATUS_TENDER_WIN" or Obj.StatusName = "STATUS_TENDER_LOST" or Obj.StatusName = "STATUS_TENDER_CLOSE") Then
  'Проверка атрибутов
  Str = PurchaseCloseAttrsCheck(Obj,u0,u1,u2)
  If Str <> "" Then
    Msgbox "Обязательные атрибуты " & Str & " не заполнены", vbExclamation
    Result = False
    Exit Sub
  End If
    FormName = "FORM_PURCHASE_STATUS_SELECT"
    Set Form = ThisApplication.InputForms(FormName)
    Set Dict = ThisApplication.Dictionary(FormName)
    If Form.Show Then
      If Dict.Exists("SELECTION") Then
        Val = Dict.Item("SELECTION")
        Call PurchaseCloseBySelect(Obj,CU,u0,u1,u2,u3,StatusName,Clf,Val)
      End If
    End If
   End If
   End If 
   
  'Если "Укрупненное состояние закупки" = "Участвуем" и "Статус закупки" = "Поданная"
 If AttrGlobalStatus = "NODE_MAIN_TENDER_CONSDITION_YES" and AttrStatus = True Then
 
    FormName = "FORM_PURCHASE_STATUS_SELECT"
    Set Form = ThisApplication.InputForms(FormName)
    Set Dict = ThisApplication.Dictionary(FormName)
    Result = False
       If Form.Show Then
        If Dict.Exists("SELECTION") Then
        Val = Dict.Item("SELECTION")
        
        Call PurchaseCloseBySelect(Obj,CU,u0,u1,u2,u3,StatusName,Clf,Val)
         
        if Clf is nothing then 
        Result = False
        Exit Sub  
        End If
      End If
    End If
  End If
 
  'Смена статуса
  Call PurchaseCloseRoute(Obj,StatusName,Clf)
  
  Result = True
  ThisScript.SysAdminModeOff
End Sub






