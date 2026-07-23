B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=10.3
@EndOfDesignText@
' Sign-In Handler class
' Version 0.30
Sub Class_Globals
	Private App As EndsMeet
	Private Path As String
	Private Method As String
	Private View As SignInView
	Private Model As UsersModel
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
    If Path = "/sign-in" Then
        HandlePage
    End If
End Sub

Private Sub HandlePage
	App.WriteHtml2(Response, View.Show(Request), App.ctx)
End Sub