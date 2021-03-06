
Call Main

Sub Main()
  ThisApplication.Utility.WaitCursor = True
  Set TableRows = ThisObject.Attributes("ATTR_ROUTE_TABLE").Rows
  TableRows.RemoveAll
  RouteText = ThisObject.Attributes("ATTR_ROADMAP_ROUTE").Value
  arr = Split(Trim(RouteText), chr(10))
  RowCount = 0
  For i = 0 to UBound(arr)
    Route = arr(i)
    Route = Replace(Route, chr(13), "", 1, -1, vbTextCompare) 
    Route = Replace(Route, chr(10), "", 1, -1, vbTextCompare) 
    RouteArr = Split(Trim(arr(i)), " ")
    Num = UBound(RouteArr)
    If Num <> 0 Then
      Set NewRow = TableRows.Create
      NewRow.Attributes(0) = RowCount
      RowCount = RowCount + 1
        'Исходный объект
        Obj0id = RouteArr(0)
        If Obj0id <> "" Then
          If ThisApplication.ObjectDefs.Has(Obj0id) = True Then
            Obj0Descr = ThisApplication.ObjectDefs(Obj0id).Description
            NewRow.Attributes(1) = Obj0Descr
            NewRow.Attributes(2) = Obj0id
          End If
        End If
        'Исходный статус
        Status0id = RouteArr(1)
        If Status0id <> "" Then
          If ThisApplication.Statuses.Has(Status0id) = True Then
            Status0Descr = ThisApplication.Statuses(Status0id).Description
            NewRow.Attributes(3) = Status0Descr
            NewRow.Attributes(4) = Status0id
          End If
        End If
        'Результирующий объект
        Obj1id = RouteArr(2)
        If Obj1id <> "" Then
          If ThisApplication.ObjectDefs.Has(Obj1id) = True Then
            Obj1Descr = ThisApplication.ObjectDefs(Obj1id).Description
            NewRow.Attributes(5) = Obj1Descr
            NewRow.Attributes(6) = Obj1id
          End If
        End If
        'Результирующий статус
        Status1id = RouteArr(3)
        If Status1id <> "" Then
          If ThisApplication.Statuses.Has(Status1id) = True Then
            Status1Descr = ThisApplication.Statuses(Status1id).Description
            NewRow.Attributes(7) = Status1Descr
            NewRow.Attributes(8) = Status1id
          End If
        End If
        
        'Роли маршрута
        Roles = ""
        For j = 4 to Num
          RoleID = RouteArr(j)
          If Len(RoleID) > 1 Then
            If Roles <> "" Then
              Roles = Roles & " " & RoleID
            Else
              Roles = RoleID
            End If
          End If
        Next
        NewRow.Attributes(9) = Roles
    End If
  Next
  
  ThisApplication.Utility.WaitCursor = False
  Msgbox "Таблица маршрутов заполнена." & chr(10) & "Создано " & RowCount & " строк."
End Sub
