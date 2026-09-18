Option Explicit
Dim shell, fso, folder, command
Set shell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
folder = fso.GetParentFolderName(WScript.ScriptFullName)
command = "powershell.exe -NoProfile -WindowStyle Hidden -Command ""Set-Content -LiteralPath '" & Replace(folder, "'", "''") & "\.wallpaper-stop' -Value stop"""
shell.Run command, 0, True
