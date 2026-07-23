B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=10.3
@EndOfDesignText@
' Index Handler class
Sub Class_Globals
	Private App As EndsMeet
	Private Path As String
	Private Method As String
	Private View As IndexView
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
	Path = Request.RequestURI
	Method = Request.Method.ToUpperCase
	Log($"${Method}: ${Path}"$)
	If Path = "/" Then
		HandlePage
	End If
End Sub

Private Sub HandlePage
	App.WriteHtml2(Response, View.Show(Request), App.ctx)
End Sub