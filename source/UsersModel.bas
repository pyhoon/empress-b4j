B4J=true
Group=Models
ModulesStructureVersion=1
Type=Class
Version=10.5
@EndOfDesignText@
Sub Class_Globals
	Private DB As MiniORM
	Type Users (first_name As String, last_name As String, email As String, hash As String, salt As String, admin As Int, active As Int)
End Sub

Public Sub Initialize
	DB = Main.DB
End Sub

Public Sub GetRowById (Id As Int) As Map
	DB.Open
	DB.Table = "users"
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
	DB.Table = "users"
	DB.Find(Id)
	Return DB.Found
End Sub

Public Sub FindRowByEmail (Email As String) As Boolean
	DB.Open
	DB.Table = "users"
	DB.Conditions = Array("email = ?")
	DB.Parameters = Array(Email)
	DB.Query
	Return DB.Found
End Sub

Public Sub FindRowByEmailNotEqualId (Email As String, Id As Int) As Boolean
	DB.Open
	DB.Table = "users"
	DB.Conditions = Array("email = ?", "id <> ?")
	DB.Parameters = Array(Email, Id)
	DB.Query
	Return DB.Found
End Sub

Public Sub FindPagesByUserId (Id As Int) As Boolean
	DB.Open
	DB.Table = "pages"
	DB.Condition = "created_by = ?"
	DB.Parameter = Id
	DB.Query
	Return DB.Found
End Sub

Public Sub Search (keyword As String) As List
	DB.Open
	DB.Table = "users"
	If keyword <> "" Then
		DB.Conditions = Array("UPPER(first_name) LIKE ? Or UPPER(last_name) LIKE ? Or UPPER(email) LIKE ?")
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

Public Sub Create (First_Name As String, Last_Name As String, Email As String, isAdmin As Int, isActive As Int, Created_Date As String)
	Dim Salt As String = Encryption.RandomHash
	Dim Hash As String = Encryption.MD5("password" & Salt)
	DB.Open
	DB.Table = "users"
	DB.Columns = Array("first_name", "last_name", "email", "hash", "salt", "admin", "active", "created_date")
	DB.Parameters = Array(First_Name, Last_Name, Email, Hash, Salt, isAdmin, isActive, Created_Date)
	'DB.ReturnRow = True
	DB.Save
End Sub

Public Sub Read As List
	DB.Open
	DB.Table = "users"
	DB.Columns = Array("id", "first_name", "last_name", "email", "admin", "active")
	DB.OrderBy = CreateMap("id": "")
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

Public Sub Update (Id As Int, First_Name As String, Last_Name As String, Email As String, isAdmin As Int, isActive As Int, Modified_Date As String)
	DB.Open
	DB.Table = "users"
	DB.Columns = Array("first_name", "last_name", "email", "admin", "active", "modified_date")
	DB.Parameters = Array(First_Name, Last_Name, Email, isAdmin, isActive, Main.CurrentDateTime)
	DB.Id = Id
	'DB.ReturnRow = True
	DB.Save
End Sub

Public Sub Delete (Id As Int)
	DB.Open
	DB.Table = "users"
	DB.Id = Id
	DB.Delete
End Sub

Public Sub CreateUsersTable
	DB.ShowExtraLogs = True
	DB.UseTimestamps = True
	DB.QueryExecute = False
	DB.QueryAddToBatch = True
	DB.IfNotExist = True
	
	Log("Creating Users table...")
	DB.Open
	DB.Table = "users"
	DB.Columns.Add(CreateMap("Name": "first_name", "Null": False))
	DB.Columns.Add(CreateMap("Name": "last_name", "Null": False))
	DB.Columns.Add(CreateMap("Name": "email", "Null": False))
	DB.Columns.Add(CreateMap("Name": "hash", "Null": False))
	DB.Columns.Add(CreateMap("Name": "salt", "Null": False))
	DB.Columns.Add(CreateMap("Name": "admin", "Type": DB.INTEGER, "Default": "0"))
	DB.Columns.Add(CreateMap("Name": "active", "Type": DB.INTEGER, "Default": "0"))
	DB.Create
	
	Dim salt As String = Encryption.RandomHash
	Dim hash As String = Encryption.MD5("admin" & salt)
	DB.Columns = Array("first_name", "last_name", "email", "hash", "salt", "admin", "active")
	DB.InsertWithParams = Array("Admin", "", "admin", hash, salt, 1, 1)
	
	Wait For (DB.ExecuteBatchAsync) Complete (Success As Boolean)
	If Success Then
		Log("Table Users created successfully!")
	Else
		Log("Table Users creation failed!")
	End If
	DB.Close
	DB.QueryExecute = True
End Sub