
Sub Query_AfterExecute(Sheet, Query, Obj)
dim clsf, obbbCls, fullPath, parentCl ', cuser 
 RCount = Sheet.RowsCount
'sheet.AddColumn
 sheet.ColumnName(2) = "Оргструктура полный путь"
  
    For i=0 To RCount-1 
      sUser = sheet.CellValue(i, 0)
          Set AllUsers = ThisApplication.Users ' Получить коллекцию пользователей
         ' set cuser= ThisApplication.Users(sUser)
          'msgbox cuser.Description
          For Each user In AllUsers
              fullPath=""
              obbbCls= empty
               if  user.Description = sUser  then       'Краткое описание             
                 if  user.Attributes.has("ATTR_KD_USER_DEPT") then
                    fullPath = user.Attributes("ATTR_KD_USER_DEPT").value
                    set obbbCls = User.Attributes("ATTR_KD_USER_DEPT").Object  ' это объект ветки классификатора
                    if not obbbCls is Nothing then
                      
                      While obbbCls.guid <>"{4E01EB03-F956-4D48-A221-1C3ADB8C1EA4}"
                        set parentCl = obbbCls.Parent
                        if   parentCl.guid <>"{4E01EB03-F956-4D48-A221-1C3ADB8C1EA4}"     then
                          fullPath= parentCl.Description & "\" &fullPath
                        end if
                        set obbbCls = parentCl
                      Wend
                    end if
                   '  msgbox fullPath
                     sheet.CellValue(i,2) = fullPath
                      
                 end if
                str = ""
              end if
          Next
    
    Next         
   
End Sub
