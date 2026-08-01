; AutoHotkey v2 script with GUI for PowerShell

MyGui := Gui()                                         ; Create the GUI object
MyGui.AddText("Enter parameter for PowerShell:")      ; Add a text label
ParamInput := MyGui.AddEdit()                          ; Create an input field
MyGui.AddButton("Run PowerShell", Func("RunPS"))      ; Add a button to trigger the PowerShell script
MyGui.Show()                                           ; Show the GUI

RunPS() {
    global ParamInput                                   ; Make ParamInput accessible
    param := ParamInput.Text                            ; Get the value from the input field
    Run('powershell.exe -Command "Write-Output ' param '"', '', 'Hide') ; Run PowerShell command
}

MyGui.OnEvent("Close", () => ExitApp())                ; Close the GUI and exit the script when closed
