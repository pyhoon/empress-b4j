B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=10.3
@EndOfDesignText@
' Users Handler class
Sub Class_Globals
	Private App As EndsMeet
	Private Path As String
	Private Method As String
	Private View As UsersView
	Private Model As UsersModel
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
	Method = req.Method
	Log($"${Request.Method}: ${Request.RequestURI}"$)
	Dim Path As String = req.RequestURI
	If Path = "/users" Then
		HandlePage
	Else If Path = "/hx/users/table" Then
		HandleTable
	Else If Path = "/hx/users/add" Then
		HandleModalAdd
	Else If Path.StartsWith("/hx/users/edit/") Then
		HandleModalEdit
	Else If Path.StartsWith("/hx/users/delete/") Then
		HandleModalDelete
	Else
		HandleUsers
	End If
End Sub

Private Sub HandlePage
	App.WriteHtml2(Response, View.Show, App.ctx)
End Sub

' Return default or search results table
Private Sub HandleTable
	Dim keyword As String = Request.GetParameter("keyword")
	Dim Rows As List = Model.Search(keyword)
	App.WriteHtml(Response, View.RenderedTable(Rows))
End Sub

' Handle CRUD operations
Private Sub HandleUsers
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
			
			Dim Found As Boolean = Model.FindRowByEmail(email)
			If Model.Error.IsInitialized Then
				ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
				Return
			End If
			If Found Then
				ShowAlert("Email already exists!", "warning")
				Return
			End If
			
			' Insert new row
			Model.Create(first_name, last_name, email, isAdmin, isActive, Main.CurrentDateTime)
			If Model.Error.IsInitialized Then
				ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
				Return
			End If
			ShowToast("User", "created", "User created successfully!", "success")
		Case "PUT"
			' Update
			Dim id As Int = Request.GetParameter("id")
			Dim first_name As String = Request.GetParameter("first_name")
			Dim last_name As String = Request.GetParameter("last_name")
			Dim email As String = Request.GetParameter("email")
			Dim admin As String = Request.GetParameter("admin")
			Dim active As String = Request.GetParameter("active")
			Dim isAdmin As Int = IIf(admin = "on", 1, 0)
			Dim isActive As Int = IIf(active = "on", 1, 0)
			
			Dim Found As Boolean = Model.FindRowById(id)
			If Model.Error.IsInitialized Then
				ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
				Return
			End If
			If Not(Found) Then
				ShowAlert("Id not found!", "warning")
				Return
			End If
			
			Dim Found As Boolean = Model.FindRowByEmailNotEqualId(email, id)
			If Model.Error.IsInitialized Then
				ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
				Return
			End If
			If Found Then
				ShowAlert("Email already exists!", "warning")
				Return
			End If
			
			' Update row
			Model.Update(id, first_name, last_name, email, isAdmin, isActive, Main.CurrentDateTime)
			If Model.Error.IsInitialized Then
				ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
				Return
			End If
			ShowToast("User", "updated", "User updated successfully!", "info")
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
			
			Dim Found As Boolean = Model.FindPagesByUserId(id)
			If Model.Error.IsInitialized Then
				ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
				Return
			End If
			If Found Then
				ShowAlert("Cannot delete user with associated pages!", "warning")
				Return
			End If
			
			' Delete row
			Model.Delete(id)
			If Model.Error.IsInitialized Then
				ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
				Return
			End If
			ShowToast("User", "deleted", "User deleted successfully!", "danger")
	End Select
End Sub

' Add modal
Private Sub HandleModalAdd
	App.WriteHtml(Response, View.Modal("Add", Null))
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
	Dim Data As Map = Model.GetRowById(id)
	If Model.Error.IsInitialized Then
		ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
		Return
	End If
	App.WriteHtml(Response, View.Modal("Edit", Data))
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
	Dim Data As Map = Model.GetRowById(id)
	If Model.Error.IsInitialized Then
		ShowAlert($"Database error: ${Model.Error.Message}"$, "danger")
		Return
	End If
	App.WriteHtml(Response, View.Modal("Delete", Data))
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