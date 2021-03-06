' $Workfile: dump.CMD_OUTLOOK.scr $ 
' $Date: 20.02.07 18:04 $ 
' $Revision: 1 $ 
' $Author: Oreshkin $ 
'
' Модуль функций работы с Outlook
'------------------------------------------------------------------------------
' Авторское право © ЗАО «НАНОСОФТ», 2008 г.

'------------------------------------------------------------------------------
' Функция получает или создает объект "Outlook.Application"
' Open:Variant - объект "Outlook.Application"
'------------------------------------------------------------------------------
Function Open()
	Dim app,olNs ':Outlook.Application - ссылка на приложение 
	Set app = Nothing
	On Error Resume Next
		Set app = GetObject(,"Outlook.Application")
		If app Is Nothing Then
			Set app = CreateObject("Outlook.Application")
			Dim dicOutlook
			Set dicOutlook = ThisApplication.Dictionary("Outlook")
			dicOutlook.Add "Outlook",app	
		End If
	On Error GoTo 0
	Set Open = app
End Function

'------------------------------------------------------------------------------
' Функция закрывает приложение "Outlook.Application"
'------------------------------------------------------------------------------
Sub Close()
	Dim app
	On Error Resume Next
	Set app = dicOutlook.Item("Outlook")
	app.Quit
	On Error GoTo 0
End Sub


'------------------------------------------------------------------------------
' метод запускает команду Outlook "Send/Receive All"
' app_:Variant - объект "Outlook.Application"
'------------------------------------------------------------------------------
Sub SendReceiveNow(app_) 
	Dim vCtl ':CommandBarControls - Выполняемая команда
	Dim vPop ':CommandBarControls - Подменю
	Dim vCB  ':CommandBars - Главное меню Outlook
	Dim vNS  ':NameSpace - Текущая сессия
	Dim vExplorers ':Explorers - The Explorers object contains a set 
	               ' of Explorer objects representing all explorers
	Dim vFolder    ':MAPIFolder  - ссылка на папку "Inbox"
	Dim vExpl	   ':Explorer - Represents the window in which the 
	               ' contents of a folder are displayed.
	Const MAINMENU = "Menu Bar"
	Const SUBMENU = "Tools"
	Const POPMENU = "Send/Receive"
	Const CONTROL = "Send/Receive All"
		
	Set vNS = app_.GetNamespace("MAPI") 
	'Then use the Send/Receive on All Accounts action in the Tools 
	'menu to send the item from the Outbox, and receive new items 
	
	If app_.Explorers.Count = 0 Then
		Set vExplorers = app_.Explorers
		Set vFolder = vNS.GetDefaultFolder(6)
		Set vExpl = vExplorers.Add(vFolder, olFolderDisplayNoNavigation)
	Else  
		Set vExpl = app_.Explorers.Item(1)
	End If
	vExpl.Display
	Set vCB = vExpl.CommandBars(MAINMENU) 
	Set vPop = vCB.Controls(SUBMENU) 
	Set vPop = vPop.Controls(POPMENU) 
	Set vCtl = vPop.Controls(CONTROL) 
	vCtl.Execute 
	
	Set vExplorers = Nothing 
	Set vFolder = Nothing 
	Set vExpl = Nothing 
	Set vCtl = Nothing 
	Set vPop = Nothing 
	Set vCB = Nothing 
	Set vNS = Nothing 
End Sub 

'------------------------------------------------------------------------------
' функция выполняет выгрузку писем(вложения) из Outlook на локальный диск
' sMInPath_:String - папка Outlook с обрабатываемыми сообщениями
' sMOutPath_:String - папка Outlook с выгруженными сообщениями
' sMErrPath_:String - папка Outlook с ошибочными сообщениями
' sLInPath_:String - Локальная папка для выгрузки
' Upload:Boolean - результат выполнения выгрузки 
'------------------------------------------------------------------------------
Function Upload(sMInPath_,sMOutPath_,sMErrPath_,sLInPath_)
	Dim app        ':Outlook.Application - ссылка на приложение 
	Dim vFolder    ':MAPIFolder  - ссылка на папку с обрабатываемыми сообщениями
	Dim count      ':Integer - порядковый номер сообщения
	               ' Переменная count необходима для перебора сообщений учитывая,
	               ' что при перемещении сообщения в другую папку коллекция Items
	               ' динамически обновляется (функция Items.GetNext а также перебор
	               ' через <For Each> работают не корректно)
	
	count = 1
	Upload = False
	' Инициализация Outlook
	Set app = Open()
	If app Is Nothing Then Exit Function
'  	' Отправка получение почты
'  	Call SendReceiveNow(app) 
	' Получение почтовой папки
	Set vFolder = GetFolder(app,sMInPath_)
	If vFolder.Items.count>0 Then
		Do 
			Set vMail = vFolder.Items.Item(count)
			' Проверка вложения
			If CheckMailAttachment(vMail) Then
				' При неудачной выгрузке счетчик увеличивается
				' при удачной, количество элементов в коллекции 
				' динамически уменьшается, что дает возможность 
				' обратится к следующему элементу по тому же
				' индексу элемента
				If Not UploadMail(app,vMail,sMOutPath_,sLInPath_) Then
					count = count+1
				End If
			Else
				Call Move(app,vMail,sMErrPath_)
			End If
		Loop While (vFolder.Items.count>=count)
	End If
	Set vFolder = Nothing
	Set app = Nothing
End Function 

'------------------------------------------------------------------------------
' функция возвращает ссылку на папку Outlook
' app_:Variant - объект "Outlook.Application"
' sPath_:String - папка Outlook
' GetFolder:MAPIFolder  - ссылка на папку
'------------------------------------------------------------------------------
Function GetFolder(app_,sPath_)
	Dim vNS
	Dim vFolder
	Dim arrMPath
	Set vNS = app_.GetNamespace("MAPI") 
	Set vFolder = vNS.GetDefaultFolder(6)
	arrMPath = Split(sPath_,"\")
	For Each sFName In arrMPath
		Set vFolder = vFolder.Folders(sFName)
	Next
	Set GetFolder = vFolder
	Set vFolder = Nothing
	Set vNS = Nothing
End Function

'------------------------------------------------------------------------------
' функция проверяет вложение письма
' vMail_:MailItem - сообщение
' Upload:Boolean - результат проверки
'------------------------------------------------------------------------------
Function CheckMailAttachment(vMail_)
	Dim nXSLCount
	CheckMailAttachment = False
	nXSLCount = 0
	For Each vAttachment In vMail_.Attachments
		sFileName = vAttachment.DisplayName 
		If InStr(1,sFileName,".xls",1) Then
			nXSLCount = nXSLCount+1
		End If
	Next
	If nXSLCount=1 Then CheckMailAttachment = True
End Function

'------------------------------------------------------------------------------
' метод перемещает сообщение в папку sMPath_
' app_:Variant - объект "Outlook.Application"
' vMail_:MailItem - сообщение
' sMPath_:String - папка назначения(перемещения)
'------------------------------------------------------------------------------
Sub Move(app_,vMail_,sMPath_)
	Dim vFolder
	Set vFolder = GetFolder(app_,sMPath_)
	vMail_.Move vFolder
	Set vFolder = Nothing
End Sub

'------------------------------------------------------------------------------
' функция выгружает сообщение
' app_:Variant - объект "Outlook.Application"
' vMail_:MailItem - сообщение
' sMOutPath_:String - папка Outlook с выгруженными сообщениями
' sLInPath_:String - Локальная папка для выгрузки
' UploadMail:Boolean - результат выполнения выгрузки
'------------------------------------------------------------------------------
Function UploadMail(app_,vMail_,sMOutPath_,sLInPath_)
	Dim sInfo
	Dim sPath
	Const ForWriting = 2
	UploadMail = False
	' Сохранение вложения
	' Получение папки с выгруженным сообщением
	sPath = SaveAttachment(vMail_,sLInPath_)
	If sPath = " " Then Exit Function
	sInfo = GetMailInfo(vMail_)
	Call ThisApplication.ExecuteScript("CMD_FSO","Write",sPath&"\mailinf.txt",sInfo,ForWriting)
	Call Move(app_,vMail_,sMOutPath_)
	UploadMail = True
End Function

'------------------------------------------------------------------------------
' функция сохраняет вложение сообщения в папку на локальном диске
' vMail_:MailItem - сообщение
' sLInPath_:String - Локальная папка для выгрузки
' SaveAttachment:Boolean - результат сохранения
'------------------------------------------------------------------------------
Function SaveAttachment(vMail_,sLInPath_)
	Dim sFormFolderName
	Dim sPath
	sPath = sLInPath_
	SaveAttachment = " "
	sPath = sPath & "\" & FormatDateTime(vMail_.ReceivedTime)
	sPath = ThisApplication.ExecuteScript("CMD_FSO","CreateFolder",sPath)
	If sPath = " " Then Exit Function
	For Each vAttachment In vMail_.Attachments
		vAttachment.SaveAsFile sPath&"\"&vAttachment.DisplayName
	Next
	SaveAttachment = sPath
End Function


'------------------------------------------------------------------------------
' функция возвращает информацию о сообщении
' vMail_:MailItem - сообщение
' GetMailInfo:String - информацию о сообщении
'------------------------------------------------------------------------------
Function GetMailInfo(vMail_)
	Dim sAddress ':String - Адрес отправителя
	Dim sSubject ':String - Тема сообщения
	Dim EntryID
	EntryID = vMail_.EntryID
	sAddress = vMail_.SenderEmailAddress
	sSubject = vMail_.Subject
	GetMailInfo = EntryID&Chr(13)&Chr(10)&sAddress&Chr(13)&Chr(10)&sSubject
End Function

Function CreateMail(app_)
	Dim vFolder    ':MAPIFolder  - ссылка на папку с обрабатываемыми сообщениями
	Dim vNS
	Dim vMail
	Set vMail = app_.CreateItem(olMailItem)
	Set CreateMail = vMail
End Function

Sub AddAttachment(vMail_,sFullFileName_,sDisplayName_)
	Dim vattachments
	Set vattachments = vMail_.Attachments
	On Error Resume Next
		vattachments.Add sFullFileName_
	On Error GoTo 0
End Sub

Sub Send(arrFiles_,sTitle_)
	Dim vMail
	Dim app
	Dim sFullFileName,sFileName
	Dim f
	
	Set app = Open()
	If app Is Nothing Then Exit Sub
	Set vMail = CreateMail(app)
	
	For Each f In arrFiles_
		sFullFileName = f.WorkFileName
		sFileName = f.FileName 		
		Call AddAttachment(vMail,sFullFileName,sFileName)
	Next
	
	vMail.Subject = sTitle_
	vMail.Display	
	' !!!!!! Закрыть программу или сделать ее видемой (пладятся OUTLOOKи)
End Sub
