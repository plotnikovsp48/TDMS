' Библиотека функций окрашивания выборок
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2016 г.

'Тип выделения формируется в виде строки содержащей следующие
'параметры через символ разделения ";":
'Цвет текста - значение long
'Цвет фона - значение long
'Жирный текст - Boolean
'Курсивный текст - Boolean
'Подчеркнутый текст - Boolean
'Перечеркнутый текст - Boolean
'Пример: HLtype = "auto;65535;true;true;false;false"

'=================================================================================================
'Функция форматирования строки по статусу
'Obj:Object - Объект выделения
'RowFormat:Object - Формат строки
'sName:String - Системное имя статуса
'HLtype:String - Тип выделения
Function QueryStatusStyle(Obj, RowFormat, sName, HLtype)
  QueryStatusStyle = False
  'Параметры выделения
  TextColor = -1 '0
  BackColor = -1 '16777215
  Bold = False
  Italic = False
  Uline = False
  StrikeOut = False
  Call DecryptHLtype(HLtype,TextColor,BackColor,Bold,Italic,Uline,StrikeOut)
  
  'Условие выделения
  If Obj.StatusName = sName Then
    Call HLtypeRun(RowFormat,TextColor,BackColor,Bold,Italic,Uline,StrikeOut)
    QueryStatusStyle = True
  End If
End Function

'=================================================================================================
'Функция форматирования строки по атрибуту
'Obj:Object - Объект выделения
'RowFormat:Object - Формат строки
'cValue:String - Текущее значение
'MinValue - Нижнее значение проверяемого атрибута
'MaxValue - Верхнее значение проверяемого атрибута
'HLtype0:String - Тип выделения: Текущее =< MinValue
'HLtype1:String - Тип выделения: MinValue < Текущее =< MaxValue
'HLtype2:String - Тип выделения" MaxValue > Текущее
Function QueryRangeStyle(Obj, RowFormat, cValue, MinValue, MaxValue, HLtype0, HLtype1, HLtype2)
  QueryRangeStyle = False
  'Параметры выделения
  TextColor = -1 '0
  BackColor = -1 '16777215
  Bold = False
  Italic = False
  Uline = False
  StrikeOut = False
  
  'Условие выделения
  If cValue =< MinValue Then
    Call DecryptHLtype(HLtype0,TextColor,BackColor,Bold,Italic,Uline,StrikeOut)
    Call HLtypeRun(RowFormat,TextColor,BackColor,Bold,Italic,Uline,StrikeOut)
    QueryRangeStyle = True
  ElseIf cValue > MinValue and cValue =< MaxValue Then
    Call DecryptHLtype(HLtype1,TextColor,BackColor,Bold,Italic,Uline,StrikeOut)
    Call HLtypeRun(RowFormat,TextColor,BackColor,Bold,Italic,Uline,StrikeOut)
    QueryRangeStyle = True
  Else
    Call DecryptHLtype(HLtype2,TextColor,BackColor,Bold,Italic,Uline,StrikeOut)
    Call HLtypeRun(RowFormat,TextColor,BackColor,Bold,Italic,Uline,StrikeOut)
    QueryRangeStyle = True
  End If
End Function

'=================================================================================================
'Процедура дешифровки типа выделения
'HLtype:String - Строка с параметрами форматирования
'TextColor:Long - цвет текста (-1 если без изменений)
'BackColor:Long - цвет фона (-1 если без изменений)
'Bold:Boolean - Жирный
'Italic:Boolean - Курсив
'Uline:Boolean - Подчеркивание
'StrikeOut:Boolean - Перечеркивание
Sub DecryptHLtype(HLtype,TextColor,BackColor,Bold,Italic,Uline,StrikeOut)
  Arr = Split(HLtype,";")
  If Ubound(Arr) = 5 Then
    If Arr(0) <> "auto" Then TextColor = Arr(0)
    If Arr(1) <> "auto" Then BackColor = Arr(1)
    If Arr(2) = "true" Then Bold = True
    If Arr(3) = "true" Then Italic = True
    If Arr(4) = "true" Then Uline = True
    If Arr(5) = "true" Then StrikeOut = True
  End If
End Sub

'=================================================================================================
'Процедура применения параметров выделения
'RowFormat:Object - Формат строки
'TextColor:Long - цвет текста (-1 если без изменений)
'BackColor:Long - цвет фона (-1 если без изменений)
'Bold:Boolean - Жирный
'Italic:Boolean - Курсив
'Uline:Boolean - Подчеркивание
'StrikeOut:Boolean - Перечеркивание
Sub HLtypeRun(RowFormat,TextColor,BackColor,Bold,Italic,Uline,StrikeOut)
  If TextColor <> -1 Then RowFormat.Color = TextColor
  If BackColor <> -1 Then RowFormat.BackColor = BackColor
  If Bold = True Then RowFormat.Bold = Bold
  If Italic = True Then RowFormat.Italic = Italic
  If Uline = True Then RowFormat.Underline = Uline
  If StrikeOut = True Then RowFormat.Strikeout = StrikeOut
End Sub


