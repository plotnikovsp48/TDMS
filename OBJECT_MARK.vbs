use CMD_MARK_LIB
use CMD_KD_SET_PERMISSIONS

'=============================================
Sub Object_PropertiesDlgBeforeClose(Obj, OkBtnPressed, Cancel)
  Obj.Permissions = SysAdminPermissions
  
  Set Dict = ThisApplication.Dictionary("MARK")
  Set Dict2 = ThisApplication.Dictionary("MARK2")  
  Set Dict3 = ThisApplication.Dictionary("MARK3") 
  'dict3.RemoveAll 
  MarkName = Obj.Attributes("ATTR_MARK_NAME").Value
  set Object = Obj.Attributes("ATTR_MARK_TODOC").Object
  TypeMark = Obj.Attributes("ATTR_MARK_TYPE").Value
  
  If OkBtnPressed then
      If Trim(MarkName)<>"" and not Object is nothing and Trim(TypeMark)<>"" then
        'иначе обрабатываем для данного документа
        If IsMarkInObject (MarkName,TypeMark,Object,Obj.Handle) then
          'Если вызвано из функции редактирования всех объектов, то просто выходим и запоминаем значения, а атрибуты возвращаем обратно gjckt
          if SetAttr (dict3,obj) = true then exit sub
          msgbox "Метка " & MarkName & " уже существует в документе " & Object.Description
          Cancel=true
        Else 
          'Удаляем признак нового объекта если такой есть
          dict.RemoveAll
        End if   
      Else
        msgbox "Заполните метку"
        Cancel = true
      End if
  Else
     if SetAttr (dict3,obj) = true then exit sub
      'Если новый объект, то при отмене нужно его удалить, иначе ничего не делаем
      if dict.exists("NEWMARK") then 
          If  dict.Item("NEWMARK") = 1 then
              Obj.Permissions = SysAdminPermissions 
              Obj.Erase
          else
          end if
      End if 
      dict.RemoveAll  
      dict3.RemoveAll  
  End if
  dict2.RemoveAll 
  
End Sub

'=============================================
function SetAttr (dict3,obj)
  SetAttr = false
      if dict3.exists("MARKCORRALL") then 
           if   dict3.item("MARKCORRALL")=1 then
               if dict3.exists("NAME") then
                   dict3.item("NAME")=Obj.Attributes("ATTR_MARK_NAME").Value
               else
                   dict3.add "NAME",Obj.Attributes("ATTR_MARK_NAME").Value
               end if
                
               if dict3.exists("TYPE") then
                   dict3.item("TYPE")=Obj.Attributes("ATTR_MARK_TYPE").Value
               else
                   dict3.add "TYPE",Obj.Attributes("ATTR_MARK_TYPE").Value
               end if
                
               if dict3.exists("NEEDBACK") then
                   dict3.item("NEEDBACK") = 1
               else
                   dict3.add "NEEDBACK",1
               end if
               SetAttr = true
               exit function
           end if
      end if
end function

'=============================================
Sub ContextMenu_ItemAdd(cmdId, MenuObject, Obj, Remove)
 
if   tdmCmdCommand = cmdID and not menuObject is nothing then
  if MenuObject.SysName <> "CMD_MARK_LINKS" and MenuObject.SysName <> "CMD_DELMARK_ALL" and MenuObject.SysName <> "CMD_MARK_CORRECT_ALL" then 
     Remove = true
  end if   
end if  
End Sub

'=============================================
Sub Object_Created(Obj, Parent)
  Set_Permission (Obj)
End Sub