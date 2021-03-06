
Extern Mycompany [Alias ("Организация"), HelpString ("Наименование организации, составившей документ")]
Function Mycompany(Obj)
ThisScript.SysAdminModeOn
  Mycompany = "" 
  Set comp = ThisApplication.Attributes("ATTR_MY_COMPANY").Object
  If comp Is Nothing Then Exit Function
  Mycompany= comp.Description
End Function

Extern Get_CERTIFICATE_SRO [Alias ("Свидетельство"), HelpString ("Сертификат")]
Function Get_CERTIFICATE_SRO(Obj)
ThisScript.SysAdminModeOn
  Get_CERTIFICATE_SRO = " " 
  txt = ThisApplication.Attributes("ATTR_CERTIFICATE_SRO").Value
  Get_CERTIFICATE_SRO = txt
End Function

Extern GetProjectName [Alias ("Наименование проекта"), HelpString ("Наименование проекта")]
Function GetProjectName(Obj) 
ThisScript.SysAdminModeOn
  GetProjectName = ""
  set proj = Obj.Attributes("ATTR_PROJECT").Object
  If proj Is Nothing Then Exit Function
  GetProjectName= proj.Attributes("ATTR_PROJECT_NAME")
End Function

Extern GetShortProjectName [Alias ("Краткое наименование проекта"), HelpString ("Краткое наименование проекта")]
Function GetShortProjectName(Obj) 
ThisScript.SysAdminModeOn
  GetShortProjectName = ""
  set proj = Obj.Attributes("ATTR_PROJECT").Object
  If proj Is Nothing Then Exit Function
  GetShortProjectName= proj.Attributes("ATTR_NAME_SHORT")
End Function

Extern GetProjectCode [Alias ("Шифр проекта"), HelpString ("Шифр проекта")]
Function GetProjectCode(Obj) 
ThisScript.SysAdminModeOn
  GetProjectCode = ""
  set proj = Obj.Attributes("ATTR_PROJECT").Object
  If proj Is Nothing Then Exit Function
  GetProjectCode= proj.Attributes("ATTR_PROJECT_CODE")
End Function

Extern StageCode [Alias ("Код стадии"), HelpString ("Код стадии проектирования")]
Function StageCode(Obj) 
ThisScript.SysAdminModeOn
  StageCode = ""
  set Stage = ThisApplication.ExecuteScript("CMD_S_DLL","GetStage",Obj)
  If Stage Is Nothing Then Exit Function
  StageCode= Stage.Attributes("ATTR_PROJECT_STAGE").Classifier.Code
End Function

Extern GetStageName [Alias ("Стадия проектирования"), HelpString ("Стадия проектирования")]
Function GetStageName(Obj) 
ThisScript.SysAdminModeOn
  GetStageName = ""
  txt = ""
  If Obj.ObjectDefName = "OBJECT_T_TASK" Then
    Set Table = Obj.Attributes("ATTR_T_TASK_PPLINKED")
    For Each Row In Table.Rows
      Set oDoc = Row.Attributes("ATTR_T_LINKEDOBJECT").Object
      If Not oDoc Is Nothing Then
        Set stage = oDoc.Attributes("ATTR_STAGE").Object
        If Not stage Is Nothing Then
          stagename = stage.Attributes("ATTR_PROJECT_STAGE").Classifier.Description
          If stagename <> "" Then
            If Trim(txt) = "" Then
              txt = stagename
            Else
              txt = txt &  Chr(13) & stagename
            End If
          End If
        End If
      End If
    Next
  Else
    set Stage = ThisApplication.ExecuteScript("CMD_S_DLL","GetStage",Obj)
    If Stage Is Nothing Then Exit Function
    txt = Stage.Attributes("ATTR_PROJECT_STAGE").Classifier.Description
  End If
  GetStageName = UCase(txt)
End Function

Extern GetDocCode [Alias ("Шифр документа"), HelpString ("Шифр документа (Шифр комплекта или тома)")]
Function GetDocCode(Obj) 
ThisScript.SysAdminModeOn
  GetDocCode = ""
  txt = ""
  Set p = Obj.Parent
  If p Is Nothing Then Exit Function
  
  Select Case p.ObjectDefName
  
  Case "OBJECT_VOLUME"
    If p.Attributes.Has("ATTR_VOLUME_CODE") Then
      txt = p.Attributes("ATTR_VOLUME_CODE").Value
    End If
  Case "OBJECT_WORK_DOCS_SET"
    If p.Attributes.Has("ATTR_WORK_DOCS_SET_CODE") Then
      txt = p.Attributes("ATTR_WORK_DOCS_SET_CODE").Value
    End If
  End Select
  
  GetDocCode = txt
End Function

Extern GetTaskDeptTo [Alias ("Отделы-получатели"), HelpString ("Отделы-получатели")]
Function GetTaskDeptTo(Obj) 
ThisScript.SysAdminModeOn
  GetTaskDeptTo = ""
  txt = ""
  Set Table = Obj.Attributes("ATTR_T_TASK_TDEPTS_TBL")
  For Each Row In Table.Rows
    Set Dept = Row.Attributes("ATTR_T_TASK_DEPT").Object
    If Not Dept Is Nothing Then
      code = Trim(Dept.Attributes("ATTR_CODE").value)
      ' Если код у ЭО не задан, то берем описание ЭО
      If Trim(code) = "" Then _
        Code = Dept.Description
'      If code <> "" Then
        If Trim(txt) = "" Then
          txt = code
        Else
          txt = txt &  ", " & code
        End If
'      End If
    End If
  Next
  GetTaskDeptTo = txt
End Function

Extern GetTaskAttachment [Alias ("Приложения"), HelpString ("Приложения к заданию")]
Function GetTaskAttachment(Obj) 
ThisScript.SysAdminModeOn
  GetTaskAttachment = ""
' ------- CASE 5613 
  Dim aFiles() : iFilesCount = -1
  For Each f In Obj.Files.FilesByDef("FILE_KD_ANNEX")
    iFilesCount = iFilesCount + 1
    Redim Preserve aFiles(iFilesCount)
    sFileName = f.FileName
    iRev = InStrRev(sFileName, ".") -1
    aFiles(iFilesCount) = mid(sFileName, 1,iRev)
  Next
  If iFilesCount >= 0 Then GetTaskAttachment = Join (aFiles, Chr(13))
' ------- CASE 5613 
  txt = ""
  Set Table = Obj.Attributes("ATTR_DOCS_TLINKS")
  For Each Row In Table.Rows
    code = ""
    Set oDoc = Row.Attributes("ATTR_DOC_REF").Object
    If Not oDoc Is Nothing Then
    
      code = oDoc.Description
      If code <> "" Then
        If Trim(txt) = "" Then
          txt = code
        Else
          txt = txt &  Chr(13) & code
        End If
      End If
    End If
  Next
  GetTaskAttachment = GetTaskAttachment & Chr(13) & txt
End Function

Extern GetAgreeList [Alias ("На согласование в"), HelpString ("Отделы-согласователи")]
Function GetAgreeList(Obj) 
ThisScript.SysAdminModeOn
  GetAgreeList = ""
  txt = ""
  Set osAgree = Obj.ReferencedBy.ObjectsByDef("OBJECT_KD_AGREEMENT")
  
  If osAgree.Count=0 Then Exit Function
  Set oAgree =  osAgree.Item(0)
  
  Set Table = oAgree.Attributes("ATTR_KD_TAPRV")
  For Each Row In Table.Rows
    Set user = Row.Attributes("ATTR_KD_APRV").User
    If Not user Is Nothing Then
      Set Dept = user.Attributes("ATTR_KD_USER_DEPT").Object
      If Not Dept Is Nothing Then
        code = Trim(Dept.Attributes("ATTR_CODE").value)
        If code <> "" Then
          If Trim(txt) = "" Then
            txt = code
          Else
            txt = txt & ", " & code
          End If
        End If
      End If
    End If
  Next
  GetAgreeList = txt
End Function

Extern GetObjectDesc [Alias ("Наименование объекта"), HelpString ("Наименование объекта")]
Function GetObjectDesc(Obj) 
ThisScript.SysAdminModeOn
  GetObjectDesc = ""
  txt = ""
  Set p = Obj.Parent
  If p Is Nothing Then Exit Function
  
  Select Case p.ObjectDefName
    Case "OBJECT_VOLUME"
      If Obj.Attributes.Has("ATTR_UNIT") Then
        Set unit = Obj.Attributes("ATTR_UNIT").Object
        If Not Unit Is Nothing Then
          txt = unit.Attributes("ATTR_UNIT_NAME")
        End If
      End If
    Case "OBJECT_WORK_DOCS_SET"
      If p.Parent.Attributes.Has("ATTR_WORK_DOCS_FOR_BUILDING_NAME") Then
        txt = p.Parent.Attributes("ATTR_WORK_DOCS_FOR_BUILDING_NAME").Value
      End If
    Case "OBJECT_WORK_DOCS_FOR_BUILDING"
      If p.Attributes.Has("ATTR_WORK_DOCS_FOR_BUILDING_NAME") Then
        txt = p.Attributes("ATTR_WORK_DOCS_FOR_BUILDING_NAME").Value
      End If
  End Select
  
  GetObjectDesc = txt
End Function

Extern GetDocDevelopUser [Alias ("Разработал"), HelpString ("Разработал")]
Function GetDocDevelopUser(Obj) 
ThisScript.SysAdminModeOn
  GetDocDevelopUser = " "
  If Obj.Attributes.Has("ATTR_RESPONSIBLE") = False Then Exit Function
  Set user = Obj.Attributes("ATTR_RESPONSIBLE").User
  If user Is Nothing Then Exit Function
  txt = user.LastName
  GetDocDevelopUser = txt
End Function

Extern GetDevelopDate [Alias ("Дата разработки"), HelpString ("Дата разработки")]
Function GetDevelopDate(Obj)
ThisScript.SysAdminModeOn 
  GetDevelopDate = ""
  If Obj.Attributes.Has("ATTR_DEVELOP_DATE") = False Then Exit Function
  If Obj.Attributes("ATTR_DEVELOP_DATE") = vbNullString Then Exit Function
  data = FormatDateTime(Obj.Attributes("ATTR_DEVELOP_DATE").Value,vbShortDate)
  txt = Right(data,7)
  GetDevelopDate = txt
End Function

'==================================== NK====================================
Extern GetDocNKUser [Alias ("Нормоконтролер документа"), HelpString ("Нормоконтролер")]
Function GetDocNKUser(Obj) 
  txt = GetCheckListUser(Obj,"nk",1)
  GetDocNKUser = txt
End Function

Extern GetDocNKPost [Alias ("Должность нормоконтролера"), HelpString ("Должность нормоконтролера")]
Function GetDocNKPost(Obj) 
  txt = GetCheckListPost(Obj,"nk",1)
  GetDocNKPost = txt
End Function

Extern GetDocNKData [Alias ("Дата проверки документа нормоконтролером"), HelpString ("Дата проверки нормовонтролером")]
Function GetDocNKData(Obj) 
  txt = GetCheckListDate(Obj,"nk",1)
  GetDocNKData = txt
End Function

'==================================== APPR====================================
Extern GetDocApproveUser [Alias ("Утвердил"), HelpString ("Утвердил")]
Function GetDocApproveUser(Obj) 
  txt = GetCheckListUser(Obj,"approve",1)
  GetDocApproveUser = txt
End Function

Extern GetDocApprovePost [Alias ("Должность утверждающего"), HelpString ("Должность утверждающего")]
Function GetDocApprovePost(Obj) 
  txt = GetCheckListPost(Obj,"approve",1)
  GetDocApprovePost = txt
End Function

Extern GetDocApproveData [Alias ("Дата утверждения документа"), HelpString ("Дата утверждения документа")]
Function GetDocApproveData(Obj) 
  txt = GetCheckListDate(Obj,"approve",1)
  GetDocApproveData = txt
End Function


'==================================== chk 1====================================
Extern GetDocCheckUser1 [Alias ("Проверил 1"), HelpString ("Проверил")]
Function GetDocCheckUser1(Obj) 
  txt = GetCheckListUser(Obj,"check",1)
  GetDocCheckUser1 = txt
End Function

Extern GetDocCheckPost1 [Alias ("Должность проверяющего 1"), HelpString ("Должность проверяющего")]
Function GetDocCheckPost1(Obj) 
  txt = GetCheckListPost(Obj,"check",1)
  GetDocCheckPost1 = txt
End Function

Extern GetDocCheckData1 [Alias ("Дата проверки 1 документа"), HelpString ("Дата проверки документа")]
Function GetDocCheckData1(Obj) 
  txt = GetCheckListDate(Obj,"check",1)
  GetDocCheckData1 = txt
End Function

'==================================== chk 2====================================
Extern GetDocCheckUser2 [Alias ("Проверил 2"), HelpString ("Проверил")]
Function GetDocCheckUser2(Obj) 
  txt = GetCheckListUser(Obj,"check",2)
  GetDocCheckUser2 = txt
End Function

Extern GetDocCheckPost2 [Alias ("Должность проверяющего 2"), HelpString ("Должность проверяющего")]
Function GetDocCheckPost2(Obj) 
  txt = GetCheckListPost(Obj,"check",2)
  GetDocCheckPost2 = txt
End Function

Extern GetDocCheckData2 [Alias ("Дата проверки 2 документа"), HelpString ("Дата проверки документа")]
Function GetDocCheckData2(Obj) 
  txt = GetCheckListDate(Obj,"check",2)
  GetDocCheckData2 = txt
End Function

'==================================== chk 3====================================
Extern GetDocCheckUser3 [Alias ("Проверил 3"), HelpString ("Проверил")]
Function GetDocCheckUser3(Obj) 
  txt = GetCheckListUser(Obj,"check",3)
  GetDocCheckUser3 = txt
End Function

Extern GetDocCheckPost3 [Alias ("Должность проверяющего 3"), HelpString ("Должность проверяющего")]
Function GetDocCheckPost3(Obj) 
  txt = GetCheckListPost(Obj,"check",3)
  GetDocCheckPost3 = txt
End Function

Extern GetDocCheckData3 [Alias ("Дата проверки 3 документа"), HelpString ("Дата проверки документа")]
Function GetDocCheckData3(Obj) 
  txt = GetCheckListDate(Obj,"check",3)
  GetDocCheckData3 = txt
End Function
'==============================================================================
Function GetCheckListUser(Obj,mark,index)
  GetCheckListUser = ""
  If Obj.Attributes.Has("ATTR_CHECK_LIST") = False Then Exit Function
  Set Table = Obj.Attributes("ATTR_CHECK_LIST")

  i = 1
  For each Row In Table.Rows
    Set cls = Row.Attributes("ATTR_CHECK_TYPE").Classifier
    If Not cls Is Nothing Then
      If cls.code = mark Then
        If i = index Then
          Set user = Row.Attributes("ATTR_USER").user
          If Not user Is Nothing Then
            txt = user.LastName
            Exit For
          End If
        else
          i= i + 1
        End If
      End If
    End If
  Next
  If txt = "" Then txt = " "
  GetCheckListUser = txt
End Function

Function GetCheckListPost(Obj,mark,index)
  GetCheckListPost = ""
  If Obj.Attributes.Has("ATTR_CHECK_LIST") Then
    Set Table = Obj.Attributes("ATTR_CHECK_LIST")
  End If
  i = 1
  For each Row In Table.Rows
    Set cls = Row.Attributes("ATTR_CHECK_TYPE").Classifier
    If Not cls Is Nothing Then
      If cls.code = mark Then
        If i = index Then
          txt = cls.Description
          Exit For
        End If
        i= i + 1
      End If
    End If
  Next
  If txt = "" Then txt = " "
  GetCheckListPost = txt
End Function

Function GetCheckListDate(Obj,mark,index)
  GetCheckListDate = ""
  If Obj.Attributes.Has("ATTR_CHECK_LIST") Then
    Set Table = Obj.Attributes("ATTR_CHECK_LIST")
  End If
  i = 1
  For each Row In Table.Rows
    Set cls = Row.Attributes("ATTR_CHECK_TYPE").Classifier
    If Not cls Is Nothing Then
      If cls.code = mark Then
        If i = index Then
          If Row.Attributes("ATTR_DATA").Empty = False Then
            data = FormatDateTime(Row.Attributes("ATTR_DATA"),vbShortDate)
            ' МЗМЕНЕНО ПО РЕЗУЛЬТАТАМ испытаний в Самаре
            'txt = Right(data,7)
            txt = Left(Data,6) & Right(Data,2)
            Exit For
          End If
        else
          i= i + 1
        End If
      End If
    End If
  Next
  If txt = "" Then txt = " "
  GetCheckListDate = txt
End Function


Extern GetContractorINN [Alias ("ИНН подрядчика"), HelpString ("ИНН Подрядчика")]
Function GetContractorINN(Obj)
  GetContractorINN = " "
  Set oCorr = ThisApplication.ExecuteScript("CMD_DLL_CONTRACTS","GetMyCompany")
  If Not oCorr Is Nothing Then _
      GetContractorINN = GetINN(oCorr)
End Function

Extern GetCustomerINN [Alias ("ИНН Заказчика"), HelpString ("ИНН Заказчика")]
Function GetCustomerINN(Obj)
  GetCustomerINN = " "
  Set oCorr = Obj.Attributes("ATTR_INVOICE_RECIPIENT").Object
  If Not oCorr Is Nothing Then _
      GetCustomerINN = GetINN(oCorr)
End Function

Function GetINN(Obj)
  GetINN = " " 
  If Obj.IsKindOf("OBJECT_CORRESPONDENT") = False Then Exit Function
  If Obj.Attributes.Has("ATTR_S_JPERSON_TIN") Then
    GetINN = Obj.Attributes("ATTR_S_JPERSON_TIN").Value
  End If
End Function

Extern GetContractorKPP [Alias ("КПП подрядчика"), HelpString ("КПП Подрядчика")]
Function GetContractorKPP(Obj)
  GetContractorKPP = " "
  Set oCorr = ThisApplication.ExecuteScript("CMD_DLL_CONTRACTS","GetMyCompany")
  If Not oCorr Is Nothing Then _
      GetContractorKPP = GetKPP(oCorr)
End Function

Extern GetCustomerKPP [Alias ("КПП Заказчика"), HelpString ("КПП Заказчика")]
Function GetCustomerKPP(Obj)
  GetCustomerKPP = " "
  Set oCorr = Obj.Attributes("ATTR_INVOICE_RECIPIENT").Object
  If Not oCorr Is Nothing Then _
      GetCustomerKPP = GetKPP(oCorr)
End Function

Function GetKPP(Obj)
  GetKPP = " " 
  If Obj.IsKindOf("OBJECT_CORRESPONDENT") = False Then Exit Function
  If Obj.Attributes.Has("ATTR_S_JPERSON_TRRC") Then
    GetKPP = Obj.Attributes("ATTR_S_JPERSON_TRRC").Value
  End If
End Function
