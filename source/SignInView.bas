B4J=true
Group=Views
ModulesStructureVersion=1
Type=Class
Version=10.3
@EndOfDesignText@
' Sign-In View
' Version 0.20
Sub Class_Globals

End Sub

Public Sub Initialize

End Sub

Public Sub Render As Tag
	Dim page1 As Tag = Html.lang("en")
	page1.add(PageHeader)
	page1.add(PageBody)
	Dim body1 As Tag = page1.ChildByTagName("body")
	'body1.add(BodyFooter)
	#If Bundle
	body1.script("$SERVER_URL$/assets/js/bootstrap.min.js")
	body1.script("$SERVER_URL$/assets/js/htmx.min.js")
	#Else
	body1.cdnScript("https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.min.js", _
	"sha384-G/EV+4j2dNv+tEPo3++6LCgdCROaejBqfUeNjuKAiuXbjrxilcCdDz6ZAVfHWe1Y")
	body1.cdnScript("https://cdn.jsdelivr.net/npm/htmx.org@2.0.8/dist/htmx.min.js", _
	"sha384-/TgkGk7p307TH7EXJDuUlgG3Ce1UVolAOFopFekQkkXihi5u/6OCvVKyz1W+idaz")
	#End If
	'body1.script("$SERVER_URL$/assets/js/app.js")
	Return page1
End Sub

Private Sub PageHeader As Tag
	Dim header1 As Tag = Head.init
	header1.add(Meta.attr("http-equiv", "content-type" ).attr("content", "text/html; charset=utf-8"))
	header1.add(Meta.attr("name", "viewport").attr("content", "width=device-width, initial-scale=1"))
	header1.add(Meta.attr("name", "description").attr("content", "Created using MiniHtml library"))
	header1.add(Meta.attr("name", "author").attr("content", "Author Name"))
	header1.title("$APP_TITLE$")
	header1.linkIcon("image/png", "$SERVER_URL$/assets/img/favicon.png")
	#If Bundle
	header1.linkCss("$SERVER_URL$/assets/css/bootstrap.min.css")
	header1.linkCss("$SERVER_URL$/assets/css/bootstrap-icons.min.css")
	#Else
	header1.cdnStyle("https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css", _
	"sha384-sRIl4kxILFvY47J16cr9ZwB07vP4J8+LH7qKQnuqkuIAvNWLzeN8tE5YBujZqJLB")
	header1.linkcss("https://cdn.jsdelivr.net/npm/bootstrap-icons@1.13.1/font/bootstrap-icons.min.css")
	#End If
	'header1.linkcss("$SERVER_URL$/assets/css/main.css?v=$VERSION$")
	Html.create("style").text($"html,
body {
  height: 100%;
}

.form-signin {
  max-width: 330px;
  padding: 1rem;
}

.form-signin .form-floating:focus-within {
  z-index: 2;
}

.form-signin input[type="email"] {
  margin-bottom: -1px;
  border-bottom-right-radius: 0;
  border-bottom-left-radius: 0;
}

.form-signin input[type="password"] {
  margin-bottom: 10px;
  border-top-left-radius: 0;
  border-top-right-radius: 0;
}"$).up(header1)
	Return header1
End Sub

Private Sub PageBody As Tag
	Dim body1 As Tag = Body.cls("d-flex align-items-center py-4 bg-body-tertiary")

	Dim main1 As Tag = Html.create("main").cls("form-signin w-100 m-auto").up(body1)
	Dim form1 As Tag = Form.up(main1)
	
	Icon.cls("h1 bi bi-infinity text-primary").up(form1)
	H1.cls("h3 mb-3 fw-normal").text("Please sign in").up(form1)
	
	Dim div1 As Tag = Div.cls("form-floating").up(form1)
	Input.typeOf("email").cls("form-control").id("floatingInput").attr("placeholder", "name@example.com").required.up(div1)
	Label.forId("floatingInput").text("Email address").up(div1)
	
	Dim div2 As Tag = Div.cls("form-floating").up(form1)
	Input.typeOf("password").cls("form-control").id("floatingPassword").attr("placeholder", "Password").required.up(div2)
	Label.forId("floatingPassword").text("Password").up(div2)
	
	Button.cls("btn btn-primary w-100 py-2").typeOf("submit").text("Sign In").up(form1)
	Paragraph.cls("mt-5 mb-3 text-body-secondary").text("© B4X 2025").up(form1)
	Return body1
End Sub