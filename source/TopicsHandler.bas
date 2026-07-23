B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=10.5
@EndOfDesignText@
' Topics Handler class
Sub Class_Globals
	Private App As EndsMeet
	Private Path As String
	Private Method As String
	Private View As TopicsView
	Private Model As TopicsModel
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
	If Path = "/topics" Then
		HandlePage
	Else If Path = "/hx/topics/table" Then
		HandleTable
	Else If Path = "/hx/topics/add" Then
		HandleModalAdd
	Else If Path.StartsWith("/hx/topics/edit/") Then
		HandleModalEdit
	Else If Path.StartsWith("/hx/topics/delete/") Then
		HandleModalDelete
	Else
		HandleTopics
	End If
End Sub

Private Sub HandlePage
	App.WriteHtml2(Response, View.Show(Request), App.ctx)
End Sub

' Return table HTML
Private Sub HandleTable
	Dim Rows As List = Model.Read
	App.WriteHtml(Response, View.RenderedTable(Rows))
End Sub

' Add modal
Private Sub HandleModalAdd
	App.WriteHtml(Response, View.Modal("Add", Null))
End Sub

' Edit modal
Private Sub HandleModalEdit
	Try
		Dim id As Int = Path.SubString("/hx/topics/edit/".Length)
	Catch
		Log(LastException)
		ShowAlert($"Error: ${LastException.Message}"$, "danger")
		Return
	End Try
	
	Dim Category As Map = Model.GetRowById(id)
	If Model.Error.IsInitialized Then
		ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
		Return
	End If	
	App.WriteHtml2(Response, View.Modal("Edit", Category), Category)
End Sub

' Delete modal
Private Sub HandleModalDelete
	Try
		Dim id As Int = Path.SubString("/hx/topics/delete/".Length)
	Catch
		Log(LastException)
		ShowAlert($"Error: ${LastException.Message}"$, "danger")
		Return
	End Try
	Dim Category As Map = Model.GetRowById(id)
	If Model.Error.IsInitialized Then
		ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
		Return
	End If	
	App.WriteHtml2(Response, View.Modal("Delete", Category), Category)
End Sub

' Handle CRUD operations
Private Sub HandleTopics
	Select Method
		Case "POST"
			' Create
			Dim name As String = Request.GetParameter("name")
			If name = "" Or name.Trim.Length < 2 Then
				ShowAlert("Category name must be at least 2 characters long.", "warning")
				Return
			End If
			
			Dim Found As Boolean = Model.FindRowByName(name)
			If Model.Error.IsInitialized Then
				ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
				Return
			End If
			If Found Then
				ShowAlert("Category already exists!", "warning")
				Return
			End If
			
			' Insert new row
			Model.Create(name, Main.CurrentDateTime)
			If Model.Error.IsInitialized Then
				ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
				Return
			End If
			ShowToast("Category", "created", "Category created successfully!", "success")
		Case "PUT"
			' Update
			Dim id As Int = Request.GetParameter("id")
			Dim name As String = Request.GetParameter("name")
			
			Dim Found As Boolean = Model.FindRowById(id)
			If Model.Error.IsInitialized Then
				ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
				Return
			End If
			If Not(Found) Then
				ShowAlert("Category not found!", "warning")
				Return
			End If
			
			Dim Found As Boolean = Model.FindRowByTopicNameNotEqualId(name, id)
			If Model.Error.IsInitialized Then
				ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
				Return
			End If
			If Found Then
				ShowAlert("Category already exists!", "warning")
				Return
			End If
			
			' Update row
			Model.Update(id, name, Main.CurrentDateTime)
			If Model.Error.IsInitialized Then
				ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
				Return
			End If
			ShowToast("Category", "updated", "Category updated successfully!", "info")
		Case "DELETE"
			' Delete
			Dim id As Int = Request.GetParameter("id")
			Dim Found As Boolean = Model.FindRowById(id)
			If Model.Error.IsInitialized Then
				ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
				Return
			End If
			If Not(Found) Then
				ShowAlert("Category not found!", "warning")
				Return
			End If
			
			Dim Found As Boolean = Model.FindPagesByTopicId(id)
			If Model.Error.IsInitialized Then
				ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
				Return
			End If
			If Found Then
				ShowAlert("Cannot delete category with associated products!", "warning")
				Return
			End If
			
			' Delete row
			Model.Delete(id)
			If Model.Error.IsInitialized Then
				ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
				Return
			End If
			ShowToast("Category", "deleted", "Category deleted successfully!", "danger")
	End Select
End Sub

Private Sub ShowAlert (Message As String, Status As String)
	Dim info As AlertInfo = MH.CreateAlertInfo(Message, Status)
	App.WriteHtml(Response, View.Alert(info))
End Sub
'
Private Sub ShowToast (Entity As String, Action As String, Message As String, Status As String)
	Dim data As List = Model.Read
	Dim info As ToastInfo = MH.CreateToastInfo(Entity, Action, Message, Status)
	App.WriteHtml(Response, View.Toast(info, data))
End Sub