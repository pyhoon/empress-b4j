B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=10.3
@EndOfDesignText@
' Sign-In Handler class
Sub Class_Globals
	Private App As EndsMeet
	Private Request As ServletRequest
	Private Response As ServletResponse
End Sub

Public Sub Initialize
    App = Main.App
End Sub

Sub Handle (req As ServletRequest, resp As ServletResponse)
    Request = req
    Response = resp
    Dim path As String = Request.RequestURI
    If path = "/sign-in" Then
        RenderPage
    End If
End Sub

Private Sub RenderPage
    Dim main1 As SignInView
    main1.Initialize
    'main1.LoadContent(ContentContainer)
    Dim page1 As MiniHtml = main1.Render
	
'    Dim body1 As MiniHtml = page1.ChildByIndex(1)
'    Dim nav1 As MiniHtml = body1.ChildByIndex(0)
'    Dim container1 As MiniHtml = nav1.ChildByIndex(0)
'    Dim navbar1 As MiniHtml = container1.ChildByIndex(3)
'    Dim ulist1 As MiniHtml = navbar1.ChildByIndex(0)
'  
'	Dim list0 As MiniHtml = MH.Li.cls("nav-item d-block d-lg-block").up(ulist1)
'	Dim anchor0 As MiniHtml = MH.Anchor.attr("href", "/help").up(list0)
'	anchor0.cls("nav-link")
'	anchor0.add(Icon.cls("bi bi-gear mr-2").attr("title", "API"))
'	anchor0.text("API")
'  
'    Dim list1 As MiniHtml = MH.Li.cls("nav-item d-block d-lg-block").up(ulist1)
'    Dim anchor1 As MiniHtml = MH.Anchor.attr("href", "/pages").up(list1)
'    anchor1.cls("nav-link")
'    anchor1.text("Pages")
'  
'    Dim list2 As MiniHtml = MH.Li.cls("nav-item d-block d-lg-block").up(ulist1)
'    Dim anchor2 As MiniHtml = MH.Anchor.attr("href", "/topics").up(list2)
'    anchor2.cls("nav-link")
'    anchor2.text("Topics")
'	
'	Dim list3 As MiniHtml = MH.Li.cls("nav-item d-block d-lg-block").up(ulist1)
'	Dim anchor3 As MiniHtml = MH.Anchor.attr("href", "/users").up(list3)
'	anchor3.cls("nav-link")
'	anchor3.text("Users")
	
    Dim doc As MiniHtml
	doc.Initialize("doctype")
    doc.Append(page1.build)
    App.WriteHtml2(Response, doc.ToString, App.ctx)
End Sub

'Private Sub ContentContainer As MiniHtml
'	'Dim form1 As MiniHtml = Form.init
'    Dim content1 As MiniHtml = MH.Div.cls("row mt-3 text-center align-items-center justify-content-center")
'    Dim col1 As MiniHtml = MH.Div.cls("col-md-12 col-lg-6").up(content1)
'    Dim container1 As MiniHtml = MH.Div.up(col1)
'    container1.attr("hx-get", "/hx/pages/list")
'    container1.attr("hx-trigger", "load")
'    container1.text("Loading...")
'
'    Return content1
'End Sub