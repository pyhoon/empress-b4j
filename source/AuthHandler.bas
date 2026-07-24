B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=10.5
@EndOfDesignText@
' Auth Handler
' Version 0.30
Sub Class_Globals
	Private App As EndsMeet
	Private Path As String
	Private Method As String
	Private View As AuthView
	Private Model As AuthModel
	Private Request As ServletRequest
	Private Response As ServletResponse
End Sub

Public Sub Initialize
	App = Main.App
	View.Initialize
	Model.Initialize
End Sub

Sub Handle (req As ServletRequest, resp As ServletResponse)
	Request = req
	Response = resp
	Method = Request.Method
	Path = Request.RequestURI
	Log($"${Method}: ${Path}"$)
	If Path = "/login" Then
		If Method = "GET" Then
			ShowLoginPage("")
		Else
			HandleLogin
		End If
	Else If Path = "/register" Then
		If Method = "GET" Then
			ShowRegisterPage("")
		Else
			HandleRegister
		End If
	Else If Path = "/logout" Then
		HandleLogout
	End If
End Sub

Private Sub ShowLoginPage (Message As String)
	Dim MV As MainView
	MV.Initialize
	MV.LoadContent(View.Login(Message))
	App.WriteHtml2(Response, MV.Render.build, App.ctx)
End Sub

Private Sub ShowRegisterPage (Message As String)
	Dim MV As MainView
	MV.Initialize
	MV.LoadContent(View.Register(Message))
	App.WriteHtml2(Response, MV.Render.build, App.ctx)
End Sub

Private Sub HandleLogin
	Dim email As String = Request.GetParameter("email")
	Dim pass As String = Request.GetParameter("password")
	
	Dim row As Map = Model.GetRowByEmailAndPassword(email, pass)
	Dim user As String = row.Get("first_name") & " " & row.Get("last_name")
	Dim admin As String = row.Get("admin")
	If Model.Error.IsInitialized Then
		ShowLoginPage("Error querying user: " & Model.Error.Message)
		Return
	End If
	If row.Size > 0 Then
		If 1 = row.Get("admin") Then
			Request.GetSession.SetAttribute("user", user.Trim)
			Request.GetSession.SetAttribute("admin", admin)
			Response.SendRedirect("/pages")
			Return
		End If
	End If
	
	ShowLoginPage("Invalid email or password")
End Sub

Private Sub HandleRegister
	Dim user As String = Request.GetParameter("username")
	Dim email As String = Request.GetParameter("email")
	Dim pass As String = Request.GetParameter("password")
	
	Dim Found As Boolean = Model.FindRowByUsername(user)
	If Model.Error.IsInitialized Then
		ShowRegisterPage("Error creating user: " & Model.Error.Message)
		'ShowAlert(Model.Error.Message, "danger")
		Return
	End If
	
	If Found Then
		ShowRegisterPage("Username already exists")
		Return
	End If
	
	Model.Create(user, email, pass, "user")
	If Model.Error.IsInitialized Then
		ShowRegisterPage("Error creating user: " & Model.Error.Message)
		Return
	End If
	
	Response.SendRedirect("/login")
End Sub

Private Sub HandleLogout
	Request.GetSession.Invalidate
	Response.SendRedirect("/login")
End Sub