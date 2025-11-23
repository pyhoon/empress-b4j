B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=10.3
@EndOfDesignText@
' Index Handler class
' Version 6.30
Sub Class_Globals
	Private DB As MiniORM
	Private App As EndsMeet
	Private Method As String
	Private Request As ServletRequest
	Private Response As ServletResponse
End Sub

Public Sub Initialize
	App = Main.App
	DB.Initialize(Main.DBType, Null)
End Sub

Sub Handle (req As ServletRequest, resp As ServletResponse)
	Request = req
	Response = resp
	Method = req.Method
	Log($"${Request.Method}: ${Request.RequestURI}"$)
	Dim path As String = req.RequestURI
	If path = "/pages" Then
		RenderPage
	Else If path = "/hx/pages/table" Then
		HandleTable
	Else If path = "/hx/pages/list" Then
		HandlePagesList
	Else If path = "/hx/pages/search" Then
		HandleSearch
	Else If path = "/hx/pages/add" Then
		HandleAddModal
	Else If path.StartsWith("/hx/pages/edit/") Then
		HandleEditModal
	Else If path.StartsWith("/hx/pages/delete/") Then
		HandleDeleteModal
	Else
		HandlePages
	End If
End Sub

Private Sub RenderPage
	Dim main1 As MainView
	main1.Initialize
	main1.LoadContent(ContentContainer)
	main1.LoadSubContent(GitHubLink)
	main1.LoadModal(ModalContainer)
	main1.LoadToast(ToastContainer)

	Dim page1 As Tag = main1.Render
	Dim ulist1 As Tag = FindUListTag(page1)
	
	Dim list0 As Tag = Li.cls("nav-item d-block d-lg-block").up(ulist1)
	Dim anchor0 As Tag = Anchor.href("/help").up(list0)
	anchor0.cls("nav-link")
	anchor0.add(Icon.cls("bi bi-gear mr-2").title("API"))
	anchor0.text("API")
  
    Dim list1 As Tag = Li.cls("nav-item d-block d-lg-block").up(ulist1)
    Dim anchor1 As Tag = Anchor.href("#").up(list1)
    anchor1.cls("nav-link")
    anchor1.text("Pages")
  
    Dim list2 As Tag = Li.cls("nav-item d-block d-lg-block").up(ulist1)
    Dim anchor2 As Tag = Anchor.href("/topics").up(list2)
    anchor2.cls("nav-link")
    anchor2.text("Topics")
	
	Dim list3 As Tag = Li.cls("nav-item d-block d-lg-block").up(ulist1)
	Dim anchor3 As Tag = Anchor.href("/users").up(list3)
	anchor3.cls("nav-link")
	anchor3.text("Users")

	Dim doc As Document
	doc.Initialize
	doc.AppendDocType
	doc.Append(page1.build)
	App.WriteHtml2(Response, doc.ToString, App.ctx)
End Sub

' Retrieve ulist tag from DOM
Private Sub FindUListTag (dom As Tag) As Tag
	Dim body1 As Tag = dom.Child(1)
	Dim nav1 As Tag = body1.Child(1)
	Dim container1 As Tag = nav1.Child(0)
	Dim navbar1 As Tag = container1.Child(3)
	Dim ulist1 As Tag = navbar1.Child(0)
	Return ulist1
End Sub

Private Sub ContentContainer As Tag
	Dim content1 As Tag = Div.cls("row mt-3")
	Dim col12 As Tag = Div.cls("col-md-12").up(content1)
	Dim form1 As Tag = Form.cls("form mb-3").up(col12)
	Dim row1 As Tag = Div.cls("row").up(form1)
	Dim col1 As Tag = Div.cls("col-md-6 col-lg-6").up(row1)

	Dim input_group1 As Tag = col1.add(Div.cls("input-group mb-3"))
	input_group1.add(Label.forId("keyword").cls("input-group-text mt-2").text("Search"))
	input_group1.add(Input.typeOf("text").cls("form-control col-md-6 mt-2").id("keyword").name("keyword"))

	Dim searchBtn As Tag = input_group1.add(Button.cls("btn btn-danger btn-md pl-3 pr-3 ml-3 mt-2").text("Submit"))
	searchBtn.hxPost("/hx/pages/search")
	searchBtn.hxTarget("#pages-container")
	searchBtn.hxSwap("innerHTML")

	Dim col2 As Tag = Div.cls("col-md-6 col-lg-6").up(row1)
	Dim div2 As Tag = Div.cls("float-end mt-2").up(col2)

	'Dim anchor1 As Tag = Anchor.up(div2)
	'anchor1.hrefOf("$SERVER_URL$/topics")
	'anchor1.cls("btn btn-primary me-2")
	'anchor1.add(Icon.cls("bi bi-list me-2"))
	'anchor1.text("Show topic")

	Dim button2 As Tag = Button.up(div2)
	button2.cls("btn btn-success ml-2")
	button2.hxGet("/hx/pages/add")
	button2.hxTarget("#modal-content")
	button2.hxTrigger("click")
	button2.data("bs-toggle", "modal")
	button2.data("bs-target", "#modal-container")
	button2.add(Icon.cls("bi bi-plus-lg me-2"))
	button2.text("Add Page")

	Dim container1 As Tag = Div.up(col12)
	container1.id("pages-container")
	container1.hxGet("/hx/pages/table")
	container1.hxTrigger("load")
	container1.text("Loading...")
	
	Return content1
End Sub

Private Sub GitHubLink As Tag
	Dim div1 As Tag = Div.cls("text-center mb-3")
	Dim anchor1 As Tag = Anchor.up(div1)
	anchor1.hrefOf("https://github.com/pyhoon/empress-b4j")
	anchor1.cls("text-primary mr-1")
	anchor1.aria("label", "github").attr("title", "GitHub").targetOf("_blank")
	Dim svg1 As Tag = Svg.up(anchor1)
	svg1.aria("hidden", "true")
	svg1.width("24").height("24")
	svg1.attr("version", "1.1")
	svg1.attr("viewBox", "0 0 16 16")
	Dim path1 As Tag = Html.create("path").up(svg1)
	path1.attr("fill-rule", "evenodd")
	path1.attr("d", "M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0 0 16 8c0-4.42-3.58-8-8-8z")
	Dim anchor2 As Tag = Anchor.up(div1)
	anchor2.hrefOf("https://github.com/pyhoon/empress-b4j")
	anchor2.sty("text-decoration: none")
	anchor2.targetOf("_blank")
	Span.sty("vertical-align: middle").text("GitHub").up(anchor2)
	Return div1
End Sub

Private Sub ModalContainer As Tag
	Dim modal1 As Tag = Div.id("modal-container")
	modal1.cls("modal fade")
	modal1.attr("tabindex", "-1")
	modal1.aria("hidden", "true")
	Dim modalDialog As Tag = Div.up(modal1).cls("modal-dialog modal-dialog-centered")
	Div.cls("modal-content").id("modal-content").up(modalDialog)
	Return modal1
End Sub

Private Sub ToastContainer As Tag
	Dim div1 As Tag = Div.cls("position-fixed end-0 p-3")
	div1.sty("z-index: 2000")
	div1.sty("bottom: 0%")
	Dim toast1 As Tag = Div.id("toast-container").up(div1)
	toast1.cls("toast align-items-center text-bg-success border-0")
	toast1.attr("role", "alert")
	Dim div2 As Tag = Div.cls("d-flex").up(toast1)
	Dim div3 As Tag = Div.cls("toast-body").id("toast-body").up(div2)
	div3.text("Operation successful!")
	Dim button1 As Tag = Button.typeOf("button").up(div2)
	button1.cls("btn-close btn-close-white me-2 m-auto")
	button1.data("bs-dismiss", "toast")
	Return div1
End Sub

' Return table HTML
Private Sub HandleTable
	App.WriteHtml(Response, CreatePagesTable.Build)
End Sub

Private Sub HandlePagesList
	DB.SQL = Main.DBOpen
	DB.Table = "pages p"
	DB.Columns = Array("p.id", "p.topic_id", "t.topic_name", "p.page_slug", "p.page_title", "p.page_body", "p.page_status", "Date(p.created_date) AS created_date", "u.first_name AS author")
	DB.Join = DB.CreateJoin("topics t", "p.topic_id = t.id", "")
	DB.Join = DB.CreateJoin("users u", "p.created_by = u.id", "")
	DB.OrderBy = CreateMap("p.id": "")
	DB.Query
  
	Dim div1 As Tag = Div.init
	For Each row As Map In DB.Results
		Dim page_slug As String = row.Get("page_slug")
		Dim page_body As String = row.Get("page_body")
		Dim page_title As String = row.Get("page_title")
		Dim page_status As String = row.Get("page_status")
		Dim topic_name As String = row.Get("topic_name")
		Dim page_created As String = "created on " & row.Get("created_date")
		page_created = page_created & " by " & row.Get("author")
      
		Dim card1 As Tag = Div.cls("card text-start mb-3")
		Dim cardbody1 As Tag = Div.cls("card-body").up(card1)
		H5.cls("card-title").up(cardbody1).text(page_title)
		H6.cls("card-subtitle mb-2 text-body-secondary").up(cardbody1).text(page_created)
		Paragraph.cls("card-text").up(cardbody1).text(page_body)
		card1.up(div1)
	Next
	DB.Close
	App.WriteHtml(Response, div1.Build)
End Sub

' Search page using keyword
Private Sub HandleSearch
	Dim table1 As Tag = HtmlTable.cls("table table-bordered table-hover rounded small")
	Dim thead1 As Tag = table1.add(Thead.cls("table-light"))
	thead1.add(Th.sty("text-align: right; width: 50px").text("#"))
	thead1.add(Th.text("Slug"))
	thead1.add(Th.text("Title"))
	thead1.add(Th.text("Topic"))
	thead1.add(Th.sty("text-align: right").text("Status"))
	thead1.add(Th.sty("text-align: center; width: 120px").text("Actions"))
	Dim tbody1 As Tag = table1.add(Tbody.init)

	DB.SQL = Main.DBOpen
	DB.Table = "pages p"
	DB.Columns = Array("p.id", "p.topic_id", "t.topic_name", "p.page_slug", "p.page_title", "p.page_status")
	DB.Join = DB.CreateJoin("topics t", "p.topic_id = t.id", "")
	Dim keyword As String = Request.GetParameter("keyword")
	If keyword <> "" Then
		DB.Where = Array("p.page_slug LIKE ? Or UPPER(p.page_title) LIKE ? Or UPPER(t.topic_name) LIKE ?")
		DB.Parameters = Array("%" & keyword & "%", "%" & keyword.ToUpperCase & "%", "%" & keyword.ToUpperCase & "%")
	End If
	DB.OrderBy = CreateMap("p.id": "")
	DB.Query
	For Each row As Map In DB.Results
		Dim id As Int = row.Get("id")
		Dim page_slug As String = row.Get("page_slug")
		Dim page_title As String = row.Get("page_title")
		Dim page_status As Int = row.Get("page_status")
		Dim topic_name As String = row.Get("topic_name")

		Dim tr1 As Tag = Tr.init.up(tbody1)
		tr1.add(Td.cls("align-middle").sty("text-align: right").text(id))
		tr1.add(Td.cls("align-middle").text(page_slug))
		tr1.add(Td.cls("align-middle").text(page_title))
		tr1.add(Td.cls("align-middle").text(topic_name))
		tr1.add(Td.cls("align-middle").sty("text-align: right").text(page_status))
		Dim td1 As Tag = tr1.add(Td.cls("align-middle text-center px-1 py-1"))

		Dim anchor1 As Tag = Anchor.cls("edit text-primary mx-2").up(td1)
		anchor1.hxGet($"/hx/pages/edit/${id}"$)
		anchor1.hxTarget("#modal-content")
		anchor1.hxTrigger("click")
		anchor1.data("bs-toggle", "modal")
		anchor1.data("bs-target", "#modal-container")
		anchor1.add(Icon.cls("bi bi-pencil"))
		anchor1.attr("title", "Edit")
		
		Dim anchor2 As Tag = Anchor.cls("delete text-danger mx-2").up(td1)
		anchor2.hxGet($"/hx/pages/delete/${id}"$)
		anchor2.hxTarget("#modal-content")
		anchor2.hxTrigger("click")
		anchor2.data("bs-toggle", "modal")
		anchor2.data("bs-target", "#modal-container")
		anchor2.add(Icon.cls("bi bi-trash3"))
		anchor2.attr("title", "Delete")
	Next
	DB.Close
	App.WriteHtml(Response, table1.Build)
End Sub

' Add modal
Private Sub HandleAddModal
	Dim form1 As Tag = Form.init
	form1.hxPost("/hx/pages")
	form1.hxTarget("#modal-messages")
	form1.hxSwap("innerHTML")

	Dim modalHeader As Tag = Div.cls("modal-header").up(form1)
	modalHeader.add(H5.cls("modal-title").text("Add Page"))
	modalHeader.add(Button.typeOf("button").cls("btn-close").data("bs-dismiss", "modal"))
	
	Dim modalBody As Tag = Div.cls("modal-body").up(form1)
	Div.id("modal-messages").up(modalBody)
	
	Dim group1 As Tag = Div.cls("form-group").up(modalBody)
	Label.forId("topic1").text("Topic ").up(group1).add(Span.cls("text-danger").text("*"))
	
	Dim select1 As Tag = CreateTopicsDropdown(-1)
	select1.id("topic1")
	select1.name("topic_id")
	select1.up(group1)

	'Dim group2 As Tag = Div.cls("form-group").up(modalBody)
	'group2.add(Label.text("Slug ")).add(Span.cls("text-danger").text("*"))
	'group2.add(Input.typeOf("text").name("page_slug").cls("form-control").attr3("required"))

	Dim group3 As Tag = Div.cls("form-group").up(modalBody)
	group3.add(Label.text("Title ")).add(Span.cls("text-danger").text("*"))
	group3.add(Input.typeOf("text").name("page_title").cls("form-control").attr3("required"))

	Dim group4 As Tag = Div.cls("form-group").up(modalBody)
	group4.add(Label.text("Body ")).add(Span.cls("text-danger").text("*"))
	group4.add(Textarea.rows("3").name("page_body").cls("form-control").attr3("required"))

    Dim group5 As Tag = modalBody.add(Div.cls("form-group"))
    Label.forId("status").text("Status ").up(group5).add(Span.cls("text-danger").text("*"))
    Dim select1 As Tag = Dropdown.up(group5).id("status").name("status").cls("form-select").attr3("required")
    Option.valueOf("0").text("Draft").up(select1)
    Option.valueOf("1").text("Published").up(select1)

	Dim modalFooter As Tag = Div.cls("modal-footer").up(form1)
	modalFooter.add(Button.typeOf("submit").cls("btn btn-success px-3").text("Create"))
	modalFooter.add(Input.typeOf("button").cls("btn btn-secondary px-3").data("bs-dismiss", "modal").attr("value", "Cancel"))
	App.WriteHtml(Response, form1.Build)
End Sub

' Edit modal
Private Sub HandleEditModal
	Dim id As String = Request.RequestURI.SubString("/hx/pages/edit/".Length)
	Dim form1 As Tag = Form.init
	form1.hxPut($"/hx/pages"$)
	form1.hxTarget("#modal-messages")
	form1.hxSwap("innerHTML")
		
	DB.SQL = Main.DBOpen
	DB.Table = "pages"
	DB.Columns = Array("topic_id", "page_slug", "page_title", "page_body", "page_status")
	DB.WhereParam("id = ?", id)
	DB.Query
	If DB.Found Then
		Dim row As Map = DB.First
		Dim page_slug As String = row.Get("page_slug")
		Dim page_title As String = row.Get("page_title")
		Dim page_body As String = row.Get("page_body")
		Dim page_status As Int = row.Get("page_status")
		Dim topic_id As Int = row.Get("topic_id")

		Dim modalHeader As Tag = Div.cls("modal-header").up(form1)
		H5.cls("modal-title").text("Edit Page").up(modalHeader)
		Button.typeOf("button").cls("btn-close").data("bs-dismiss", "modal").up(modalHeader)
		
		Dim modalBody As Tag = Div.cls("modal-body").up(form1)
		Div.id("modal-messages").up(modalBody)
		Input.typeOf("hidden").up(modalBody).name("id").valueOf(id)
		
		Dim group1 As Tag = Div.cls("form-group").up(modalBody)
		Label.forId("topic2").text("Topic ").up(group1).add(Span.cls("text-danger")).text("*")
		
		Dim select1 As Tag = CreateTopicsDropdown(topic_id)
		select1.id("topic2")
		select1.name("topic_id")
		select1.up(group1)
		
		Dim group2 As Tag = Div.cls("form-group").up(modalBody)
		group2.add(Label.text("Slug ")).add(Span.cls("text-danger").text("*"))
		group2.add(Input.typeOf("text").cls("form-control").name("page_slug").valueOf(page_slug))

		Dim group3 As Tag = Div.cls("form-group").up(modalBody)
		group3.add(Label.text("Title ")).add(Span.cls("text-danger").text("*"))
		group3.add(Input.typeOf("text").cls("form-control").name("page_title").valueOf(page_title).attr3("required"))

		Dim group4 As Tag = Div.cls("form-group").up(modalBody)
		group4.add(Label.text("Body ")).add(Span.cls("text-danger").text("*"))
		group4.add(Textarea.rows("3").cls("form-control").name("page_body").text(page_body).attr3("required"))

		Dim group5 As Tag = modalBody.add(Div.cls("form-group"))
        Label.forId("status").text("Status ").up(group5).add(Span.cls("text-danger").text("*"))
        Dim select1 As Tag = Dropdown.up(group5).id("status").name("page_status").cls("form-select").attr3("required")
        Dim option0 As Tag = Option.valueOf("0").text("Draft").up(select1)
        Dim option1 As Tag = Option.valueOf("1").text("Published").up(select1)
		If page_status = 0 Then option0.selected
        If page_status = 1 Then option1.selected
				
		Dim modalFooter As Tag = Div.cls("modal-footer").up(form1)
		modalFooter.add(Button.cls("btn btn-primary px-3").text("Update"))
		modalFooter.add(Input.typeOf("button").cls("btn btn-secondary px-3").data("bs-dismiss", "modal").valueOf("Cancel"))
	End If
	DB.Close
	App.WriteHtml(Response, form1.Build)
End Sub

Private Sub CreateTopicsDropdown (selected As Int) As Tag
	Dim select1 As Tag = Dropdown.cls("form-select")
	select1.attr3("required")
	select1.hxGet("/hx/topics/list")
	Option.valueOf("").text("Select topic").attr3(IIf(selected < 1, "selected", "")).attr3("disabled").up(select1)

	DB.SQL = Main.DBOpen
	DB.Table = "topics"
	DB.Columns = Array("id", "topic_name")
	DB.Query
	For Each row As Map In DB.Results
		Dim topic_id As Int = row.Get("id")
		Dim topic_name As String = row.Get("topic_name")
		If topic_id = selected Then
			Option.valueOf(topic_id).attr3("selected").text(topic_name).up(select1)
		Else
			Option.valueOf(topic_id).text(topic_name).up(select1)
		End If
	Next
	DB.Close
	Return select1
End Sub

' Delete modal
Private Sub HandleDeleteModal
	Dim id As String = Request.RequestURI.SubString("/hx/pages/delete/".Length)
	Dim form1 As Tag = Form.init
	form1.hxDelete($"/hx/pages"$)
	form1.hxTarget("#modal-messages")
	form1.hxSwap("innerHTML")
		
	DB.SQL = Main.DBOpen
	DB.Table = "pages"
	DB.Columns = Array("id", "page_slug", "page_title")
	DB.WhereParam("id = ?", id)
	DB.Query
	If DB.Found Then
		Dim row As Map = DB.First
		'Dim page_slug As String = row.Get("page_slug")
		Dim page_title As String = row.Get("page_title")

		Dim modalHeader As Tag = Div.cls("modal-header").up(form1)
		H5.cls("modal-title").text("Delete Page").up(modalHeader)
		Button.typeOf("button").cls("btn-close").data("bs-dismiss", "modal").up(modalHeader)
		
		Dim modalBody As Tag = Div.cls("modal-body").up(form1)
		Div.id("modal-messages").up(modalBody)
		Input.typeOf("hidden").name("id").valueOf(id).up(modalBody)
		Paragraph.text($"Delete ${page_title}?"$).up(modalBody)
		
		Dim modalFooter As Tag = Div.cls("modal-footer").up(form1)
		Button.cls("btn btn-danger px-3").text("Delete").up(modalFooter)
		Input.typeOf("button").cls("btn btn-secondary px-3").data("bs-dismiss", "modal").valueOf("Cancel").up(modalFooter)
	End If
	DB.Close
	App.WriteHtml(Response, form1.Build)
End Sub

' Handle CRUD operations
Private Sub HandlePages
	Select Method
		Case "POST"
			' Create
			'Dim page_slug As String = Request.GetParameter("page_slug")
			Dim page_title As String = Request.GetParameter("page_title")
			Dim page_body As String = Request.GetParameter("page_body")
			Dim tempstatus As String = Request.GetParameter("page_status")
			Dim page_status As Int = IIf(tempstatus.Trim = "", 0, tempstatus)
			Dim topic_id As String = Request.GetParameter("topic_id")
			
			If page_title = "" Then
				ShowAlert("Page title must not be empty.", "warning")
				Return
			End If

			Dim page_slug As String = Utilities.Slugify(page_title)
			If page_slug = "" Or page_slug.Trim.Length < 2 Then
				ShowAlert("Page slug must be at least 2 characters long.", "warning")
				Return
			End If
			
			If page_body = "" Then
				ShowAlert("Page body must not be empty.", "warning")
				Return
			End If
			
			' Check conflict
			Try
				DB.SQL = Main.DBOpen
				DB.Table = "pages"
				DB.Where = Array("page_slug = ?")
				DB.Parameters = Array(page_slug)
				DB.Query
				If DB.Found Then
					ShowAlert("Page slug already exists!", "warning")
					DB.Close
					Return
				End If
			Catch
				Log(LastException)
				ShowAlert($"Database error: ${LastException.Message}"$, "danger")
			End Try
			' Insert new row
			Try
				DB.Reset
				DB.Columns = Array("topic_id", "page_slug", "page_title", "page_body", "page_status", "created_date")
				DB.Parameters = Array(topic_id, page_slug, page_title, page_body, page_status, Main.CurrentDateTime)
				DB.Save
				ShowToast("Page", "created", "Page created successfully!", "success")
			Catch
				ShowAlert($"Database error: ${LastException.Message}"$, "danger")
			End Try
			DB.Close
		Case "PUT"
			' Update
			Dim id As Int = Request.GetParameter("id")
			Dim page_slug As String = Request.GetParameter("page_slug")
			Dim page_title As String = Request.GetParameter("page_title")
			Dim page_body As String = Request.GetParameter("page_body")
			Dim page_status As Int = Request.GetParameter("page_status")
			Dim topic_id As String = Request.GetParameter("topic_id")
			
			If page_slug = "" Or page_slug.Trim.Length < 2 Then
				ShowAlert("Page slug must be at least 2 characters long.", "warning")
				Return
			End If
			
			DB.SQL = Main.DBOpen
			DB.Table = "pages"
			DB.Find(id)
			If DB.Found = False Then
				ShowAlert("Page not found!", "warning")
				DB.Close
				Return
			End If

			DB.Reset
			DB.Where = Array("page_slug = ?", "id <> ?")
			DB.Parameters = Array(page_slug, id)
			DB.Query
			If DB.Found Then
				ShowAlert("Page slug already exists!", "warning")
				DB.Close
				Return
			End If
			
			' Update row
			Try
				DB.Reset
				DB.Columns = Array("topic_id", "page_slug", "page_title", "page_body", "page_status", "modified_date")
				DB.Parameters = Array(topic_id, page_slug, page_title, page_body, page_status, Main.CurrentDateTime)
				DB.Id = id
				DB.Save
				ShowToast("Page", "updated", "Page updated successfully!", "info")
			Catch
				ShowAlert($"Database error: ${LastException.Message}"$, "danger")
			End Try
			DB.Close
		Case "DELETE"
			' Delete
			Dim id As Int = Request.GetParameter("id")
			
			DB.SQL = Main.DBOpen
			DB.Table = "pages"
			DB.Find(id)
			If DB.Found = False Then
				ShowAlert("Page not found!", "warning")
				DB.Close
				Return
			End If

			' Delete row
			Try
				DB.Table = "pages"
				DB.Id = id
				DB.Delete
				ShowToast("Page", "deleted", "Page deleted successfully!", "danger")
			Catch
				ShowAlert($"Database error: ${LastException.Message}"$, "danger")
			End Try
			DB.Close
	End Select
End Sub

Private Sub CreatePagesTable As Tag
	Dim table1 As Tag = HtmlTable.cls("table table-bordered table-hover rounded small")
	Dim thead1 As Tag = table1.add(Thead.cls("table-light"))
	thead1.add(Th.sty("text-align: right; width: 50px").text("#"))
	thead1.add(Th.text("Slug"))
	thead1.add(Th.text("Title"))
	thead1.add(Th.sty("text-align: center").text("Topic"))
	thead1.add(Th.sty("text-align: center").text("Status"))
	thead1.add(Th.sty("text-align: center; width: 120px").text("Actions"))
	Dim tbody1 As Tag = table1.add(Tbody.init)

	DB.SQL = Main.DBOpen
	DB.Table = "pages p"
	DB.Columns = Array("p.id", "p.topic_id", "t.topic_name", "p.page_slug", "p.page_title", "p.page_status")
	DB.Join = DB.CreateJoin("topics t", "p.topic_id = t.id", "")
	DB.OrderBy = CreateMap("p.id": "")
	DB.Query
	For Each row As Map In DB.Results
		Dim tr1 As Tag = CreatePagesRow(row)
		tr1.up(tbody1)
	Next
	DB.Close
	Return table1
End Sub

Private Sub CreatePagesRow (data As Map) As Tag
	Dim id As Int = data.Get("id")
	Dim page_slug As String = data.Get("page_slug")
	Dim page_title As String = data.Get("page_title")
	Dim page_topic As String = data.Get("topic_name")
	Dim page_status As String = IIf(1 = data.Get("page_status"), "Published", "Draft")

	Dim tr1 As Tag = Tr.init
	tr1.add(Td.cls("align-middle").sty("text-align: right").text(id))
	tr1.add(Td.cls("align-middle").text(page_slug))
	tr1.add(Td.cls("align-middle").text(page_title))
	tr1.add(Td.cls("align-middle text-center").text(page_topic))
	tr1.add(Td.cls("align-middle text-center").sty("text-align: right").text(page_status))
	Dim td6 As Tag = Td.cls("align-middle text-center px-1 py-1").up(tr1)

	Dim anchor1 As Tag = Anchor.cls("edit text-primary mx-2").up(td6)
	anchor1.hxGet($"/hx/pages/edit/${id}"$)
	anchor1.hxTarget("#modal-content")
	anchor1.hxTrigger("click")
	anchor1.data("bs-toggle", "modal")
	anchor1.data("bs-target", "#modal-container")
	anchor1.add(Icon.cls("bi bi-pencil"))
	anchor1.attr("title", "Edit")

	Dim anchor2 As Tag = Anchor.cls("delete text-danger mx-2").up(td6)
	anchor2.hxGet($"/hx/pages/delete/${id}"$)
	anchor2.hxTarget("#modal-content")
	anchor2.hxTrigger("click")
	anchor2.data("bs-toggle", "modal")
	anchor2.data("bs-target", "#modal-container")
	anchor2.add(Icon.cls("bi bi-trash3"))
	anchor2.attr("title", "Delete")

	Return tr1
End Sub

Private Sub ShowAlert (message As String, status As String)
	Dim div1 As Tag = Div.cls("alert alert-" & status).text(message)
	App.WriteHtml(Response, div1.Build)
End Sub

Private Sub ShowToast (entity As String, action As String, message As String, status As String)
	Dim div1 As Tag = Div.id("pages-container")
	div1.hxSwapOob("true")
	div1.add(CreatePagesTable)

	Dim script1 As MiniJs
	script1.Initialize
	script1.AddCustomEventDispatch("entity:changed", _
	CreateMap( _
	"entity": entity, _
	"action": action, _
	"message": message, _
	"status": status))

	App.WriteHtml(Response, div1.Build & CRLF & script1.Generate)
End Sub