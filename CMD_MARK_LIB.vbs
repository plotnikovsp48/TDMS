
'=============================================
sub CreateMark(MarkDescription,Object, ifAsk)
'Создаем новую метку

 ThisScript.SysAdminModeOn
 Set Dict = ThisApplication.Dictionary("MARK") 
 if not dict.exists("NEWMARK") then 
    dict.add "NEWMARK",1
 else
    dict.item("NEWMARK") = 1
 end if
 mark_type = ThisApplication.Classifiers("NODE_MARK_TYPE").Classifiers._
         Item("NODE_MARK_TYPE_PRIVAT").Description
  if  not ifAsk then 
  ' проверяем, что уже есть
   If IsMarkInObject (MarkDescription,mark_type ,Object,0) then
        'эNewMark.Erase 
        'call dellMark(Object, MarkDescription) ' если уже есть зачем добавлять
        exit sub
   end if       
 end if      

 set ObjRoots = thisapplication.GetObjectByGUID(thisapplication.Attributes("ATTR_MARK_FOLDER_ROOT").Value)
 if ObjRoots is nothing then 
    msgbox "Не найдена папка для меток", vbCritical, "Ошибка"
    exit sub
 end if
 ObjRoots.Permissions =  SysAdminPermissions
 Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg
 set FormObjDef = ThisApplication.ObjectDefs("OBJECT_MARK")
 Set NewMark = ObjRoots.Objects.Create(FormObjDef)
 NewMark.Attributes("ATTR_MARK_NAME").Value = MarkDescription
 CreateObjDlg.Object = NewMark
 set us = ThisApplication.CurrentUser
' set dept=us.Attributes("ATTR_USER_DEPT").Object
 NewMark.Attributes("ATTR_MARK_USER").Value = us
' NewMark.Attributes("ATTR_MARK_DEPT").Value = dept
 NewMark.Attributes("ATTR_MARK_TODOC").Value = Object
 NewMark.Attributes("ATTR_MARK_TYPE").Value = ThisApplication.Classifiers("NODE_MARK_TYPE").Classifiers._
         Item("NODE_MARK_TYPE_PRIVAT").Description

 CreateObjDlg.ActiveForm = thisApplication.InputForms("FORM_NEWMARK")

 if  ifAsk then 
    if not CreateObjDlg.Show then _
       exit sub
' else
'  ' проверяем, что уже есть
'   If IsMarkInObject (MarkDescription,NewMark.Attributes("ATTR_MARK_TYPE").Value ,Object,NewMark.Handle) then
'        NewMark.Erase ' т.к апдейта нет, то не добавляется
'        'msgbox "Метка " & MarkName & " уже существует в документе " & Object.Description, vbInformation
'        exit sub
'   end if       
 end if      
 NewMark.Update

 ThisScript.SysAdminModeOff

End Sub

'=============================================
function IsMarkInObject(MarkName,TypeMark,Object,MarkHandle)
  'Проверяем есть ли в объекте метки с такими же параметрами или есть ли метка с таким же handle
  IsMarkInObject = false          
  Thisscript.SysAdminModeOn
  set q = Thisapplication.Queries("QUERY_IS_MARK_INOBJ")
  q.Parameter("PARAM0") = MarkName
  q.Parameter("PARAM1") = TypeMark
  q.Parameter("PARAM2") = Object
  q.Parameter("PARAM3") = thisApplication.CurrentUser
  set objs = q.Objects
  If objs.Count = 1 then
    If  MarkHandle <> objs(0).Handle then IsMarkInObject = true ' если это она же и только одна, то больше нет
  elseIf objs.Count > 1 then IsMarkInObject = true
  end if              
  Thisscript.SysAdminModeOff
end function

'=============================================
Sub SetIconMark(Obj,imgName)
  Obj.Permissions = SysAdminPermissions ' задаем права 
  if ThisApplication.Icons.Has(imgName) then
    if not imgName = Obj.Icon.SysName then
      Obj.Icon = ThisApplication.Icons(imgName)
    end if
  end if
end sub


'=============================================
' заменяем ненужные символы
sub ReplaceStr(Str)
  a="  "
  stra=" "
  'b=";"
  'strb=","
  'c="-"
  'strc=" "
  'd="\"
  'strd=" "
  'e="|"
  'stre=" "
  'f="/"
  'strf=" "
  Str=Trim(LCase(Str))
  For i=0 to 5
      Str=Replace(Str,a,stra)
      Str=Replace(Str,a,stra)' чтобы убрать 4 пробела
    '  Str=Replace(Str,b,strb)
    '  Str=Replace(Str,c,strc)
    '  Str=Replace(Str,d,strd)
    '  Str=Replace(Str,e,stre)
    '  Str=Replace(Str,f,strf)
  next
end sub
'=============================================
sub dellMark(obj, descr)
  thisScript.SysAdminModeOn
  set query = thisApplication.Queries("QUERY_OBJ_MARK")
  query.Parameter("PARAM0") = obj.handle
  set objs = query.Objects
  if objs.Count > 0 then 
    for each teg in objs 
      if teg.Attributes("ATTR_MARK_NAME").value = descr then teg.Erase
    next
  end if
end sub

'=============================================
function HasMark(docObj, MarkDesc)
  HasMark = false
  Thisscript.SysAdminModeOn
  set q = Thisapplication.Queries("QUERY_CHECK_MARK")
  q.Parameter("PARAM0") = MarkDesc
  q.Parameter("PARAM2") = docObj.handle
  q.Parameter("PARAM3") = thisApplication.CurrentUser
  set objs = q.Objects
  If objs.Count <> 0 then
    HasMark = true
  end if              
  Thisscript.SysAdminModeOff

'  'thisscript.SysAdminModeOn
'  HasMark = false 
'  for each mark in  docObj.ReferencedBy 
'    if mark.Permissions.View <> 0 then 
'     ' mark.Permissions = sysAdminPermissions
'      if mark.Description = MarkDesc then 
'          HasMark = true
'          exit function
'      end if 
'    end if    
'  next 
end function
