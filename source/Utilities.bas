B4J=true
Group=Modules
ModulesStructureVersion=1
Type=StaticCode
Version=10.3
@EndOfDesignText@
' Utilities Code module
Sub Process_Globals
	
End Sub

Public Sub Slugify (str As String) As String
	str = str.ToLowerCase.Trim
	str = Regex.Replace("\s", str, "-")
	str = Regex.Replace("[^\w\-]+", str, "")
	str = Regex.Replace("\-\-+", str, "-")
	str = Regex.Replace("^-+/", str, "")
	Return str
End Sub