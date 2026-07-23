B4J=true
Group=Views
ModulesStructureVersion=1
Type=Class
Version=10.3
@EndOfDesignText@
' Sign-In View
Sub Class_Globals
	Private App As EndsMeet
End Sub

Public Sub Initialize
	App = Main.App
End Sub

Public Sub Show (Req As ServletRequest) As String
	Dim CacheName As String = "SignIn Page"
	If MC.ExistInCache(App.ctx, CacheName) = False Then
		MC.WriteToCache(App.ctx, CacheName, SignInPage)
	End If
	Dim page1 As MiniHtml = MC.ReadFromCache(App.ctx, CacheName)
	Dim doc As MiniHtml
	doc.Initialize("doctype")
	doc.Append(page1.build)
	Return doc.ToString
End Sub

Public Sub SignInPage As MiniHtml
	Dim page1 As MiniHtml = MH.Html
	page1.add(PageHeader)
	page1.add(PageBody)
	Dim body1 As MiniHtml = page1.ChildByName("body")
	'Local assets
	'body1.script("$SERVER_URL$/assets/js/bootstrap.min.js")
	'body1.script("$SERVER_URL$/assets/js/htmx.min.js")
	body1.cdn("script", "https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.min.js") _
	.integrity("sha384-G/EV+4j2dNv+tEPo3++6LCgdCROaejBqfUeNjuKAiuXbjrxilcCdDz6ZAVfHWe1Y") _
	.crossorigin("anonymous")
	body1.cdn("script", "https://cdn.jsdelivr.net/npm/htmx.org@2.0.8/dist/htmx.min.js") _
	.integrity("sha384-/TgkGk7p307TH7EXJDuUlgG3Ce1UVolAOFopFekQkkXihi5u/6OCvVKyz1W+idaz") _
	.crossorigin("anonymous")
	'body1.script("$SERVER_URL$/assets/js/app.js")
	Return page1
End Sub

Private Sub PageHeader As MiniHtml
	Dim head1 As MiniHtml = MH.Head
	MH.Meta.up(head1).attr("http-equiv", "content-type" ).attr("content", "text/html; charset=utf-8")
	MH.Meta.up(head1).attr("name", "viewport").attr("content", "width=device-width, initial-scale=1")
	MH.Meta.up(head1).attr("name", "description").attr("content", "Created using Pakai framework")
	MH.Meta.up(head1).attr("name", "author").attr("content", "Aeric Poon")
	MH.Title.up(head1).text("$APP_TITLE$")
	MH.Link.up(head1).attr("rel", "icon").attr("type", "image/png").attr("href", "$SERVER_URL$/assets/img/favicon.png")
	'Local assets
	'head1.cdn("style", "$SERVER_URL$/assets/css/bootstrap.min.css")
	'head1.cdn("style", "$SERVER_URL$/assets/css/bootstrap-icons.min.css")
	head1.cdn("style", "https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css") _
	.integrity("sha384-sRIl4kxILFvY47J16cr9ZwB07vP4J8+LH7qKQnuqkuIAvNWLzeN8tE5YBujZqJLB").crossorigin("anonymous")
	head1.cdn("style", "https://cdn.jsdelivr.net/npm/bootstrap-icons@1.13.1/font/bootstrap-icons.min.css")
	'head1.cdn("style", "$SERVER_URL$/assets/css/main.css?v=$VERSION$")
	Dim css1 As MiniCss
	css1.Initialize(Me)
	css1.SetStartIndent("      ")
	Dim cb1 As MiniCssBuilder
	cb1.Initialize(css1)
	cb1.Rule("html, body")
	cb1.Property("height", "100%")
	cb1.Rule(".form-signin")
	cb1.Property("max-width", "330px")
	cb1.Property("padding", "1rem")
	cb1.Rule(".form-signin .form-floating:focus-within")
	cb1.Property("z-index", "2")
	cb1.Rule($".form-signin input[type="email"]"$)
	cb1.Property("margin-bottom", "-1px")
	cb1.Property("border-bottom-left-radius", "0")
	cb1.Property("border-bottom-right-radius", "0")
	cb1.Rule($".form-signin input[type="password"]"$)
	cb1.Property("margin-bottom", "10px")
	cb1.Property("border-top-left-radius", "0")
	cb1.Property("border-top-right-radius", "0")
	Dim sty1 As MiniHtml = MH.Style.up(head1)
	sty1.text(css1.GenerateCSS)
	Return head1
End Sub

Private Sub PageBody As MiniHtml
	Dim body1 As MiniHtml = MH.Body.cls("d-flex align-items-center py-4 bg-body-tertiary")
	Dim main1 As MiniHtml = MH.CreateTag("main").cls("form-signin w-100 m-auto").up(body1)
	Dim form1 As MiniHtml = MH.Form.up(main1)
	form1.attr("action", "/pages")
	MH.Icon.cls("h1 bi bi-infinity text-primary").up(form1)
	MH.H1.cls("h3 mb-3 fw-normal").text("Please sign in").up(form1)
	Dim div1 As MiniHtml = MH.Div.cls("form-floating").up(form1)
	MH.Input.attr("type", "email").cls("form-control").attr("id", "floatingInput").attr("placeholder", "name@example.com").required.up(div1)
	MH.Label.attr("for", "floatingInput").text("Email address").up(div1)
	Dim div2 As MiniHtml = MH.Div.cls("form-floating").up(form1)
	MH.Input.attr("type", "password").cls("form-control").attr("id", "floatingPassword").attr("placeholder", "Password").required.up(div2)
	MH.Label.attr("for", "floatingPassword").text("Password").up(div2)
	MH.Button.cls("btn btn-primary w-100 py-2").attr("type", "submit").text("Sign In").up(form1)
	MH.P.cls("mt-5 mb-3 text-body-secondary").text("&copy; B4X 2026").up(form1)
	Return body1
End Sub