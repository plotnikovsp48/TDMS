

Sub Form_BeforeShow(Form, Obj)
  Set Dict = ThisApplication.Dictionary("RoutesTree")
  Set Tree = Form.Controls("ROUTETREE").ActiveX
  Set Sheet1 = Nothing
  Root = Tree.InsertItem("Дерево маршрутов", 0, 1)
  Tree.SetItemIcon Root , ThisApplication.Icons.SystemIcon(40)
  SelectedItem = 0
  
  If Dict.Exists("Handle") Then
    Handle = Dict.Item("Handle")
    Set RouteObj = ThisApplication.Utility.GetObjectByHandle(Handle)
    Set Query = ThisApplication.Queries("QUERY_TABLE_ROUTE_SEARCH")
    Query.Parameter("ROUTE") = "=['" & RouteObj.Description & "']" & Handle
    Set Sheet1 = Query.Sheet
  End If
  
  If Sheet1 is Nothing Then Exit Sub
  ThisApplication.Utility.WaitCursor = True
  
  'Первый уровень
  ItemGuid1 = ""
  Temp1 = ""
  For i = 0 to Sheet1.RowsCount-1
    ItemGuid1 = Sheet1.CellValue(i,1)
    If InStr(Temp1, ItemGuid1) = 0 Then
      Temp1 = Temp1 & ";" & ItemGuid1
      ItemValue = Sheet1.CellValue(i,0)
      TableItem1 =  Tree.InsertItem(ItemValue, Root, 1)
      Tree.SetItemData TableItem1, ItemGuid1
      'Определяем иконку
      If ThisApplication.ObjectDefs.Has(ItemGuid1) Then
        Set Icon = ThisApplication.ObjectDefs(ItemGuid1).Icon
        Tree.SetItemIcon TableItem1 , Icon
      End If
      
      'Второй уровень
      Query.Parameter("Obj0id") = ItemGuid1
      Query.Parameter("Status0id") = ""
      Query.Parameter("Obj1id") = ""
      Set Sheet2 = Query.Sheet
      If Sheet2.RowsCount <> 0 Then
        Temp2 = ""
        For j = 0 to Sheet2.RowsCount-1
          ItemGuid2 = Sheet2.CellValue(j,3)
          If ItemGuid2 = "" Then ItemGuid2 = "NoStatus"
          If InStr(Temp2, ItemGuid2) = 0 Then
            Temp2 = Temp2 & ";" & ItemGuid2
            ItemValue = Sheet2.CellValue(j,2)
            If ItemValue = "" Then ItemValue = "Статус не указан"
            TableItem2 =  Tree.InsertItem(ItemValue, TableItem1, 1)
            Tree.SetItemData TableItem2, ItemGuid2
            Tree.SetItemIcon TableItem2, ThisApplication.Icons.SystemIcon(144)
            
            'Третий уровень
            If ItemGuid2 = "NoStatus" Then ItemGuid2 = ""
            Query.Parameter("Status0id") = ItemGuid2
            Query.Parameter("Obj1id") = ""
            Set Sheet3 = Query.Sheet
            If Sheet3.RowsCount <> 0 Then
              Temp3 = ""
              For k = 0 to Sheet3.RowsCount-1
                ItemGuid3 = Sheet3.CellValue(k,5)
                If InStr(Temp3, ItemGuid3) = 0 Then
                  Temp3 = Temp3 & ";" & ItemGuid3
                  ItemValue = Sheet3.CellValue(k,4)
                  TableItem3 =  Tree.InsertItem(ItemValue, TableItem2, 1)
                  Tree.SetItemData TableItem3, ItemGuid3
                  'Определяем иконку
                  If ThisApplication.ObjectDefs.Has(ItemGuid3) Then
                    Set Icon = ThisApplication.ObjectDefs(ItemGuid3).Icon
                    Tree.SetItemIcon TableItem3 , Icon
                  End If
                  
                  'Четвертый уровень
                  Query.Parameter("Obj1id") = ItemGuid3
                  Set Sheet4 = Query.Sheet
                  If Sheet3.RowsCount <> 0 Then
                    Temp4 = ""
                    For m = 0 to Sheet3.RowsCount-1
                      ItemGuid4 = Sheet3.CellValue(m,7)
                      If InStr(Temp4, ItemGuid4) = 0 Then
                        Temp4 = Temp4 & ";" & ItemGuid4
                        ItemValue = Sheet3.CellValue(m,6)
                        If ItemValue = "" Then ItemValue = "Статус не указан"
                        TableItem4 =  Tree.InsertItem(ItemValue, TableItem3, 1)
                        Tree.SetItemData TableItem4, ItemGuid4
                        Tree.SetItemIcon TableItem4, ThisApplication.Icons.SystemIcon(144)
                      End If
                    Next
                  End If
                  
                End If
              Next
            End If
            
          End If
        Next
      End If
    End If
  Next
  
  ThisApplication.Utility.WaitCursor = False
  
End Sub

'Узел выделен
Sub ROUTETREE_Selected(hItem,action)
  Set Tree = ThisForm.Controls("ROUTETREE").ActiveX
  Set RouteText = ThisForm.Controls("ROUTETEXT")
  RouteStr = ""
  
  If hItem <> Tree.RootItem Then
    RouteStr = Tree.GetItemText(hItem)
    ParentItem = Tree.GetParentItem(hItem)
    If ParentItem <> Tree.RootItem Then
      RouteStr = Tree.GetItemText(ParentItem) & " - " & RouteStr
      ParentItem = Tree.GetParentItem(ParentItem)
      If ParentItem <> Tree.RootItem Then
        RouteStr = Tree.GetItemText(ParentItem) & " - " & RouteStr
        ParentItem = Tree.GetParentItem(ParentItem)
        If ParentItem <> Tree.RootItem Then
          RouteStr = Tree.GetItemText(ParentItem) & " - " & RouteStr
        End If
      End If
    End If
  End If
  
  RouteText.Value = RouteStr
  
End Sub