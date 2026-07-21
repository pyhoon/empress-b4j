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