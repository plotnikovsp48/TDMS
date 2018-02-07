use "CMD_MARK_LIB"


'=============================================
Sub ADDMARK_OnClick()
 'Создаем новую метку
  ThisScript.SysAdminModeOn
  set qw = ThisForm.Controls("QUERY_ALLMARKS").ActiveX
  If ThisForm.Controls("QUERY_ALLMARKS").SelectedObjects.Count > 0 then
    For p = 0 to qw.Count-1
        If qw.isItemSelected(p) then
          NameMark = qw.ItemText(p,1)
          call CreateMark(NameMark,ThisObject,true)
        end if
    next 
 end if
End Sub


'=============================================
Sub DELLMARK_OnClick()
  Set Dict = ThisApplication.Dictionary("MARK") 
  'Удаляем выделенные метки
  For each ObjToDell in ThisForm.Controls("QUERY_MARK_TO_VDLETTER").SelectedObjects
    If ObjToDell.Attributes("ATTR_MARK_USER").User.SysName =ThisApplication.CurrentUser.Sysname _
           or (ThisApplication.CurrentUser.Sysname = "SYSADMIN") then
              ObjToDell.Permissions = SysAdminPermissions
              ObjToDell.erase
    end if
  next
End Sub


'=============================================
Sub ADDNEWMARK_OnClick()
  call CreateMark("",ThisObject,true)
end sub

'=============================================
Sub Form_BeforeShow(Form, Obj)
  'Выбор одной метки для добавления
  set q = Form.Controls("QUERY_ALLMARKS").ActiveX
  q.SingleSelection = true
End Sub

'=============================================
Sub QUERY_ALLMARKS_DblClick(iItem, bCancelDefault)
  BTN_ADD_SEL_OnClick()
  thisForm.Refresh
  bCancelDefault = true
End Sub

'=============================================
Sub QUERY_MARK_TO_VDLETTER_DblClick(iItem, bCancelDefault)

  Set Dict2 = ThisApplication.Dictionary("MARK2") 
  if not dict2.exists("MARKCOR") then 
    dict2.add "MARKCOR",1
  else
   dict2.item("MARKCOR") = 1
  end if
End Sub

'=============================================
Sub BTN_ADD_SEL_OnClick()
' создаем новую без вопросов
 ThisScript.SysAdminModeOn
  set qw = ThisForm.Controls("QUERY_ALLMARKS").ActiveX
  If ThisForm.Controls("QUERY_ALLMARKS").SelectedObjects.Count > 0 then
    For p = 0 to qw.Count-1
        If qw.isItemSelected(p) then
          NameMark = qw.ItemText(p,1)
          call CreateMark(NameMark,ThisObject, false)
        end if
    next 
 end if
End Sub