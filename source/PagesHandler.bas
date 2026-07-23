B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=10.3
@EndOfDesignText@
' Pages Handler class
Sub Class_Globals
	Private App As EndsMeet
	Private Path As String
	Private Method As String
	Private View As PagesView
	Private Model As PagesModel
	Private Request As ServletRequest
	Private Response As ServletResponse
End Sub

Public Sub Initialize
	App = Main.App
	View.Initialize
	Model.Initialize
End Sub

Sub Handle (req As ServletRequest, resp As ServletResponse)
	Request = req
	Response = resp
	Path = Request.RequestURI
	Method = Request.Method.ToUpperCase
	Log($"${Method}: ${Path}"$)
	If Path = "/pages" Then
		HandlePage
	Else If Path = "/hx/pages/search" Then
		HandleSearch
	Else If Path = "/hx/pages/table" Then
		HandleTable
	Else If Path = "/hx/pages/list" Then
		HandleList
	Else If Path = "/hx/pages/add" Then
		HandleModalAdd
	Else If Path.StartsWith("/hx/pages/edit/") Then
		HandleModalEdit
	Else If Path.StartsWith("/hx/pages/delete/") Then
		HandleModalDelete
	Else
		HandlePages
	End If
End Sub

Private Sub HandlePage
	App.WriteHtml2(Response, View.Show, App.ctx)
End Sub

' Search page using keyword
Private Sub HandleSearch
	Dim keyword As String = Request.GetParameter("keyword")
	Dim Rows As List = Model.Search(keyword)
	App.WriteHtml(Response, View.RenderedTable(Rows))
End Sub

' Return default or search results table
Private Sub HandleTable
	Dim keyword As String = Request.GetParameter("keyword")
	Dim Rows As List = Model.Search(keyword)
	App.WriteHtml(Response, View.RenderedTable(Rows))
End Sub

Private Sub HandleList
	Dim Rows As List = Model.List
	App.WriteHtml(Response, View.RenderedList(Rows))
End Sub

' Add modal
Private Sub HandleModalAdd
	Dim TM As TopicsModel
	TM.Initialize
	Dim Topics As List = TM.Read
	If TM.Error.IsInitialized Then
		ShowAlert($"Database error: ${TM.Error.Message}"$, "danger")
		Return
	End If
	App.WriteHtml(Response, View.Modal("Add", Topics, Null))
End Sub

' Edit modal
Private Sub HandleModalEdit
	Try
		Dim id As Int = Path.SubString("/hx/pages/edit/".Length)
	Catch
		Log(LastException)
		ShowAlert($"Error: ${LastException.Message}"$, "danger")
		Return
	End Try
	Dim TM As TopicsModel
	TM.Initialize
	Dim Topics As List = TM.Read
	If TM.Error.IsInitialized Then
		ShowAlert($"Database error: ${TM.Error.Message}"$, "danger")
		Return
	End If
	Dim Page As Map = Model.GetRowById(id)
	If Model.Error.IsInitialized Then
		ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
		Return
	End If
	App.WriteHtml(Response, View.Modal("Edit", Topics, Page))
End Sub

' Delete modal
Private Sub HandleModalDelete
	Try
		Dim id As Int = Path.SubString("/hx/pages/delete/".Length)
	Catch
		Log(LastException)
		ShowAlert($"Error: ${LastException.Message}"$, "danger")
		Return
	End Try
	Dim Page As Map = Model.GetRowById(id)
	If Model.Error.IsInitialized Then
		ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
		Return
	End If
	App.WriteHtml(Response, View.Modal("Delete", Null, Page))
End Sub

Private Sub ShowAlert (Message As String, Status As String)
	Dim info As AlertInfo = MH.CreateAlertInfo(Message, Status)
	App.WriteHtml(Response, View.Alert(info))
End Sub

Private Sub ShowToast (Entity As String, Action As String, Message As String, Status As String)
	Dim data As List = Model.Read
	Dim info As ToastInfo = MH.CreateToastInfo(Entity, Action, Message, Status)
	App.WriteHtml(Response, View.Toast(info, data))
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
			Dim Found As Boolean = Model.FindRowBySlug(page_slug)
			If Model.Error.IsInitialized Then
				ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
				Return
			End If
			If Found Then
				ShowAlert("Page slug already exists!", "warning")
				Return
			End If
			
			' Insert new row
			Model.Create(topic_id, page_slug, page_title, page_body, page_status, Main.CurrentDateTime)
			If Model.Error.IsInitialized Then
				ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
				Return
			End If
			ShowToast("Page", "created", "Page created successfully!", "success")
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

			Dim Found As Boolean = Model.FindRowById(id)
			If Model.Error.IsInitialized Then
				ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
				Return
			End If
			If Not(Found) Then
				ShowAlert("Id not found!", "warning")
				Return
			End If

			' Check conflict
			Dim Found As Boolean = Model.FindRowBySlugNotEqualId(page_slug, id)
			If Model.Error.IsInitialized Then
				ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
				Return
			End If
			If Found Then
				ShowAlert("Page slug already exists!", "warning")
				Return
			End If

			' Update row
			Model.Update(id, topic_id, page_slug, page_title, page_body, page_status, Main.CurrentDateTime)
			If Model.Error.IsInitialized Then
				ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
				Return
			End If
			ShowToast("Page", "updated", "Page updated successfully!", "info")
		Case "DELETE"
			' Delete
			Dim id As Int = Request.GetParameter("id")
			Dim Found As Boolean = Model.FindRowById(id)
			If Model.Error.IsInitialized Then
				ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
				Return
			End If
			If Not(Found) Then
				ShowAlert("Id not found!", "warning")
				Return
			End If
			
			' Delete row
			Model.Delete(id)
			If Model.Error.IsInitialized Then
				ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
				Return
			End If
			ShowToast("Page", "deleted", "Page deleted successfully!", "danger")
	End Select
End Sub