B4J=true
Group=Models
ModulesStructureVersion=1
Type=Class
Version=10.5
@EndOfDesignText@
' Topics Model
Sub Class_Globals
	Private DB As MiniORM
	Type Topics (topic_name As String)
End Sub

Public Sub Initialize
	DB = Main.DB
End Sub

Public Sub GetRowById (Id As Int) As Map
	DB.Open
	DB.Table = "topics"
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
	DB.Table = "topics"
	DB.Find(Id)
	Return DB.Found
End Sub

Public Sub FindRowByName (Name As String) As Boolean
	DB.Open
	DB.Table = "topics"
	DB.Conditions = Array("topic_name = ?")
	DB.Parameters = Array(Name)
	DB.Query
	Return DB.Found
End Sub

Public Sub FindRowByTopicNameNotEqualId (Name As String, Id As Int) As Boolean
	DB.Open
	DB.Table = "topics"
	DB.Conditions = Array("topic_name = ?", "id <> ?")
	DB.Parameters = Array(Name, Id)
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

Public Sub Found As Boolean
	Return DB.Found
End Sub

Public Sub First As Map
	Return DB.First
End Sub

Public Sub Error As Exception
	Return DB.Error
End Sub

Public Sub Create (Name As String, Created_Date As String)
	DB.Open
	DB.Table = "topics"
	DB.Columns = Array("topic_name", "created_date")
	DB.Parameters = Array(Name, Created_Date)
	'DB.ReturnRow = True
	DB.Save
End Sub

Public Sub Read As List
	DB.Open
	DB.Table = "topics"
	DB.Columns = Array("id", "topic_name")
	DB.Query
	Return DB.Results
End Sub

Public Sub Update (Id As Int, Name As String, Modified_Date As String)
	DB.Open
	DB.Table = "topics"
	DB.Columns = Array("topic_name", "modified_date")
	DB.Parameters = Array(Name, Modified_Date)
	DB.Condition = "id = ?"
	DB.Parameter = Id
	'DB.ReturnRow = True
	DB.Save
End Sub

Public Sub Delete (Id As Int)
	DB.Open
	DB.Table = "topics"
	DB.Id = Id
	DB.Delete
End Sub

Public Sub CreateTopicsTable
	DB.ShowExtraLogs = True
	DB.UseTimestamps = True
	DB.QueryExecute = False
	DB.QueryAddToBatch = True
	DB.IfNotExist = True
	
	Log("Creating Topics table...")
	DB.Open
	DB.Table = "tbl_topics"
	DB.Columns.Add(CreateMap("Name": "topic_name", "Null": False))
	DB.Create
	
	DB.Columns = Array("topic_name")
	DB.InsertWithParams = Array("News")
	DB.InsertWithParams = Array("Products")	
	
	Wait For (DB.ExecuteBatchAsync) Complete (Success As Boolean)
	If Success Then
		Log("Table Topics created successfully!")
	Else
		Log("Table Topics creation failed!")
	End If
	DB.Close
	DB.QueryExecute = True
End Sub