#Requires AutoHotkey v2.0
#SingleInstance Force
SetWorkingDir(A_ScriptDir)  ; Ensures a consistent starting directory

; =====================================================================
;  Personal hotkeys - run at startup.
;
;  Text snippets (passwords, emails, addresses) are NOT in this file.
;  They live in secrets.ini, which is excluded by .gitignore.
;  See secrets.example.ini for the format.
; =====================================================================

SnippetFile := A_ScriptDir "\secrets.ini"
LoadSnippets(SnippetFile)

LoadSnippets(file) {
    if !FileExist(file) {
        MsgBox("Snippet file not found:`n`n" file "`n`n"
             . "Copy secrets.example.ini to secrets.ini and fill in your values.",
               "MyAutoHotkey", "Icon!")
        ExitApp
    }

    try
        section := IniRead(file, "Snippets")
    catch
        section := ""

    if (section = "") {
        MsgBox("No [Snippets] entries found in:`n`n" file, "MyAutoHotkey", "Icon!")
        ExitApp
    }

    failed := ""
    for line in StrSplit(section, "`n", "`r") {
        if (line = "")
            continue
        pos := InStr(line, "=")          ; split on the FIRST '=' only,
        if !pos                          ; so values may contain '='
            continue
        key   := SubStr(line, 1, pos - 1)
        value := SubStr(line, pos + 1)
        try
            Hotkey(key, TypeSnippet.Bind(value))
        catch as err
            failed .= "`n  " key " - " err.Message
    }

    if (failed != "")
        MsgBox("These hotkeys could not be bound:`n" failed, "MyAutoHotkey", "Icon!")
}

; Types the snippet literally - no AutoHotkey escaping applied.
TypeSnippet(text, *) => SendText(text)

; ---------------------------------------------------------------------
;  Fixed hotkeys (no private data, safe to track)
; ---------------------------------------------------------------------

; Suppress the default PrtScn behavior; HyperSnap listens on its own trigger.
PrintScreen::return

^6::
{
    Send("^a^x")
    ; BROKEN: referenced undefined vars X1/X2/Y1/Y2 and an invalid Format spec
    ; ({:Tab 2}). Left out so the script loads. Restore once the intended
    ; behavior is clarified.
}

; Alt-Esc to close the active window
!Esc::Send("!{F4}")

; Google Search highlighted text
^+c::
{
    A_Clipboard := ""  ; Clear clipboard to avoid stale data
    Send("^c")
    ClipWait(1)        ; Wait up to 1s for the clipboard to contain data
    if A_Clipboard
        Run("http://www.google.com/search?q=" . A_Clipboard)
}

; Suspend AutoHotkey
#ScrollLock::Suspend()

^+F12::
{
    Send("^a")    ; Select all
    Sleep(100)    ; Wait for 100 milliseconds (adjust if needed)
    Send("^v")    ; Paste
    Sleep(100)    ; Wait for 100 milliseconds (adjust if needed)
    Send("^Home+{End}^c")  ; Select the first line and copy
}
