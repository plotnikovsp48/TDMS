use CMD_KD_SET_PERMISSIONS

'==============================================================================
'EV папка для документов
function GET_FOLDER(year_my, objType)

    set GET_FOLDER = nothing
    thisscript.SysAdminModeOn

    if objType is nothing then exit function
    if objType.SuperObjectDefs.Has("OBJECT_KD_ORDER") then set objType = thisApplication.ObjectDefs("OBJECT_KD_ORDER")
    attrName = "ATTR_FOLDER_" & objType.SysName
    if not thisApplication.Attributes.Has(attrName) then exit function
    folder_Guid = thisApplication.Attributes(attrName).Value
    set folder_Obj =  thisApplication.GetObjectByGUID(folder_Guid)
    if folder_Obj is nothing then exit function
    
    'set root1 = folder_Obj.Objects.ObjectsByDef("OBJECT_KD_FOLDER")
   
    if year_my = "" then
        year_my = Date
        year_my = Cstr(Year(year_my))    
    end if
   
    if folder_Obj.Objects.Has(year_my) then
         set GET_FOLDER = folder_Obj.Objects(year_my)
    else
         set GET_FOLDER = CreateFolderYear(folder_Obj, year_my)
    end if
    

end function
'==============================================================================
function CreateFolderYear(folder_Obj, year_my)
  thisscript.SysAdminModeOn
  set CreateFolderYear = nothing
  set new_year = folder_Obj.Objects.Create("OBJECT_KD_FOLDER")
  new_year.Attributes("ATTR_FOLDER_NAME").Value = year_my
  new_year.Update
  Set_Permission (new_year)
  set CreateFolderYear = new_year
end function
'==============================================================================
' EV папка для поручений
function GET_FOLDER_OFFER(year_my)
    set GET_FOLDER_OFFER = GET_FOLDER(year_my, thisApplication.ObjectDefs("OBJECT_KD_ORDER"))
end function
