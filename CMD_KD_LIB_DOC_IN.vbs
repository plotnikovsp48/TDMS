use CMD_KD_FILE_LIB
use CMD_KD_CURUSER_LIB

'=============================================
'Function LoadFileToDoc(FileDef)
'  ThisScript.SysAdminModeOn
'  Set SelFileDlg = ThisApplication.Dialogs.FileDlg
'  If FileDef = "FILE_KD_RESOLUTION" or FileDef = "FILE_KD_SCAN_DOC" Then _
'     SelFileDlg.Filter = "Документ PDF (*.pdf)|*.pdf||"  
'  SelFileDlg.InitialDirectory  = path 'директория по умолчанию???????
'  If SelFileDlg.Show <> TRUE Then Exit Function
'  FileNames = SelFileDlg.FileNames
'  if Ubound(SelFileDlg.FileNames)>0 then
'    msgbox "Можно приложить только ОДИН файл!", vbOKOnly + vbExclamation
'    exit Function
'  end if
'  FileName = FileNames(0)
'  set FSO = CreateObject("Scripting.FileSystemObject")
'  FileNm = FSO.GetFileName(FileName)
'  Set Files = ThisObject.Files
'  For each File in Files
'      If File.FileName = FileNm Then
'         msgbox "Файл "&FileNm&"("&File.FileDef.description&")"&" уже загружен в документ "&ThisObject.Description
'         Exit Function
'      End if
'  Next
'  
' Set NewFile = ThisObject.Files.Create(FileDef)
' NewFile.CheckIn FileName
' If FileDef = "FILE_KD_SCAN_DOC" Then _
' ThisObject.Files.Main = NewFile 'если скан документ
' ThisObject.Update
'End Function


'=============================================
Sub AddFilesToDoc(FilePath)
    if not isSecretary( GetCurUser()) then exit sub ' EV только секретарь может добавлять файлы
    ThisScript.SysAdminModeOn
    mas = array("Скан документа","Приложение")    
    'статус Черновик резолюция не прикладывается
    If ThisObject.Status.SysName = "STATUS_KD_REGISTERED" Then 
       Set SelectClassifDlg = ThisApplication.Dialogs.SelectClassifierDlg
       SelectClassifDlg.Root = ThisApplication.Classifiers("NODE_KD_TYPE_FILES_DOC")
       SelectClassifDlg.Caption = "Выбор типа файла:"
       RetVal = SelectClassifDlg.Show
       if not RetVal then exit sub
       
       TypeFl = SelectClassifDlg.Classifier.SysName
       TypeFl = Replace(TypeFl,"NODE","FILE")

    Else   
       Set SelDlg = ThisApplication.Dialogs.SelectDlg
       SelDlg.Caption = "Выбор типа файла:"
       SelDlg.SelectFrom = mas
       RetVal = SelDlg.Show
       if not RetVal then exit sub
       SelectedArray = SelDlg.Objects
       if Ubound(SelectedArray)<0  then exit sub
       set clTypeFl = thisApplication.Classifiers.Find(SelectedArray(0))
       if clTypeFl is nothing then exit sub
       TypeFl = clTypeFl.SysName
       TypeFl = Replace(TypeFl,"NODE","FILE")
    End if   
    If RetVal Then
       Set Files = ThisObject.Files
       If not (TypeFl = "FILE_KD_ANNEX") Then
          For each File in  Files
             If File.FileDefName = TypeFl Then 
                msg = msgbox("Документ уже содержит файл такого типа, перезаписать ?", vbExclamation + vbYesNo)
                If msg = vbYesNo Then 
                   Exit Sub 
                Else 
                   File.Erase   
                   ThisObject.Update
                End if   
             End if   
          Next 
          
       End if
       if FilePath >"" then 
         call LoadFileByObj(TypeFl, FilePath, true, thisObject)
       else
         LoadFileToDoc(TypeFl)
       end if
'       If TypeFl = "FILE_KD_RESOLUTION" Then 'создание поручения по резолюции 'EV перенесено в загрузку файла
'          call CreateOrders(nothing,ThisObject)      
'       End if
    End If
End Sub

''=============================================
'Function CreateOrder(Objecr)
'   YearTek = Year(date())
'   Set Obj = ThisApplication.Root.Objects("Делопроизводство")
'   Set Obj = Obj.Objects("Поручения")
'   'Set YearObj = Obj.Objects(YearTek)
'   If not Obj.objects.has(YearTek) Then
'      Set YearObj = Obj.Objects.Create(ThisApplication.ObjectDefs("OBJECT_KD_FOLDER")) 
'      YearObj.Attributes("ATTR_FOLDER_NAME") = YearTek
'   Else
'      Set YearObj = Obj.Objects(YearTek)
'   End if   
'   Set CreateOrd = ThisApplication.Dialogs.CreateObjectDlg
'   CreateOrd.ParentObject = YearObj
'   CreateOrd.ObjectDef = "OBJECT_KD_ORDER_REP"
'   CreateOrd.ActiveForm = ThisApplication.InputForms("FORM_KD_ODER")
'   CreateOrd.Show
'End Function

'=============================================
function Check_Fields()
'проверка на заполнение полей
    mes = ""
    If ThisForm.Attributes("ATTR_KD_VD_INСNUM").Value = "" Then _
       mes = mes & "Регистрация документа невозможна, не заполнено поле "&chr(34)&"Исходящий номер ВД"&chr(34) & vbNewLine
    If ThisForm.Attributes("ATTR_KD_VD_SENDDATE").Value = "" Then _
       mes = mes & "Регистрация документа невозможна, не заполнено поле "&chr(34)&"Дата отправки ВД"&chr(34)& vbNewLine
    If ThisForm.Attributes("ATTR_KD_TOPIC").Value = "" Then _
       mes = mes & "Регистрация документа невозможна, не заполнено поле "&chr(34)&"Тема"&chr(34) & vbNewLine
    If ThisForm.Attributes("ATTR_KD_CPNAME").Value = "" Then _
       mes = mes & "Регистрация документа невозможна, не заполнено поле "&chr(34)&"Наименование Контрагента"&chr(34) & vbNewLine
    If ThisForm.Attributes("ATTR_KD_CPADRS").Value = "" Then _
       mes = mes & "Регистрация документа невозможна, не заполнено поле "&chr(34)&"Контактное лицо"&chr(34) & vbNewLine
    If ThisForm.Attributes("ATTR_KD_DEL").Value = "" Then _
       mes = mes & "Регистрация документа невозможна, не заполнено поле "&chr(34)&"Способ доставки"&chr(34) & vbNewLine
'    If ThisForm.Attributes("ATTR_KD_QNT").Value = 0 Then _
'       mes = mes & "Регистрация документа невозможна, не заполнено поле "&chr(34)&"Количество листов документа"&chr(34) & vbNewLine
   check_Fields = mes  
end function

'=============================================
sub Set_Doc_Ready(docObj)
  ' проверяем есть скан
  set file = GetFileByType("FILE_KD_SCAN_DOC")
  if file is nothing then 
    msgBox "Невозможно отметить, что документ рассмотрен руководством, т.к. не приложен скан документа!", vbCritical
    exit sub
  end if
  ' проверяем есть резолюция
  set file = GetFileByType("FILE_KD_RESOLUTION")
  if file is nothing then 
    ans = msgBox("К документу не приложена резолюция! Вы уверены, что хотите продолжить?",_
         vbCritical + vbYesNo, "К документу не приложена резолюция!")
    if ans <> vbYes then exit sub
  end if

  ' меняем статус
  docObj.Permissions = sysAdminPermissions
  docObj.Status = thisApplication.Statuses("STATUS_KD_VIEWED_RUK")
  docObj.Update
  msgBox "Документ рассмотрен руководством", vbInformation  

end sub


