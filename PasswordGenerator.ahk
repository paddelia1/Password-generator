#Requires AutoHotkey v2.0
#SingleInstance Force
; =====================================================================
;  Password & Passphrase Generator
;  Pure AutoHotkey v2 - no external libraries, no SDK, no dependencies.
;  Just run it with AutoHotkey v2 (or compile it to a standalone .exe).
;
;  Version  : 1.0.5
;  Modified : July 24, 2026 (local time)
;  Change   : Added "Add a special character" option to Passphrase panel;
;             passphrase word selection no longer repeats words; special
;             character now lands only at word/number boundaries; moved
;             the Result section down to stop it overlapping the
;             "Customize word list..." row; reverted word-selection
;             entropy back to the simple k*log2(N) estimate.
; =====================================================================

; ---------------------------------------------------------------------
;  Character sets
; ---------------------------------------------------------------------
global CHARS := Map(
    "upper",   "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
    "lower",   "abcdefghijklmnopqrstuvwxyz",
    "digits",  "0123456789",
    "symbols", "!@#$%^&*()-_=+[]{};:,.?"
)
; Characters that are easy to confuse with one another
global AMBIGUOUS := "O0oIl1|`"'``{}[]()/\;:.,"

; ---------------------------------------------------------------------
;  Word list for passphrases (short, common, easy-to-type words)
; ---------------------------------------------------------------------
global WORDS := StrSplit(
    "able,acid,aged,also,area,army,away,baby,back,ball,band,bank,base,bath,bear,beat,been,beer,bell,belt,bend,bird,blow,blue,boat,body,bomb,bone,book,boot,born,boss,both,bowl,bulk,burn,bush,busy,cake,call,calm,came,camp,card,care,case,cash,cast,cell,chat,chef,chip,city,clay,club,coal,coat,code,cold,come,cook,cool,cope,copy,cord,core,corn,cost,crew,crop,cure,dark,data,date,dawn,days,dead,deal,dear,debt,deep,deer,desk,dial,diet,dirt,dish,dock,does,dome,done,door,dose,down,draw,drew,drop,drug,drum,dual,duck,dust,duty,each,earn,ease,east,easy,edge,else,euro,even,ever,evil,exam,exit,face,fact,fade,fail,fair,fall,farm,fast,fate,fear,feat,feed,feel,feet,fell,felt,file,fill,film,find,fine,fire,firm,fish,fist,five,flag,flat,flee,flew,flip,flow,foam,fold,folk,food,fool,foot,ford,form,fort,four,free,frog,fuel,full,fund,gain,gale,game,gang,gate,gave,gear,gene,gift,girl,give,glad,glow,glue,goal,goat,goes,gold,golf,gone,good,gray,grew,grid,grim,grin,grip,grow,gulf,hair,half,hall,hand,hang,hard,harm,hate,have,hawk,head,heal,heap,hear,heat,held,hell,helm,help,herb,herd,here,hero,hide,high,hill,hint,hire,hold,hole,holy,home,hood,hook,hope,horn,host,hour,huge,hunt,hurt,icon,idea,idle,inch,into,iron,item,jack,jade,jail,jazz,join,joke,jump,jury,just,keen,keep,kept,kick,kind,king,kiss,kite,knee,knew,knot,know,lace,lack,lady,laid,lake,lamb,lamp,land,lane,last,late,lawn,lazy,lead,leaf,lean,leap,left,lend,lens,less,life,lift,like,limb,lime,line,link,lion,list,live,load,loan,lock,logo,lone,long,look,loop,lord,lose,loss,lost,loud,love,luck,lump,lung,made,mail,main,make,male,mall,many,maps,mark,mart,mask,mass,mast,mate,math,maze,meal,mean,meat,meet,melt,menu,mere,mesh,mild,mile,milk,mill,mind,mine,mint,miss,mist,mode,mold,mole,monk,mood,moon,more,moss,most,moth,move,much,mule,must,mute,myth,nail,name,navy,near,neat,neck,need,nest,news,next,nice,node,none,noon,norm,nose,note,noun,null,numb,oath,obey,okay,once,only,onto,open,oral,oval,oven,over,pace,pack,pact,page,paid,pain,pair,pale,palm,park,part,pass,past,path,peak,pear,peer,pick,pier,pile,pill,pine,pink,pipe,plan,play,plot,plug,plum,plus,poem,poet,pole,poll,pond,pony,pool,poor,pope,pork,port,pose,post,pour,pray,prep,prey,prom,pull,pump,punk,pure,push,quiz,race,rack,rage,raid,rail,rain,rake,ramp,rank,rare,rate,read,real,rear,reef,rely,rent,rest,rice,rich,ride,ring,riot,ripe,rise,risk,road,roar,robe,rock,role,roll,roof,room,root,rope,rose,ruby,rude,rule,rush,rust,sack,safe,sage,said,sail,sake,sale,salt,same,sand,sang,save,scan,seal,seat,seed,seek,seem,seen,self,sell,semi,send,sent,ship,shop,shot,show,shut,sick,side,sigh,sign,silk,sing,sink,site,size,skin,skip,slab,slam,slap,sled,slid,slim,slip,slot,slow,slug,snap,snow,soap,soar,sock,soft,soil,sold,sole,solo,some,song,soon,sort,soul,soup,sour,span,spin,spot,spun,spur,star,stay,stem,step,stir,stop,stow,such,suit,sung,sunk,sure,surf,swam,swan,swap,sway,swim,tail,take,tale,talk,tall,tank,tape,task,taxi,team,tear,tech,teen,tell,tend,tent,term,test,text,than,that,thaw,them,then,they,thin,this,thus,tide,tidy,tied,tier,tile,till,tilt,time,tiny,tips,tire,toad,toll,tomb,tone,tool,torn,tour,town,toys,trap,tray,tree,trek,trim,trio,trip,true,tube,tuna,tune,turn,twin,type,ugly,undo,unit,upon,urge,used,user,vary,vast,verb,very,vest,veto,vibe,view,vine,visa,void,vote,wade,wage,wait,wake,walk,wall,wand,want,ward,ware,warm,warn,warp,wash,wave,wavy,ways,weak,wear,weed,week,weep,well,went,were,west,what,when,whip,whom,wide,wife,wild,will,wind,wine,wing,wink,wipe,wire,wise,wish,wolf,wood,wool,word,wore,work,worm,worn,wrap,wren,yard,yarn,yawn,year,yell,yoga,yolk,your,zeal,zero,zone,zoom",
    ","
)

; ---------------------------------------------------------------------
;  Custom word list (saved locally next to the script / exe)
; ---------------------------------------------------------------------
global WORDLIST_FILE := A_ScriptDir "\PasswordGenerator.words.txt"
global customWords := LoadCustomWords()

; ---------------------------------------------------------------------
;  Build the GUI
; ---------------------------------------------------------------------
global myGui := Gui("+Resize -MaximizeBox", "Password Generator")
myGui.SetFont("s10", "Segoe UI")
myGui.BackColor := "FFFFFF"
myGui.MarginX := 16
myGui.MarginY := 14

; --- Mode selector ---
myGui.SetFont("s10 Bold")
myGui.Add("Text", "xm y14", "Type:")
myGui.SetFont("s10 Norm")
global rbPassword   := myGui.Add("Radio", "x+10 yp Checked", "Password")
global rbPassphrase := myGui.Add("Radio", "x+16 yp", "Passphrase")

myGui.Add("Text", "xm y+12 w420 h1 Border 0x10")   ; horizontal divider

; Both panels share the same top edge; only one is visible at a time.
PANEL_Y := 78

; ================= PASSWORD panel =================
global pnlPw := []
myGui.SetFont("s10 Bold")
pnlPw.Push(myGui.Add("Text", "xm y" PANEL_Y, "Password settings"))
myGui.SetFont("s10 Norm")

pnlPw.Push(myGui.Add("Text", "xm y+14 w120", "Length:"))
global sldLen := myGui.Add("Slider", "x+0 yp-4 w190 Range4-128 TickInterval8 vPwLen", 16)
global edtLen := myGui.Add("Edit", "x+12 yp-1 w46 Number Limit3 Center")
global udLen  := myGui.Add("UpDown", "Range4-128", 16)
sldLen.OnEvent("Change", LenFromSlider)
edtLen.OnEvent("Change", LenFromEdit)
pnlPw.Push(sldLen, edtLen, udLen)

global cbUpper := myGui.Add("Checkbox", "xm y+14 w190 Checked vUseUpper", "Uppercase (A-Z)")
global cbLower := myGui.Add("Checkbox", "x+16 yp w190 Checked vUseLower", "Lowercase (a-z)")
global cbDigit := myGui.Add("Checkbox", "xm y+10 w190 Checked vUseDigit", "Digits (0-9)")
global cbSym   := myGui.Add("Checkbox", "x+16 yp w190 Checked vUseSym", "Symbols (!@#$)")
global cbNoAmb := myGui.Add("Checkbox", "xm y+10 w400 vNoAmbiguous", "Avoid ambiguous characters (O 0 l 1 I |)")
pnlPw.Push(cbUpper, cbLower, cbDigit, cbSym, cbNoAmb)

; ================= PASSPHRASE panel =================
global pnlPp := []
myGui.SetFont("s10 Bold")
pnlPp.Push(myGui.Add("Text", "xm y" PANEL_Y, "Passphrase settings"))
myGui.SetFont("s10 Norm")

pnlPp.Push(myGui.Add("Text", "xm y+14 w120", "Number of words:"))
global sldWords := myGui.Add("Slider", "x+0 yp-4 w190 Range3-10 TickInterval1 vWordCount", 4)
global edtWords := myGui.Add("Edit", "x+12 yp-1 w46 Number Limit2 Center")
global udWords  := myGui.Add("UpDown", "Range3-10", 4)
sldWords.OnEvent("Change", WordsFromSlider)
edtWords.OnEvent("Change", WordsFromEdit)
pnlPp.Push(sldWords, edtWords, udWords)

pnlPp.Push(myGui.Add("Text", "xm y+14 w120", "Separator:"))
global ddSep := myGui.Add("DropDownList", "x+0 yp-2 w210 vSeparator Choose1",
    ["- (hyphen)", ". (dot)", "_ (underscore)", "space", "(none)"])
ddSep.OnEvent("Change", (*) => GenerateResult())
pnlPp.Push(ddSep)

global cbCap := myGui.Add("Checkbox", "xm y+16 w190 Checked vCapitalize", "Capitalize each word")
global cbNum := myGui.Add("Checkbox", "x+16 yp w200 Checked vAddNumber", "Append a random number")
global cbSpecial := myGui.Add("Checkbox", "xm y+10 w400 vAddSpecial", "Add a special character (random position)")
pnlPp.Push(cbCap, cbNum, cbSpecial)

global btnCustom := myGui.Add("Button", "xm y+14 w175 h30", "Customize word list...")
global cbCustom  := myGui.Add("Checkbox", "x+14 yp+6 w230 vUseCustom", "Use my word list")
btnCustom.OnEvent("Click", ShowCustomEditor)
cbCustom.OnEvent("Click", (*) => GenerateResult())
pnlPp.Push(btnCustom, cbCustom)

; ================= Output area =================
myGui.SetFont("s10 Bold")
myGui.Add("Text", "xm y286", "Result")
myGui.SetFont("s12 Norm", "Consolas")
global edtOut := myGui.Add("Edit", "xm y+8 w420 h60 ReadOnly -Wrap +HScroll")
myGui.SetFont("s10 Norm", "Segoe UI")

global lblStrength := myGui.Add("Text", "xm y+10 w420 cGray", "Strength: -")

; ================= Buttons =================
global btnGen  := myGui.Add("Button", "xm y+16 w130 h34 Default", "Generate")
global btnCopy := myGui.Add("Button", "x+15 yp w130 h34", "Copy to clipboard")
global btnClose:= myGui.Add("Button", "x+15 yp w130 h34", "Close")

btnGen.OnEvent("Click", GenerateResult)
btnCopy.OnEvent("Click", CopyResult)
btnClose.OnEvent("Click", (*) => ExitApp())
rbPassword.OnEvent("Click", SwitchMode)
rbPassphrase.OnEvent("Click", SwitchMode)
for cb in [cbUpper, cbLower, cbDigit, cbSym, cbNoAmb, cbCap, cbNum, cbSpecial]
    cb.OnEvent("Click", (*) => GenerateResult())
myGui.OnEvent("Close", (*) => ExitApp())
myGui.OnEvent("Escape", (*) => ExitApp())

; ---------------------------------------------------------------------
;  Keep the length slider and the typed number box in sync
; ---------------------------------------------------------------------
global syncing := false

LenFromSlider(*) {
    global syncing
    if syncing
        return
    syncing := true
    udLen.Value := sldLen.Value
    syncing := false
    GenerateResult()
}

LenFromEdit(*) {
    global syncing
    if syncing
        return
    if (edtLen.Value = "")           ; mid-typing / empty box: wait
        return
    syncing := true
    sldLen.Value := udLen.Value      ; UpDown has already clamped to 4-128
    syncing := false
    GenerateResult()
}

WordsFromSlider(*) {
    global syncing
    if syncing
        return
    syncing := true
    udWords.Value := sldWords.Value
    syncing := false
    GenerateResult()
}

WordsFromEdit(*) {
    global syncing
    if syncing
        return
    if (edtWords.Value = "")         ; mid-typing / empty box: wait
        return
    syncing := true
    sldWords.Value := udWords.Value  ; UpDown has already clamped to 3-10
    syncing := false
    GenerateResult()
}

; ---------------------------------------------------------------------
;  Show / hide panels based on selected mode
; ---------------------------------------------------------------------
SwitchMode(*) {
    isPw := rbPassword.Value
    for ctrl in pnlPw
        ctrl.Visible := isPw
    for ctrl in pnlPp
        ctrl.Visible := !isPw
    GenerateResult()
}

; ---------------------------------------------------------------------
;  Random helpers
; ---------------------------------------------------------------------
RandChar(str) => SubStr(str, Random(1, StrLen(str)), 1)

Shuffle(str) {
    arr := StrSplit(str)
    Loop arr.Length - 1 {
        i := arr.Length - A_Index + 1
        j := Random(1, i)
        tmp := arr[i], arr[i] := arr[j], arr[j] := tmp
    }
    out := ""
    for c in arr
        out .= c
    return out
}

; ---------------------------------------------------------------------
;  Generation logic
; ---------------------------------------------------------------------
GenerateResult(*) {
    result := rbPassword.Value ? GeneratePassword() : GeneratePassphrase()
    edtOut.Value := result
    UpdateStrength(result)
}

GeneratePassword() {
    noAmb := cbNoAmb.Value
    pool := ""
    required := []   ; guarantee at least one char from each selected set

    AddSet(key, enabled) {
        if !enabled
            return
        set := CHARS[key]
        if (noAmb)
            set := StripAmbiguous(set)
        if (set = "")
            return
        pool .= set
        required.Push(RandChar(set))
    }

    AddSet("upper",   cbUpper.Value)
    AddSet("lower",   cbLower.Value)
    AddSet("digits",  cbDigit.Value)
    AddSet("symbols", cbSym.Value)

    if (pool = "")
        return "(select at least one character type)"

    len := sldLen.Value
    if (len < required.Length)
        len := required.Length

    pw := ""
    for c in required
        pw .= c
    Loop len - required.Length
        pw .= RandChar(pool)

    return Shuffle(pw)
}

StripAmbiguous(set) {
    out := ""
    Loop Parse set
        if !InStr(AMBIGUOUS, A_LoopField, true)
            out .= A_LoopField
    return out
}

GeneratePassphrase() {
    seps := ["-", ".", "_", " ", ""]
    sep := seps[ddSep.Value]

    list := ActiveWordList()
    wantCount := sldWords.Value

    ; Draw without replacement so the same word can't appear twice.
    ; (If the active list is smaller than the requested word count -
    ; e.g. a short custom list - the pool is refilled once it's
    ; exhausted so generation still succeeds instead of erroring out.)
    pool := []
    for w in list
        pool.Push(w)

    picked := []
    Loop wantCount {
        if (pool.Length = 0) {
            for w in list
                pool.Push(w)
        }
        idx := Random(1, pool.Length)
        w := pool[idx]
        pool.RemoveAt(idx)
        if (cbCap.Value)
            w := StrUpper(SubStr(w, 1, 1)) . SubStr(w, 2)
        picked.Push(w)
    }

    ; Build the list of segments (words, plus the optional trailing number)
    ; that get joined with the separator. The special character - if
    ; enabled - is inserted as its own segment, so it only ever lands at
    ; the start, the end, or between two segments - never inside a word.
    segments := picked.Clone()

    if (cbNum.Value)
        segments.Push(Random(10, 99))

    if (cbSpecial.Value) {
        sym := RandChar(CHARS["symbols"])
        insertPos := Random(1, segments.Length + 1)
        segments.InsertAt(insertPos, sym)
    }

    phrase := ""
    for i, s in segments
        phrase .= (i > 1 ? sep : "") . s

    return phrase
}

; ---------------------------------------------------------------------
;  Strength estimation (entropy, in bits)
; ---------------------------------------------------------------------
UpdateStrength(str) {
    if (str = "" || SubStr(str, 1, 1) = "(") {
        lblStrength.Opt("cGray")
        lblStrength.Text := "Strength: -"
        return
    }

    if (rbPassphrase.Value) {
        bits := sldWords.Value * (Ln(ActiveWordList().Length) / Ln(2))
        if (cbNum.Value)
            bits += Ln(90) / Ln(2)
        if (cbSpecial.Value) {
            boundaryCount := sldWords.Value + (cbNum.Value ? 1 : 0) + 1
            bits += Ln(StrLen(CHARS["symbols"]) * boundaryCount) / Ln(2)
        }
    } else {
        pool := 0
        if RegExMatch(str, "[a-z]")
            pool += 26
        if RegExMatch(str, "[A-Z]")
            pool += 26
        if RegExMatch(str, "[0-9]")
            pool += 10
        if RegExMatch(str, "[^a-zA-Z0-9]")
            pool += 22
        bits := StrLen(str) * (Ln(pool) / Ln(2))
    }

    bits := Round(bits)
    if (bits < 45)
        label := "Weak",        color := "cC00000"
    else if (bits < 70)
        label := "Fair",        color := "cB07000"
    else if (bits < 100)
        label := "Strong",      color := "c008000"
    else
        label := "Very strong", color := "c006000"

    lblStrength.Opt(color)
    lblStrength.Text := "Strength: " label "   (~" bits " bits of entropy)"
}

; ---------------------------------------------------------------------
;  Clipboard
; ---------------------------------------------------------------------
CopyResult(*) {
    if (edtOut.Value = "" || SubStr(edtOut.Value, 1, 1) = "(")
        return
    A_Clipboard := edtOut.Value
    orig := btnCopy.Text
    btnCopy.Text := "Copied!"
    SetTimer(() => btnCopy.Text := orig, -1200)
}

; ---------------------------------------------------------------------
;  Custom word list: storage, editor and selection
; ---------------------------------------------------------------------
ActiveWordList() {
    return (cbCustom.Value && customWords.Length >= 2) ? customWords : WORDS
}

LoadCustomWords() {
    list := []
    if FileExist(WORDLIST_FILE) {
        for line in StrSplit(FileRead(WORDLIST_FILE, "UTF-8"), "`n", "`r") {
            w := Trim(line)
            if (w != "")
                list.Push(w)
        }
    }
    return list
}

SaveCustomWords(list) {
    text := ""
    for w in list
        text .= w "`n"
    try FileDelete(WORDLIST_FILE)
    if (text != "")
        FileAppend(text, WORDLIST_FILE, "UTF-8")
}

; Split free-form text into a clean, de-duplicated word list
ParseWords(text) {
    seen := Map()
    seen.CaseSense := false
    result := []
    for tok in StrSplit(RegExReplace(text, "[\s,;]+", "`n"), "`n") {
        w := Trim(tok)
        if (w != "" && !seen.Has(w)) {
            seen[w] := true
            result.Push(w)
        }
    }
    return result
}

UpdateCustomUI() {
    n := customWords.Length
    cbCustom.Text := "Use my word list (" n " word" (n = 1 ? "" : "s") ")"
    cbCustom.Enabled := (n >= 2)
    if (n < 2)
        cbCustom.Value := 0
}

ShowCustomEditor(*) {
    ed := Gui("+Owner" myGui.Hwnd " +ToolWindow", "Customize word list")
    ed.SetFont("s10", "Segoe UI")
    ed.MarginX := 14, ed.MarginY := 12
    ed.Add("Text", "xm", "Enter the words for your personal passphrase.")
    ed.Add("Text", "xm y+2 cGray", "One per line, or separated by spaces / commas.")
    box := ed.Add("Edit", "xm y+8 w380 h240 +Multi +WantReturn +WantTab")
    pre := ""
    for w in customWords
        pre .= w "`n"
    box.Value := pre
    hint := ed.Add("Text", "xm y+6 w380 cGray",
        "Tip: more unique words = stronger passphrases (aim for 20+).")
    btnS := ed.Add("Button", "xm y+12 w110 h32 Default", "Save")
    ed.Add("Button", "x+10 yp w110 h32", "Cancel").OnEvent("Click", (*) => ed.Destroy())
    btnS.OnEvent("Click", SaveEditor)
    ed.OnEvent("Escape", (*) => ed.Destroy())

    SaveEditor(*) {
        global customWords
        words := ParseWords(box.Value)
        if (words.Length < 2) {
            MsgBox("Please enter at least 2 words.", "Customize word list", "Icon! Owner" ed.Hwnd)
            return
        }
        customWords := words
        SaveCustomWords(customWords)
        UpdateCustomUI()
        cbCustom.Value := 1        ; switch to the custom list right away
        ed.Destroy()
        GenerateResult()
    }

    ed.Show("AutoSize")
}

; ---------------------------------------------------------------------
;  Launch
; ---------------------------------------------------------------------
UpdateCustomUI()    ; reflect any saved list
SwitchMode()        ; set initial panel visibility
GenerateResult()    ; produce a first value
myGui.Show("w452 h498")
