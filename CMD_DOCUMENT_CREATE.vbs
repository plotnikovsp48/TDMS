' Автор: Стромков С.А.
'
' Создает документ
'------------------------------------------------------------------------------
' Авторское право © ЗАО «СИСОФТ», 2016 г.

Call CreateDoc(ThisObject)

Function CreateDoc(Obj)
  Set CreateDoc = Nothing
  
  If Obj.Permissions.EditContent <> 1 Then 
    'msgbox "У вас недостаточно прав на создание документа", vbCritical
    'Exit Function
  End If
  Select case Obj.ObjectDefName
    Case "OBJECT_FOLDER"
      Set CreateDoc = CreateDocInFolder(Obj)
    Case "OBJECT_BOD"
      Set CreateDoc = CreateDocBOD(Obj)
    Case Else
      Set CreateDoc = CreateDocGEN(Obj)
  End Select
End Function

Function CreateDocInFolder(Obj)
  Set CreateDocInFolder = Nothing
  Select Case Obj.Attributes("ATTR_FOLDER_TYPE").Classifier.SysName
    Case "NODE_FOLDER_AUTH-SUPERVISION"
      Set CreateDocInFolder = CreateDocAN(Obj)
    Case "NODE_FOLDER_GENERAL","NODE_FOLDER_BOD","NODE_FOLDER_PEMC","NODE_FOLDER_ARCHIVE"
      Set CreateDocInFolder =  CreateDocGEN(Obj)
    Case Else 
      Set CreateDocInFolder =  CreateDocGEN(Obj)
  End Select
End Function

Function CreateDocBOD(Obj)
  Set CreateDocBOD = CreateDocGEN(Obj)
End Function

Function CreateDocGEN(Root)
  set objType = thisApplication.ObjectDefs("OBJECT_DOCUMENT")
  Set CreateDocGEN = CreateDocByType(Root,objType)
End Function

Function CreateDocAN(Root)
  If Root.Attributes("ATTR_FOLDER_NAME").Value = "Документы АН" Then
    set objType = thisApplication.ObjectDefs("OBJECT_DOCUMENT_AN")
    Set CreateDocAN = CreateDocByType(Root,objType)
  ElseIf Root.Attributes("ATTR_FOLDER_NAME").Value = "Журналы АН" Then
    set objType = thisApplication.ObjectDefs("OBJECT_LIST_AN")
    Set CreateDocAN = CreateDocByType(Root,objType)
  Else
    arr = Array("Документ АН","Журнал АН")
    Set objType = SelectDocTypeByList(arr)
    If objType Is Nothing Then Exit Function
    
    If objType.SysName = "OBJECT_LIST_AN" Then
      Set tmpRoot = Root.Objects("Журналы АН")
    ElseIf objType.SysName = "OBJECT_DOCUMENT_AN" Then
      Set tmpRoot = Root.Objects("Документы АН")
    End If
    If Not tmpRoot Is Nothing Then Set Root = tmpRoot
    
    Set CreateDocAN = CreateDocByType(Root,objType)
  End If
End Function

function SelectDocTypeByList(DocTypesArray)
  Set SelectDocTypeByList = Nothing
   Set SelDlg = ThisApplication.Dialogs.SelectDlg
    SelDlg.SelectFrom = DocTypesArray
    SelDlg.Caption = "Выбор типа документа"
    SelDlg.Prompt = "Выберите тип документа:"
    
    RetVal = SelDlg.Show
      
    'Если пользователь отменил диалог или ничего не выбрал, закончить работу.
    If ( (RetVal <> TRUE) or (UBound(SelDlg.Objects)<0) ) Then  
      exit function
    end if
   
    SelectedArray = SelDlg.Objects  
    if SelectedArray(0) = "" then exit function
    
    set SelectDocTypeByList = thisApplication.ObjectDefs(SelectedArray(0))
End Function

Function CreateDocByType(Root,oDef)
  Set CreateDocByType = Nothing
  Set CreateDocByType =  ThisApplication.ExecuteScript("CMD_DLL", "Create",oDef.SysName,Root)
  'If oDoc Is Nothing Then Exit Sub
  
'  If ThisApplication.Attributes("ATTR_SORT_AUTO") = True Then 
'    If oDoc.Parent Is Nothing Then
'      Exit Sub
'    Else
'      Set p = oDoc.Parent
'    End If
'    ThisApplication.ExecuteCommand "CMD_SORT",p
'  End If  

End Function
