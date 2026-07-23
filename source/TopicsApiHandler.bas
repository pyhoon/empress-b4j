B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=10.3
@EndOfDesignText@
' Topics Api Handler class
' Version 6.99 rev1
Sub Class_Globals
	Private Path As String
	Private Method As String
	Private Request As ServletRequest
	Private Response As ServletResponse
	Private HRM As HttpResponseMessage
	Private Model As TopicsModel
End Sub

Public Sub Initialize
	HRM = Main.HRM
	Model.Initialize
End Sub

Sub Handle (req As ServletRequest, resp As ServletResponse)
	Request = req
	Response = resp
	Path = Request.RequestURI
	Method = Request.Method.ToUpperCase
	If Path = "/api/topics" And Method = "GET" Then
		GetTopics
	Else If Path = "/api/topics" And Method = "POST" Then
		PostTopic
	Else If Path.StartsWith("/api/topics/") And Method = "GET" Then
		GetTopicById
	Else If Path.StartsWith("/api/topics/") And Method = "PUT" Then
		PutTopicById
	Else If Path.StartsWith("/api/topics/") And Method = "DELETE" Then
		DeleteTopicById
	Else
		WebApiUtils.ReturnBadRequest(HRM, Response)
	End If
End Sub

Private Sub GetTopics
	Log($"${Method}: ${Path}"$)
	Dim Data As List = Model.Read
	If Model.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = Model.Error.Message
	Else
		HRM.ResponseCode = 200
		HRM.ResponseData = Data
	End If
	WebApiUtils.ReturnHttpResponse(HRM, Response)
End Sub

Private Sub GetTopicById
	Log($"${Method}: ${Path}"$)
	Try
		Dim id As Int = Path.SubString("/api/topics/".Length)
	Catch
		HRM.ResponseCode = 400
		HRM.ResponseError = "Invalid id value"
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End Try
	
	Dim Row As Map = Model.GetRowById(id)
	If Model.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = Model.Error.Message
	Else
		If Model.Found Then
			HRM.ResponseCode = 200
			HRM.ResponseObject = Row
		Else
			HRM.ResponseCode = 404
			HRM.ResponseError = "Topic not found"
		End If
	End If
	WebApiUtils.ReturnHttpResponse(HRM, Response)
End Sub

Private Sub PostTopic
	Log($"${Method}: ${Path}"$)
	Dim str As String = WebApiUtils.RequestDataText(Request)
	If WebApiUtils.ValidateContent(str, HRM.PayloadType) = False Then
		HRM.ResponseCode = 422
		HRM.ResponseError = $"Invalid ${HRM.PayloadType} payload"$
		WebApiUtils.ReturnHttpResponse(HRM, Response)
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
			WebApiUtils.ReturnHttpResponse(HRM, Response)
			Return
		End If
	Next
	
	' Check conflict Topic name
	Dim name As String = data.Get("topic_name")
	Dim Found As Boolean = Model.FindRowByName(name)
	If Model.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = Model.Error.Message
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End If
	If Found Then
		HRM.ResponseCode = 409
		HRM.ResponseError = "Topic already exist"
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End If
	
	' Insert new row
	Model.Create(name, Main.CurrentDateTime)
	If Model.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = Model.Error.Message
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End If
	
	' Retrieve new row
	HRM.ResponseCode = 201
	HRM.ResponseObject = Model.First
	HRM.ResponseMessage = "Topic created successfully"
	WebApiUtils.ReturnHttpResponse(HRM, Response)
End Sub

Private Sub PutTopicById
	Log($"${Method}: ${Path}"$)
	Try
		Dim id As Int = Path.SubString("/api/topics/".Length)
		
	Catch
		HRM.ResponseCode = 400
		HRM.ResponseError = "Invalid id value"
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End Try
	
	Dim str As String = WebApiUtils.RequestDataText(Request)
	If WebApiUtils.ValidateContent(str, HRM.PayloadType) = False Then
		HRM.ResponseCode = 422
		HRM.ResponseError = $"Invalid ${HRM.PayloadType} payload"$
		WebApiUtils.ReturnHttpResponse(HRM, Response)
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
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End If
	
	' Find row by id
	Dim Found As Boolean = Model.FindRowById(id)
	If Model.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = Model.Error.Message
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End If
	If Not(Found) Then
		HRM.ResponseCode = 404
		HRM.ResponseError = "Topic not found"
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End If
	
	' Check conflict Topic name
	Dim name As String = data.Get("topic_name")
	Dim Found As Boolean = Model.FindRowByTopicNameNotEqualId(name, id)
	If Model.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = Model.Error.Message
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End If
	If Found Then
		HRM.ResponseCode = 409
		HRM.ResponseError = "Topic already exist"
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End If
	
	' Update row by id
	Model.Update(id, name, Main.CurrentDateTime)
	If Model.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = Model.Error.Message
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End If

	' Return updated row
	HRM.ResponseCode = 200
	HRM.ResponseMessage = "Topic updated successfully"
	HRM.ResponseObject = Model.First
	WebApiUtils.ReturnHttpResponse(HRM, Response)
End Sub

Private Sub DeleteTopicById
	Log($"${Method}: ${Path}"$)
	Try
		Dim id As Int = Path.SubString("/api/topics/".Length)
	Catch
		HRM.ResponseCode = 400
		HRM.ResponseError = "Invalid id value"
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End Try
	
	' Find row by id
	Dim Found As Boolean = Model.FindRowById(id)
	If Model.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = Model.Error.Message
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End If
	If Not(Found) Then
		HRM.ResponseCode = 404
		HRM.ResponseError = "Topic not found"
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End If
	
	' Delete row
	Model.Delete(id)
	If Model.Error.IsInitialized Then
		HRM.ResponseCode = 422
		HRM.ResponseError = Model.Error.Message
		WebApiUtils.ReturnHttpResponse(HRM, Response)
		Return
	End If
	HRM.ResponseCode = 200
	HRM.ResponseMessage = "Topic deleted successfully"
	WebApiUtils.ReturnHttpResponse(HRM, Response)
End Sub