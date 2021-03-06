
use CMD_MARK_LIB

call  Corrall(ThisObject)

sub Corrall(Obj)

Set Dict2 = ThisApplication.Dictionary("MARK2") 
Set Dict3 = ThisApplication.Dictionary("MARK3")

    
if not dict3.exists("MARKCORRALL") then 
   dict3.add "MARKCORRALL",1
else
   dict3.item("MARKCORRALL")=1
end if

'Поскольку выборка упорядочена по ролям, то показывается объект, у которого роль-редактирвоание атрибутов для данного пользователя
set qw= Thisapplication.Queries("QUERY_MARKS_UNIQ")
qw.Parameter("PARAM0")=Obj.Description
set mrs=qw.Objects
            
For each mr in mrs
                If mr.Roles.Has("ROLE_EDIT_ATTR") Then
                   If ThisApplication.CurrentUser.Handle= mr.Roles("ROLE_EDIT_ATTR").User.handle _
                   or (ThisApplication.CurrentUser.Sysname="SYSADMIN") then
                                 
                            'открываем доступ к редактированию метки
            
                            if not dict2.exists("MARKCOR") then 
                              dict2.add "MARKCOR",1
                            else
                             dict2.item("MARKCOR")=1
                            end if
                            
                            'set q= Thisapplication.Queries("QUERY_MARKS_UNIQ")
                            'q.Parameter("PARAM0")=mr.Description
                            'set marks=q.Objects
                            markdescriptiom=mr.attributes("ATTR_MARK_NAME").value
                            marktype=mr.attributes("ATTR_MARK_TYPE").value
                            
                            
                            Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg
                            CreateObjDlg.Object = mr
                            CreateObjDlg.ActiveForm = thisApplication.InputForms("FORM_NEWMARK")
                            'ThisObject.Update
                            CreateObjDlg.Show
                            
                            
                            'если есть признак необхожимости корректровки, т е было нажато ОК
                            
                            if dict3.exists("MARKCORRALL") then 
                               If  dict3.Item("MARKCORRALL")=1 then
                                   If dict3.Item("NEEDBACK")=1 then
                                      mr.attributes("ATTR_MARK_NAME").value=markdescriptiom
                                      mr.attributes("ATTR_MARK_TYPE").value =marktype
                                      mr.Update   
                                   end if
                                                                    
                                  answer = MsgBox("Сделать тип метки одинаковым для всех?", vbQuestion + vbYesNo)
                                 
                                                             
                                 
                                  For each mark in mrs
                                     If  mark.Roles.Has("ROLE_EDIT_ATTR") Then
                                         If ThisApplication.CurrentUser.Handle= mark.Roles("ROLE_EDIT_ATTR").User.handle _
                                            or (ThisApplication.CurrentUser.Sysname="SYSADMIN") then
                                            If answer <> vbYes Then
                                               dict3.Item("TYPE")=mark.Attributes("ATTR_MARK_TYPE").value
                                            end if
                                            
                                            If not IsMarkInObject( dict3.Item("NAME"),dict3.Item("TYPE"),mark.Attributes("ATTR_MARK_TODOC").Object,mark.Handle) then
                                                
                                             mark.Permissions = SysAdminPermissions
                                             mark.Attributes("ATTR_MARK_NAME").value= dict3.Item("NAME")
                                             need=1
                                                   If answer = vbYes Then  
                                                      'mr.Update
                                                      mark.Attributes("ATTR_MARK_TYPE").Value=dict3.Item("TYPE")
                                                   'else
                                                     ' mr.attributes("ATTR_MARK_TYPE").value= marktype  
                                                   end if
                                             mark.update      
                                             else
                                             ThisApplication.AddNotify "Метка "  & dict3.Item("NAME")  & " уже есть в документе " &  mark.Attributes("ATTR_MARK_TODOC").Object.description     
                                             end if     
                                         end if    
                                     end if   
                                   
                                   Next
                
                                 end if
                              else
                              exit sub   
                             end if      
                  
                      exit for   
                   end if
                 end if
next       

if  need=1 then
else
need=0 
msgbox "Нет прав для редактирования"
end if
    
Dict3.RemoveAll            

end sub            
            
            
            
'            
'            
'            
'               
'                       else
'                       msgbox "Нет прав для редактирования"
'                       'exit sub
'                       end if
'              else
'              msgbox "Нет прав для редактирования"
'                                 
'                   
'                   end if
'            next
'            

'If ThisObject.Roles.Has("ROLE_EDIT_ATTR") Then
'         If ThisApplication.CurrentUser.Handle= ThisObject.Roles("ROLE_EDIT_ATTR").User.handle _
'            or (ThisApplication.CurrentUser.Sysname="SYSADMIN") then
'         
'            'открываем доступ к редактированию метки
'            
'            if not dict2.exists("MARKCOR") then 
'              dict2.add "MARKCOR",1
'            else
'             dict2.item("MARKCOR")=1
'            end if
'            
'            set q= Thisapplication.Queries("QUERY_MARKS_UNIQ")
'            q.Parameter("PARAM0")=ThisObject.Description
'            set marks=q.Objects
'            
'            Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg
'            CreateObjDlg.Object = ThisObject
'            CreateObjDlg.ActiveForm = thisApplication.InputForms("FORM_NEWMARK")
'            'ThisObject.Update
'            CreateObjDlg.Show
'            
'            
'            'если есть признак необхожимости корректровки, т е было нажато ОК
'            Set Dict3 = ThisApplication.Dictionary("MARK3")
'            if dict3.exists("MARKCORRALL") then 
'               If  dict3.Item("MARKCORRALL")=1 then
'                  answer = MsgBox("Сделать тип метки одинаковым для всех?", vbQuestion + vbYesNo)
'                  ThisObject.Update
'                  For each mark in marks
'                     If  mark.Roles.Has("ROLE_EDIT_ATTR") Then
'                         If ThisApplication.CurrentUser.Handle= mark.Roles("ROLE_EDIT_ATTR").User.handle _
'                            or (ThisApplication.CurrentUser.Sysname="SYSADMIN") then
'                             mark.Permissions = SysAdminPermissions
'                             mark.Attributes("ATTR_MARK_NAME").value= ThisObject.Description
'                             If answer = vbYes Then  
'                                mark.Attributes("ATTR_MARK_TYPE").Value=ThisObject.Attributes("ATTR_MARK_TYPE").Value
'                             end if
'                         end if    
'                     end if   
'                   
'                   Next

'               end if
'            end if      
'                  
'            
'            
'               
'         else
'         msgbox "Нет прав для редактирования"
'         'exit sub
'         end if
'else
'msgbox "Нет прав для редактирования"
''exit sub
'dict3.removeall
'end if         
'          


 

