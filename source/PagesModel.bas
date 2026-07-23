B4J=true
Group=Models
ModulesStructureVersion=1
Type=Class
Version=10.5
@EndOfDesignText@
' Pages Model
Sub Class_Globals
	Private DB As MiniORM
	Type Pages (topic_id As Int, page_slug As String, page_title As String, page_body As String, page_status As String, page_featured_image As Byte)
End Sub

Public Sub Initialize
	DB = Main.DB
End Sub

Public Sub GetRowById (Id As Int) As Map
	DB.Open
	DB.Table = "pages"
	DB.Condition = "id = ?"
	DB.Parameter = Id
	DB.Query
	If DB.Found Then
		Return DB.First
	End If
	Return CreateMap()
End Sub

Public Sub FindRowById (Id As Int) As Boolean
	DB.Open
	DB.Table = "pages"
	DB.Find(Id)
	Return DB.Found
End Sub

Public Sub FindRowBySlug (Slug As String) As Boolean
	DB.Open
	DB.Table = "pages"
	DB.Conditions = Array("page_slug = ?")
	DB.Parameters = Array(Slug)
	DB.Query
	Return DB.Found
End Sub

Public Sub FindRowByTitle (Title As String) As Boolean
	DB.Open
	DB.Table = "pages"
	DB.Conditions = Array("page_title = ?")
	DB.Parameters = Array(Title)
	DB.Query
	Return DB.Found
End Sub

Public Sub FindRowBySlugNotEqualId (Slug As String, Id As Int) As Boolean
	DB.Open
	DB.Table = "pages"
	DB.Conditions = Array("page_slug = ?", "id <> ?")
	DB.Parameters = Array(Slug, Id)
	DB.Query
	Return DB.Found
End Sub

Public Sub FindPagesByTopicId (Id As Int) As Boolean
	DB.Open
	DB.Table = "pages"
	DB.Condition = "topic_id = ?"
	DB.Parameter = Id
	DB.Query
	Return DB.Found
End Sub

Public Sub Search (keyword As String) As List
	DB.Open
	DB.Table = "pages p"
	DB.Columns = Array("p.id", "p.topic_id", "t.topic_name", "p.page_slug", "p.page_title", "p.page_status")
	DB.Join("", "topics t", Array("p.topic_id = t.id"))
	If keyword <> "" Then
		DB.Conditions = Array("UPPER(p.page_slug) LIKE ? Or UPPER(p.page_title) LIKE ? Or UPPER(t.topic_name) LIKE ?")
		DB.Parameters = Array("%" & keyword.ToUpperCase & "%", "%" & keyword.ToUpperCase & "%", "%" & keyword.ToUpperCase & "%")
	End If
	DB.Query
	Return DB.Results
End Sub

Public Sub Found As Boolean
	Return DB.Found
End Sub

Public Sub First As Map
	Return DB.First
End Sub

Public Sub Error As Exception
	Return DB.Error
End Sub

Public Sub Create (Topic_Id As Int, Page_Slug As String, Page_Title As String, Page_Body As String, Page_Status As Int, Created_Date As String)
	DB.Open
	DB.Table = "pages"	
	DB.Columns = Array("topic_id", "page_slug", "page_title", "page_body", "page_status", "created_date")
	DB.Parameters = Array(Topic_Id, Page_Slug, Page_Title, Page_Body, Page_Status, Main.CurrentDateTime)
	'DB.ReturnRow = True
	DB.Save
End Sub

Public Sub Read As List
	DB.Open
	DB.Table = "pages"
	DB.Columns = Array("id", "topic_name")
	DB.Query
	Return DB.Results
End Sub

Public Sub List As List
	DB.Open
	DB.Table = "pages p"
	DB.Columns = Array("p.id", "p.topic_id", "t.topic_name", "p.page_slug", "p.page_title", "p.page_body", "p.page_status", "Date(p.created_date) AS created_date", "u.first_name AS author")
	DB.Join("", "topics t", Array("p.topic_id = t.id"))
	DB.Join("", "users u", Array("p.created_by = u.id"))
	DB.OrderBy = CreateMap("p.id": "")
	DB.Query
	Return DB.Results
End Sub

Public Sub Update (Id As Int, Topic_Id As Int, Page_Slug As String, Page_Title As String, Page_Body As String, Page_Status As Int, Modified_Date As String)
	DB.Open
	DB.Table = "pages"
	DB.Columns = Array("topic_id", "page_slug", "page_title", "page_body", "page_status", "modified_date")
	DB.Parameters = Array(Topic_Id, Page_Slug, Page_Title, Page_Body, Page_Status, Modified_Date)
	DB.Condition = "id = ?"
	DB.Parameter = Id
	'DB.ReturnRow = True
	DB.Save
End Sub

Public Sub Delete (Id As Int)
	DB.Open
	DB.Table = "pages"
	DB.Id = Id
	DB.Delete
End Sub

Public Sub CreatePagesTable
	DB.ShowExtraLogs = True
	DB.UseTimestamps = True
	DB.QueryExecute = False
	DB.QueryAddToBatch = True
	DB.IfNotExist = True
	
	Log("Creating Pages table...")
	DB.Open
	DB.Table = "pages"
	DB.Columns.Add(CreateMap("Name": "topic_id", "Type": DB.INTEGER, "Default": "0"))
	DB.Columns.Add(CreateMap("Name": "page_slug", "Null": False))
	DB.Columns.Add(CreateMap("Name": "page_title", "Null": False))
	DB.Columns.Add(CreateMap("Name": "page_body", "Null": False))
	DB.Columns.Add(CreateMap("Name": "page_status", "Null": False))
	DB.Columns.Add(CreateMap("Name": "page_featured_image", "Type": DB.BLOB))
	DB.Foreign = "topic_id"
	DB.References("topics", "id")
	DB.Create
	
	Wait For (DB.ExecuteBatchAsync) Complete (Success As Boolean)
	If Success Then
		Log("Table Pages created successfully!")
	Else
		Log("Table Pages creation failed!")
	End If
	DB.Close
	DB.QueryExecute = True
End Sub