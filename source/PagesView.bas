B4J=true
Group=Views
ModulesStructureVersion=1
Type=Class
Version=10.5
@EndOfDesignText@
' Pages View
Sub Class_Globals
	Private App As EndsMeet
End Sub

Public Sub Initialize
	App = Main.App
End Sub

Public Sub Show As String
	Dim CacheName As String = "Pages Page"
	If MC.ExistInCache(App.ctx, CacheName) = False Then
		MC.WriteToCache(App.ctx, CacheName, PagesPage)
	End If
	Dim page1 As MiniHtml = MC.ReadFromCache(App.ctx, CacheName)
	Dim doc As MiniHtml
	doc.Initialize("doctype")
	doc.Append(page1.build)
	Return doc.ToString
End Sub

Public Sub Modal (Action As String, TopicList As List, Data As Map) As String
	Select Action
		Case "Add"
			Dim CacheName As String = "Pages Add Modal"
			If MC.ExistInCache(App.ctx, CacheName) = False Then
				MC.WriteToCache(App.ctx, CacheName, ModalAdd)
			End If
			Dim modal1 As MiniHtml = MC.ReadFromCache(App.ctx, CacheName)
			Dim select1 As MiniHtml = modal1.ChildById("topic1")
			select1.Children.Clear
			Dim option1 As MiniHtml = MH.Option.up(select1)
			option1.attr("value", "")
			option1.text("Select Topic")
			option1.selected
			option1.disabled
			For Each row As Map In TopicList
				Dim option2 As MiniHtml = MH.Option.up(select1)
				option2.attr("value", row.Get("id"))
				option2.text(row.Get("topic_name"))
			Next
			Return modal1.build
		Case "Edit"
			Dim CacheName As String = "Pages Edit Modal"
			If MC.ExistInCache(App.ctx, CacheName) = False Then
				MC.WriteToCache(App.ctx, CacheName, ModalEdit)
			End If
			Dim modal1 As MiniHtml = MC.ReadFromCache(App.ctx, CacheName)
			Dim id1 As MiniHtml = modal1.ChildById("id")
			id1.attr("value", Data.Get("id"))
			Dim select1 As MiniHtml = modal1.ChildById("topic2")
			select1.Children.Clear
			Dim option1 As MiniHtml = MH.Option.up(select1)
			option1.attr("value", "")
			option1.text("Select Topic")
			option1.disabled
			For Each row As Map In TopicList
				Dim option2 As MiniHtml = MH.Option.up(select1)
				option2.attr("value", row.Get("id"))
				option2.text(row.Get("topic_name"))
				If row.Get("id") = Data.Get("topic_id") Then option2.selected
			Next
			Dim input2 As MiniHtml = modal1.ChildById("input2")
			input2.attr("value", Data.Get("page_slug"))
			Dim input3 As MiniHtml = modal1.ChildById("input3")
			input3.attr("value", Data.Get("page_title"))
			Dim input4 As MiniHtml = modal1.ChildById("input4")
			input4.attr("value", Data.Get("page_status"))
			Return modal1.build
		Case "Delete"
			Dim CacheName As String = "Pages Delete Modal"
			If MC.ExistInCache(App.ctx, CacheName) = False Then
				MC.WriteToCache(App.ctx, CacheName, ModalDelete)
			End If
			Dim modal1 As MiniHtml = MC.ReadFromCache(App.ctx, CacheName)
			Dim id1 As MiniHtml = modal1.ChildById("id")
			id1.attr("value", Data.Get("id"))
			Dim p1 As MiniHtml = modal1.ChildById("p1")
			p1.text2($"Delete ${Data.Get("page_title")} (${Data.Get("page_slug")})?"$)
			Return modal1.build
		Case Else
			Return ""
	End Select
End Sub

Public Sub Alert (info As AlertInfo) As String
	Return MH.Alert(info)
End Sub

Public Sub Toast (info As ToastInfo, data As List) As String
	Return MH.Toast("pages-container", PagesTableFilled(data), info)
End Sub

Public Sub RenderedTable (data As List) As String
	Return PagesTableFilled(data).build
End Sub

Public Sub RenderedList (data As List) As String
	Return PagesListFilled(data).build
End Sub

Private Sub PagesPage As MiniHtml
	Dim main1 As MainView
	main1.Initialize
	main1.LoadContent(ContainerContent)
	main1.LoadSubContent(MH.GitHubLink)
	main1.LoadModal(MH.ContainerModal)
	main1.LoadToast(MH.ContainerToast)
	Dim page1 As MiniHtml = main1.Render
	Dim navitem1 As MiniHtml = page1.ChildById("nav-item")
	MH.TopicsLink.up(navitem1)
	MH.UsersLink.up(navitem1)
	If App.api.EnableHelp Then
		MH.HelpLink.up(navitem1)
	End If
	MH.NavLinkItem("Home", "/", "bi bi-house me-2", "Home").up(navitem1)
	Return page1
End Sub

Private Sub ContainerContent As MiniHtml
	Dim content1 As MiniHtml = MH.Div.cls("row mt-3")
	Dim col12 As MiniHtml = MH.Div.up(content1).cls("col-md-12")
	Dim form1 As MiniHtml = MH.Form.up(col12).cls("form mb-3")
	Dim row1 As MiniHtml = MH.Div.up(form1).cls("row")
	Dim col1 As MiniHtml = MH.Div.up(row1).cls("col-md-6 col-lg-6")
	Dim group1 As MiniHtml = MH.Div.up(col1).cls("input-group mb-3")
	Dim label1 As MiniHtml = MH.Label.up(group1)
	label1.attr("for", "keyword")
	label1.cls("input-group-text mt-2")
	label1.text("Search")
	Dim input1 As MiniHtml = MH.Input.up(group1)
	input1.attr("type", "text")
	input1.cls("form-control col-md-6 mt-2")
	input1.attr("id", "keyword")
	input1.attr("name", "keyword")
	Dim searchBtn As MiniHtml = MH.Button.up(group1)
	searchBtn.cls("btn btn-danger btn-md pl-3 pr-3 ml-3 mt-2")
	searchBtn.text("Submit")
	searchBtn.attr("hx-post", "/hx/pages/table")
	searchBtn.attr("hx-target", "#pages-container")
	searchBtn.attr("hx-swap", "innerHTML")
	Dim col2 As MiniHtml = MH.Div.up(row1).cls("col-md-6 col-lg-6")
	Dim div2 As MiniHtml = MH.Div.up(col2).cls("float-end mt-2")
	Dim button1 As MiniHtml = MH.Button.up(div2)
	button1.cls("btn btn-success ml-2")
	button1.attr("hx-get", "/hx/pages/add")
	button1.attr("hx-target", "#modal-content")
	button1.attr("hx-trigger", "click")
	button1.attr("data-bs-toggle", "modal")
	button1.attr("data-bs-target", "#modal-container")
	MH.Icon.up(button1).cls("bi bi-plus-lg me-2")
	button1.text("Add Pages")
	Dim container1 As MiniHtml = MH.Div.up(col12)
	container1.attr("id", "pages-container")
	container1.attr("hx-get", "/hx/pages/table")
	container1.attr("hx-trigger", "load")
	container1.text("Loading...")
	Return content1
End Sub

Private Sub PagesListFilled (data As List) As MiniHtml
	Dim div1 As MiniHtml = MH.Div
	For Each row As Map In data
		Dim page_created As String = "created on " & row.Get("created_date")
		page_created = page_created & " by " & row.Get("author")		
		'Dim page_slug As String = row.Get("page_slug")
		Dim page_title As String = row.Get("page_title")
		Dim page_body As String = row.Get("page_body")
		'Dim page_status As String = row.Get("page_status")
		'Dim topic_name As String = row.Get("topic_name")
      
		Dim card1 As MiniHtml = MH.Div.cls("card text-start mb-3")
		Dim cardbody1 As MiniHtml = MH.Div.up(card1).cls("card-body")
		MH.H5.up(cardbody1).cls("card-title").text(page_title)
		MH.H6.up(cardbody1).cls("card-subtitle mb-2 text-body-secondary").text(page_created)
		MH.P.up(cardbody1).cls("card-text").text(page_body)
		card1.up(div1)
	Next
	Return div1
End Sub

Private Sub PagesTableFilled (data As List) As MiniHtml
	Dim CacheName As String = "Pages Table"
	If MC.ExistInCache(App.ctx, CacheName) = False Then
		MC.WriteToCache(App.ctx, CacheName, PagesTable)
	End If
	
	Dim CacheName As String = "Pages Table Row"
	If MC.ExistInCache(App.ctx, CacheName) = False Then
		MC.WriteToCache(App.ctx, CacheName, PagesTableRow.ConvertToBytes) ' bytes()
	End If

	Dim table1 As MiniHtml = MC.ReadFromCache(App.ctx, "Pages Table")
	Dim tbody1 As MiniHtml = table1.ChildByIndex(1)
	tbody1.Children.Clear
	For Each row As Map In data
		Dim tr1 As MiniHtml = MC.ReadFromCache(App.ctx, "Pages Table Row") ' bytes()
		tr1.ChildByIndex(0).text2(row.Get("id")).sty("text-align: right")
		tr1.ChildByIndex(1).text2(row.Get("page_slug"))
		tr1.ChildByIndex(2).text2(row.Get("page_title"))
		tr1.ChildByIndex(3).text2(row.Get("topic_name"))
		tr1.ChildByIndex(4).text2(row.Get("page_status")).sty("text-align: center")
		tr1.ChildByIndex(5).ChildByIndex(0).attr("hx-get", "/hx/pages/edit/" & row.Get("id"))
		tr1.ChildByIndex(5).ChildByIndex(1).attr("hx-get", "/hx/pages/delete/" & row.Get("id"))
		tr1.up(tbody1)
	Next
	Return table1
End Sub

Private Sub PagesTable As MiniHtml
	Dim table1 As MiniHtml = MH.Table
	table1.cls("table table-bordered table-hover rounded small")
	Dim thead1 As MiniHtml = MH.Thead.cls("table-light").up(table1)
	MH.Th.up(thead1).sty("text-align: right; width: 50px").text("#")
	MH.Th.up(thead1).text("Slug")
	MH.Th.up(thead1).text("Title")
	MH.Th.up(thead1).text("Topic")
	MH.Th.up(thead1).text("Status").sty("text-align: center")
	MH.Th.up(thead1).sty("text-align: center; width: 120px").text("Actions")
	MH.Tbody.up(table1)
	Return table1
End Sub

Private Sub PagesTableRow As MiniHtml
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
	a1.attr("hx-get", "/hx/pages/edit/{id}")
	a1.attr("hx-target", "#modal-content")
	a1.attr("hx-trigger", "click")
	a1.attr("data-bs-toggle", "modal")
	a1.attr("data-bs-target", "#modal-container")
	MH.Icon.up(a1).cls("bi bi-pencil")
	a1.attr("title", "Edit")
	Dim a2 As MiniHtml = MH.Anchor.up(td6)
	a2.cls("delete text-danger mx-2")
	a2.attr("hx-get", "/hx/pages/delete/{id}")
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
	form1.attr("hx-post", "/hx/pages")
	form1.attr("hx-target", "#modal-messages")
	form1.attr("hx-swap", "innerHTML")
	Dim modalHeader As MiniHtml = MH.Div.up(form1)
	modalHeader.cls("modal-header")
	Dim h51 As MiniHtml = MH.H5.up(modalHeader)
	h51.cls("modal-title").text("Add Page")
	Dim close1 As MiniHtml = MH.Button.up(modalHeader)
	close1.attr("type", "button")
	close1.cls("btn-close")
	close1.attr("data-bs-dismiss", "modal")
	Dim modalBody As MiniHtml = MH.Div.up(form1)
	modalBody.cls("modal-body")
	MH.Div.up(modalBody).attr("id", "modal-messages")
	
	Dim group1 As MiniHtml = MH.Div.up(modalBody)
	group1.cls("form-group")
	Dim label1 As MiniHtml = MH.Label.up(group1)
	label1.attr("for", "topic1")
	label1.text("Topic ")
	Dim span1 As MiniHtml = MH.Span.up(label1)
	span1.cls("text-danger").text("*")
	Dim select1 As MiniHtml = MH.SelectTag.up(group1)
	select1.cls("form-select")
	select1.attr("id", "topic1")
	select1.attr("name", "topic")
	select1.required
	
	'Dim group2 As MiniHtml = MH.Div.up(modalBody)
	'group2.cls("form-group")
	'Dim label2 As MiniHtml = MH.Label.up(group2)
	'label2.text("Slug ")
	'Dim span2 As MiniHtml = MH.Span.up(label2)
	'span2.cls("text-danger").text("*")
	'Dim input2 As MiniHtml = MH.Input.up(group2)
	'input2.attr("type", "text")
	'input2.attr("name", "slug")
	'input2.cls("form-control")
	'input2.required
	
	Dim group2 As MiniHtml = MH.Div.up(modalBody)
	group2.cls("form-group")
	Dim label2 As MiniHtml = MH.Label.up(group2)
	label2.text("Title ")
	Dim span2 As MiniHtml = MH.Span.up(label2)
	span2.cls("text-danger").text("*")
	Dim input2 As MiniHtml = MH.Input.up(group2)
	input2.attr("type", "text")
	input2.attr("name", "title")
	input2.cls("form-control")
	input2.required
	
	'Dim group3 As MiniHtml = MH.Div.up(modalBody).cls("form-group")
	'group3.add(MH.Label.text("Title ")).add(MH.Span.cls("text-danger").text("*"))
	'group3.add(MH.Input.attr("type", "text").attr("name", "page_title").cls("form-control").required)

	Dim group3 As MiniHtml = MH.Div.up(modalBody).cls("form-group")
	Dim label3 As MiniHtml = MH.Label.text("Body ")
	MH.Span.up(label3).cls("text-danger").text("*")
	MH.Textarea.up(group3).cls("form-control").attr("rows", "3").attr("name", "page_body").required

    Dim group4 As MiniHtml = MH.Div.up(modalBody).cls("form-group")
    Dim label4 As MiniHtml = MH.Label.up(group4).attr("for", "status").text("Status ")
	MH.Span.up(label4).cls("text-danger").text("*")
    Dim select2 As MiniHtml = MH.SelectTag.up(group4).cls("form-select").attr("id", "status").attr("name", "status").required
    MH.Option.up(select2).attr("value", "0").text("Draft")
    MH.Option.up(select2).attr("value", "1").text("Published")
	
	'Dim group5 As MiniHtml = MH.Div.up(modalBody).cls("form-group")
	'Dim label5 As MiniHtml = MH.Label.up(group5).attr("for", "status").text("Status ")
	'Dim input5 As MiniHtml = MH.Input.up(group5)
	'input5.attr("type", "text")
	'input5.attr("name", "status")
	'input5.cls("form-control")
	
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
	form1.attr("hx-put", "/hx/pages")
	form1.attr("hx-target", "#modal-messages")
	form1.attr("hx-swap", "innerHTML")
	Dim modalHeader As MiniHtml = MH.Div.up(form1).cls("modal-header")
	Dim h51 As MiniHtml = MH.H5.up(modalHeader)
	h51.cls("modal-title").text("Edit Page")
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
	Dim group1 As MiniHtml = MH.Div.up(modalBody)
	group1.cls("form-group")
	Dim label1 As MiniHtml = MH.Label.up(group1)
	label1.attr("for", "topic2")
	label1.text("Topic ")
	Dim span1 As MiniHtml = MH.Span.up(label1)
	span1.cls("text-danger").text("*")
	Dim select1 As MiniHtml = MH.SelectTag.up(group1)
	select1.cls("form-select")
	select1.attr("id", "topic2")
	select1.attr("name", "topic")
	select1.required
	Dim option1 As MiniHtml = MH.Option.up(select1)
	option1.attr("value", "")
	option1.text("Select Topic")
	Dim group2 As MiniHtml = MH.Div.up(modalBody)
	group2.cls("form-group")
	Dim label2 As MiniHtml = MH.Label.up(group2)
	label2.text("Code ")
	Dim span2 As MiniHtml = MH.Span.up(label2)
	span2.cls("text-danger").text("*")
	Dim input2 As MiniHtml = MH.Input.up(group2)
	input2.attr("type", "text")
	input2.cls("form-control")
	input2.attr("name", "code")
	input2.attr("id", "input2")
	input2.required
	Dim group3 As MiniHtml = MH.Div.up(modalBody)
	group3.cls("form-group")
	Dim label3 As MiniHtml = MH.Label.up(group3)
	label3.attr("for", "name")
	label3.text("Name ")
	Dim span3 As MiniHtml = MH.Span.up(label3)
	span3.cls("text-danger").text("*")
	Dim input3 As MiniHtml = MH.Input.up(group3)
	input3.attr("type", "text")
	input3.cls("form-control")
	input3.attr("id", "name")
	input3.attr("name", "name")
	input3.attr("id", "input3")
	input3.required
	Dim group4 As MiniHtml = MH.Div.up(modalBody)
	group4.cls("form-group")
	Dim label4 As MiniHtml = MH.Label.up(group4)
	label4.text("Price ")
	Dim input4 As MiniHtml = MH.Input.up(group4)
	input4.attr("type", "text")
	input4.cls("form-control")
	input4.attr("name", "price")
	input4.attr("id", "input4")
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
	form1.attr("hx-delete", "/hx/pages")
	form1.attr("hx-target", "#modal-messages")
	form1.attr("hx-swap", "innerHTML")
	Dim modalHeader As MiniHtml = MH.Div.cls("modal-header").up(form1)
	Dim h51 As MiniHtml = MH.H5.up(modalHeader)
	h51.cls("modal-title").text("Delete Page")
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