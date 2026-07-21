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
	DB = Main.DB
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
	
	Dim page1 As MiniHtml = main1.Render
	Dim ulist1 As MiniHtml = FindUListTag(page1)
	
	Dim list0 As MiniHtml = MH.Li.cls("nav-item d-block d-lg-block").up(ulist1)
	Dim anchor0 As MiniHtml = MH.Anchor.attr("href", "/help").up(list0)
	anchor0.cls("nav-link")
	anchor0.add(MH.Icon.cls("bi bi-gear mr-2").attr("title", "API"))
	anchor0.text("API")
  
    Dim list1 As MiniHtml = MH.Li.cls("nav-item d-block d-lg-block").up(ulist1)
    Dim anchor1 As MiniHtml = MH.Anchor.attr("href", "/pages").up(list1)
    anchor1.cls("nav-link")
    anchor1.text("Pages")
  
    Dim list2 As MiniHtml = MH.Li.cls("nav-item d-block d-lg-block").up(ulist1)
    Dim anchor2 As MiniHtml = MH.Anchor.attr("href", "/topics").up(list2)
    anchor2.cls("nav-link")
    anchor2.text("Topics")
	
	Dim list3 As MiniHtml = MH.Li.cls("nav-item d-block d-lg-block").up(ulist1)
	Dim anchor3 As MiniHtml = MH.Anchor.attr("href", "/users").up(list3)
	anchor3.cls("nav-link")
	anchor3.text("Users")

	Dim doc As MiniHtml
	doc.Initialize("doctype")
	doc.Append(page1.build)
	App.WriteHtml2(Response, doc.ToString, App.ctx)
End Sub

' Retrieve ulist tag from DOM
Private Sub FindUListTag (dom As MiniHtml) As MiniHtml
	Dim body1 As MiniHtml = dom.ChildByIndex(1)
	Dim nav1 As MiniHtml = body1.ChildByIndex(1)
	Dim container1 As MiniHtml = nav1.ChildByIndex(0)
	Dim navbar1 As MiniHtml = container1.ChildByIndex(3)
	Dim ulist1 As MiniHtml = navbar1.ChildByIndex(0)
	Return ulist1
End Sub

Private Sub ContentContainer As MiniHtml
	Dim content1 As MiniHtml = MH.Div.cls("row mt-3 text-center align-items-center justify-content-center")
	Dim col1 As MiniHtml = MH.Div.cls("col-md-12 col-lg-6").up(content1)
	Dim form1 As MiniHtml = MH.Form.cls("form mb-3").attr("action", "").up(col1)
	
	Dim row1 As MiniHtml = MH.Div.cls("row").up(form1)
	Dim col2 As MiniHtml = MH.Div.cls("col-md-6 col-lg-6 text-start").up(row1)
	MH.H3.cls("text-uppercase").text("User List").up(col2)
	
	Dim div1 As MiniHtml = MH.Div.cls("col-md-6 col-lg-6").up(row1)
	Dim div2 As MiniHtml = MH.Div.cls("text-end mt-2").up(div1)

	Dim anchor1 As MiniHtml = MH.Anchor.up(div2)
	anchor1.attr("href", "$SERVER_URL$")
	anchor1.cls("btn btn-primary me-2")
	anchor1.add(MH.Icon.cls("bi bi-house me-2"))
	anchor1.text("Home")

	Dim button2 As MiniHtml = MH.Button.up(div2)
	button2.cls("btn btn-success ml-2")
	button2.attr("hx-get", "/hx/users/add")
	button2.attr("hx-target", "#modal-content")
	button2.attr("hx-trigger", "click")
	button2.attr("data-bs-toggle", "modal")
	button2.attr("data-bs-target", "#modal-container")
	button2.add(MH.Icon.cls("bi bi-plus-lg me-2"))
	button2.text("Add User")

	Dim container1 As MiniHtml = MH.Div.up(col1)
	container1.attr("id", "users-container")
	container1.attr("hx-get", "/hx/users/table")
	container1.attr("hx-trigger", "load")
	container1.text("Loading...")

	Return content1
End Sub

Private Sub ModalContainer As MiniHtml
	Dim modal1 As MiniHtml = MH.Div.attr("id", "modal-container")
	modal1.cls("modal fade")
	modal1.attr("tabindex", "-1")
	modal1.attr("aria-hidden", "true")
	Dim modalDialog As MiniHtml = MH.Div.up(modal1).cls("modal-dialog modal-dialog-centered")
	MH.Div.cls("modal-content").attr("id", "modal-content").up(modalDialog)
	Return modal1
End Sub

Private Sub ToastContainer As MiniHtml
	Dim div1 As MiniHtml = MH.Div.cls("position-fixed end-0 p-3")
	div1.sty("z-index: 2000")
	div1.sty("bottom: 0%")
	Dim toast1 As MiniHtml = MH.Div.attr("id", "toast-container").up(div1)
	toast1.cls("toast align-items-center text-bg-success border-0")
	toast1.attr("role", "alert")
	Dim div2 As MiniHtml = MH.Div.cls("d-flex").up(toast1)
	Dim div3 As MiniHtml = MH.Div.cls("toast-body").attr("id", "toast-body").up(div2)
	div3.text("Operation successful!")
	Dim button1 As MiniHtml = MH.Button.attr("type", "button").up(div2)
	button1.cls("btn-close btn-close-white me-2 m-auto")
	button1.attr("data-bs-dismiss", "toast")
	Return div1
End Sub

' Return table HTML
Private Sub HandleTable
	App.WriteHtml(Response, CreateUserTable.Build)
End Sub

' Add modal
Private Sub HandleAddModal
	Dim form1 As MiniHtml = MH.Form
	form1.attr("hx-post", "/hx/users")
	form1.attr("hx-target", "#modal-messages")
	form1.attr("hx-swap", "innerHTML")
	
	Dim modalHeader As MiniHtml = MH.Div.cls("modal-header").up(form1)
	MH.H5.cls("modal-title").text("Add User").up(modalHeader)
	MH.Button.attr("type", "button").cls("btn-close").attr("data-bs-dismiss", "modal").up(modalHeader)

	Dim modalBody As MiniHtml = MH.Div.cls("modal-body").up(form1)
	MH.Div.attr("id", "modal-messages").up(modalBody)'.hxSwapOob("true")
	
	Dim group1 As MiniHtml = MH.Div.cls("form-group mb-2").up(modalBody)
	MH.Label.attr("for", "first_name").text("First Name ").up(group1).add(MH.Span.cls("text-danger").text("*"))
	MH.Input.attr("type", "text").cls("form-control").attr("id", "first_name").attr("name", "first_name").attr("value", "").required.up(group1)
		
	Dim group2 As MiniHtml = MH.Div.cls("form-group mb-2").up(modalBody)
	MH.Label.attr("for", "last_name").text("Last Name ").up(group2).add(MH.Span.cls("text-danger").text("*"))
	MH.Input.attr("type", "text").cls("form-control").attr("id", "last_name").attr("name", "last_name").attr("value", "").required.up(group2)
	
	Dim group3 As MiniHtml = MH.Div.cls("form-group mb-2").up(modalBody)
	MH.Label.attr("for", "email").text("Email ").up(group3).add(MH.Span.cls("text-danger").text("*"))
	MH.Input.attr("type", "text").cls("form-control").attr("id", "email").attr("name", "email").attr("value", "").required.up(group3)
	
	Dim group4 As MiniHtml = MH.Div.cls("form-group mb-2").up(modalBody)
	MH.Label.attr("for", "password").text("Password ").up(group4).add(MH.Span.cls("text-danger").text("*"))
	MH.Input.attr("type", "password").cls("form-control").attr("id", "password").attr("name", "password").attr("value", "").required.up(group4)

	Dim group5 As MiniHtml = MH.Div.cls("form-check form-switch mb-2").up(modalBody)
	MH.Input.attr("type", "checkbox").cls("form-check-input").attr("id", "admin").attr("name", "admin").attr("role", "switch").up(group5)
	MH.Label.attr("for", "admin").cls("form-check-label").text("Admin").up(group5)
		
	Dim group6 As MiniHtml = MH.Div.cls("form-check form-switch mb-2").up(modalBody)
	MH.Input.attr("type", "checkbox").cls("form-check-input").attr("id", "active").attr("name", "active").attr("role", "switch").checked.up(group6)
	MH.Label.attr("for", "active").cls("form-check-label").text("Active").up(group6)

	Dim modalFooter As MiniHtml = MH.Div.cls("modal-footer").up(form1)
	MH.Button.attr("type", "submit").cls("btn btn-success px-3").text("Create").up(modalFooter)
	MH.Button.attr("type", "button").cls("btn btn-secondary px-3").attr("data-bs-dismiss", "modal").text("Cancel").up(modalFooter)

	App.WriteHtml(Response, form1.Build)
End Sub

' Edit modal
Private Sub HandleEditModal
	Dim id As String = Request.RequestURI.SubString("/hx/users/edit/".Length)
	Dim form1 As MiniHtml = MH.Form
	form1.attr("hx-put", $"/hx/users"$)
	form1.attr("hx-target", "#modal-messages")
	form1.attr("hx-swap", "innerHTML")
		
	DB.Open
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

		Dim modalHeader As MiniHtml = MH.Div.cls("modal-header").up(form1)
		MH.H5.cls("modal-title").text("Edit User").up(modalHeader)
		MH.Button.attr("type", "button").cls("btn-close").attr("data-bs-dismiss", "modal").up(modalHeader)
		
		Dim modalBody As MiniHtml = MH.Div.cls("modal-body").up(form1)
		MH.Div.attr("id", "modal-messages").up(modalBody)
		MH.Input.attr("type", "hidden").up(modalBody).attr("name", "id").attr("value", id)
		
		Dim group1 As MiniHtml = MH.Div.cls("form-group mb-2").up(modalBody)
		MH.Label.attr("for", "first_name").text("First Name ").up(group1).add(MH.Span.cls("text-danger").text("*"))
		MH.Input.attr("type", "text").cls("form-control").attr("id", "first_name").attr("name", "first_name").attr("value", first_name).required.up(group1)
		
		Dim group2 As MiniHtml = MH.Div.cls("form-group mb-2").up(modalBody)
		MH.Label.attr("for", "last_name").text("Last Name ").up(group2).add(MH.Span.cls("text-danger").text("*"))
		MH.Input.attr("type", "text").cls("form-control").attr("id", "last_name").attr("name", "last_name").attr("value", last_name).required.up(group2)
	
		Dim group3 As MiniHtml = MH.Div.cls("form-group mb-2").up(modalBody)
		MH.Label.attr("for", "email").text("Email ").up(group3).add(MH.Span.cls("text-danger").text("*"))
		MH.Input.attr("type", "text").cls("form-control").attr("id", "email").attr("name", "email").attr("value", email).required.up(group3)

		'Dim group4 As MiniHtml = MH.Div.cls("form-group mb-2").up(modalBody)
		'Label.attr("for", "password").text("Password ").up(group4).add(Span.cls("text-danger").text("*"))
		'Input.attr("type", "text").cls("form-control").attr("id", "password").attr("name", "password").attr("value", "").required.up(group4)

		Dim group5 As MiniHtml = MH.Div.cls("form-check form-switch mb-2").up(modalBody)
		MH.Input.attr("type", "checkbox").cls("form-check-input").attr("id", "admin").attr("name", "admin").attr("role", "switch").attr3(admin).up(group5)
		MH.Label.attr("for", "admin").cls("form-check-label").text("Admin").up(group5)
		
		Dim group6 As MiniHtml = MH.Div.cls("form-check form-switch mb-2").up(modalBody)
		MH.Input.attr("type", "checkbox").cls("form-check-input").attr("id", "active").attr("name", "active").attr("role", "switch").attr3(active).up(group6)
		MH.Label.attr("for", "active").cls("form-check-label").text("Active").up(group6)

		Dim modalFooter As MiniHtml = MH.Div.cls("modal-footer").up(form1)
		MH.Button.attr("type", "submit").cls("btn btn-primary px-3").text("Update").up(modalFooter)
		MH.Button.attr("type", "button").cls("btn btn-secondary px-3").attr("data-bs-dismiss", "modal").text("Cancel").up(modalFooter)
	End If
	DB.Close

	App.WriteHtml(Response, form1.Build)
End Sub

' Delete modal
Private Sub HandleDeleteModal
	Dim id As String = Request.RequestURI.SubString("/hx/users/delete/".Length)
	Dim form1 As MiniHtml = MH.Form
	form1.attr("hx-delete", $"/hx/users"$)
	form1.attr("hx-target", "#modal-messages")
	form1.attr("hx-swap", "innerHTML")

	DB.Open
	DB.Table = "users"
	DB.Columns = Array("id", "first_name", "last_name", "email")
	DB.WhereParam("id = ?", id)
	DB.Query
	If DB.Found Then
		Dim row As Map = DB.First
		Dim first_name As String = row.Get("first_name")
		Dim last_name As String = row.Get("last_name")
		Dim email As String = row.Get("email")

		Dim modalHeader As MiniHtml = MH.Div.cls("modal-header").up(form1)
		MH.H5.cls("modal-title").text("Delete User").up(modalHeader)
		MH.Button.attr("type", "button").cls("btn-close").attr("data-bs-dismiss", "modal").up(modalHeader)
		
		Dim modalBody As MiniHtml = MH.Div.cls("modal-body").up(form1)
		MH.Div.attr("id", "modal-messages").up(modalBody)
		MH.Input.attr("type", "hidden").attr("name", "id").attr("value", id).up(modalBody)
		MH.P.text($"Delete ${first_name} ${last_name} (${email})?"$).up(modalBody)

		Dim modalFooter As MiniHtml = MH.Div.cls("modal-footer").up(form1)
		MH.Button.attr("type", "submit").cls("btn btn-danger px-3").text("Delete").up(modalFooter)
		MH.Button.attr("type", "button").cls("btn btn-secondary px-3").attr("data-bs-dismiss", "modal").text("Cancel").up(modalFooter)
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
				DB.Open
				DB.Table = "users"
				DB.Conditions = Array("email = ?")
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
			
			DB.Open
			DB.Table = "users"
			
			DB.Find(id)
			If DB.Found = False Then
				ShowAlert("User not found!", "warning")
				DB.Close
				Return
			End If

			DB.Reset
			DB.Conditions = Array("email = ?", "id <> ?")
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
			DB.Open
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

Private Sub CreateUserTable As MiniHtml
	Dim table1 As MiniHtml = MH.Table.cls("table table-bordered table-hover rounded small")
	Dim thead1 As MiniHtml = MH.Thead.cls("table-light").up(table1)
	thead1.add(MH.Th.sty("text-align: right; width: 50px").text("#"))
	thead1.add(MH.Th.text("First Name"))
	thead1.add(MH.Th.text("Last Name"))
	thead1.add(MH.Th.text("Email"))
	thead1.add(MH.Th.text("Admin"))
	thead1.add(MH.Th.text("Active"))
	thead1.add(MH.Th.sty("text-align: center; width: 120px").text("Actions"))
	Dim tbody1 As MiniHtml = MH.Tbody.up(table1)
	
	DB.Open
	DB.Table = "users"
	DB.Columns = Array("id", "first_name", "last_name", "email", "admin", "active")
	DB.OrderBy = CreateMap("id": "")
	DB.Query
	For Each row As Map In DB.Results
		Dim tr1 As MiniHtml = CreateUserRow(row)
		tr1.up(tbody1)
	Next
	DB.Close
	Return table1
End Sub

Private Sub CreateUserRow (data As Map) As MiniHtml
	Dim id As Int = data.Get("id")
	Dim first_name As String = data.Get("first_name")
	Dim last_name As String = data.Get("last_name")
	Dim email As String = data.Get("email")
	Dim admin As String = IIf(1 = data.Get("admin"), "yes", "no")
	Dim active As String = IIf(1 = data.Get("active"), "yes", "no")

	Dim tr1 As MiniHtml = MH.Tr
	tr1.add(MH.Td.cls("align-middle").sty("text-align: right").text(id))
	tr1.add(MH.Td.cls("align-middle").text(first_name))
	tr1.add(MH.Td.cls("align-middle").text(last_name))
	tr1.add(MH.Td.cls("align-middle").text(email))
	tr1.add(MH.Td.cls("align-middle").text(admin))
	tr1.add(MH.Td.cls("align-middle").text(active))
	
	Dim td3 As MiniHtml = MH.Td.cls("align-middle text-center px-1 py-1").up(tr1)

	Dim anchor1 As MiniHtml = MH.Anchor.cls("edit text-primary mx-2").up(td3)
	anchor1.attr("hx-get", $"/hx/users/edit/${id}"$)
	anchor1.attr("hx-target", "#modal-content")
	anchor1.attr("hx-trigger", "click")
	anchor1.attr("data-bs-toggle", "modal")
	anchor1.attr("data-bs-target", "#modal-container")
	anchor1.add(MH.Icon.cls("bi bi-pencil"))
	anchor1.attr("title", "Edit")
		
	Dim anchor2 As MiniHtml = MH.Anchor.cls("delete text-danger mx-2").up(td3)
	anchor2.attr("hx-get", $"/hx/users/delete/${id}"$)
	anchor2.attr("hx-target", "#modal-content")
	anchor2.attr("hx-trigger", "click")
	anchor2.attr("data-bs-toggle", "modal")
	anchor2.attr("data-bs-target", "#modal-container")
	anchor2.add(MH.Icon.cls("bi bi-trash3"))
	anchor2.attr("title", "Delete")
	
	Return tr1
End Sub

Private Sub ShowAlert (message As String, status As String)
	Dim div1 As MiniHtml = MH.Div.cls("alert alert-" & status).text(message)
	App.WriteHtml(Response, div1.Build)
End Sub

Private Sub ShowToast (entity As String, action As String, message As String, status As String)
	Dim div1 As MiniHtml = MH.Div.attr("id", "users-container")
	div1.attr("hx-swap-oob", "true")
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