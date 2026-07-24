; Function to capture PowerShell output
PSOutput := RunWaitOneLine("powershell.exe -Command Get-Process")

MsgBox, % "PowerShell Output: " PSOutput

RunWaitOneLine(cmd) {
    shell := ComObjCreate("WScript.Shell")
    exec := shell.Exec(cmd)
    return exec.StdOut.ReadAll()
}
