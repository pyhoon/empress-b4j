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
	If path = "/users" Then
		RenderPage
	Else If path = "/hx/users/table" Then
		HandleTable
	Else If path = "/hx/users/add" Then
		HandleAddModal
	Else If path.StartsWith("/hx/users/edit/") Then
		HandleEditModal
	Else If path.StartsWith("/hx/users/delete/") Then
		HandleDeleteModal
	Else
		HandleUser
	End If
End Sub

Private Sub RenderPage
	Dim main1 As MainView
	main1.Initialize
	main1.LoadContent(ContentContainer)
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
    Dim anchor1 As Tag = Anchor.href("/pages").up(list1)
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
	Dim content1 As Tag = Div.cls("row mt-3 text-center align-items-center justify-content-center")
	Dim col1 As Tag = Div.cls("col-md-12 col-lg-6").up(content1)
	Dim form1 As Tag = Form.cls("form mb-3").action("").up(col1)
	
	Dim row1 As Tag = Div.cls("row").up(form1)
	Dim col2 As Tag = Div.cls("col-md-6 col-lg-6 text-start").up(row1)
	H3.cls("text-uppercase").text("User List").up(col2)
	
	Dim div1 As Tag = Div.cls("col-md-6 col-lg-6").up(row1)
	Dim div2 As Tag = Div.cls("text-end mt-2").up(div1)

	Dim anchor1 As Tag = Anchor.up(div2)
	anchor1.hrefOf("$SERVER_URL$")
	anchor1.cls("btn btn-primary me-2")
	anchor1.add(Icon.cls("bi bi-house me-2"))
	anchor1.text("Home")

	Dim button2 As Tag = Button.up(div2)
	button2.cls("btn btn-success ml-2")
	button2.hxGet("/hx/users/add")
	button2.hxTarget("#modal-content")
	button2.hxTrigger("click")
	button2.data("bs-toggle", "modal")
	button2.data("bs-target", "#modal-container")
	button2.add(Icon.cls("bi bi-plus-lg me-2"))
	button2.text("Add User")

	Dim container1 As Tag = Div.up(col1)
	container1.id("users-container")
	container1.hxGet("/hx/users/table")
	container1.hxTrigger("load")
	container1.text("Loading...")

	Return content1
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
	App.WriteHtml(Response, CreateUserTable.Build)
End Sub

' Add modal
Private Sub HandleAddModal
	Dim form1 As Tag = Form.init
	form1.hxPost("/hx/users")
	form1.hxTarget("#modal-messages")
	form1.hxSwap("innerHTML")
	
	Dim modalHeader As Tag = Div.cls("modal-header").up(form1)
	H5.cls("modal-title").text("Add User").up(modalHeader)
	Button.typeOf("button").cls("btn-close").data("bs-dismiss", "modal").up(modalHeader)

	Dim modalBody As Tag = Div.cls("modal-body").up(form1)
	Div.id("modal-messages").up(modalBody)'.hxSwapOob("true")
	
	Dim group1 As Tag = Div.cls("form-group mb-2").up(modalBody)
	Label.forId("first_name").text("First Name ").up(group1).add(Span.cls("text-danger").text("*"))
	Input.typeOf("text").cls("form-control").id("first_name").name("first_name").valueOf("").required.up(group1)
		
	Dim group2 As Tag = Div.cls("form-group mb-2").up(modalBody)
	Label.forId("last_name").text("Last Name ").up(group2).add(Span.cls("text-danger").text("*"))
	Input.typeOf("text").cls("form-control").id("last_name").name("last_name").valueOf("").required.up(group2)
	
	Dim group3 As Tag = Div.cls("form-group mb-2").up(modalBody)
	Label.forId("email").text("Email ").up(group3).add(Span.cls("text-danger").text("*"))
	Input.typeOf("text").cls("form-control").id("email").name("email").valueOf("").required.up(group3)
	
	Dim group4 As Tag = Div.cls("form-group mb-2").up(modalBody)
	Label.forId("password").text("Password ").up(group4).add(Span.cls("text-danger").text("*"))
	Input.typeOf("password").cls("form-control").id("password").name("password").valueOf("").required.up(group4)

	Dim group5 As Tag = Div.cls("form-check form-switch mb-2").up(modalBody)
	Input.typeOf("checkbox").cls("form-check-input").id("admin").name("admin").attr("role", "switch").up(group5)
	Label.forId("admin").cls("form-check-label").text("Admin").up(group5)
		
	Dim group6 As Tag = Div.cls("form-check form-switch mb-2").up(modalBody)
	Input.typeOf("checkbox").cls("form-check-input").id("active").name("active").attr("role", "switch").checked.up(group6)
	Label.forId("active").cls("form-check-label").text("Active").up(group6)

	Dim modalFooter As Tag = Div.cls("modal-footer").up(form1)
	Button.typeOf("submit").cls("btn btn-success px-3").text("Create").up(modalFooter)
	Button.typeOf("button").cls("btn btn-secondary px-3").data("bs-dismiss", "modal").text("Cancel").up(modalFooter)

	App.WriteHtml(Response, form1.Build)
End Sub

' Edit modal
Private Sub HandleEditModal
	Dim id As String = Request.RequestURI.SubString("/hx/users/edit/".Length)
	Dim form1 As Tag = Form.init
	form1.hxPut($"/hx/users"$)
	form1.hxTarget("#modal-messages")
	form1.hxSwap("innerHTML")
		
	DB.SQL = Main.DBOpen
	DB.Table = "users"
	DB.Columns = Array("id", "first_name", "last_name", "email", "admin", "active")
	DB.WhereParam("id = ?", id)
	DB.Query
	If DB.Found Then
		Dim row As Map = DB.First
		Dim first_name As String = row.Get("first_name")
		Dim last_name As String = row.Get("last_name")
		Dim email As String = row.Get("email")
		Dim admin As String = IIf(1 = row.Get("admin"), "checked", "")
		Dim active As String = IIf(1 = row.Get("active"), "checked", "")

		Dim modalHeader As Tag = Div.cls("modal-header").up(form1)
		H5.cls("modal-title").text("Edit User").up(modalHeader)
		Button.typeOf("button").cls("btn-close").data("bs-dismiss", "modal").up(modalHeader)
		
		Dim modalBody As Tag = Div.cls("modal-body").up(form1)
		Div.id("modal-messages").up(modalBody)
		Input.typeOf("hidden").up(modalBody).name("id").valueOf(id)
		
		Dim group1 As Tag = Div.cls("form-group mb-2").up(modalBody)
		Label.forId("first_name").text("First Name ").up(group1).add(Span.cls("text-danger").text("*"))
		Input.typeOf("text").cls("form-control").id("first_name").name("first_name").valueOf(first_name).required.up(group1)
		
		Dim group2 As Tag = Div.cls("form-group mb-2").up(modalBody)
		Label.forId("last_name").text("Last Name ").up(group2).add(Span.cls("text-danger").text("*"))
		Input.typeOf("text").cls("form-control").id("last_name").name("last_name").valueOf(last_name).required.up(group2)
	
		Dim group3 As Tag = Div.cls("form-group mb-2").up(modalBody)
		Label.forId("email").text("Email ").up(group3).add(Span.cls("text-danger").text("*"))
		Input.typeOf("text").cls("form-control").id("email").name("email").valueOf(email).required.up(group3)

		'Dim group4 As Tag = Div.cls("form-group mb-2").up(modalBody)
		'Label.forId("password").text("Password ").up(group4).add(Span.cls("text-danger").text("*"))
		'Input.typeOf("text").cls("form-control").id("password").name("password").valueOf("").required.up(group4)

		Dim group5 As Tag = Div.cls("form-check form-switch mb-2").up(modalBody)
		Input.typeOf("checkbox").cls("form-check-input").id("admin").name("admin").attr("role", "switch").attr3(admin).up(group5)
		Label.forId("admin").cls("form-check-label").text("Admin").up(group5)
		
		Dim group6 As Tag = Div.cls("form-check form-switch mb-2").up(modalBody)
		Input.typeOf("checkbox").cls("form-check-input").id("active").name("active").attr("role", "switch").attr3(active).up(group6)
		Label.forId("active").cls("form-check-label").text("Active").up(group6)

		Dim modalFooter As Tag = Div.cls("modal-footer").up(form1)
		Button.typeOf("submit").cls("btn btn-primary px-3").text("Update").up(modalFooter)
		Button.typeOf("button").cls("btn btn-secondary px-3").data("bs-dismiss", "modal").text("Cancel").up(modalFooter)
	End If
	DB.Close

	App.WriteHtml(Response, form1.Build)
End Sub

' Delete modal
Private Sub HandleDeleteModal
	Dim id As String = Request.RequestURI.SubString("/hx/users/delete/".Length)
	Dim form1 As Tag = Form.init
	form1.hxDelete($"/hx/users"$)
	form1.hxTarget("#modal-messages")
	form1.hxSwap("innerHTML")

	DB.SQL = Main.DBOpen
	DB.Table = "users"
	DB.Columns = Array("id", "first_name", "last_name", "email")
	DB.WhereParam("id = ?", id)
	DB.Query
	If DB.Found Then
		Dim row As Map = DB.First
		Dim first_name As String = row.Get("first_name")
		Dim last_name As String = row.Get("last_name")
		Dim email As String = row.Get("email")

		Dim modalHeader As Tag = Div.cls("modal-header").up(form1)
		H5.cls("modal-title").text("Delete User").up(modalHeader)
		Button.typeOf("button").cls("btn-close").data("bs-dismiss", "modal").up(modalHeader)
		
		Dim modalBody As Tag = Div.cls("modal-body").up(form1)
		Div.id("modal-messages").up(modalBody)
		Input.typeOf("hidden").name("id").valueOf(id).up(modalBody)
		Paragraph.text($"Delete ${first_name} ${last_name} (${email})?"$).up(modalBody)

		Dim modalFooter As Tag = Div.cls("modal-footer").up(form1)
		Button.typeOf("submit").cls("btn btn-danger px-3").text("Delete").up(modalFooter)
		Button.typeOf("button").cls("btn btn-secondary px-3").data("bs-dismiss", "modal").text("Cancel").up(modalFooter)
	End If
	DB.Close

	App.WriteHtml(Response, form1.Build)
End Sub

' Handle CRUD operations
Private Sub HandleUser
	Select Method
		Case "POST"
			' Create
			Dim first_name As String = Request.GetParameter("first_name")
			Dim last_name As String = Request.GetParameter("last_name")
			
			If first_name = "" Or first_name.Trim.Length < 2 Then
				ShowAlert("First name must be at least 2 characters long.", "warning")
				Return
			End If
			
			Dim email As String = Request.GetParameter("email")
			If email = "" Then
				ShowAlert("Email must not be empty.", "warning")
				Return
			End If

			Dim password As String = Request.GetParameter("password")
			If password = "" Then
				ShowAlert("Password must not be empty.", "warning")
				Return
			End If
			
			Dim admin As String = Request.GetParameter("admin")
			Dim active As String = Request.GetParameter("active")
			Dim isAdmin As Int = IIf(admin = "on", 1, 0)
			Dim isActive As Int = IIf(active = "on", 1, 0)			
			Try
				DB.SQL = Main.DBOpen
				DB.Table = "users"
				DB.Where = Array("email = ?")
				DB.Parameters = Array(email)
				DB.Query
				If DB.Found Then
					DB.Close
					ShowAlert("User already exists!", "warning")
					Return
				End If
			Catch
				Log(LastException)
				ShowAlert($"Database error: ${LastException.Message}"$, "danger")
			End Try

			' Insert new row
			Try
				Dim salt As String = Encryption.RandomHash
				Dim hash As String = Encryption.MD5(password & salt)
				DB.Reset
				DB.Columns = Array("first_name", "last_name", "email", "hash", "salt", "admin", "active")
				DB.Parameters = Array(first_name, last_name, email, hash, salt, isAdmin, isActive)
				DB.Save
				DB.Close
				ShowToast("User", "created", "User created successfully!", "success")
			Catch
				ShowAlert($"Database error: ${LastException.Message}"$, "danger")
			End Try
		Case "PUT"
			' Update
			Dim id As Int = Request.GetParameter("id")
			Dim first_name As String = Request.GetParameter("first_name")
			Dim last_name As String = Request.GetParameter("last_name")
			Dim email As String = Request.GetParameter("email")
			Dim admin As String = Request.GetParameter("admin")
			Dim active As String = Request.GetParameter("active")
			
			DB.SQL = Main.DBOpen
			DB.Table = "users"
			
			DB.Find(id)
			If DB.Found = False Then
				ShowAlert("User not found!", "warning")
				DB.Close
				Return
			End If

			DB.Reset
			DB.Where = Array("email = ?", "id <> ?")
			DB.Parameters = Array(email, id)
			DB.Query
			If DB.Found Then
				ShowAlert("User already exists!", "warning")
				DB.Close
				Return
			End If
			
			Dim isAdmin As Int = IIf(admin = "on", 1, 0)
			Dim isActive As Int = IIf(active = "on", 1, 0)
			' Update row
			Try
				DB.Reset
				DB.Columns = Array("first_name", "last_name", "email", "admin", "active", "modified_date")
				DB.Parameters = Array(first_name, last_name, email, isAdmin, isActive, Main.CurrentDateTime)
				DB.Id = id
				DB.Save
				DB.Close
				ShowToast("User", "updated", "User updated successfully!", "info")
			Catch
				ShowAlert($"Database error: ${LastException.Message}"$, "danger")
			End Try
		Case "DELETE"
			' Delete
			Dim id As Int = Request.GetParameter("id")
			DB.SQL = Main.DBOpen
			DB.Table = "users"
			
			DB.Find(id)
			If DB.Found = False Then
				ShowAlert("User not found!", "warning")
				DB.Close
				Return
			End If
			
			DB.Table = "pages"
			DB.WhereParam("created_by = ?", id)
			DB.Query
			If DB.Found Then
				ShowAlert("Cannot delete user with associated pages!", "warning")
				DB.Close
				Return
			End If

			' Delete row
			Try
				DB.Table = "users"
				DB.Id = id
				DB.Delete
				DB.Close
				ShowToast("User", "deleted", "User deleted successfully!", "danger")
			Catch
				ShowAlert($"Database error: ${LastException.Message}"$, "danger")
			End Try
	End Select
End Sub

Private Sub CreateUserTable As Tag
	Dim table1 As Tag = HtmlTable.cls("table table-bordered table-hover rounded small")
	Dim thead1 As Tag = Thead.cls("table-light").up(table1)
	thead1.add(Th.sty("text-align: right; width: 50px").text("#"))
	thead1.add(Th.text("First Name"))
	thead1.add(Th.text("Last Name"))
	thead1.add(Th.text("Email"))
	thead1.add(Th.text("Admin"))
	thead1.add(Th.text("Active"))
	thead1.add(Th.sty("text-align: center; width: 120px").text("Actions"))
	Dim tbody1 As Tag = Tbody.init.up(table1)
	
	DB.SQL = Main.DBOpen
	DB.Table = "users"
	DB.Columns = Array("id", "first_name", "last_name", "email", "admin", "active")
	DB.OrderBy = CreateMap("id": "")
	DB.Query
	For Each row As Map In DB.Results
		Dim tr1 As Tag = CreateUserRow(row)
		tr1.up(tbody1)
	Next
	DB.Close
	Return table1
End Sub

Private Sub CreateUserRow (data As Map) As Tag
	Dim id As Int = data.Get("id")
	Dim first_name As String = data.Get("first_name")
	Dim last_name As String = data.Get("last_name")
	Dim email As String = data.Get("email")
	Dim admin As String = IIf(1 = data.Get("admin"), "yes", "no")
	Dim active As String = IIf(1 = data.Get("active"), "yes", "no")

	Dim tr1 As Tag = Tr.init
	tr1.add(Td.cls("align-middle").sty("text-align: right").text(id))
	tr1.add(Td.cls("align-middle").text(first_name))
	tr1.add(Td.cls("align-middle").text(last_name))
	tr1.add(Td.cls("align-middle").text(email))
	tr1.add(Td.cls("align-middle").text(admin))
	tr1.add(Td.cls("align-middle").text(active))
	
	Dim td3 As Tag = Td.cls("align-middle text-center px-1 py-1").up(tr1)

	Dim anchor1 As Tag = Anchor.cls("edit text-primary mx-2").up(td3)
	anchor1.hxGet($"/hx/users/edit/${id}"$)
	anchor1.hxTarget("#modal-content")
	anchor1.hxTrigger("click")
	anchor1.data("bs-toggle", "modal")
	anchor1.data("bs-target", "#modal-container")
	anchor1.add(Icon.cls("bi bi-pencil"))
	anchor1.attr("title", "Edit")
		
	Dim anchor2 As Tag = Anchor.cls("delete text-danger mx-2").up(td3)
	anchor2.hxGet($"/hx/users/delete/${id}"$)
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
	Dim div1 As Tag = Div.id("users-container")
	div1.hxSwapOob("true")
	div1.add(CreateUserTable)

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