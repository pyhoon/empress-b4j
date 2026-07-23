B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=10.3
@EndOfDesignText@
' Sign-In Handler class
Sub Class_Globals
	Private App As EndsMeet
	Private View As SignInView
	Private Request As ServletRequest
	Private Response As ServletResponse
End Sub

Public Sub Initialize
    App = Main.App
	View.Initialize
End Sub

Sub Handle (req As ServletRequest, resp As ServletResponse)
    Request = req
    Response = resp
    Dim path As String = Request.RequestURI
    If path = "/sign-in" Then
        HandlePage
    End If
End Sub

Private Sub HandlePage
	App.WriteHtml2(Response, View.Show, App.ctx)
End Sub