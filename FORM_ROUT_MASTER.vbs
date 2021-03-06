' Автор: Орешкин А.В. 
'
' Диалог мастера создания маршрутов
'------------------------------------------------------------------------------
' Авторское право © ЗАО <СиСофт>, 2016 г.

USE CMD_DIALOGS

' Выбор типа объекта(исходный)
Sub BUTTON_ADD_OBJ1_OnClick()
  dim arr
  dim res
  res = SysDlg(ThisApplication.ObjectDefs)
  If res = "" Then 
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, 2402
    Exit Sub
  End If  
  arr = Split(res,"#")
  ThisForm.Attributes("ATTR_ROUT_MASTER_OBJECT1").Value=arr(0)
  ThisForm.Attributes("ATTR_ROUT_MASTER_OBJECT1_ID").Value=arr(1)
End Sub

' Выбор типа объекта(результирующий)
Sub BUTTON_ADD_OBJ2_OnClick()
  dim arr
  dim res
  res = SysDlg(ThisApplication.ObjectDefs)
  If res = "" Then 
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, 2402
    Exit Sub
  End If  
  arr = Split(res,"#")
  ThisForm.Attributes("ATTR_ROUT_MASTER_OBJECT2").Value=arr(0)
  ThisForm.Attributes("ATTR_ROUT_MASTER_OBJECT2_ID").Value=arr(1)  
End Sub

' Выбор статуса(исходный)
Sub BUTTON_ADD_ST1_OnClick()
  dim arr
  dim res
  dim sysdefs
  dim sObjSysName
  ' Считываем статусы типа объекта или берем все статусы
  sObjSysName = ThisForm.Attributes("ATTR_ROUT_MASTER_OBJECT1").Value
  If sObjSysName <> "" Then
    If ThisApplication.ObjectDefs.Has(sObjSysName)Then
      Set sysdefs = ThisApplication.ObjectDefs(sObjSysName).Statuses
    End If
  Else
    Set sysdefs = ThisApplication.Statuses
  End If
  res = SysDlg(sysdefs)
  If res = "" Then 
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, 2402
    Exit Sub
  End If
  arr = Split(res,"#")
  ThisForm.Attributes("ATTR_ROUT_MASTER_STATUS1").Value=arr(0)
  ThisForm.Attributes("ATTR_ROUT_MASTER_STATUS1_ID").Value=arr(1)  
End Sub

' Выбор статуса(результирующий)
Sub BUTTON_ADD_ST2_OnClick()
  dim arr
  dim res
  dim sysdefs
  dim sObjSysName
  ' Считываем статусы типа объекта или берем все статусы
  sObjSysName = ThisForm.Attributes("ATTR_ROUT_MASTER_OBJECT2").Value
  If sObjSysName <> "" Then
    If ThisApplication.ObjectDefs.Has(sObjSysName)Then
      Set sysdefs = ThisApplication.ObjectDefs(sObjSysName).Statuses
    End If
  Else
    Set sysdefs = ThisApplication.Statuses
  End If
  res = SysDlg(sysdefs)
  If res = "" Then 
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, 2402
    Exit Sub
  End If
  arr = Split(res,"#")
  ThisForm.Attributes("ATTR_ROUT_MASTER_STATUS2").Value=arr(0)
  ThisForm.Attributes("ATTR_ROUT_MASTER_STATUS2_ID").Value=arr(1)   
End Sub


' Выбор ролей
Sub ATTR_ROUT_MASTER_ROLES_CellInitEditCtrl(nRow, nCol, pEditCtrl, bCancelEdit)
  If nCol = 1 or nCol = 3 Then Exit Sub

  Set vRoleDefs = ThisApplication.RoleDefs
  Call AddFromCollection(nRow, nCol, vRoleDefs)
End Sub

' Формируем контекстное меню
Sub ATTR_ROUT_MASTER_ROLES_ContextMenu(nRow, nCol, x, y, bCancelDefault)
  dim menu
  dim answ
  dim Row
  dim ColumnName
  
  bCancelDefault = True
  'Проверяем на наличие строк
  If nRow = -1 Then Exit Sub
  If nCol = -1 Then Exit Sub
  ' Определяем наименование текущей колонки
  ColumnName = ThisForm.Controls("ATTR_ROUT_MASTER_ROLES").ActiveX.ColumnName(nCol)
  
  Set menu = ThisApplication.Dialogs.ContextMenu
  If ThisForm.Attributes("ATTR_ROUT_MASTER_ROLES").Rows.Count =< nRow Then Exit Sub
  Set Row = ThisForm.Attributes("ATTR_ROUT_MASTER_ROLES").Rows(nRow)
  
  'Формируем меню
  Select Case ColumnName 'Определение столбца по имени, можно выбирать по номеру
    Case "Исходная роль"
      menu.AppendUserMenu 1,"Копировать исходную роль", 25
      menu.AppendUserMenu 2,"Выбрать роль", 29
      menu.AppendUserMenu 3,"Выбрать группу", 27
      menu.AppendUserMenu 4,"Текущий пользователь", 234
  End Select
  
  'Показываем меню
  answ = menu.Show
  'В зависимости от выбранного пункта - действие
  res = ExecMenuComand(answ,nRow,nCol)

'  ThisForm.Refresh 
End Sub


' Выбор из группы системных элементов и добавление значений в таблицу
Sub AddFromCollection(nRow, nCol, vDefs_)
  dim arr
  dim res
  res = SysDlg(vDefs_)
  If res = "" Then 
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, 2402
    Exit Sub
  End If  
  arr = Split(res,"#")
  Set rows = ThisForm.Attributes("ATTR_ROUT_MASTER_ROLES").Rows
  If rows.count <(nRow+1) Then 
    Set row = rows.create
  Else
    Set row = rows(nRow)
  End If
  If nCol = 0 Then
    sAttr1="ATTR_ROUT_MASTER_ROLES_CUR"
    sAttr2="ATTR_ROUT_MASTER_ROLES_CUR_ID"
  Else
    sAttr1="ATTR_ROUT_MASTER_ROLES_NEXT"
    sAttr2="ATTR_ROUT_MASTER_ROLES_NEXT_ID"    
  End If
  row.Attributes(sAttr1)=arr(0)
  row.Attributes(sAttr2)=arr(1)
  rows.Update
  ThisForm.Refresh
End Sub


' Выполнение команд контекстного меню
Function ExecMenuComand(id_,nRow,nCol)
  dim vDefs
  ExecMenuComand = ""
  Select Case id_ 
    Case 1
      Call CopyRole(nRow, nCol)
    Case 2
      Set vDefs = ThisApplication.RoleDefs
      Call AddFromCollection(nRow, nCol, vDefs)
    Case 3
      Set vDefs = ThisApplication.Groups
      Call AddFromCollection(nRow, nCol, vDefs)
    Case 4
      Call SetCU(nRow, nCol)
  End Select  
  
  ExecMenuComand = id_
  ThisForm.Refresh
End Function

' Копировать роль
Sub CopyRole(nRow, nCol)
  dim rows
  dim row
  Set rows = ThisForm.Attributes("ATTR_ROUT_MASTER_ROLES").Rows
  Set row = rows(nRow)
  row.Attributes("ATTR_ROUT_MASTER_ROLES_CUR")=row.Attributes("ATTR_ROUT_MASTER_ROLES_NEXT")
  row.Attributes("ATTR_ROUT_MASTER_ROLES_CUR_ID")=row.Attributes("ATTR_ROUT_MASTER_ROLES_NEXT_ID") 
End Sub

' Назначить текущего пользователя
Sub SetCU(nRow, nCol)
  dim rows
  dim row
  Set rows = ThisForm.Attributes("ATTR_ROUT_MASTER_ROLES").Rows
  Set row = rows(nRow)
  row.Attributes("ATTR_ROUT_MASTER_ROLES_CUR")="Текущий пользователь"
  row.Attributes("ATTR_ROUT_MASTER_ROLES_CUR_ID")="CU"
End Sub

Sub Form_BeforeShow(Form, Obj)
  ' Считываем историю из словаря
  Set dict = ThisApplication.Dictionary("RouteDic")
  If Not dict.Exists("history") Then Exit Sub
  ' Формируем список
  Set ctrl = Form.Controls("ATTR_ROUT_MASTER_HISTORY")
  Set ActiveX = ctrl.ActiveX
  ActiveX.ComboItems = dict.Item("history")
End Sub

Sub ATTR_ROUT_MASTER_HISTORY_Modified()
  Set ctrl = ThisForm.Controls("ATTR_ROUT_MASTER_HISTORY")
  Set ActiveX = ctrl.ActiveX
  Call SetAttrs(ctrl.Value)
'  ThisApplication.AddNotify ThisForm.Controls("ATTR_ROUT_MASTER_HISTORY")
End Sub

' Заполняем диалог изменения маршрута на основе строки маршрута
Sub SetAttrs(route)
  arr = Split(Trim(route), chr(32))
  num = UBound(arr)
  Set ctrl = ThisForm.Controls("ATTR_ROUT_MASTER_ROLES")
  ctrl.ReadOnly = False  
  If num<3 Then Exit Sub
  
  ThisForm.Attributes("ATTR_ROUT_MASTER_OBJECT1_ID")=arr(0)
  ThisForm.Attributes("ATTR_ROUT_MASTER_OBJECT1")=ThisApplication.ExecuteScript("CMD_ROUTER", "GetDes", arr(0))
  ThisForm.Attributes("ATTR_ROUT_MASTER_STATUS1_ID")=arr(1)
  ThisForm.Attributes("ATTR_ROUT_MASTER_STATUS1")=ThisApplication.ExecuteScript("CMD_ROUTER", "GetDes", arr(1))
  ThisForm.Attributes("ATTR_ROUT_MASTER_OBJECT2_ID")=arr(2)
  ThisForm.Attributes("ATTR_ROUT_MASTER_OBJECT2")=ThisApplication.ExecuteScript("CMD_ROUTER", "GetDes", arr(2))
  ThisForm.Attributes("ATTR_ROUT_MASTER_STATUS2_ID")=arr(3)
  ThisForm.Attributes("ATTR_ROUT_MASTER_STATUS2")=ThisApplication.ExecuteScript("CMD_ROUTER", "GetDes", arr(3))
  
  set rows = ThisForm.Attributes("ATTR_ROUT_MASTER_ROLES").Rows
  ' Не нашел массового удаления всех строк(очистки таблицы)
  For Each row In rows
    row.erase
  Next
  ' Заполняем роли 
  For i = 4 to num step 2
    If arr(i) <> "" Then
      Set row = rows.Create
      row.Attributes("ATTR_ROUT_MASTER_ROLES_CUR_ID")=arr(i)
      row.Attributes("ATTR_ROUT_MASTER_ROLES_CUR") = ThisApplication.ExecuteScript("CMD_ROUTER", "GetDes", arr(i))
      row.Attributes("ATTR_ROUT_MASTER_ROLES_NEXT_ID")=arr(i+1)
      row.Attributes("ATTR_ROUT_MASTER_ROLES_NEXT") = ThisApplication.ExecuteScript("CMD_ROUTER", "GetDes", arr(i+1))
    End If
  Next
  rows.Update  
  ThisForm.Refresh
End Sub


' Поиск маршрута
Sub BUTTON_FIND_OnClick()
  dim arr
  dim num
  dim ctrl
  ' Ищем маршрут
  route = ThisApplication.ExecuteScript("CMD_ROUTER", "FindRoute", ThisObject, ThisForm)
  ' Заполняем атрибуты
  Call SetAttrs(route)
End Sub

' Добавить маршрут
Sub BUTTON_ADD_OnClick()
  Dim res
  ' Запускаем мастер создания маршрута
  res = ThisApplication.ExecuteScript("CMD_ROUTER", "AddRoute", ThisObject, ThisForm)
  ThisForm.Refresh
  If res="" Then Exit sub
  ' Добавляем в историю
  Call AddToRouteHistory(res)  
  ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, 2403, res
  ' Перезагружаем словарь
  Set dicStatusTransition = ThisApplication.ExecuteScript("CMD_ROUTER","CreateRouteDic","ROUTE_SPDS")
End Sub

' Удалить маршрут
Sub BUTTON_DEL_OnClick()
  Dim res
  ' Запускаем мастер удаления маршрута
  res = ThisApplication.ExecuteScript("CMD_ROUTER", "DelRoute", ThisObject, ThisForm)
  ThisForm.Refresh
  If res="" Then Exit sub
  
  ' Добавляем в историю
  Call AddToRouteHistory(res)
  ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, 2404, res
End Sub

' Выбор из истории
Sub BUTTON_HISTORY_OnClick()
  Set dict = ThisApplication.Dictionary("RouteDic")
  If Not dict.Exists("history") Then 
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, 2405
    Exit Sub
  End If
    
  rArray = dict.Item("history")
  ' Выбираем маршрут
  res = GetFromRouteHistory(rArray)
  If res = "" Then
'    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, 2405
    Exit Sub
  End If
  Call SetAttrs(res)
End Sub

' Выбор из таблицы маршрутов
Sub BUTTON_SELECT_OnClick()
  rArray = CreateArrFromRoadMap()
  ' Выбираем маршрут
  res = GetFromRouteHistory(rArray)
  If res = "" Then
'    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, 2405
    Exit Sub
  End If
  Call SetAttrs(res) 
End Sub

' Создание масива из текстового описания маршрутной карты
Function CreateArrFromRoadMap()
  ' Считываем маршрут
  sRoute = ThisObject.Attributes("ATTR_ROADMAP_ROUTE").Value
  ' Содаем массив
  CreateArrFromRoadMap = Split(sRoute, chr(10))
End Function

' Добавить маршрут в историю мастера создания маршрута
Sub AddToRouteHistory(sRouteLine_)
  Set dict = ThisApplication.Dictionary("RouteDic")
  If Not dict.Exists("history") Then 
    Dim rArray()
    dict.Add "history", rArray
  Else
    rArray = dict.Item("history")
  End If 
  count = 1
  on error resume next
  count = UBound(rArray)+1
  on error goto 0
  ReDim Preserve rArray(count)
  rArray(count) = sRouteLine_
  dict.Item("history") = rArray
End Sub

' Получить маршрут из истории мастера создания маршрута
Function GetFromRouteHistory(arr_)
  GetFromRouteHistory = "" 
  ' Создание выборки для диалога
  Set sheet = CreateRoadMapSheet(arr_) 
  If sheet Is Nothing Then Exit Function
  set dlg = ThisApplication.Dialogs.SelectDlg
  dlg.SelectFrom = sheet
  If Not dlg.Show Then Exit Function
  Set os = dlg.Objects
  GetFromRouteHistory = os.CellValue(0,4) 
End Function


' Создание выборки(sheet) на основе масссива маршрутов
Function CreateRoadMapSheet(arr_) 
  Set CreateRoadMapSheet = Nothing
  Set sheet = ThisApplication.CreateSheet
  col = sheet.AddColumn(5) 
  sheet.ColumnName(0) = "Исходный объект"
  sheet.ColumnName(1) = "Исходный статус"
  sheet.ColumnName(2) = "Результирующий объект"
  sheet.ColumnName(3) = "Результирующий статус"
  sheet.ColumnName(4) = "Строка маршрута"
  num = UBound(arr_)
  For i = 1 to num
    sRouteLine = arr_(i)
    arrRoute = Split(Trim(sRouteLine), chr(32))
    count = UBound(arrRoute)
    If count>3 Then count = 3
    iRow = sheet.AddRow
    For j=0 to count   
      sheet.CellValue(iRow,j)=arrRoute(j)
    Next
    sheet.CellValue(iRow,4)=sRouteLine
  Next
  Set CreateRoadMapSheet = sheet
End Function
