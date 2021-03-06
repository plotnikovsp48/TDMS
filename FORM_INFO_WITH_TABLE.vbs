' Форма ввода - Информационное окно
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

Sub Form_BeforeShow(Form, Obj)
  Set Grid = Form.Controls("TDMSGRID1").ActiveX
  
  'Инициализация таблицы
  Grid.ColumnAutosize = True
  Grid.InsertMode = False
  Grid.ReadOnly = True
  Grid.InsertColumn Grid.ColumnCount, "Параметр", 120
  Grid.InsertColumn Grid.ColumnCount, "Заданное значение", 120
  Grid.InsertColumn Grid.ColumnCount, "Расчетное значение", 120
  For i = 0 to 3
    Grid.InsertRow Grid.RowCount
  Next
  
  'Заполнение таблицы
  Grid.CellValue(0,0) = "НДС"
  Grid.CellValue(1,0) = "Цена без НДС"
  Grid.CellValue(2,0) = "Цена с НДС"
  Grid.CellValue(3,0) = "Сумма НДС"
  Set Dict = Form.Dictionary
'  Grid.CellValue(0,1) = Dict.Item("ATTR_LOT_NDS_VALUE")
  Grid.CellValue(0,1) = Dict.Item("ATTR_NDS_VALUE")
  Grid.CellValue(1,1) = Dict.Item("ATTR_TENDER_PRICE")
  Grid.CellValue(2,1) = Dict.Item("ATTR_TENDER_NDS_PRICE")
  Grid.CellValue(3,1) = Dict.Item("ATTR_TENDER_SUM_NDS")
  Grid.CellValue(0,2) = Grid.CellValue(0,1)
  Grid.CellValue(2,2) = Grid.CellValue(2,1)
  Val = Grid.CellValue(0,1)
  x = 0
  If StrComp(Val,"Без НДС",vbTextCompare) = 0 Then
    x = 0
  ElseIf StrComp(Val,"НДС 0%",vbTextCompare) = 0 Then
    x = 0
  ElseIf StrComp(Val,"НДС 10%",vbTextCompare) = 0 Then
    x = 0.1
  ElseIf StrComp(Val,"НДС 18%",vbTextCompare) = 0 Then
    x = 0.18
  End If
  Val = Grid.CellValue(2,1)
  Grid.CellValue(1,2) = Round(Val - Val / 1.18 * x , 4)
  Grid.CellValue(3,2) = Round(Val / 1.18 * x , 4)
End Sub


