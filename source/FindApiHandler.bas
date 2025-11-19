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
	Private ElementKey As String
End Sub

Public Sub Initialize
	App = Main.App
	HRM.Initialize
	Main.SetApiMessage(HRM)
	DB.Initialize(Main.DBType, Null)
	'HRM.ResponseKeys = Array("m", "a", "r")
	'HRM.ResponseKeysAlias = Array("message", "code", "data")
End Sub

Sub Handle (req As ServletRequest, resp As ServletResponse)
	Request = req
	Response = resp
	Method = Request.Method.ToUpperCase
	Dim FullElements() As String = WebApiUtils.GetUriElements(Request.RequestURI)
	Elements = WebApiUtils.CropElements(FullElements, 3)
	If ElementMatch("") Then
		If App.MethodAvailable2(Method, "/api/find", Me) Then
			Select Method
				Case "GET"
					GetAllPages
					Return
				Case "POST"
					SearchByKeywords
					Return
			End Select
		End If
		ReturnMethodNotAllow
		Return
	End If
	If ElementMatch("key/id") Then
		If App.MethodAvailable2(Method, "/api/find/pages-by-topic-id/*", Me) Then
			If ElementKey = "pages-by-topic-id" Then
				GetPagesByTopicId(ElementId)
				Return
			End If
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
		Case "key/id"
			If Elements.Length = 2 Then
				ElementKey = Elements(0)
				If IsNumber(Elements(1)) Then
					ElementId = Elements(1)
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

Public Sub GetAllPages
	Log($"${Request.Method}: ${Request.RequestURI}"$)
	DB.SQL = Main.DBOpen
	DB.Table = "pages p"
	' Construct results with new column name alias
	DB.Select = Array("p.id id", "p.topic_id", "t.topic_name", "p.page_slug", "p.page_title", "p.page_body", "p.page_status")
	DB.Join = DB.CreateJoin("topics t", "p.topic_id = t.id", "")
	DB.OrderBy = CreateMap("p.id": "")
	DB.Query
	HRM.ResponseCode = 200
	HRM.ResponseData = DB.Results2
	DB.Close
	ReturnApiResponse
End Sub

Public Sub GetPagesByTopicId (id As Int)
	Log($"${Request.Method}: ${Request.RequestURI}"$)
	DB.SQL = Main.DBOpen
	DB.Table = "pages p"
	' Construct results with new column name alias
	DB.Select = Array("p.id id", "p.topic_id", "t.topic_name", "p.page_slug", "p.page_title", "p.page_body", "p.page_status")
	DB.Join = DB.CreateJoin("topics t", "p.topic_id = t.id", "")
	DB.WhereParam("t.id = ?", id)
	DB.OrderBy = CreateMap("p.id": "")
	DB.Query
	HRM.ResponseCode = 200
	HRM.ResponseData = DB.Results2
	DB.Close
	ReturnApiResponse
End Sub

Public Sub SearchByKeywords
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
	If data.ContainsKey("keyword") = False Then
		HRM.ResponseCode = 400
		HRM.ResponseError = "Key 'keyword' not found"
		ReturnApiResponse
		Return
	End If
	Dim SearchForText As String = data.Get("keyword")
	DB.SQL = Main.DBOpen
	DB.Table = "pages p"
	' Construct results with new column name alias
	DB.Select = Array("p.id id", "p.topic_id", "t.topic_name", "p.page_slug", "p.page_title", "p.page_body", "p.page_status")
	DB.Join = DB.CreateJoin("topics t", "p.topic_id = t.id", "")
	If SearchForText <> "" Then
		DB.Where = Array("p.page_title LIKE ? Or UPPER(p.page_body) LIKE ? Or UPPER(t.topic_name) LIKE ?")
		DB.Parameters = Array("%" & SearchForText & "%", "%" & SearchForText.ToUpperCase & "%", "%" & SearchForText.ToUpperCase & "%")
	End If
	DB.OrderBy = CreateMap("p.id": "")
	DB.Query
	HRM.ResponseCode = 200
	HRM.ResponseData = DB.Results2
	DB.Close
	ReturnApiResponse
End Sub