

Sub Object_PropertiesDlgBeforeClose(Obj, OkBtnPressed, Cancel)
  'Очищаем словарь параметров таблицы маршрутов
  ThisApplication.Dictionary("QueryRoute").RemoveAll
End Sub