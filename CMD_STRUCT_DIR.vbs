' Автор: Стромков С.А.
'
' Команда позволяет создать элемент структуры проекта, если он отсутствует или был удален по какой-то причине
' Объект структуры - объект, входящий в состав объекта Проект в единственном экземпляре
'------------------------------------------------------------------------------------------------------
' Авторское право © ЗАО «СиСофт», 2016

Dim o
Set o=ThisObject
Call Main (o)

Sub Main(o_)
  Dim sObjDefs,oDef,o
  Dim SelDlg,RetVal
  Dim InArray,SelectedArray
  
  Set sObjDefs=o_.ObjectDef.ObjectDefs
  
  ' Подготавливаем массив типов объектов для диалога
  InArray = InCollPrepare(o_,sObjDefs)
  
  ' Если ничего не выбрано или нет типов объектов
  If sObjDefs.Count=0 Or Ubound(InArray)=0 Then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", VbExclamation, 1253
    Exit Sub
  End If
         
  'Открыть диалог, передав на вход массив строк
  Set SelDlg = ThisApplication.Dialogs.SelectDlg
  SelDlg.UseCheckBoxes=True
  SelDlg.SelectFrom = InArray
  SelDlg.Caption = "Наименования типов объектов"
  SelDlg.Prompt = "Выберите объекты структуры:"
  RetVal = SelDlg.Show

  If (RetVal <> True) Then Exit Sub

  SelectedArray = SelDlg.Objects
                
  For Each oDef in SelDlg.Objects
  If  not ThisApplication.ObjectDefs.Index(oDef)=-1 Then
    If o_.Objects.ObjectsByDef(oDef).count=0 Then 
      Set o = ThisApplication.ExecuteScript("CMD_S_DLL", "CreateObj", oDef,o_,False)
    End If
  End If
  Next
End Sub

'==============================================================================
' Добавляет в массив типы объектов, которые отсутствуют в проекте
'------------------------------------------------------------------------------
' o_:TDMSObject - Объект
' odsProject_:TDMSObjectDefs - Коллекция типов объектов, входящих в состав объекта 
'
' InCollPrepare:Array - Массив тпов объектов
'==============================================================================

Private Function InCollPrepare(o_,odsProject_)
  Dim sObjDef
  Dim arr
  Redim arr(0)
  Set InCollPrepare=Nothing
  For Each sObjDef in odsProject_
    If o_.Objects.ObjectsByDef(sObjDef).count=0 Then 
      Redim Preserve arr (Ubound(arr)+1)
      Set arr(Ubound(arr))=sObjDef
    End If
  Next
  InCollPrepare=arr
End Function

