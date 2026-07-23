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

Public Sub Show As String
	Dim CacheName As String = "Index Page"
	If MC.ExistInCache(App.ctx, CacheName) = False Then
		MC.WriteToCache(App.ctx, CacheName, IndexPage)
	End If
	Dim page1 As MiniHtml = MC.ReadFromCache(App.ctx, CacheName)
	Dim doc As MiniHtml
	doc.Initialize("doctype")
	doc.Append(page1.build)
	Return doc.ToString
End Sub

Private Sub IndexPage As MiniHtml
	Dim main1 As MainView
    main1.Initialize
    main1.LoadContent(ContainerContent)
	'main1.LoadSubContent(MH.GitHubLink)
	'main1.LoadModal(ContainerModal)
	'main1.LoadToast(ContainerToast)
    Dim page1 As MiniHtml = main1.Render
	Dim navitem1 As MiniHtml = page1.ChildById("nav-item")
	'MH.TopicsLink.up(navitem1)
	If App.api.EnableHelp Then
		MH.HelpLink.up(navitem1)
	End If
	MH.SignInLink.up(navitem1)
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