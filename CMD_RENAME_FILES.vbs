
Sub Object_BeforeModify(Obj, Cancel)
  ' Case 560
  If CheckAttrChange (Obj, "ATTR_DOC_CODE") Then ' Требуется переименование файлов
    Set oOld = ThisApplication.GetObjectByGUID(Obj.GUID)
    sOldCode = oOld.Attributes("ATTR_DOC_CODE").Value
    sNewCode = Obj.Attributes("ATTR_DOC_CODE").Value
    Set fToRename = GetFileByName(Obj.Files, sOldCode)
    While Not fToRename Is Nothing
    ' Перименование файла с именем = описанию
      If Not fToRename Is Nothing Then _
        fToRename.FileName = Replace(fToRename.FileName, sOldCode, sNewCode)
      Set fToRename = GetFileByName(Obj.Files, sOldCode)
    Wend
    ' Переименование файлов с типом "Электронный Скан документа" и наименованием {имя файла}###.pdf
    sScanName = sOldCode + "###"
    Set fToRename = GetFileByName(Obj.Files.FilesByDef("FILE_E-THE_ORIGINAL"), sScanName)
    If Not fToRename Is Nothing Then _
      fToRename.FileName = Replace(fToRename.FileName, sOldCode, sNewCode)
    Set fToRename = GetFileByName(Obj.Files.FilesByDef("FILE_KD_EL_SCAN_DOC"), sScanName)
    If Not fToRename Is Nothing Then _
      fToRename.FileName = Replace(fToRename.FileName, sOldCode, sNewCode)
  End If
End Sub

' Case 560 Проверка атрибута на изменение
Function CheckAttrChange(Obj, sAttDefName)
CheckAttrChange = False
  If Obj Is Nothing Then Exit Function
  If Obj.Attributes.Has(sAttDefName) = False Then Exit Function
  sNewValue = Obj.Attributes(sAttDefName).Value
  ' Проверка что объект уже создан
  Set oOld = ThisApplication.GetObjectByGUID(Obj.GUID)
  If oOld Is Nothing Then Exit Function
  If oOld.Attributes.Has(sAttDefName) = False Then Exit Function
  sOldValue = oOld.Attributes(sAttDefName).Value
  ' Проверка на изменение атрибута
  CheckAttrChange = sNewValue <> sOldValue
End Function

' Case 560 Поиск файла по имени
Function GetFileByName(oFiles, sName)
  Set GetFileByName = Nothing
  For Each f In oFiles
    sFileName = f.FileName
    iRev = InStrRev(sFileName, ".") -1
    sFileName = mid(sFileName, 1,iRev)
    If sFileName = sName Then
      Set GetFileByName = f
      Exit Function
    End If
  Next
End Function
