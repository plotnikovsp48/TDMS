' $Workfile: COMMAND.SCRIPT.CMD_SORT.scr $ 
' $Date: 29.09.08 12:37 $ 
' $Revision: 4 $ 
' $Author: Oreshkin $ 
'
' Сортировка элементов дерева навигации по алфавиту
'------------------------------------------------------------------------------
' Авторское право © ЗАО «НАНОСОФТ», 2008 г.

Const ORDER="OBJECT_CONTRACTS,OBJECT_CONTRACT,OBJECT_PROJECT,OBJECT_BOD,OBJECT_PROJECT_DOCS_I,OBJECT_SURV,OBJECT_STAGE,OBJECT_FOLDER,OBJECT_T_TASKS,OBJECT_PROJECT_SECTION,OBJECT_PROJECT_SECTION_SUBSECTION,OBJECT_WORK_DOCS_FOR_BUILDING,OBJECT_WORK_DOCS_SET,OBJECT_DRAWING,OBJECT_DOC_DEV"
ThisScript.SysAdminModeOn
Dim o
Set o = ThisObject
Call Sort(o)

Sub Sort(o_)
  Dim os,o,count
  Dim i,j
  Dim v1,v2,d1,d2
  If o_ Is Nothing Then Exit Sub
  If o_.ObjectDefName = "OBJECT_STAGE" Then Exit Sub ' Стадию сортируем отдельно
  Set os = o_.Content
  count = os.Count
  For j= 0 To count
    For i=count-1 To 1 Step -1
      v1 = os.Item(i).Description
      d1 = os.Item(i).ObjectDefName
      v2 = os.Item(i-1).Description
      d2 = os.Item(i-1).ObjectDefName
      If d1 = d2 Then
        If StrComp(v1,v2,vbTextCompare) = -1 Then
          os.Swap os.Item(i), os.Item(i-1)
        End If
      Else
        If InStr(ORDER,d1) < InStr(ORDER,d2) Then
          os.Swap os.Item(i), os.Item(i-1)
        End If            
      End If  
    Next
  Next
  os.Update
  ThisApplication.Shell.Update o_
'   ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, 1008
End Sub
