' Автор: Стромков С.А.
'
' Создание разделов
'------------------------------------------------------------------------------------------------------
' Авторское право © ЗАО «СиСофт», 2016

Dim o,p,arr(),odef
Set o = ThisObject
Set oProj=o.Attributes("ATTR_PROJECT").Object
o.Permissions = SysAdminPermissions

Call Main (o)

'Основная процедура. Одинаковая для всех разделов и подразделов
Sub Main(o_)
  Dim vDivisions
  'call Prepare (o_)
  Set clsRoot = Prepare (o_)
  If clsRoot is nothing then exit Sub
  
  cls = clsRoot.SysName & "_NO"
  
  If Not clsRoot.Classifiers.Has(cls) Then Exit Sub
  
  ' Создание раздела
  Call CreateSections(o_,clsRoot.Classifiers.FindBySysId(cls) ,odef)
End Sub

'==============================================================================
' Поиск корневого узла классификатора структуры проекта в зависимости от стадии и вида проектируемого объекта
'------------------------------------------------------------------------------
' o_: TDMSObject - объект с которого создается раздел/подраздел
' Prepare: TDMSClissifiers - коллекция узлов классификатора для отображения в диалоге
' oDef: - тип объекта, который создается
'==============================================================================
Function Prepare(o_)
  Set Prepare = Nothing
  Select Case o_.ObjectDefName  'sysID типа объекта, внутри которого строим разделы\подразделы
    Case "OBJECT_STAGE"
      Set clsRoot = ThisApplication.Classifiers.FindBySysId("NODE_PROJECT_STRUCT").Classifiers
      oDef="OBJECT_PROJECT_SECTION"
      
      'Set cls = GetStageStructureRoot()
      Set cls = ThisApplication.ExecuteScript ("CMD_PROJECT_SECTION_ADD", "GetStageStructureRoot",ThisObject)
      If cls Is Nothing Then 
        Msgbox "Структура проекта не найдена!",vbCritical,"Ошибка"
        Exit Function
      End If       
    Case "OBJECT_PROJECT_SECTION"
      cls = o_.Attributes("ATTR_PROJECT_DOCS_SECTION").Classifier.SysName
      oDef="OBJECT_PROJECT_SECTION_SUBSECTION"
  End Select  

  '  Set Prepare = clsRoot.FindBySysId(cls)
  Set Prepare = clsRoot.FindBySysId(cls.SysName)
End Function

'==============================================================================
'--------Создание разделов--------
'Создаёт отмеченные пользователем разделы
'==============================================================================
Private Sub CreateSections(o_,vDivisions_,oDefName_)

    'Создание нового объекта

      Set NewObj = o_.Objects.Create(oDefName_) 
      Call SetAttrs(NewObj,vDivisions_)
      Set Dlg = ThisApplication.Dialogs.EditObjectDlg
      Dlg.Object = NewObj
      If Not Dlg.Show Then
        NewObj.Erase
      End If
End Sub

' Установка атрибутов объекта
'------------------------------------------------------------------------------
' ПРИНИМАЕТ:
'   o_:TDMSObject - Объект, которому устанавливаем атрибуты. (Этап)
'==============================================================================
Private Sub SetAttrs(Obj,vDiv)
  sDivn = vDiv.Code
  
  ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", Obj,"ATTR_PROJECT_DOCS_SECTION", vDiv,True
  ThisApplication.ExecuteScript "CMD_PROJECT_SECTION_ADD","SetSectionAttrs",Obj
End Sub
