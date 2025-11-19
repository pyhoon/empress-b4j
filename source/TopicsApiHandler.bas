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
		If App.MethodAvailable2(Method, "/api/topics", Me) Then
			Select Method
				Case "GET"
					Gettopics
					Return
				Case "POST"
					CreateNewtopic
					Return
			End Select
		End If
		ReturnMethodNotAllow
		Return
	Else If ElementMatch("id") Then
		If App.MethodAvailable2(Method, "/api/topics/*", Me) Then
			Select Method
				Case "GET"
					GettopicById(ElementId)
					Return
				Case "PUT"
					UpdatetopicById(ElementId)
					Return
				Case "DELETE"
					DeletetopicById(ElementId)
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

Private Sub Gettopics
	Log($"${Request.Method}: ${Request.RequestURI}"$)
	DB.SQL = Main.DBOpen
	DB.Table = "topics"
	DB.Query
	HRM.ResponseCode = 200
	HRM.ResponseData = DB.Results2
	ReturnApiResponse
	DB.Close
End Sub

Private Sub GettopicById (id As Int)
	Log($"${Request.Method}: ${Request.RequestURI}"$)
	DB.SQL = Main.DBOpen
	DB.Table = "topics"
	DB.Find(id)
	If DB.Found Then
		HRM.ResponseCode = 200
		HRM.ResponseObject = DB.First2
	Else
		HRM.ResponseCode = 404
		HRM.ResponseError = "Topic not found"
	End If
	ReturnApiResponse
	DB.Close
End Sub

Private Sub CreateNewtopic
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
	Dim RequiredKeys As List = Array As String("topic_name") 
	For Each requiredkey As String In RequiredKeys
		If data.ContainsKey(requiredkey) = False Then
			HRM.ResponseCode = 400
			HRM.ResponseError = $"Key '${requiredkey}' not found"$
			ReturnApiResponse
			Return
		End If
	Next
	' Check conflict topic name
	DB.SQL = Main.DBOpen
	DB.Table = "topics"
	DB.Where = Array("topic_name = ?")
	DB.Parameters = Array(data.Get("topic_name"))
	DB.Query
	If DB.Found Then
		HRM.ResponseCode = 409
		HRM.ResponseError = "Topic already exist"
		ReturnApiResponse
		DB.Close
		Return
	End If
	' Insert new row
	DB.Reset
	DB.Columns = Array("topic_name", _
	"created_date")
	DB.Parameters = Array(data.Get("topic_name"), _
	data.GetDefault("created_date", WebApiUtils.CurrentDateTime))
	DB.Save
	' Retrieve new row
	HRM.ResponseCode = 201
	HRM.ResponseObject = DB.First2
	HRM.ResponseMessage = "Topic created successfully"
	ReturnApiResponse
	DB.Close
End Sub

Private Sub UpdatetopicById (id As Int)
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
	If data.ContainsKey("topic_name") = False Then
		HRM.ResponseCode = 400
		HRM.ResponseError = "Key 'topic_name' not found"
		ReturnApiResponse
		Return
	End If
	' Check conflict topic name
	DB.SQL = Main.DBOpen
	DB.Table = "topics"
	DB.Where = Array("topic_name = ?", "id <> ?")
	DB.Parameters = Array(data.Get("topic_name"), id)
	DB.Query
	If DB.Found Then
		HRM.ResponseCode = 409
		HRM.ResponseError = "Topic already exist"
		ReturnApiResponse
		DB.Close
		Return
	End If
	' Find row by id
	DB.Find(id)
	If DB.Found = False Then
		HRM.ResponseCode = 404
		HRM.ResponseError = "Topic not found"
		ReturnApiResponse
		DB.Close
		Return
	End If
	' Update row by id
	DB.Reset
	DB.Columns = Array("topic_name", _
	"modified_date")
	DB.Parameters = Array(data.Get("topic_name"), _
	data.GetDefault("created_date", WebApiUtils.CurrentDateTime))
	DB.Id = id
	DB.Save
	' Return updated row
	HRM.ResponseCode = 200
	HRM.ResponseMessage = "Topic updated successfully"
	HRM.ResponseObject = DB.First2
	ReturnApiResponse
	DB.Close
End Sub

Private Sub DeletetopicById (id As Int)
	Log($"${Request.Method}: ${Request.RequestURI}"$)
	DB.SQL = Main.DBOpen
	DB.Table = "topics"
	' Find row by id
	DB.Find(id)
	If DB.Found = False Then
		HRM.ResponseCode = 404
		HRM.ResponseError = "Topic not found"
		ReturnApiResponse
		DB.Close
		Return
	End If
	' Delete row
	DB.Reset
	DB.Id = id
	DB.Delete
	HRM.ResponseCode = 200
	HRM.ResponseMessage = "Topic deleted successfully"
	ReturnApiResponse
	DB.Close
End Sub