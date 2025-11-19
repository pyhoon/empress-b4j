B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=10.3
@EndOfDesignText@
'Api Handler class
'Version 6.30
Sub Class_Globals
	Private DB As MiniORM
	Private App As EndsMeet
	Private Request As ServletRequest
	Private Response As ServletResponse
	Private HRM As HttpResponseMessage
	Private Method As String
	Private Elements() As String
	Private ElementId As Int
End Sub

Public Sub Initialize
	App = Main.App
	HRM.Initialize
	Main.SetApiMessage(HRM)
	DB.Initialize(Main.DBType, Null)
End Sub

Sub Handle (req As ServletRequest, resp As ServletResponse)
	Request = req
	Response = resp
	Method = Request.Method.ToUpperCase
	Dim FullElements() As String = WebApiUtils.GetUriElements(Request.RequestURI)
	Elements = WebApiUtils.CropElements(FullElements, 3) ' 3 For Api handler
	If ElementMatch("") Then
		If App.MethodAvailable2(Method, "/api/pages", Me) Then
			Select Method
				Case "GET"
					GetPages
					Return
				Case "POST"
					PostPage
					Return
			End Select
		End If
		ReturnMethodNotAllow
		Return
	Else If ElementMatch("id") Then
		If App.MethodAvailable2(Method, "/api/pages/*", Me) Then
			Select Method
				Case "GET"
					GetPageById(ElementId)
					Return
				Case "PUT"
					PutPageById(ElementId)
					Return
				Case "DELETE"
					DeletePageById(ElementId)
					Return
			End Select
		End If
		ReturnMethodNotAllow
		Return
	End If
	ReturnBadRequest
End Sub

Private Sub ElementMatch (Pattern As String) As Boolean
	Select Pattern
		Case ""
			If Elements.Length = 0 Then
				Return True
			End If
		Case "id"
			If Elements.Length = 1 Then
				If IsNumber(Elements(0)) Then
					ElementId = Elements(0)
					Return True
				End If
			End If
	End Select
	Return False
End Sub

Private Sub ReturnApiResponse
	WebApiUtils.ReturnHttpResponse(HRM, Response)
End Sub

Private Sub ReturnBadRequest
	WebApiUtils.ReturnBadRequest(HRM, Response)
End Sub

Private Sub ReturnMethodNotAllow
	WebApiUtils.ReturnMethodNotAllow(HRM, Response)
End Sub

Private Sub GetPages
	Log($"${Request.Method}: ${Request.RequestURI}"$)
	DB.SQL = Main.DBOpen
	DB.Table = "pages"
	DB.Query
	HRM.ResponseCode = 200
	HRM.ResponseData = DB.Results2
	ReturnApiResponse
	DB.Close
End Sub

Private Sub GetPageById (id As Int)
	Log($"${Request.Method}: ${Request.RequestURI}"$)
	DB.SQL = Main.DBOpen
	DB.Table = "pages"
	DB.Find(id)
	If DB.Found Then
		HRM.ResponseCode = 200
		HRM.ResponseObject = DB.First2
	Else
		HRM.ResponseCode = 404
		HRM.ResponseError = "Page not found"
	End If
	'HRM.ResponseKeys = Array("s", "r")
	ReturnApiResponse
	DB.Close
End Sub

Private Sub PostPage
	Log($"${Request.Method}: ${Request.RequestURI}"$)
	Dim str As String = WebApiUtils.RequestDataText(Request)
	If WebApiUtils.ValidateContent(str, HRM.PayloadType) = False Then
		HRM.ResponseCode = 422
		HRM.ResponseError = $"Invalid ${HRM.PayloadType} payload"$
		ReturnApiResponse
		Return
	End If
	If HRM.PayloadType = WebApiUtils.MIME_TYPE_XML Then
		Dim data As Map = WebApiUtils.ParseXML(str)		' XML payload
	Else
		Dim data As Map = WebApiUtils.ParseJSON(str)	' JSON payload
	End If
	' Check whether required keys are provided
	Dim RequiredKeys As List = Array As String("topic_id", "page_title", "page_body") ' "page_slug" and "page_status" are optional
	For Each requiredkey As String In RequiredKeys
		If data.ContainsKey(requiredkey) = False Then
			HRM.ResponseCode = 400
			HRM.ResponseError = $"Key '${requiredkey}' not found"$
			ReturnApiResponse
			Return
		End If
	Next
	' Check conflict page code
	DB.SQL = Main.DBOpen
	DB.Table = "pages"
	DB.Where = Array("page_slug = ?")
	DB.Parameters = Array(Utilities.Slugify(data.Get("page_title")))
	DB.Query
	If DB.Found Then
		HRM.ResponseCode = 409
		HRM.ResponseError = "Page already exist"
		ReturnApiResponse
		DB.Close
		Return
	End If
	' Insert new row
	DB.Reset
	DB.Columns = Array("topic_id", _
	"page_slug", _
	"page_title", _
	"page_body", _
	"page_status", _
	"created_date")
	DB.Parameters = Array(data.Get("topic_id"), _
	Utilities.Slugify(data.Get("page_title")), _
	data.Get("page_title"), _
	data.Get("page_body"), _
	data.GetDefault("page_status", 0), _
	data.GetDefault("created_date", WebApiUtils.CurrentDateTime))
	DB.Save
	' Retrieve new row
	HRM.ResponseCode = 201
	HRM.ResponseObject = DB.First2
	HRM.ResponseMessage = "Page created successfully"
	ReturnApiResponse
	DB.Close
End Sub

Private Sub PutPageById (id As Int)
	Log($"${Request.Method}: ${Request.RequestURI}"$)
	Dim str As String = WebApiUtils.RequestDataText(Request)
	If WebApiUtils.ValidateContent(str, HRM.PayloadType) = False Then
		HRM.ResponseCode = 422
		HRM.ResponseError = $"Invalid ${HRM.PayloadType} payload"$
		ReturnApiResponse
		Return
	End If
	If HRM.PayloadType = WebApiUtils.MIME_TYPE_XML Then
		Dim data As Map = WebApiUtils.ParseXML(str)		' XML payload
	Else
		Dim data As Map = WebApiUtils.ParseJSON(str)	' JSON payload
	End If
	' Check whether required keys are provided
	Dim RequiredKeys As List = Array As String("topic_id", "page_slug", "page_title") ' "page_status" is optional
	For Each requiredkey As String In RequiredKeys
		If data.ContainsKey(requiredkey) = False Then
			HRM.ResponseCode = 400
			HRM.ResponseError = $"Key '${requiredkey}' not found"$
			ReturnApiResponse
			Return
		End If
	Next
	' Check conflict page code
	DB.SQL = Main.DBOpen
	DB.Table = "pages"
	DB.Where = Array("page_slug = ?", "id <> ?")
	DB.Parameters = Array(data.Get("page_slug"), id)
	DB.Query
	If DB.Found Then
		HRM.ResponseCode = 409
		HRM.ResponseError = "Page slug already exist"
		ReturnApiResponse
		DB.Close
		Return
	End If
	' Find row by id
	DB.Find(id)
	If DB.Found = False Then
		HRM.ResponseCode = 404
		HRM.ResponseError = "Page not found"
		ReturnApiResponse
		DB.Close
		Return
	End If
	' Update row by id
	DB.Reset
	DB.Columns = Array("topic_id", _
	"page_slug", _
	"page_title", _
	"page_status", _
	"modified_date")
	DB.Parameters = Array(data.Get("topic_id"), _
	data.Get("page_slug"), _
	data.Get("page_title"), _
	data.GetDefault("page_status", 0), _
	data.GetDefault("modified_date", WebApiUtils.CurrentDateTime))
	DB.Id = id
	DB.Save
	' Return updated row
	HRM.ResponseCode = 200
	HRM.ResponseMessage = "Page updated successfully"
	HRM.ResponseObject = DB.First2
	ReturnApiResponse
	DB.Close
End Sub

Private Sub DeletePageById (id As Int)
	Log($"${Request.Method}: ${Request.RequestURI}"$)
	DB.SQL = Main.DBOpen
	DB.Table = "pages"
	' Find row by id
	DB.Find(id)
	If DB.Found = False Then
		HRM.ResponseCode = 404
		HRM.ResponseError = "Page not found"
		ReturnApiResponse
		DB.Close
		Return
	End If
	' Delete row
	DB.Reset
	DB.Id = id
	DB.Delete
	HRM.ResponseCode = 200
	HRM.ResponseMessage = "Page deleted successfully"
	ReturnApiResponse
	DB.Close
End Sub