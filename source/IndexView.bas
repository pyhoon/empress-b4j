B4J=true
Group=Views
ModulesStructureVersion=1
Type=Class
Version=10.5
@EndOfDesignText@
' Index View
Sub Class_Globals
	Private App As EndsMeet
End Sub

Public Sub Initialize
	App = Main.App
End Sub

Public Sub Show (Req As ServletRequest) As String
	Dim CacheName As String = "Index Page"
	If MC.ExistInCache(App.ctx, CacheName) = False Then
		MC.WriteToCache(App.ctx, CacheName, IndexPage(Req))
	End If
	Dim page1 As MiniHtml = MC.ReadFromCache(App.ctx, CacheName)
	Dim doc As MiniHtml
	doc.Initialize("doctype")
	doc.Append(page1.build)
	Return doc.ToString
End Sub

Private Sub IndexPage (Req As ServletRequest) As MiniHtml
	Dim main1 As MainView
	main1.Initialize
	main1.LoadContent(ContainerContent)
	'main1.LoadSubContent(MH.GitHubLink)
	'main1.LoadModal(ContainerModal)
	'main1.LoadToast(ContainerToast)
	Dim page1 As MiniHtml = main1.Render
	Dim navbarCollapse As MiniHtml = page1.ChildById("navbarCollapse")
	Dim navitem1 As MiniHtml = navbarCollapse.ChildByIndex(0)
	If 1 = Req.GetSession.GetAttribute("admin") Then
		MH.PagesLink.up(navitem1)
		MH.TopicsLink.up(navitem1)
		MH.UsersLink.up(navitem1)
		If App.api.EnableHelp Then
			MH.HelpLink.up(navitem1)
		End If
		MH.SignOutLink.up(navitem1)
	Else
		MH.SignInLink.up(navitem1)
	End If
	Return page1
End Sub

Private Sub ContainerContent As MiniHtml
    Dim content1 As MiniHtml = MH.Div.cls("row mt-3 text-center align-items-center justify-content-center")
    Dim col1 As MiniHtml = MH.Div.up(content1).cls("col-md-12 col-lg-6")
    Dim container1 As MiniHtml = MH.Div.up(col1)
    container1.attr("hx-get", "/hx/pages/list")
    container1.attr("hx-trigger", "load")
    container1.text("Loading...")
    Return content1
End Sub