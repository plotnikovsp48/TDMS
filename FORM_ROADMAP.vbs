' Автор: Чернышов Д.С.
'
' Работа с маршрутной таблицей
'------------------------------------------------------------------------------
' Авторское право c ЗАО <СиСофт>, 2016 г.

USE CMD_FSO
USE CMD_EXCEL

'==============================================================================================
'Выгрузка маршрутной карты в Excel 
Sub BUTTON_TO_EXCEL_OnClick()
  ThisApplication.Utility.WaitCursor = True
  Set TableRows = ThisObject.Attributes("ATTR_ROUTE_TABLE").Rows
  sRoute = ""
  For Each Row in TableRows
    StrRoute = Row.Attributes(0)&";"&Row.Attributes(2)&";"&Row.Attributes(4)&";"&Row.Attributes(6)&";"&_
      Row.Attributes(8)&";"&Row.Attributes(9)&";"&Row.Attributes(10)
    StrRoute = Replace(StrRoute, chr(13), "", 1, -1, vbTextCompare)
    If sRoute <> "" Then
      sRoute = sRoute & chr(10) & StrRoute
    Else
      sRoute = StrRoute
    End If
  Next
  ThisObject.CheckOut
  fname = ThisObject.WorkFolder & "\" & ThisObject.Description & ".txt"
  res = CreateTextFileFromStr(sRoute,fname)
  Set FSO = Open()
  Set wb = OpenTextFile(FSO,fname)
  ThisApplication.Utility.WaitCursor = False
End Sub

'==============================================================================================
'Загрузка маршрутной карты из файла 
Sub BUTTON_FROM_EXCEL_OnClick()
  ThisObject.Permissions = SysAdminPermissions
  
  Key = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning", vbQuestion + vbYesNo, 2001)
  If Key = vbNo Then Exit Sub
  ' выбираем файл
  fname = ThisApplication.ExecuteScript("CMD_DIALOGS","SelectFileDlg","FILE_ANY")  
  ' создаем версию маршрутной карты
  ThisObject.Versions.Create ' - НЕ ЗАБЫТЬ ВКЛЮЧИТЬ
  ' считываем файл маршрута в таблицу
  sRoute = CreateStrFromTextFile(fname)
  If Trim(fname) = "" Then Exit Sub
  
  ThisApplication.Utility.WaitCursor = True
  Set TableRows = ThisObject.Attributes("ATTR_ROUTE_TABLE").Rows
  TableRows.RemoveAll
  sRoute = Replace(sRoute, chr(9), " ", 1, -1, vbTextCompare)
  arr = Split(sRoute, chr(10))
  RowCount = 0
  For i = 0 to UBound(arr)
    Route = Replace(arr(i), ";", " ")
    RouteArr = Split(Route, " ")
    Num = UBound(RouteArr)
    If Len(Route) > 10 Then
      Set NewRow = TableRows.Create
      RowCount = RowCount + 1
        'Номер маршрута
        RouteNum = RouteArr(0)
        NewRow.Attributes(0) = RouteNum
        'Исходный объект
        Obj0id = RouteArr(1)
        If Obj0id <> "" Then
          If ThisApplication.ObjectDefs.Has(Obj0id) = True Then
            Obj0Descr = ThisApplication.ObjectDefs(Obj0id).Description
            NewRow.Attributes(1) = Obj0Descr
            NewRow.Attributes(2) = Obj0id
          End If
        End If
        'Исходный статус
        Status0id = RouteArr(2)
        If Status0id <> "" Then
          If ThisApplication.Statuses.Has(Status0id) = True Then
            Status0Descr = ThisApplication.Statuses(Status0id).Description
            NewRow.Attributes(3) = Status0Descr
            NewRow.Attributes(4) = Status0id
          End If
        End If
        'Результирующий объект
        Obj1id = RouteArr(3)
        If Obj1id <> "" Then
          If ThisApplication.ObjectDefs.Has(Obj1id) = True Then
            Obj1Descr = ThisApplication.ObjectDefs(Obj1id).Description
            NewRow.Attributes(5) = Obj1Descr
            NewRow.Attributes(6) = Obj1id
          End If
        End If
        'Результирующий статус
        Status1id = RouteArr(4)
        If Status1id <> "" Then
          If ThisApplication.Statuses.Has(Status1id) = True Then
            Status1Descr = ThisApplication.Statuses(Status1id).Description
            NewRow.Attributes(7) = Status1Descr
            NewRow.Attributes(8) = Status1id
          End If
        End If
        
        'Роли и связи
        strRoles = ""
        strNext = ""
        For j = 5 to Num
          Value = Trim(RouteArr(j))
          Value = Replace(Value, chr(13), "", 1, -1, vbTextCompare)
          If Len(Value) > 1 Then
            'Роли маршрута
            If IsNumeric(Left(Value,1)) = False Then
              If strRoles <> "" Then
                strRoles = strRoles & " " & Value
              Else
                strRoles = Value
              End If
            'Следующие маршруты
            Else
              If strNext <> "" Then
                strNext = strNext & " " & Value
              Else
                strNext = Value
              End If
            End If
          End If
        Next
        If strRoles <> "" Then NewRow.Attributes(9) = strRoles
        If strNext <> "" Then NewRow.Attributes(10) = strNext
    End If
  Next
  
  ThisApplication.Utility.WaitCursor = False
  ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", , 2002, RowCount
  ThisObject.Update
  
End Sub

'==============================================================================================
Sub Form_BeforeShow(Form, Obj)
  'Настройки отображения выборки маршрутов
  Set Table = Form.Controls("QUERY_ROUTE_TABLE").ActiveX
  ID = Obj.Attributes("ATTR_ROUTE_ID_SHOW").Value
  Descr = Obj.Attributes("ATTR_ROUTE_DESCRIPTION_SHOW").Value
  Call QueryChangeShow(Table,ID,Descr)
  
  'Инициализация описания маршрута
  Call GridsInit(Form)
End Sub

'==============================================================================================
'Процедура инициализации таблицы ролей
Sub GridsInit(Form)
  Set GridRoles = Form.Controls("GRIDROLES").ActiveX
  GridRoles.InsertColumn GridRoles.ColumnCount, "Исходная роль", 20
  GridRoles.InsertColumn GridRoles.ColumnCount, "ID Исходная роль", 20
  GridRoles.InsertColumn GridRoles.ColumnCount, "Результирующая роль", 20
  GridRoles.InsertColumn GridRoles.ColumnCount, "ID Результирующая роль", 20
  GridRoles.ColumnAutosize = True
  GridRoles.InsertMode = False
  
  Set GridNext = Form.Controls("GRIDNEXT").ActiveX
  GridNext.InsertColumn GridNext.ColumnCount, "№", 20
  GridNext.InsertColumn GridNext.ColumnCount, "Исходный объект ID", 20
  GridNext.InsertColumn GridNext.ColumnCount, "Исходный статус ID", 20
  GridNext.InsertColumn GridNext.ColumnCount, "Результирующий объект ID", 20
  GridNext.InsertColumn GridNext.ColumnCount, "Результирующий статус ID", 20
  GridNext.ColumnAutosize = True
  GridNext.InsertMode = False
End Sub

'==============================================================================================
'Процедура изменения отображения выборки
Sub QueryChangeShow(Table,ID,Descr)
  If ID = True and Descr = False Then
    For i = 8 to 2 Step -2
      Table.DeleteColumn(i)
    Next
  ElseIf ID = False and Descr = True Then
    For i = 9 to 3 Step -2
      Table.DeleteColumn(i)
    Next
  ElseIf ID = False and Descr = False Then
    For i = 9 to 2 Step -1
      Table.DeleteColumn(i)
    Next
  End If
End Sub

'==============================================================================================
Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
  'Настройки отображения выборки маршрутов
  If Attribute.AttributeDefName = "ATTR_ROUTE_ID_SHOW" or _
  Attribute.AttributeDefName = "ATTR_ROUTE_DESCRIPTION_SHOW" Then
    ID = Form.Attributes("ATTR_ROUTE_ID_SHOW").Value
    Descr = Form.Attributes("ATTR_ROUTE_DESCRIPTION_SHOW").Value
    Set Dict = ThisApplication.Dictionary("QueryRoute")
    Dict.Item("ID") = ID
    Dict.Item("DESCR") = Descr
  
    'Form.Refresh
    'Set Table = Form.Controls("QUERY_ROUTE_TABLE").ActiveX
    
    'Call QueryChangeShow(Table,ID,Descr)
  End If
End Sub

'==============================================================================================
'Выделен маршрут
Sub QUERY_ROUTE_TABLE_Selected(iItem, action)
  Set Table = ThisForm.Controls("QUERY_ROUTE_TABLE")
  'arrRouteNum = Table.SelectedItems
  'RouteNum = arrRouteNum(0)
  'ThisObject.Dictionary.Item("SelItem") = RouteNum
  
  'Сохраняем данные из таблицы ролей
  str = RouteSave
  If str <> "" Then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", , 2013
  End If
  
  'Определение номера маршрута
  RouteNum = ""
  sRow = Table.ActiveX.SelectedItem
  If sRow <> -1 Then
    If Table.Value.RowsCount = Table.ActiveX.Count Then
      RouteNum = Table.Value.CellValue(sRow,0)
    Else
      ThisApplication.Utility.WaitCursor = True
      'TDMS долго получает данные строки
      RouteNum = Table.SelectedObjects(0).Attributes(0).value
      ThisApplication.Utility.WaitCursor = False
    End If
  End If
  
  'Заполняем таблицу ролей
  Call GridRolesFill(Table,RouteNum)
  'Заполняем таблицу следующих маршрутов
  Call GridNextFill(Table,RouteNum)
  'Заполняем заголовок маршрута
  Call TitleFill(Table,RouteNum)
End Sub

'==============================================================================================
'Процедура заполнения таблицы следующих маршрутов
'Table - ссылка на выборку на форме
'RouteNum - Номер маршрута
Sub GridRolesFill(Table,RouteNum)
  Set GridRoles = ThisForm.Controls("GRIDROLES").ActiveX
  GridRoles.RemoveAllRows
  Check = True
  If RouteNum = "" Then
    Check = False
  End If
  If Check = False Then
    GridRoles.Redraw
    Exit Sub
  End If
  
  'RolesText = Table.Value.CellValue(sRow,Table.Value.ColumnsCount-2)
  Set TableRows = ThisObject.Attributes("ATTR_ROUTE_TABLE").Rows
  For Each Row in TableRows
    If Row.Attributes(0).Value = RouteNum Then
      RolesText = Row.Attributes("ATTR_ROUTE_TABLE_TEXT").Value
    End If
  Next
  
  ArrRoles = Split(Trim(RolesText)," ")
  For i = 0 to Ubound(ArrRoles)-1 Step 2
    Role0id = ArrRoles(i)
    Role1id = ArrRoles(i+1)
    If Role0id <> "" and Role1id <> "" Then
      'Если ID - роли
      If ThisApplication.RoleDefs.Has(Role0id) Then
        Role0descr = ThisApplication.RoleDefs(Role0id).Description
      Else
        'Если ID - пользователь или группа
        If Role0id = "CU" Then
          Role0descr = "Текущий пользователь"
        ElseIf ThisApplication.Groups.Has(Role0id) Then
          Role0descr = ThisApplication.Groups(Role0id).Description
        ElseIf ThisApplication.Users.Has(Role0id) Then
          Role0descr = ThisApplication.Users(Role0id).Description
        Else
          Role0descr = "ОШИБКА!!!"
        End If
      End If
      If ThisApplication.RoleDefs.Has(Role1id) Then
        Role1descr = ThisApplication.RoleDefs(Role1id).Description
      Else
        Role1descr = "ОШИБКА!!!"
      End If
      'Создаем строку, если найдены описания
      If Role0descr <> "" and Role1descr <> "" Then
        GridRoles.InsertRow GridRoles.RowCount
        GridRoles.CellValue(GridRoles.RowCount-1,0) = Role0descr
        GridRoles.CellValue(GridRoles.RowCount-1,1) = Role0id
        GridRoles.CellValue(GridRoles.RowCount-1,2) = Role1descr
        GridRoles.CellValue(GridRoles.RowCount-1,3) = Role1id
      Else
        GridRoles.InsertRow GridRoles.RowCount
        GridRoles.CellValue(GridRoles.RowCount-1,1) = Role0id
        GridRoles.CellValue(GridRoles.RowCount-1,3) = Role1id
        ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", , 2003, Role0id, Role1id
      End If
    End If
  Next
  GridRoles.Redraw
End Sub

'==============================================================================================
'Процедура заполнения таблицы следующих маршрутов
'Table - ссылка на выборку на форме
'RouteNum - Номер маршрута
Sub GridNextFill(Table,RouteNum)
  Set GridNext = ThisForm.Controls("GRIDNEXT").ActiveX
  GridNext.RemoveAllRows
  Check = True
  sRow = Table.ActiveX.SelectedItem
  If RouteNum = "" Then
    Check = False
  End If
  If Check = False Then
    GridNext.Redraw
    Exit Sub
  End If
  
  'NextText = Table.Value.CellValue(sRow,Table.Value.ColumnsCount-1)
  Set TableRows = ThisObject.Attributes("ATTR_ROUTE_TABLE").Rows
  For Each Row in TableRows
    If Row.Attributes(0).Value = RouteNum Then
      NextText = Row.Attributes("ATTR_ROUTE_TABLE_NEXT").Value
    End If
  Next
  
  ArrNexts = Split(Trim(NextText)," ")
  For i = 0 to Ubound(ArrNexts)
    ArrNext = Split(Trim(ArrNexts(i)),".")
    GridNext.InsertRow GridNext.RowCount
    For j = 0 to 4
      GridNext.CellValue(GridNext.RowCount-1,j) = ArrNext(j)
    Next
  Next
  GridNext.Redraw
End Sub

'==============================================================================================
'Процедура заполнения заголовка выделенного маршрута
'Table - ссылка на выборку на форме
'RouteNum - Номер маршрута
Sub TitleFill(Table,RouteNum)
  sRow = Table.ActiveX.SelectedItem
  Set Title = ThisForm.Controls("TITLE")
  TitleText = ""
  If RouteNum = "" Then
    Title.Value = ""
    Exit Sub
    '  Title.Value = "Во время работы фильтров в выборке, нет возможности получить данные с выборки - ошибка TDMS 5"
    '  Exit Sub
  End If
  
  Set TableRows = ThisObject.Attributes("ATTR_ROUTE_TABLE").Rows
  For Each Row in TableRows
    If Row.Attributes(0).Value = RouteNum Then
      TitleText = RouteNum & " = " & Row.Attributes(1).Value & " (" & Row.Attributes(3).Value & ")" & _
        " - " & Row.Attributes(5).Value & " (" & Row.Attributes(7).Value & ")"
      Exit For
    End If
  Next
  Title.Value = TitleText
End Sub

'==============================================================================================
'Кнопка - добавить следующий маршрут для текущего
Sub BUTTON_ADD_NEXT_OnClick()
  'RoutesNext = ""
  'ErrStr = ""
  'Set TableForm = ThisForm.Controls("QUERY_ROUTE_TABLE")
  'Set Dlg = ThisApplication.Dialogs.SelectDlg
  'Set Query = ThisApplication.Queries("QUERY_ROUTE_TABLE")
  'Query.Parameter("ROUTE") = ThisObject
  'If Query.Sheet.RowsCount <> 0 Then
  '  Dlg.Prompt = "Выбор маршрута"
  '  Dlg.SelectFrom = Query.Sheet
  '  ThisApplication.Utility.WaitCursor = True
  '  'Диалог выбора маршрутов
  '  If Dlg.Show Then
  '    ThisApplication.Utility.WaitCursor = False
  '    Set Sheet = Dlg.Objects
  '    If Sheet.RowsCount <> 0 Then
  '      Set Row0 = TableForm.SelectedObjects(0)
  '      RoutesNext0 = Row0.Attributes("ATTR_ROUTE_TABLE_NEXT").Value
  '      RouteNum0 = Row0.Attributes("ATTR_ROUTE_TABLE_NUM").Value
  '      For i = 0 to Sheet.RowsCount-1
  '        Set Row1 = Sheet.RowValue(i)
  '        If Row1.Attributes("ATTR_ROUTE_TABLE_NUM").Value = RouteNum0 Then
  '          Msgbox "Нельзя создавать циклическую связь.", vbExclamation
  '        Else
  '          RouteID = Row1.Attributes(0)&"."&Row1.Attributes(2)&"."&Row1.Attributes(4)&"."&_
  '            Row1.Attributes(6)&"."&Row1.Attributes(8)
  '          If InStr(RoutesNext0,RouteID) = 0 Then
  '            If RoutesNext <> "" Then
  '              RoutesNext = RoutesNext & " " & RouteID
  '            Else
  '              RoutesNext = RouteID
  '            End If
  '          Else
  '            ErrStr = ErrStr & chr(10) & RouteID
  '          End If
  '        End If
  '      Next
  '    End If
  '  End If
  'Else
  '  Msgbox "Маршруты не найдены.", vbExclamation
  '  Exit Sub
  'End If
  
  Set TableForm = ThisForm.Controls("QUERY_ROUTE_TABLE")
  If TableForm.ActiveX.SelectedItem = -1 Then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", , 2007
    Exit Sub
  End If
  
  Set Title = ThisForm.Controls("TITLE")
  Set GridNext = ThisForm.Controls("GRIDNEXT").ActiveX
  RouteNum = Title.Value
  If RouteNum = "" Then
    Exit Sub
  End If
  RouteNum = cInt(Left(RouteNum,InStr(RouteNum," ")-1))
  
  ErrStr = ""
  
  Set Dlg = ThisApplication.Dialogs.SelectDlg
  Set Query = ThisApplication.Queries("QUERY_ROUTE_TABLE")
  Query.Parameter("ROUTE") = ThisObject
  If Query.Sheet.RowsCount <> 0 Then
    Dlg.Prompt = "Выбор маршрута"
    Dlg.SelectFrom = Query.Sheet
    ThisApplication.Utility.WaitCursor = True
    'Диалог выбора маршрутов
    If Dlg.Show Then
      ThisApplication.Utility.WaitCursor = False
      Set Sheet = Dlg.Objects
      If Sheet.RowsCount <> 0 Then
        For i = 0 to Sheet.RowsCount-1
          Set Row1 = Sheet.RowValue(i)
          If Row1.Attributes("ATTR_ROUTE_TABLE_NUM").Value = RouteNum Then
            ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", , 2011
          Else
            RouteNum1 = Row1.Attributes(0)
            Check = True
            For j = 0 to GridNext.RowCount-1
              If GridNext.CellValue(j,0) = cstr(RouteNum1) Then
                Check = False
                ErrStr = ErrStr & chr(10) & RouteNum1
                Exit For
              End If
            Next
            If Check = True Then
              GridNext.InsertRow GridNext.RowCount
              GridNext.CellValue(GridNext.RowCount-1,0) = RouteNum1
              GridNext.CellValue(GridNext.RowCount-1,1) = Row1.Attributes(2)
              GridNext.CellValue(GridNext.RowCount-1,2) = Row1.Attributes(4)
              GridNext.CellValue(GridNext.RowCount-1,3) = Row1.Attributes(6)
              GridNext.CellValue(GridNext.RowCount-1,4) = Row1.Attributes(8)
            End If
          End If
        Next
      End If
    End If
  Else
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", , 2004
    Exit Sub
  End If
  
  If ErrStr <> "" Then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", , 2005, ErrStr
  End If
  
  'Если были выбраны маршруты, то вписываем их ключи в текущий маршрут
  'If RoutesNext <> "" Then
  '  
  '  If RoutesNext0 <> "" Then
  '    RoutesNext0 = RoutesNext0 & " " & RoutesNext
  '  Else
  '    RoutesNext0 = RoutesNext
  '  End If
  '  For Each Row1 in ThisObject.Attributes("ATTR_ROUTE_TABLE").Rows
  '    If Row1.Attributes(0).Value = Row0.Attributes(0).Value Then
  '      If Row1.Attributes("ATTR_ROUTE_TABLE_NEXT").Value <> RoutesNext0 Then
  '        Row1.Attributes("ATTR_ROUTE_TABLE_NEXT").Value = RoutesNext0
  '        ThisObject.Update
  '        ThisForm.Refresh
  '        Call GridNextFill(TableForm)
  '      End If
  '    End If
  '  Next
  'End If
End Sub

'==============================================================================================
'Кнопка - удалить следующий маршрут для текущего
Sub BUTTON_DEL_NEXT_OnClick()
  Set GridNext = ThisForm.Controls("GRIDNEXT").ActiveX
  ArrRows = GridNext.SelectedRows
  For i = Ubound(ArrRows) to 0 Step -1
    GridNext.RemoveRow ArrRows(i)
  Next
  GridNext.Redraw
'  RoutesNext = ""
'  Dim ArrSel()
'  Set GridNext = ThisForm.Controls("GRIDNEXT").ActiveX
'  Set Table = ThisForm.Controls("QUERY_ROUTE_TABLE")
'  If Table.ActiveX.SelectedItem = -1 Then
'    Msgbox "Не выбран маршрут.", vbExclamation
'    Exit Sub
'  End If
'  Set Dlg = ThisApplication.Dialogs.SelectDlg
'  
'  'Создаем виртуальную таблицу для диалога
'  Set Sheet = ThisApplication.CreateSheet
'  Sheet.AddColumn 5
'  Sheet.ColumnName(0) = "№"
'  Sheet.ColumnName(1) = "Исходный объект ID"
'  Sheet.ColumnName(2) = "Исходный статус ID"
'  Sheet.ColumnName(3) = "Результирующий объект ID"
'  Sheet.ColumnName(4) = "Результирующий статус ID"
'  'Заполняем виртуальную таблицу
'  Set GridNext = ThisForm.Controls("GRIDNEXT").ActiveX
'  For i = 0 to GridNext.RowCount-1
'    Sheet.InsertRow Sheet.RowsCount
'    For j = 0 to GridNext.ColumnCount-1
'      Sheet.CellValue(i,j) = GridNext.CellValue(i,j)
'    Next
'  Next
'  
'  'Показываем диалог
'  If Sheet.RowsCount > 0 Then
'    Dlg.SelectFrom = Sheet
'    Dlg.Prompt = "Выбор маршрута"
'    If Dlg.Show Then
'      If Dlg.Objects.RowsCount > 0 Then
'        'Удаляем из таблицы на форме строки
'        For i = 0 to Dlg.Objects.RowsCount-1
'          RouteNum = Dlg.Objects.CellValue(i,0)
'          For j = 0 to GridNext.RowCount
'            If GridNext.CellValue(j,0) = RouteNum Then
'              GridNext.RemoveRow j
'              Exit For
'            End If
'          Next
'        Next
'        GridNext.Redraw
'        'Формируем новую строку для маршрута
'        For i = 0 to GridNext.RowCount-1
'          RowText = GridNext.CellValue(i,0) & "." & GridNext.CellValue(i,1) & "." & _
'            GridNext.CellValue(i,2) & "." & GridNext.CellValue(i,3) & "." & GridNext.CellValue(i,4)
'          If RoutesNext <> "" Then
'            RoutesNext = RoutesNext & " " & RowText
'          Else
'            RoutesNext = RowText
'          End If
'        Next
'        'Записываем новую строку связей в маршрут
'        RouteNum = Table.Value.CellValue(Table.ActiveX.SelectedItem,0)
'        For Each Row in ThisObject.Attributes("ATTR_ROUTE_TABLE").Rows
'          If Row.Attributes(0).Value = RouteNum Then
'            If Row.Attributes("ATTR_ROUTE_TABLE_NEXT").Value <> RoutesNext Then
'              Row.Attributes("ATTR_ROUTE_TABLE_NEXT").Value = RoutesNext
'              ThisObject.Update
'              ThisForm.Refresh
'            End If
'          End If
'        Next
'      End If
'    End If
'  Else
'    Msgbox "Нет маршрутов для удаления.", vbExclamation
'  End If
End Sub

'==============================================================================================
'Кнопка - Удалить выбранные маршруты
Sub BUTTON_ROUTE_DEL_OnClick()
  Set TableForm = ThisForm.Controls("QUERY_ROUTE_TABLE")
  Set TableRows = ThisObject.Attributes("ATTR_ROUTE_TABLE").Rows
  sRow = TableForm.ActiveX.SelectedItem
  If sRow = -1 Then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", , 2007
    Exit Sub
  ElseIf TableForm.Value.RowsCount <> TableForm.ActiveX.Count Then
    RouteNum = ThisForm.Controls("TITLE").Value
    If RouteNum = "" Then
      Exit Sub
    ElseIf IsNumeric(Left(RouteNum,1)) = False Then
      Exit Sub
    End If
    RouteNum = cInt(Left(RouteNum,InStr(RouteNum," ")-1))
  Else
    RouteNum = TableForm.Value.CellValue(sRow,0)
  End If
  
  Key = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning", vbQuestion + vbYesNo, 2006)
  If Key = vbYes Then
    Count = 0
    ThisApplication.Utility.WaitCursor = True
    For Each Row in TableRows
      If Row.Attributes(0).Value = RouteNum Then
        TableRows.Remove Row
        Count = Count + 1
        Exit For
      End If
    Next
    ThisApplication.Utility.WaitCursor = False
    If Count <> 0 Then
      ThisObject.Update
      ThisForm.Refresh
      ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", , 2008, Count
    End If
  End If
End Sub

'==============================================================================================
'Кнопка - создать маршрут
Sub BUTTON_ROUTE_CREATE_OnClick()
  Set Form = ThisApplication.InputForms("FORM_ROUTE_CHANGE")

  'Показываем форму
  If Form.Show Then
    'Получаем данные с формы
    Obj0 = Form.Attributes("ATTR_ROUT_MASTER_OBJECT1").Value
    Obj0id = Form.Attributes("ATTR_ROUT_MASTER_OBJECT1_ID").Value
    Status0 = Form.Attributes("ATTR_ROUT_MASTER_STATUS1").Value
    Status0id = Form.Attributes("ATTR_ROUT_MASTER_STATUS1_ID").Value
    Obj1 = Form.Attributes("ATTR_ROUT_MASTER_OBJECT2").Value
    Obj1id = Form.Attributes("ATTR_ROUT_MASTER_OBJECT2_ID").Value
    Status1 = Form.Attributes("ATTR_ROUT_MASTER_STATUS2").Value
    Status1id = Form.Attributes("ATTR_ROUT_MASTER_STATUS2_ID").Value
    
    If Obj0id = "" or Obj1id = "" Then
      Exit Sub
    End If
    
    Set Query = ThisApplication.Queries("QUERY_TABLE_ROUTE_SEARCH")
    Query.Parameter("ROUTE") = ThisObject
    Query.Parameter("Obj0id") = Obj0id
    Query.Parameter("Status0id") = Status0id
    Query.Parameter("Obj1id") = Obj1id
    Query.Parameter("Status1id") = Status1id
    Set Sheet = Query.Sheet
    If Sheet.RowsCount <> 0 Then
      ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", , 2009
    Else
      Set TableRows = ThisObject.Attributes("ATTR_ROUTE_TABLE").Rows
      If TableRows.Count <> 0 Then
        MaxNum = TableRows(TableRows.Count-1).Attributes(0).Value + 1
      Else
        MaxNum = 0
      End If
      Set NewRow = TableRows.Create
      NewRow.Attributes(0).Value = MaxNum
      NewRow.Attributes(1).Value = Obj0
      NewRow.Attributes(2).Value = Obj0id
      NewRow.Attributes(3).Value = Status0
      NewRow.Attributes(4).Value = Status0id
      NewRow.Attributes(5).Value = Obj1
      NewRow.Attributes(6).Value = Obj1id
      NewRow.Attributes(7).Value = Status1
      NewRow.Attributes(8).Value = Status1id
      ThisObject.Update
      'ThisForm.Refresh
      ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", , 2010, MaxNum
      Set TableForm = ThisForm.Controls("QUERY_ROUTE_TABLE")
      TableForm.ActiveX.SelectItems TableForm.ActiveX.Count-1,TableForm.ActiveX.Count-1,True
    End If
  End If
End Sub

'==============================================================================================
'Кнопка - Создать строку ролей
Sub BUTTON_ADD_ROLE_OnClick()
  Set Table = ThisForm.Controls("QUERY_ROUTE_TABLE")
  If Table.ActiveX.SelectedItem = -1 Then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", , 2007
    Exit Sub
  End If
  Set GridRoles = ThisForm.Controls("GRIDROLES").ActiveX
  GridRoles.InsertRow GridRoles.RowCount
End Sub

'==============================================================================================
'Кнопка - Удалить строки ролей
Sub BUTTON_DEL_ROLE_OnClick()
  Set GridRoles = ThisForm.Controls("GRIDROLES").ActiveX
  ArrRows = GridRoles.SelectedRows
  For i = Ubound(ArrRows) to 0 Step -1
    GridRoles.RemoveRow ArrRows(i)
  Next
  GridRoles.Redraw
End Sub

'==============================================================================================
'Событие - Контекстное меню в таблице ролей
Sub GRIDROLES_ContextMenu(nRow,nCol,x,y,bCancel)
  Set Table = ThisForm.Controls("QUERY_ROUTE_TABLE")
  Set menu = ThisApplication.Dialogs.ContextMenu
  If Table.ActiveX.SelectedItem = -1 Then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", , 2007
    Exit Sub
  End If
  Set GridRoles = ThisForm.Controls("GRIDROLES").ActiveX
  'Определяем начальный или результирующий
  If nCol < 2 Then
    nCol0 = 0
    nCol1 = 1
  Else
    nCol0 = 2
    nCol1 = 3
  End If
  
  'Меню выбора роли
  If nRow >= 0 Then
    menu.AppendUserMenu 1, "Выбрать роль", 180
  End If
  If nCol < 2 Then
    menu.AppendUserMenu 2, "Выбрать группу", 180
    'menu.AppendUserMenu 3, "Выбрать пользователя", 180
    menu.AppendUserMenu 4, "Текущий пользователь", 180
  End If
  
  result = menu.Show(x, y)
  
  Select Case result
  
    Case 1 'Выбрать роль
      Set Dlg = ThisApplication.Dialogs.SelectDlg
      Dlg.Prompt = "Выберите роль"
      Dlg.SelectFrom = ThisApplication.RoleDefs
      If Dlg.Show Then
        If Dlg.Objects.Count <> 0 Then
          Set Role = Dlg.Objects(0)
          GridRoles.CellValue(nRow,nCol0) = Role.Description
          GridRoles.CellValue(nRow,nCol1) = Role.SysName
        End If
      End If
      
    Case 2 'Выбрать группу
      Set Dlg = ThisApplication.Dialogs.SelectDlg
      Dlg.Prompt = "Выберите группу"
      Dlg.SelectFrom = ThisApplication.Groups
      If Dlg.Show Then
        If Dlg.Objects.Count <> 0 Then
          Set Group = Dlg.Objects(0)
          GridRoles.CellValue(nRow,nCol0) = Group.Description
          GridRoles.CellValue(nRow,nCol1) = Group.SysName
        End If
      End If
      
    'Case 3 'Выбрать пользователя
    '  Set Dlg = ThisApplication.Dialogs.SelectDlg
    '  Dlg.Prompt = "Выберите пользователя"
    '  Dlg.SelectFrom = ThisApplication.Users
    '  If Dlg.Show Then
    '    If Dlg.Objects.Count <> 0 Then
    '      Set Users = Dlg.Objects(0)
    '      GridRoles.CellValue(nRow,nCol0) = Users.Description
    '      GridRoles.CellValue(nRow,nCol1) = Users.SysName
    '    End If
    '  End If
      
    Case 4 'Текущий пользователь
      GridRoles.CellValue(nRow,nCol0) = "Текущий пользователь"
      GridRoles.CellValue(nRow,nCol1) = "CU"
      
  End Select
End Sub

'==============================================================================================
'Функция сохранения таблицы ролей
'Возврат - строка, описание ошибки
Function RouteSave()
  RouteSave = ""
  Set Title = ThisForm.Controls("TITLE")
  'Set Table = ThisForm.Controls("QUERY_ROUTE_TABLE")
  Set GridRoles = ThisForm.Controls("GRIDROLES").ActiveX
  Set GridNext = ThisForm.Controls("GRIDNEXT").ActiveX
  Set TableRows = ThisObject.Attributes("ATTR_ROUTE_TABLE").Rows
  RouteNum = Title.Value
  If RouteNum = "" Then
    Exit Function
  ElseIf IsNumeric(Left(RouteNum,1)) = False Then
    Exit Function
  End If
  RouteNum = cInt(Left(RouteNum,InStr(RouteNum," ")-1))
  
  'Формируем строку ролей
  strRoles = ""
  Check = True
  For i = 0 to GridRoles.RowCount-1
    Role0 = GridRoles.CellValue(i,1)
    Role1 = GridRoles.CellValue(i,3)
    If Role0 = "" or Role1 = "" Then
      Check = False
      Exit For
    End If
    If strRoles <> "" Then
      strRoles = strRoles & " " & Role0 & " " & Role1
    Else
      strRoles = Role0 & " " & Role1
    End If
  Next
  
  'Формируем строку следующих маршрутов
  strNext = ""
  For i = 0 to GridNext.RowCount-1
    RowText = GridNext.CellValue(i,0) & "." & GridNext.CellValue(i,1) & "." & _
      GridNext.CellValue(i,2) & "." & GridNext.CellValue(i,3) & "." & GridNext.CellValue(i,4)
    If strNext <> "" Then
      strNext = strNext & " " & RowText
    Else
      strNext = RowText
    End If
  Next

  'Ошибка - не заполнены поля
  If Check = False Then
    RouteSave = "Для сохранения маршрута, необходимо заполнить все поля в таблице ролей."
    Exit Function
  End If
  
  'Находим маршрут и меняем строку ролей
  For Each Row in TableRows
    If Row.Attributes("ATTR_ROUTE_TABLE_NUM").Value = RouteNum Then
      UpdateRoles = False
      UpdateNext = False
      If StrComp(Trim(Row.Attributes("ATTR_ROUTE_TABLE_TEXT").Value), strRoles, vbTextCompare) <> 0 Then
        'ThisApplication.AddNotify Trim(Row.Attributes("ATTR_ROUTE_TABLE_TEXT").Value)
        'ThisApplication.AddNotify strRoles
        'ThisApplication.AddNotify Row.Attributes("ATTR_ROUTE_TABLE_NUM").Value & " - " & RouteNum
        UpdateRoles = True
      End If
      If StrComp(Trim(Row.Attributes("ATTR_ROUTE_TABLE_NEXT").Value), strNext, vbTextCompare) <> 0 Then
        UpdateNext = True
      End If
      If UpdateRoles = True or UpdateNext = True Then
        Key = ThisApplication.ExecuteScript("CMD_MESSAGE","ShowWarning",vbQuestion+vbYesNo,2012,RouteNum)
        If Key = vbYes Then
          If UpdateRoles = True Then Row.Attributes("ATTR_ROUTE_TABLE_TEXT").Value = strRoles
          If UpdateNext = True Then Row.Attributes("ATTR_ROUTE_TABLE_NEXT").Value = strNext
          ThisObject.Update
        End If
      End If
      Exit Function
    End If
  Next
End Function

'==============================================================================================
Sub Form_BeforeClose(Form, Obj, Cancel)
  'Сохраняем данные из таблицы ролей
  str = RouteSave
  If str <> "" Then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", , 2013
    Msgbox str,vbCritical
    Cancel = True
  End If
End Sub

'==============================================================================================
'Кнопка - Добавить маршрут из файла
Sub BUTTON_ADD_ROUTE_OnClick()
  ThisObject.Permissions = SysAdminPermissions

  ' выбираем файл
  fname = ThisApplication.ExecuteScript("CMD_DIALOGS","SelectFileDlg","FILE_ANY")  
  ' создаем версию маршрутной карты
  ThisObject.Versions.Create ' - НЕ ЗАБЫТЬ ВКЛЮЧИТЬ
  ' считываем файл маршрута в таблицу
  sRoute = CreateStrFromTextFile(fname)
  
  ThisApplication.Utility.WaitCursor = True
  Set Query = ThisApplication.Queries("QUERY_TABLE_ROUTE_SEARCH")
  Set TableRows = ThisObject.Attributes("ATTR_ROUTE_TABLE").Rows
  sRoute = Replace(sRoute, chr(9), " ", 1, -1, vbTextCompare)
  arr = Split(sRoute, chr(10))
  RowCount = 0
  For i = 0 to UBound(arr)
    Route = arr(i)
    RouteArr = Split(Route, " ")
    Num = UBound(RouteArr)
    If Len(Route) > 10 Then
      RouteNum = RouteArr(0)
      Obj0id = RouteArr(1)
      Status0id = RouteArr(2)
      Obj1id = RouteArr(3)
      Status1id = RouteArr(4)
      'Проверяем наличие маршрута в системе
      Query.Parameter("ROUTE") = ThisObject
      Query.Parameter("Obj0id") = Obj0id
      Query.Parameter("Status0id") = Status0id
      Query.Parameter("Obj1id") = Obj1id
      Query.Parameter("Status1id") = Status1id
      Set Sheet = Query.Sheet
      If Sheet.RowsCount <> 0 Then
        ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", , 2009
      Else
        Set NewRow = TableRows.Create
        RowCount = RowCount + 1
        'Номер маршрута
        NewRow.Attributes(0) = RouteNum
        'Исходный объект
        If Obj0id <> "" Then
          If ThisApplication.ObjectDefs.Has(Obj0id) = True Then
            Obj0Descr = ThisApplication.ObjectDefs(Obj0id).Description
            NewRow.Attributes(1) = Obj0Descr
            NewRow.Attributes(2) = Obj0id
          End If
        End If
        'Исходный статус
        If Status0id <> "" Then
          If ThisApplication.Statuses.Has(Status0id) = True Then
            Status0Descr = ThisApplication.Statuses(Status0id).Description
            NewRow.Attributes(3) = Status0Descr
            NewRow.Attributes(4) = Status0id
          End If
        End If
        'Результирующий объект
        If Obj1id <> "" Then
          If ThisApplication.ObjectDefs.Has(Obj1id) = True Then
            Obj1Descr = ThisApplication.ObjectDefs(Obj1id).Description
            NewRow.Attributes(5) = Obj1Descr
            NewRow.Attributes(6) = Obj1id
          End If
        End If
        'Результирующий статус
        If Status1id <> "" Then
          If ThisApplication.Statuses.Has(Status1id) = True Then
            Status1Descr = ThisApplication.Statuses(Status1id).Description
            NewRow.Attributes(7) = Status1Descr
            NewRow.Attributes(8) = Status1id
          End If
        End If
        
        'Роли и связи
        strRoles = ""
        strNext = ""
        For j = 5 to Num
          Value = RouteArr(j)
          If Len(Value) > 1 Then
            'Роли маршрута
            If IsNumeric(Left(Value,1)) = False Then
              If strRoles <> "" Then
                strRoles = strRoles & " " & Value
              Else
                strRoles = Value
              End If
            'Следующие маршруты
            Else
              If strNext <> "" Then
                strNext = strNext & " " & Value
              Else
                strNext = Value
              End If
            End If
          End If
        Next
        If strRoles <> "" Then NewRow.Attributes(9) = strRoles
        If strNext <> "" Then NewRow.Attributes(10) = strNext
      End If
    End If
  Next
  
  ThisApplication.Utility.WaitCursor = False
  If RowCount <> 0 Then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", , 2002, RowCount
    ThisObject.Update
  End If
End Sub

'==============================================================================================
'Кнопка изменения маршрута
Sub BUTTON_CHANGE_ROUTE_OnClick()
  'Ищем выделенную строку в таблице
  Set TableForm = ThisForm.Controls("QUERY_ROUTE_TABLE")
  Set TableRows = ThisObject.Attributes("ATTR_ROUTE_TABLE").Rows
  sRow = TableForm.ActiveX.SelectedItem
  If sRow = -1 Then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", , 2007
    Exit Sub
  ElseIf TableForm.Value.RowsCount <> TableForm.ActiveX.Count Then
    RouteNum = ThisForm.Controls("TITLE").Value
    If RouteNum = "" Then
      Exit Sub
    ElseIf IsNumeric(Left(RouteNum,1)) = False Then
      Exit Sub
    End If
    RouteNum = cInt(Left(RouteNum,InStr(RouteNum," ")-1))
  Else
    RouteNum = TableForm.Value.CellValue(sRow,0)
  End If
  Set Row = Nothing
  For Each Row in TableRows
    If Row.Attributes(0).Value = RouteNum Then
      Exit For
    End If
  Next

  Set Form = ThisApplication.InputForms("FORM_ROUTE_CHANGE")
  'Заполняем поля формы
  Form.Attributes("ATTR_ROUT_MASTER_OBJECT1").Value = Row.Attributes("ATTR_ROUT_MASTER_OBJECT1").Value
  Form.Attributes("ATTR_ROUT_MASTER_STATUS1").Value = Row.Attributes("ATTR_ROUT_MASTER_STATUS1").Value
  Form.Attributes("ATTR_ROUT_MASTER_OBJECT2").Value = Row.Attributes("ATTR_ROUT_MASTER_OBJECT2").Value
  Form.Attributes("ATTR_ROUT_MASTER_STATUS2").Value = Row.Attributes("ATTR_ROUT_MASTER_STATUS2").Value
  Form.Attributes("ATTR_ROUT_MASTER_OBJECT1_ID").Value = Row.Attributes("ATTR_ROUT_MASTER_OBJECT1_ID").Value
  Form.Attributes("ATTR_ROUT_MASTER_STATUS1_ID").Value = Row.Attributes("ATTR_ROUT_MASTER_STATUS1_ID").Value
  Form.Attributes("ATTR_ROUT_MASTER_OBJECT2_ID").Value = Row.Attributes("ATTR_ROUT_MASTER_OBJECT2_ID").Value
  Form.Attributes("ATTR_ROUT_MASTER_STATUS2_ID").Value = Row.Attributes("ATTR_ROUT_MASTER_STATUS2_ID").Value
  
  'Показываем форму
  If Form.Show Then
    'Получаем данные с формы
    Obj0 = Form.Attributes("ATTR_ROUT_MASTER_OBJECT1").Value
    Obj0id = Form.Attributes("ATTR_ROUT_MASTER_OBJECT1_ID").Value
    Status0 = Form.Attributes("ATTR_ROUT_MASTER_STATUS1").Value
    Status0id = Form.Attributes("ATTR_ROUT_MASTER_STATUS1_ID").Value
    Obj1 = Form.Attributes("ATTR_ROUT_MASTER_OBJECT2").Value
    Obj1id = Form.Attributes("ATTR_ROUT_MASTER_OBJECT2_ID").Value
    Status1 = Form.Attributes("ATTR_ROUT_MASTER_STATUS2").Value
    Status1id = Form.Attributes("ATTR_ROUT_MASTER_STATUS2_ID").Value
    
    If Obj0id = "" or Obj1id = "" Then
      Exit Sub
    End If
    
    Set Query = ThisApplication.Queries("QUERY_TABLE_ROUTE_SEARCH")
    Query.Parameter("ROUTE") = ThisObject
    Query.Parameter("Obj0id") = Obj0id
    Query.Parameter("Status0id") = Status0id
    Query.Parameter("Obj1id") = Obj1id
    Query.Parameter("Status1id") = Status1id
    Set Sheet = Query.Sheet
    If Sheet.RowsCount <> 0 Then
      ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", , 2009
    Else
      Row.Attributes(1).Value = Obj0
      Row.Attributes(2).Value = Obj0id
      Row.Attributes(3).Value = Status0
      Row.Attributes(4).Value = Status0id
      Row.Attributes(5).Value = Obj1
      Row.Attributes(6).Value = Obj1id
      Row.Attributes(7).Value = Status1
      Row.Attributes(8).Value = Status1id
      ThisObject.Update
      TableForm.ActiveX.SelectItems TableForm.ActiveX.Count-1,TableForm.ActiveX.Count-1,True
    End If
  End If
End Sub

'==============================================================================================
'Кнопка - Копировать маршрут
Sub BUTTON_ROUTE_COPY_OnClick()
  'Ищем выделенную строку в таблице
  Set TableForm = ThisForm.Controls("QUERY_ROUTE_TABLE")
  Set TableRows = ThisObject.Attributes("ATTR_ROUTE_TABLE").Rows
  sRow = TableForm.ActiveX.SelectedItem
  If sRow = -1 Then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", , 2007
    Exit Sub
  ElseIf TableForm.Value.RowsCount <> TableForm.ActiveX.Count Then
    RouteNum = ThisForm.Controls("TITLE").Value
    If RouteNum = "" Then
      Exit Sub
    ElseIf IsNumeric(Left(RouteNum,1)) = False Then
      Exit Sub
    End If
    RouteNum = cInt(Left(RouteNum,InStr(RouteNum," ")-1))
  Else
    RouteNum = TableForm.Value.CellValue(sRow,0)
  End If
  Set Row = Nothing
  For Each Row in TableRows
    If Row.Attributes(0).Value = RouteNum Then
      Exit For
    End If
  Next

  Set Form = ThisApplication.InputForms("FORM_ROUTE_CHANGE")
  'Заполняем поля формы
  Form.Attributes("ATTR_ROUT_MASTER_OBJECT1").Value = Row.Attributes("ATTR_ROUT_MASTER_OBJECT1").Value
  Form.Attributes("ATTR_ROUT_MASTER_STATUS1").Value = Row.Attributes("ATTR_ROUT_MASTER_STATUS1").Value
  Form.Attributes("ATTR_ROUT_MASTER_OBJECT2").Value = Row.Attributes("ATTR_ROUT_MASTER_OBJECT2").Value
  Form.Attributes("ATTR_ROUT_MASTER_STATUS2").Value = Row.Attributes("ATTR_ROUT_MASTER_STATUS2").Value
  Form.Attributes("ATTR_ROUT_MASTER_OBJECT1_ID").Value = Row.Attributes("ATTR_ROUT_MASTER_OBJECT1_ID").Value
  Form.Attributes("ATTR_ROUT_MASTER_STATUS1_ID").Value = Row.Attributes("ATTR_ROUT_MASTER_STATUS1_ID").Value
  Form.Attributes("ATTR_ROUT_MASTER_OBJECT2_ID").Value = Row.Attributes("ATTR_ROUT_MASTER_OBJECT2_ID").Value
  Form.Attributes("ATTR_ROUT_MASTER_STATUS2_ID").Value = Row.Attributes("ATTR_ROUT_MASTER_STATUS2_ID").Value
  
  'Показываем форму
  If Form.Show Then
    'Получаем данные с формы
    Obj0 = Form.Attributes("ATTR_ROUT_MASTER_OBJECT1").Value
    Obj0id = Form.Attributes("ATTR_ROUT_MASTER_OBJECT1_ID").Value
    Status0 = Form.Attributes("ATTR_ROUT_MASTER_STATUS1").Value
    Status0id = Form.Attributes("ATTR_ROUT_MASTER_STATUS1_ID").Value
    Obj1 = Form.Attributes("ATTR_ROUT_MASTER_OBJECT2").Value
    Obj1id = Form.Attributes("ATTR_ROUT_MASTER_OBJECT2_ID").Value
    Status1 = Form.Attributes("ATTR_ROUT_MASTER_STATUS2").Value
    Status1id = Form.Attributes("ATTR_ROUT_MASTER_STATUS2_ID").Value
    
    If Obj0id = "" or Obj1id = "" Then
      Exit Sub
    End If
    
    Set Query = ThisApplication.Queries("QUERY_TABLE_ROUTE_SEARCH")
    Query.Parameter("ROUTE") = ThisObject
    Query.Parameter("Obj0id") = Obj0id
    Query.Parameter("Status0id") = Status0id
    Query.Parameter("Obj1id") = Obj1id
    Query.Parameter("Status1id") = Status1id
    Set Sheet = Query.Sheet
    If Sheet.RowsCount <> 0 Then
      ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", , 2009
    Else
      Set TableRows = ThisObject.Attributes("ATTR_ROUTE_TABLE").Rows
      If TableRows.Count <> 0 Then
        MaxNum = TableRows(TableRows.Count-1).Attributes(0).Value + 1
      Else
        MaxNum = 0
      End If
      Set NewRow = TableRows.Create
      NewRow.Attributes(0).Value = MaxNum
      NewRow.Attributes(1).Value = Obj0
      NewRow.Attributes(2).Value = Obj0id
      NewRow.Attributes(3).Value = Status0
      NewRow.Attributes(4).Value = Status0id
      NewRow.Attributes(5).Value = Obj1
      NewRow.Attributes(6).Value = Obj1id
      NewRow.Attributes(7).Value = Status1
      NewRow.Attributes(8).Value = Status1id
      NewRow.Attributes(9).Value = Row.Attributes(9).Value
      NewRow.Attributes(10).Value = Row.Attributes(10).Value
      ThisObject.Update
      ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", , 2010, MaxNum
      Set TableForm = ThisForm.Controls("QUERY_ROUTE_TABLE")
      TableForm.ActiveX.SelectItems TableForm.ActiveX.Count-1,TableForm.ActiveX.Count-1,True
    End If
  End If
End Sub

'==============================================================================================
'Кнопка - Передвинуть строку вверх
Sub BUTTON_ROLE_UP_OnClick()
  Set GridRoles = ThisForm.Controls("GRIDROLES").ActiveX
  ArrRows = GridRoles.SelectedRows
  If Ubound(ArrRows) <> 0 or GridRoles.SelectedRow < 1 Then Exit Sub
  
  NumUp = 3
  Dim Arr(3)
  'Заполняем буфер
  For i = 0 to NumUp
    Arr(i) = GridRoles.CellValue(GridRoles.SelectedRow,i)
  Next
  'Заполняем нижнюю строку
  For i = 0 to NumUp
    GridRoles.CellValue(GridRoles.SelectedRow,i) = GridRoles.CellValue(GridRoles.SelectedRow-1,i)
  Next
  'Заполняем верхнюю строку
  For i = 0 to NumUp
    GridRoles.CellValue(GridRoles.SelectedRow-1,i) = Arr(i)
  Next
  
  'Меняем выделение в таблице
  Arr0 = GridRoles.Selection
  Arr0(0) = Arr0(0)-1
  Arr0(2) = Arr0(2)-1
  GridRoles.Selection = Arr0
  
  GridRoles.Redraw
End Sub

'==============================================================================================
'Кнопка - Передвинуть строку вниз
Sub BUTTON_ROLE_DOWN_OnClick()
  Set GridRoles = ThisForm.Controls("GRIDROLES").ActiveX
  ArrRows = GridRoles.SelectedRows
  If Ubound(ArrRows) <> 0 or GridRoles.SelectedRow >= GridRoles.RowCount-1 Then Exit Sub
  
  NumUp = 3
  Dim Arr(3)
  'Заполняем буфер
  For i = 0 to NumUp
    Arr(i) = GridRoles.CellValue(GridRoles.SelectedRow,i)
  Next
  'Заполняем нижнюю строку
  For i = 0 to NumUp
    GridRoles.CellValue(GridRoles.SelectedRow,i) = GridRoles.CellValue(GridRoles.SelectedRow+1,i)
  Next
  'Заполняем верхнюю строку
  For i = 0 to NumUp
    GridRoles.CellValue(GridRoles.SelectedRow+1,i) = Arr(i)
  Next
  
  'Меняем выделение в таблице
  Arr0 = GridRoles.Selection
  Arr0(0) = Arr0(0)+1
  Arr0(2) = Arr0(2)+1
  GridRoles.Selection = Arr0
  
  GridRoles.Redraw
End Sub

'Кнопка - вызов дерева маршрутов
Sub BUTTON_TREE_OnClick()
  Set Dict = ThisApplication.Dictionary("RoutesTree")
  Set Form = ThisApplication.InputForms("FORM_ROUTES_TREE")
  Dict.Item("Handle") = ThisObject.Handle
  Form.Show
  Dict.RemoveAll
End Sub
