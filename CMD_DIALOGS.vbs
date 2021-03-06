' $Workfile: COMMAND.SCRIPT.CMD_DIALOGS.scr $ 
' $Date: 29.09.08 12:37 $ 
' $Revision: 3 $ 
' $Author: Oreshkin $ 
'
' Модуль диалогов
'------------------------------------------------------------------------------
' Авторское право © ЗАО «НАНОСОФТ», 2008 г.


'==============================================================================
' Функция предоставляет диалог выбора файла в зависимости от получаемого 
' типу файла
'------------------------------------------------------------------------------
' ВОЗВРАЩАЕТ:
'   SelectFileDlg:String - Полное имя файла
'==============================================================================
Function SelectFileDlg(FileType)
  SelectFileDlg = " "
  Set FileDef = ThisApplication.FileDefs(FileType)
  If Not FileDef Is Nothing Then
    Set SelFileDlg = ThisApplication.Dialogs.FileDlg
    SelFileDlg.Filter = FileDef.Description & " (" & FileDef.Extensions & ")|" & replace(FileDef.Extensions,",",";") & "||"
    If SelFileDlg.Show Then 
      SelectFileDlg = SelFileDlg.FileName
    End If
  End If
End Function

'==============================================================================
' Функция предоставляет диалог формы
'------------------------------------------------------------------------------
' ВОЗВРАЩАЕТ:
'==============================================================================
Function FormDlg(Form, Attr)
  FormDlg = " "
  Set FDlg = ThisApplication.InputForms(Form)
  If FDlg.Show Then 
    If FDlg.Attributes(Attr) <> "" Then
      FormDlg = FDlg.Attributes(Attr)
    End If
  End If
End Function

'==============================================================================
' Функция предоставляет диалог выбора пользователя
'------------------------------------------------------------------------------
' ВОЗВРАЩАЕТ:
'   SelectUsersDlg:TDMSUsers - Выбранные пользователи
'==============================================================================
Function SelectUsersDlg()
  Set SelectUsersDlg = Nothing
  Set SelUser = ThisApplication.Dialogs.SelectUserDlg
  While SelUser.Show 
    If  SelUser.Users.Count <> 0 Then
      Set SelectUsersDlg = SelUser.Users(0)
      Exit Function
    Else
      ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1110
    End If  
  Wend
End Function

'==============================================================================
' Функция предоставляет диалог выбора объекта
'------------------------------------------------------------------------------
' ВОЗВРАЩАЕТ:
'   SelectObjectDlg:TDMSUsers - Выбранные объекты
'==============================================================================
Function SelectObjectDlg(ObjDef)
  Set SelectObjectDlg = Nothing
  Set SelObject = ThisApplication.Dialogs.SelectObjectDlg
  SelObject.ObjectDef = ObjDef
  While SelObject.Show 
    If  SelObject.Objects.Count > 0 Then
      Set SelectObjectDlg = SelObject.Objects
      Exit Function
    Else
      ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1107
    End If  
  Wend
End Function

'==============================================================================
' Функция предоставляет диалог выбора пользователей назначенных на определенную
' роль или диалог выбора объектов определенного типа
'------------------------------------------------------------------------------
' ПРИНИМАЕТ:
'   Flag:String =   "OBJ" - диалог выбора объектов
'                       "USER" - диалог выбора пользователей
'                       "GROUP" - диалог выбора пользователей  из группы
'   Obj:TDMSObject - Объект TDMS (для "GROUP" Nothing)
'   Def:String - Системный идентификатор роли,объекта или группы
'
' ВОЗВРАЩАЕТ:
'   SelectDialog:String -   Строку Handles выбранных объектов или пользователей
'   разделенную символом chr(1)   
'==============================================================================
Function SelectDialog(Flag,Obj,Def)
  Dim Arr
  SelectDialog = " "
  Set SelDlg = ThisApplication.Dialogs.SelectDlg
  Select Case Flag
    Case "OBJ"
      Arr = CreateObjArray(Obj,Def)
    Case "USER" 
      Arr = CreateUserArray(Obj,Def)
    Case "GROUP"  
      Set Arr = ThisApplication.Groups(Def).Users
    Case "QUERY"  
      Set Arr = ThisApplication.Queries(Def).Sheet.Objects
    Case "NODE"  
      Set Arr = ThisApplication.Classifiers(Def).Classifiers
  End Select
  SelDlg.SelectFrom = Arr
  If SelDlg.Show Then 
    SelectDialog = JoinHandles(SelDlg.Objects,Flag)
  End If
End Function

'==============================================================================
' Функция возвращает массив объектов определенного типа
'------------------------------------------------------------------------------
' ПРИНИМАЕТ:
'   Obj:TDMSObject - Объект TDMS
'   ObjDef:String - Системный идентификатор объекта
'
' ВОЗВРАЩАЕТ:
'   CreateObjArray:Variant()- Массив объектов TDMSObject
'==============================================================================
Private Function CreateObjArray(Obj,ObjDef)
  Dim Objects()
  count = 0
  CreateObjArray = ""
  For Each TObj In Obj.Objects.ObjectsByDef(ObjDef)
    count = count + 1
    ReDim Preserve Objects(count)
    Set Objects(count-1) = TObj 
    CreateObjArray = Objects
  Next
End Function

'==============================================================================
' Функция возвращает массив пользователей назначенных на определенную роль 
'------------------------------------------------------------------------------
' ПРИНИМАЕТ:
'   Obj:TDMSObject - Объект TDMS
'   RoleDef:String - Системный идентификатор Роли
'
' ВОЗВРАЩАЕТ:
'   CreateUserArray:Variant()- Массив пользователей TDMSUser
'==============================================================================
Private Function CreateUserArray(Obj,RoleDef)
  Dim Users()
  count = 0
  CreateUserArray = ""
  For Each TRole In Obj.Roles
    If TRole.RoleDefName = RoleDef Then
      count = count + 1
      ReDim Preserve Users(count)
      Set Users(count-1) = TRole.User 
      CreateUserArray = Users
    End If
  Next
End Function

'==============================================================================
' Функция возвращает строку объединенных Handles Объектов(Ролей) с 
' разделителем chr(1)
'------------------------------------------------------------------------------
' ПРИНИМАЕТ:
'   Objects:Variant() - Массив объектов или пользователей
'   Flag:String =   "OBJ" - диалог выбора объектов
'                     "USER" - диалог выбора пользователей
'
' ВОЗВРАЩАЕТ:
'   JoinHandles:String -  Строку Handles выбранных объектов или пользователей
'   разделенную символом chr(1)   
'==============================================================================
Private Function JoinHandles(Objects, Flag)
  JoinHandles = " "
  If vartype(Objects)= 8204 Then
    If UBound(Objects,1) = -1 Then Exit Function
  End If
  For Each Object In Objects
    Select Case Flag
    
      Case "OBJ", "QUERY" 
        If JoinHandles = " " Then
          JoinHandles = Object.Handle
        Else
          JoinHandles = JoinHandles & chr(1) & Object.Handle
        End If      
        
      Case "USER", "GROUP"
        If JoinHandles = " " Then
          JoinHandles = Object.SysName
        Else
          JoinHandles = JoinHandles & chr(1) & Object.SysName
        End If    
      Case "NODE"
        If JoinHandles = " " Then
          JoinHandles = Object.SysName
        Else
          JoinHandles = JoinHandles & "," & Object.SysName
        End If    
        
    End Select        
  Next
End Function

Function EditDlg(Caption,Prompt)
  EditDlg = Chr(1)
  Set SelectNum = ThisApplication.Dialogs.SimpleEditDlg
  SelectNum.Caption = Caption
  SelectNum.Prompt = Prompt
  If  SelectNum.Show Then
    If Trim(SelectNum.Text) <> "" Then
      EditDlg = Trim(SelectNum.Text)
    End If
  End If
End Function


Function EditObjectDlg(ObjDef)
  Set EditObjectDlg = Nothing
  Set Obj = ThisApplication.ObjectDefs(ObjDef).CreateObject
  Set EditObj = ThisApplication.Dialogs.EditObjectDlg
  EditObj.Object = Obj
  If EditObj.Show Then
    Set EditObjectDlg = Obj
  Else
    Obj.Erase
  End If  
End Function

'==============================================================================
' Функция предоставляет диалог выбора папки
'------------------------------------------------------------------------------
' ВОЗВРАЩАЕТ:
'==============================================================================
Private Function GetFolder()
  Const MY_COMPUTER = &H11&
  Const WINDOW_HANDLE = 0
  Const OPTIONS = 512
  objPath = " "
  Set objShell = CreateObject("Shell.Application")
  Set objFolder = objShell.Namespace(MY_COMPUTER)
  Set objFolderItem = objFolder.Self
'   strPath=ThisApplication.Attributes("ATTR_FOLDER_FOR_IMPORT")
  If strPath="" Then strPath = objFolderItem.Path
  Set objFolder = objShell.BrowseForFolder(WINDOW_HANDLE, "Select a folder:", OPTIONS, 0)'strPath)  
  If Not objFolder Is Nothing Then
     Set objFolderItem = objFolder.Self
      objPath = objFolderItem.Path  
  End If
  GetFolder = objPath
End Function


'==============================================================================
' Функция предоставляет диалог выбора системных элементов (типов объектов, статусов)
'------------------------------------------------------------------------------
' ПРИНИМАЕТ:
'   sysdefs_:Variant - Коллекция системных элементов
'
' ВОЗВРАЩАЕТ:
'   SysDlg:String - Описание выбранного элемента в формате <discription>#<sysname>
'==============================================================================
Function SysDlg(sysdefs_)
  dim arr()
  dim count
  dim dlg
  dim mark
  count = 0
  SysDlg = ""
  For Each e In sysdefs_
    mark = ""
    str = Empty
    If e.Comments.count>0 Then str = e.Comments(0).text
    If Not IsEmpty(str) Then 
      mark = Left(str,1)
    end if
    If mark = "#" Then
      count = count+1
      Redim Preserve arr(count)
      arr(count - 1) = e.Description & "#" & e.SysName
    End If
  Next
  If count=0 Then Exit Function
  set dlg = ThisApplication.Dialogs.SelectDlg
  dlg.SelectFrom = arr
  If Not dlg.Show Then Exit Function
  os = dlg.Objects
  SysDlg = os(0)
End Function


'==============================================================================
' Функция предоставляет диалог выбора пользователей
'------------------------------------------------------------------------------
' ВОЗВРАЩАЕТ:
'   SelectUsersDlg:TDMSUsers - Выбранные пользователи
'==============================================================================
Function SelectUsersFromCollDlg(coll_)
  Set SelectUsersFromCollDlg = Nothing
  If Coll_ Is Nothing Then exit Function
  
  Set SelUser = ThisApplication.Dialogs.SelectUserDlg
  SelUser.SelectFromUsers = coll_
  While SelUser.Show 
    If  SelUser.Users.Count <> 0 Then
      Set SelectUsersFromCollDlg = SelUser.Users
      Exit Function
    Else
      ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1110
    End If  
  Wend
End Function

'==============================================================================
' Функция предоставляет диалог выбора пользователя
'------------------------------------------------------------------------------
' ВОЗВРАЩАЕТ:
'   SelectUsersDlg:TDMSUsers - Выбранные пользователи
'==============================================================================
Function SelectUserFromCollDlg(coll_)
  Set SelectUserFromCollDlg = Nothing
  If Coll_ Is Nothing Then exit Function
  
  Set SelUser = ThisApplication.Dialogs.SelectUserDlg
  SelUser.SelectFromUsers = coll_
  While SelUser.Show 
    If  SelUser.Users.Count <> 0 Then
      Set SelectUserFromCollDlg = SelUser.Users(0)
      Exit Function
    Else
      ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1110
    End If  
  Wend
End Function
