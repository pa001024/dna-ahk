; 键盘鼠标操作录制器（简易版）
; 使用说明：
; 1、快捷键：F3录像/停止录像，F4回放
; 2、点击托盘图标也可以显示录制内容，复制到用户脚本中使用即可

#NoEnv
SetBatchLines -1
#SingleInstance Force
#MaxThreadsPerHotkey 2  ; 让F3可以中断录制
DetectHiddenWindows On

OnExit, 键鼠录像GuiClose

录像机.查看()
Return

; 热键，一键录像/停止
F3::
if (onoff := !onoff)
  录像机.录制()
 else
  录像机.停止()
Return

; 回放热键
F4::
if (回放onoff := !回放onoff) {
  录像机.回放()
  if (录像机.间隔时间变量!="")
    SetTimer 外部回放, % 录像机.间隔时间变量 * 1000
 } else {
  录像机.停止()
  SetTimer 外部回放, Off
  WinGet, NewPID, PID, <<ExecVideoReplay>> ahk_class AutoHotkeyGUI
  Process Close, %NewPID%
  Tip("回放结束")
}
Return

外部回放:
  录像机.回放()
Return


Esc::
键鼠录像GuiClose:
  WinGet, NewPID, PID, <<ExecVideoReplay>> ahk_class AutoHotkeyGUI
  Process Close, %NewPID%
  ExitApp
Return


;================ 下面是函数类 ================
; 基于FeiYue的基础上修改优化
Class 录像机 {   ; --> 类开始
  Static oldx, oldy, oldt, ok, text

  录制(鼠标录制间隔:=15) {
    GuiControlGet, ButtonCheckBox, 键鼠录像:, Button1
    Gui 键鼠录像: Destroy
    录像机.回放("", 1)
    if (this.ok=1)
      this.ok := 0, this.ReStart(A_ThisFunc)
    SetFormat, IntegerFast, d
    CoordMode ToolTip
    ToolTip -- 正在录制 --, A_ScreenWidth//2-(44*A_ScreenDPI/96), 0
    this.text := "SetBatchLines -1`r`nCoordMode Mouse`r`n`r`n"
    , this.oldx := this.oldy:="", this.oldt := A_TickCount
    , this.SetHotkey(this.ok:=1)
    , _ := this.LogPos.Bind(this)
    if (ButtonCheckBox=1)
      SetTimer %_%, 300
     else
      SetTimer %_%, % (鼠标录制间隔<15 ? 15 : 鼠标录制间隔)
    ListLines Off
    While (this.ok=1)
      Sleep 100
    ListLines On
    SetTimer %_%, Off
    ToolTip
    this.SetHotkey(0)
    , _ := this.查看.Bind(this)
    SetTimer %_%, -5
    Return this.text

    间隔时间保存:
      GuiControlGet, 间隔时间变量, 键鼠录像:, Edit2
      录像机.间隔时间变量 := 间隔时间变量
      RegWrite, REG_SZ, HKCU\Software\AHKMouseRecord, Time, % 录像机.间隔时间变量
    Return
  }

  回放(s:="", flag:="") {
    this.ok := 0
    if (!flag)
      if (this.text="") {
        CoordMode ToolTip
        ToolTip 请先按F3键进行录制, A_ScreenWidth//2-(60*A_ScreenDPI/96), 0
        Return
      } else {
        s := this.text
        GuiControlGet, 间隔时间变量, 键鼠录像:, Edit2
        (间隔时间变量!="" && 录像机.间隔时间变量 := 间隔时间变量)
        Gui 键鼠录像: Destroy
      }
    DetectHiddenWindows On
    WinGet, NewPID, PID, <<ExecVideoReplay>> ahk_class AutoHotkeyGUI
    Process Close, %NewPID%
    add=
    (LTrim ` %
    #NoTrayIcon
    #SingleInstance Force
    SetBatchLines -1
    Gui, Gui_Flag_Gui: Show, Hide, <<ExecVideoReplay>>
    CoordMode ToolTip
    CoordMode Mouse
    ToolTip, -- 正在回放 --, A_ScreenWidth//2-(44*A_ScreenDPI/96), 0
    )
    if (!flag)
      s := add "`n" StrReplace(s, "Return") "`nToolTip 回放结束`nSleep 500`nExitApp"
     else
      s := add "`n" StrReplace(s, "Return") "`nExitApp"
    exec := ComObjCreate("WScript.Shell").Exec(A_AhkPath " /ErrorStdOut /f *")
    , exec.StdIn.Write(s)
    , exec.StdIn.Close()
    循环回放 := this.回放.Bind()
  }

  查看() {
    ; Global
    if (this.ok=1)
      this.ok := 0, this.ReStart(A_ThisFunc)
    Gui 键鼠录像: +LastFound Hwndh录制器界面
    Gui 键鼠录像: Add, CheckBox, y+8 h16 Hwndh鼠标频率 Checked0, 低频率记录鼠标移动轨迹
    Gui 键鼠录像: Font, cBlue s12
    Gui 键鼠录像: Add, Edit, w330 h400
    Gui 键鼠录像: Add, Button, w330 Default Hwndh键鼠回放按钮, 键鼠录制内容回放
    
    FileRead, 读取回放录制脚本内容, %A_ScriptDir%\已录制的AHK代码.txt
    
    if (读取回放录制脚本内容!="" && this.text="")
      this.text := 读取回放录制脚本内容

    GuiControl, 键鼠录像:, Edit1, % this.text := StrReplace(this.text, "Sleep, 0`r`n")

    __回放按钮 := this.回放.Bind(this, this.text, "")
    GuiControl, 键鼠录像: +g, %h键鼠回放按钮%, %__回放按钮%

    RegRead, 间隔时间变量, HKCU\Software\AHKMouseRecord, Time
    录像机.间隔时间变量 := 间隔时间变量
    Gui 键鼠录像: Add, Text, xs y+16 Section, 间隔时间：
    Gui 键鼠录像: Add, Edit, ys-4 w60 R1 Number Limit6 g间隔时间保存, % 录像机.间隔时间变量
    Gui 键鼠录像: Add, Text, ys, 秒/次

    Gui 键鼠录像: Show, h505, 〔 F3：录制/停止，F4：回放 〕

    FileDelete, %A_ScriptDir%\已录制的AHK代码.txt
    FileAppend, % this.text, %A_ScriptDir%\已录制的AHK代码.txt

    ControlFocus, Button2
  }

  停止() {
    this.ok := 0
  }

  托盘图标自动加载() {
    Static init := 录像机.托盘图标自动加载()
    Menu Tray, UseErrorLevel, On
    Menu Tray, Color, FFFFFF
    hMenu := MenuGetHandle("Tray")
    , ___ := this.查看.Bind(this)
    Loop 10
      DllCall("RemoveMenu", "Ptr", hMenu, "int", 65310-A_Index, "int", 0)
    Menu Tray, Icon, shell32.dll, 204
    Menu Tray, Click, 1
    Menu Tray, Add, 显示编辑界面, %___%
    Menu Tray, Default, 显示编辑界面
    Menu Tray, Add
    RegRead InstallDir, HKLM\SOFTWARE\AutoHotkey, InstallDir
    if FileExist(InstallDir "\WindowSpy.ahk") {
      DllCall("InsertMenu", "Ptr", hMenu, "Uint", 65311, "Uint", 0, "Uptr", 65302, "Str", "坐标获取工具", "int")
      Menu Tray, Add
    }
    DllCall("InsertMenu", "Ptr", hMenu, "Uint", 65311, "Uint", 0, "Uptr", 65307, "Str", "关闭录制器", "int")
  }

  LogPos() {
    ListLines Off
    CoordMode Mouse
    MouseGetPos, x, y
    if (this.oldx!=x || this.oldy!=y)
      this.oldx := x, this.oldy := y
      , t := -this.oldt+(this.oldt := A_TickCount)
      , this.text .= "Sleep, " t "`r`nMouseMove, " x ", " y ", 0`r`n"
  }

  SetHotkey(f:=1) {
    ;-- 可以过滤已使用的热键，以逗号分隔
    Static allkeys
    ListLines Off
    if (allkeys="") {
      ; 过滤会与LShift、LControl、LAlt等冲突的，补上主键盘与小键盘虚拟按键码相同导致遗漏的
      s:="|Shift|Control|Alt|||Home|End|PgUp|PgDn|Left|Right|Up|Down|Ins|Del|NumpadEnter|"
      Loop, 254
        k := GetKeyName("vk" . Format("{:X}",A_Index))
        , (StrLen(k)=1 && k := Format("{:L}", k))
        , s .= InStr(s, "|" k "|") ? "" : k "|"
      s := Trim(SubStr(s, InStr(s,"||")+1), "|")
      , allkeys := StrReplace(s, "Control", "Ctrl")
    }
    f := (f ? "On":"Off")
    , r := this.LogKey.Bind(this)
    Loop, Parse, allkeys, |
      if A_LoopField not in F3,F4
        Hotkey, ~*%A_LoopField%, %r%, %f% UseErrorLevel
    ListLines On
  }

  LogKey() {
    Critical
    k := SubStr(A_ThisHotkey,3)
    if k Contains Button,Wheel
      this.LogPos()
    if k Contains Shift,Ctrl,Alt,Win,Button
    {
      t := -this.oldt+(this.oldt := A_TickCount)
      , this.text .= "Sleep, " t "`r`nSend, {" k " Down}`r`n"
      Critical Off
      KeyWait %k%
      t := -this.oldt+(this.oldt:=A_TickCount)
      , this.text .= "Sleep, " t "`r`nSend, {" k " Up}`r`n"
    } else {  ; 处理QQ中文输入法自动发送左右键来调整光标的情况
      if (k="NumpadLeft"||k="NumpadRight") and !GetkeyState(k,"P")
        Return
      k := (k="``" ? Format("vk{:x}",GetKeyVK("``")) : k)
      , t := -this.oldt+(this.oldt := A_TickCount)
      , this.text .= "Sleep, " t "`r`nSend, {Blind}{" k "}`r`n"
    }
  }

  ReStart(f:="") {
    if (f="")
      SetTimer, %__%, % "-1" __ := Func(this.func).Bind(this)
     else {
      this.func := f, __:=Func(A_ThisFunc).Bind(this)
      SetTimer, %__%, -1, -1
    }
    Exit
  }
}  ;<-- 类结束

Tip(s:="", Period:="") {
  SetTimer %A_ThisFunc%, % s="" ? "Off" : "-" (Period="" ? 1500 : Period)
  ToolTip %s%, , , 17
}