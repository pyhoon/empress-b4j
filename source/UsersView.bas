B4J=true
Group=Views
ModulesStructureVersion=1
Type=Class
Version=10.5
@EndOfDesignText@
' Users View
Sub Class_Globals
	Private App As EndsMeet
End Sub

Public Sub Initialize
	App = Main.App
End Sub

Public Sub Show (Req As ServletRequest) As String
	Dim CacheName As String = "Users Page"
	If MC.ExistInCache(App.ctx, CacheName) = False Then
		MC.WriteToCache(App.ctx, CacheName, UsersPage(Req))
	End If
	Dim page1 As MiniHtml = MC.ReadFromCache(App.ctx, CacheName)
	Dim doc As MiniHtml
	doc.Initialize("doctype")
	doc.Append(page1.build)
	Return doc.ToString
End Sub

Public Sub Modal (Action As String, Data As Map) As String
	Select Action
		Case "Add"
			Dim CacheName As String = "Users Add Modal"
			If MC.ExistInCache(App.ctx, CacheName) = False Then
				MC.WriteToCache(App.ctx, CacheName, ModalAdd)
			End If
			Dim modal1 As MiniHtml = MC.ReadFromCache(App.ctx, CacheName)
			Return modal1.build
		Case "Edit"
			Dim CacheName As String = "Users Edit Modal"
			If MC.ExistInCache(App.ctx, CacheName) = False Then
				MC.WriteToCache(App.ctx, CacheName, ModalEdit)
			End If
			Dim modal1 As MiniHtml = MC.ReadFromCache(App.ctx, CacheName)
			Dim id1 As MiniHtml = modal1.ChildById("id")
			id1.attr("value", Data.Get("id"))
			Dim first_name As MiniHtml = modal1.ChildById("first_name")
			first_name.attr("value", Data.Get("first_name"))
			Dim last_name As MiniHtml = modal1.ChildById("last_name")
			last_name.attr("value", Data.Get("last_name"))
			Dim email As MiniHtml = modal1.ChildById("email")
			email.attr("value", Data.Get("email"))
			Return modal1.build
		Case "Delete"
			Dim CacheName As String = "Users Delete Modal"
			If MC.ExistInCache(App.ctx, CacheName) = False Then
				MC.WriteToCache(App.ctx, CacheName, ModalDelete)
			End If
			Dim modal1 As MiniHtml = MC.ReadFromCache(App.ctx, CacheName)
			Dim id1 As MiniHtml = modal1.ChildById("id")
			id1.attr("value", Data.Get("id"))
			Dim p1 As MiniHtml = modal1.ChildById("p1")
			p1.text2($"Delete ${Data.Get("first_name")} ${Data.Get("last_name")} (${Data.Get("email")})?"$)
			Return modal1.build
		Case Else
			Return ""
	End Select
End Sub

Public Sub Alert (info As AlertInfo) As String
	Return MH.Alert(info)
End Sub

Public Sub Toast (info As ToastInfo, data As List) As String
	Return MH.Toast("users-container", UsersTableFilled(data), info)
End Sub

Public Sub RenderedTable (data As List) As String
	Return UsersTableFilled(data).build
End Sub

Private Sub UsersPage (Req As ServletRequest) As MiniHtml
	Dim main1 As MainView
	main1.Initialize
	main1.LoadContent(ContainerContent)
	main1.LoadModal(MH.ContainerModal)
	main1.LoadToast(MH.ContainerToast)
	Dim page1 As MiniHtml = main1.Render
	Dim navitem1 As MiniHtml = page1.ChildById("nav-item")
	If 1 = Req.GetSession.GetAttribute("admin") Then
		MH.PagesLink.up(navitem1)
		MH.TopicsLink.up(navitem1)
		MH.HomeLink.up(navitem1)
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
	Dim row1 As MiniHtml = MH.Div
	row1.cls("row mt-3 text-center align-items-center justify-content-center")
	Dim col1 As MiniHtml = MH.Div.up(row1)
	col1.cls("col-md-12 col-lg-6")
	Dim form1 As MiniHtml = MH.Form.up(col1)
	form1.cls("form mb-3")
	form1.attr("action", "")
	Dim row2 As MiniHtml = MH.Div.up(form1)
	row2.cls("row")
	Dim col2 As MiniHtml = MH.Div.up(row2)
	col2.cls("col-md-6 col-lg-6 text-start")
	Dim h31 As MiniHtml = MH.H3.up(col2)
	h31.text("USER LIST")
	Dim div1 As MiniHtml = MH.Div.up(row2)
	div1.cls("col-md-6 col-lg-6")
	Dim div2 As MiniHtml = MH.Div.up(div1)
	div2.cls("text-end mt-2")
	
	MH.ButtonAdd("Add User", "btn btn-success ml-2", "/hx/users/add", "#modal-content", "click", "#modal-container", "modal").up(div2)
	
	Dim container1 As MiniHtml = MH.Div.up(col1)
	container1.attr("id", "users-container")
	container1.attr("hx-get", "/hx/users/table")
	container1.attr("hx-trigger", "load")
	container1.text("Loading...")
	Return row1
End Sub

Private Sub UsersTableFilled (data As List) As MiniHtml
	Dim CacheName As String = "Users Table"
	If MC.ExistInCache(App.ctx, CacheName) = False Then
		MC.WriteToCache(App.ctx, CacheName, UsersTable)
	End If
	
	Dim CacheName As String = "Users Table Row"
	If MC.ExistInCache(App.ctx, CacheName) = False Then
		MC.WriteToCache(App.ctx, CacheName, UsersTableRow.ConvertToBytes) ' bytes()
	End If

	Dim table1 As MiniHtml = MC.ReadFromCache(App.ctx, "Users Table")
	Dim tbody1 As MiniHtml = table1.ChildByIndex(1)
	tbody1.Children.Clear
	For Each row As Map In data
		Dim tr1 As MiniHtml = MC.ReadFromCache(App.ctx, "Users Table Row") ' bytes()
		tr1.ChildByIndex(0).text2(row.Get("id"))
		tr1.ChildByIndex(1).text2(row.Get("first_name"))
		tr1.ChildByIndex(2).text2(row.Get("last_name"))
		tr1.ChildByIndex(3).text2(row.Get("email"))
		tr1.ChildByIndex(4).text2(row.Get("admin"))
		tr1.ChildByIndex(5).ChildByIndex(0).attr("hx-get", "/hx/users/edit/" & row.Get("id"))
		tr1.ChildByIndex(5).ChildByIndex(1).attr("hx-get", "/hx/users/delete/" & row.Get("id"))
		tr1.up(tbody1)
	Next
	Return table1
End Sub

Private Sub UsersTable As MiniHtml
	Dim table1 As MiniHtml = MH.Table
	table1.cls("table table-bordered table-hover rounded small")
	Dim thead1 As MiniHtml = MH.Thead.cls("table-light").up(table1)
	MH.Th.up(thead1).sty("text-align: right; width: 50px").text("#")
	MH.Th.up(thead1).text("First Name")
	MH.Th.up(thead1).text("Last Name")
	MH.Th.up(thead1).text("Email")
	MH.Th.up(thead1).sty("text-align: center").text("Admin")
	MH.Th.up(thead1).sty("text-align: center; width: 120px").text("Actions")
	MH.Tbody.up(table1)
	Return table1
End Sub

Private Sub UsersTableRow As MiniHtml
	Dim tr1 As MiniHtml = MH.Tr
	MH.Td.up(tr1).cls("align-middle").sty("text-align: right")
	MH.Td.up(tr1).cls("align-middle")
	MH.Td.up(tr1).cls("align-middle")
	MH.Td.up(tr1).cls("align-middle")
	MH.Td.up(tr1).cls("align-middle").sty("text-align: center")
	Dim td6 As MiniHtml = MH.Td.up(tr1)
	td6.cls("align-middle text-center px-1 py-1")
	Dim a1 As MiniHtml = MH.Anchor.up(td6)
	a1.cls("edit text-primary mx-2")
	a1.attr("hx-get", "/hx/users/edit/{id}")
	a1.attr("hx-target", "#modal-content")
	a1.attr("hx-trigger", "click")
	a1.attr("data-bs-toggle", "modal")
	a1.attr("data-bs-target", "#modal-container")
	MH.Icon.up(a1).cls("bi bi-pencil")
	a1.attr("title", "Edit")
	Dim a2 As MiniHtml = MH.Anchor.up(td6)
	a2.cls("delete text-danger mx-2")
	a2.attr("hx-get", "/hx/users/delete/{id}")
	a2.attr("hx-target", "#modal-content")
	a2.attr("hx-trigger", "click")
	a2.attr("data-bs-toggle", "modal")
	a2.attr("data-bs-target", "#modal-container")
	MH.Icon.up(a2).cls("bi bi-trash3")
	a2.attr("title", "Delete")
	Return tr1
End Sub

Private Sub ModalAdd As MiniHtml
	Dim form1 As MiniHtml = MH.Form
	form1.attr("hx-post", "/hx/users")
	form1.attr("hx-target", "#modal-messages")
	form1.attr("hx-swap", "innerHTML")
	
	Dim modalHeader As MiniHtml = MH.Div.up(form1)
	modalHeader.cls("modal-header")
	Dim h51 As MiniHtml = MH.H5.up(modalHeader)
	h51.cls("modal-title").text("Add User")
	Dim close1 As MiniHtml = MH.Button.up(modalHeader)
	close1.attr("type", "button")
	close1.cls("btn-close")
	close1.attr("data-bs-dismiss", "modal")
	Dim modalBody As MiniHtml = MH.Div.up(form1)
	modalBody.cls("modal-body")
	MH.Div.up(modalBody).attr("id", "modal-messages")'.attr("hx-swap-oob", "true")
	
	Dim group1 As MiniHtml = MH.Div.up(modalBody)
	group1.cls("form-group mb-2")
	Dim label1 As MiniHtml = MH.Label.up(group1)
	label1.attr("for", "first_name")
	label1.text("First Name ")
	Dim span1 As MiniHtml = MH.Span.up(label1)
	span1.cls("text-danger").text("*")
	Dim input1 As MiniHtml = MH.Input.up(group1)
	input1.cls("form-control")
	input1.attr("type", "text")
	input1.attr("id", "first_name")
	input1.attr("name", "first_name")
	input1.attr("value", "")
	input1.required
	
	Dim group2 As MiniHtml = MH.Div.up(modalBody)
	group2.cls("form-group mb-2")
	Dim label2 As MiniHtml = MH.Label.up(group2)
	label2.attr("for", "last_name")
	label2.text("Last Name ")
	Dim span2 As MiniHtml = MH.Span.up(label2)
	span2.cls("text-danger").text("*")
	Dim input2 As MiniHtml = MH.Input.up(group2)
	input2.cls("form-control")
	input2.attr("type", "text")
	input2.attr("id", "last_name")
	input2.attr("name", "last_name")
	input2.attr("value", "")
	input2.required
	
	Dim group3 As MiniHtml = MH.Div.up(modalBody)
	group3.cls("form-group mb-2")
	Dim label3 As MiniHtml = MH.Label.up(group3)
	label3.attr("for", "email")
	label3.text("Email ")
	Dim span3 As MiniHtml = MH.Span.up(label3)
	span3.cls("text-danger").text("*")
	Dim input3 As MiniHtml = MH.Input.up(group3)
	input3.cls("form-control")
	input3.attr("type", "email")
	input3.attr("id", "email")
	input3.attr("name", "email")
	input3.attr("value", "")
	input3.required
	
	Dim group4 As MiniHtml = MH.Div.up(modalBody)
	group4.cls("form-group mb-2")
	Dim label4 As MiniHtml = MH.Label.up(group4)
	label4.attr("for", "password")
	label4.text("Password ")
	Dim span4 As MiniHtml = MH.Span.up(label4)
	span4.cls("text-danger").text("*")
	Dim input4 As MiniHtml = MH.Input.up(group4)
	input4.cls("form-control")
	input4.attr("type", "password")
	input4.attr("id", "password")
	input4.attr("name", "password")
	input4.attr("value", "")
	input4.required
	
	Dim group5 As MiniHtml = MH.Div.up(modalBody)
	group5.cls("form-check form-switch mb-2")
	Dim label5 As MiniHtml = MH.Label.up(group5)
	label5.attr("for", "admin")
	label5.cls("form-check-label")
	label5.text("Admin ")
	Dim span5 As MiniHtml = MH.Span.up(label5)
	span5.cls("text-danger").text("*")	
	Dim input5 As MiniHtml = MH.Input.up(group5)
	input5.cls("form-check-input")
	input5.attr("type", "checkbox")
	input5.attr("id", "admin")
	input5.attr("name", "admin")
	input5.attr("role", "switch")
	input5.required
	
	Dim group6 As MiniHtml = MH.Div.up(modalBody)
	group6.cls("form-check form-switch mb-2")
	Dim label6 As MiniHtml = MH.Label.up(group6)
	label6.attr("for", "active")
	label6.text("Active ")
	Dim span6 As MiniHtml = MH.Span.up(label6)
	span6.cls("text-danger").text("*")
	Dim input6 As MiniHtml = MH.Input.up(group6)
	input6.cls("form-check-input")
	input6.attr("type", "checkbox")
	input6.attr("id", "active")
	input6.attr("name", "active")
	input6.attr("role", "switch")
	input6.required
	
	Dim modalFooter As MiniHtml = MH.Div.up(form1).cls("modal-footer")
	
	Dim button1 As MiniHtml = MH.Button.up(modalFooter)
	button1.attr("type", "submit")
	button1.cls("btn btn-success px-3")
	button1.text("Create")
	
	Dim button2 As MiniHtml = MH.Button.up(modalFooter)
	button2.attr("type", "button")
	button2.cls("btn btn-secondary px-3")
	button2.attr("data-bs-dismiss", "modal")
	button2.text("Cancel")
	
	Return form1
End Sub

Private Sub ModalEdit As MiniHtml
	Dim form1 As MiniHtml = MH.Form
	form1.attr("hx-put", "/hx/users")
	form1.attr("hx-target", "#modal-messages")
	form1.attr("hx-swap", "innerHTML")
	
	Dim modalHeader As MiniHtml = MH.Div.up(form1).cls("modal-header")
	Dim h51 As MiniHtml = MH.H5.up(modalHeader)
	h51.cls("modal-title").text("Edit User")
	Dim close1 As MiniHtml = MH.Button.up(modalHeader)
	close1.attr("type", "button")
	close1.cls("btn-close")
	close1.attr("data-bs-dismiss", "modal")
	Dim modalBody As MiniHtml = MH.Div.up(form1).cls("modal-body")
	Dim div1 As MiniHtml = MH.Div.up(modalBody)
	div1.attr("id", "modal-messages")
	
	Dim id1 As MiniHtml = MH.Input.up(modalBody)
	id1.attr("type", "hidden")
	id1.attr("name", "id")
	id1.attr("id", "id")
	
	Dim group1 As MiniHtml = MH.Div.up(modalBody)
	group1.cls("form-group mb-2")
	Dim label1 As MiniHtml = MH.Label.up(group1)
	label1.attr("for", "first_name")
	label1.text("First Name ")
	Dim span1 As MiniHtml = MH.Span.up(label1)
	span1.cls("text-danger").text("*")
	Dim input1 As MiniHtml = MH.Input.up(group1)
	input1.cls("form-control")
	input1.attr("type", "text")
	input1.attr("id", "first_name")
	input1.attr("name", "first_name")
	input1.required
	
	Dim group2 As MiniHtml = MH.Div.up(modalBody)
	group2.cls("form-group mb-2")
	Dim label2 As MiniHtml = MH.Label.up(group2)
	label2.attr("for", "last_name")
	label2.text("Last Name ")
	Dim span2 As MiniHtml = MH.Span.up(label2)
	span2.cls("text-danger").text("*")
	Dim input2 As MiniHtml = MH.Input.up(group2)
	input2.cls("form-control")
	input2.attr("type", "text")
	input2.attr("id", "last_name")
	input2.attr("name", "last_name")
	input2.required
	
	Dim group3 As MiniHtml = MH.Div.up(modalBody)
	group3.cls("form-group mb-2")
	Dim label3 As MiniHtml = MH.Label.up(group3)
	label3.attr("for", "email")
	label3.text("Email ")
	Dim span3 As MiniHtml = MH.Span.up(label3)
	span3.cls("text-danger").text("*")
	Dim input3 As MiniHtml = MH.Input.up(group3)
	input3.cls("form-control")
	input3.attr("type", "email")
	input3.attr("id", "email")
	input3.attr("name", "email")
	input3.required
	
	Dim group4 As MiniHtml = MH.Div.up(modalBody)
	group4.cls("form-group mb-2")
	Dim label4 As MiniHtml = MH.Label.up(group4)
	label4.attr("for", "password")
	label4.text("Password ")
	Dim span4 As MiniHtml = MH.Span.up(label4)
	span4.cls("text-danger").text("*")
	Dim input4 As MiniHtml = MH.Input.up(group4)
	input4.cls("form-control")
	input4.attr("type", "password")
	input4.attr("id", "password")
	input4.attr("name", "password")
	input4.required
	
	Dim group5 As MiniHtml = MH.Div.up(modalBody)
	group5.cls("form-check form-switch mb-2")
	Dim label5 As MiniHtml = MH.Label.up(group5)
	label5.attr("for", "admin")
	label5.cls("form-check-label")
	label5.text("Admin ")
	Dim span5 As MiniHtml = MH.Span.up(label5)
	span5.cls("text-danger").text("*")	
	Dim input5 As MiniHtml = MH.Input.up(group5)
	input5.cls("form-check-input")
	input5.attr("type", "checkbox")
	input5.attr("id", "admin")
	input5.attr("name", "admin")
	input5.attr("role", "switch")
	input5.required
	
	Dim group6 As MiniHtml = MH.Div.up(modalBody)
	group6.cls("form-check form-switch mb-2")
	Dim label6 As MiniHtml = MH.Label.up(group6)
	label6.attr("for", "active")
	label6.text("Active ")
	Dim span6 As MiniHtml = MH.Span.up(label6)
	span6.cls("text-danger").text("*")	
	Dim input6 As MiniHtml = MH.Input.up(group6)
	input6.cls("form-check-input")
	input6.attr("type", "checkbox")
	input6.attr("id", "active")
	input6.attr("name", "active")
	input6.attr("role", "switch")
	input6.required
	
	Dim modalFooter As MiniHtml = MH.Div.up(form1).cls("modal-footer")
	
	Dim button1 As MiniHtml = MH.Button.up(modalFooter)
	button1.cls("btn btn-primary px-3")
	button1.text("Update")
	
	Dim button2 As MiniHtml = MH.Button.up(modalFooter)
	button2.attr("type", "button")
	button2.cls("btn btn-secondary px-3")
	button2.attr("data-bs-dismiss", "modal")
	button2.text("Cancel")
	
	Return form1
End Sub

Private Sub ModalDelete As MiniHtml
	Dim form1 As MiniHtml = MH.Form
	form1.attr("hx-delete", "/hx/users")
	form1.attr("hx-target", "#modal-messages")
	form1.attr("hx-swap", "innerHTML")
	
	Dim modalHeader As MiniHtml = MH.Div.cls("modal-header").up(form1)
	Dim h51 As MiniHtml = MH.H5.up(modalHeader)
	h51.cls("modal-title").text("Delete User")
	Dim close1 As MiniHtml = MH.Button.up(modalHeader)
	close1.attr("type", "button")
	close1.cls("btn-close")
	close1.attr("data-bs-dismiss", "modal")
	Dim modalBody As MiniHtml = MH.Div.cls("modal-body").up(form1)
	
	Dim div1 As MiniHtml = MH.Div.up(modalBody)
	div1.attr("id", "modal-messages")
	Dim id1 As MiniHtml = MH.Input.up(modalBody)
	id1.attr("type", "hidden")
	id1.attr("name", "id")
	id1.attr("id", "id")
	MH.P.up(modalBody).Id = "p1"
	
	Dim modalFooter As MiniHtml = MH.Div.up(form1).cls("modal-footer")
	
	Dim button1 As MiniHtml = MH.Button.up(modalFooter)
	button1.cls("btn btn-danger px-3")
	button1.text("Delete")
	
	Dim button2 As MiniHtml = MH.Button.up(modalFooter)
	button2.attr("type", "button")
	button2.cls("btn btn-secondary px-3")
	button2.attr("data-bs-dismiss", "modal")
	button2.text("Cancel")
	
	Return form1
End Sub