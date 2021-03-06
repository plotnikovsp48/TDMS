' Выборка - Подготовка материалов (Внешние закупки)
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

USE "CMD_OBJECTS_STYLE_DLL"

Sub Query_AfterExecute(Sheet, Query, Obj)
  
  For i = 0 to Sheet.RowsCount-1
    Set Obj0 = Sheet.RowValue(i)
    
    'Форматирование строк
    Set RowFormat = Sheet.RowFormat(i)
    'ЖЕЛТЫМ – для закупок у которых до наступления даты, указанной в атрибуте
    aName = "ATTR_TENDER_GET_OFFERS_STOP_TIME"
    If Obj0.Attributes.Has(aName) Then
      aInt = 3
      MaxValue = Obj0.Attributes(aName).Value
      MinValue = MaxValue - aInt
      HLtype1 = "auto;65535;false;false;false;false"
      HLtype2 = "auto;255;false;false;false;false"
      Res = QueryRangeStyle(Obj0,RowFormat,Date,MinValue,MaxValue,"",HLtype1,HLtype2)
    End If
  Next

End Sub


