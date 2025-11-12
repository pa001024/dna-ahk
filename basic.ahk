#Requires AutoHotkey v2.0
#Include lib.ahk

; 按键映射
Insert::=

; Alt+中键移动窗口
!MButton::
{
    CoordMode "Mouse", "Screen"
    MouseGetPos &oriX, &oriY, &hwnd
    WinGetPos &winX, &winY, &winW, &winH, hwnd
    Loop
    {
        if !GetKeyState("MButton", "P")
            break
        MouseGetPos &x, &y
        offsetX := x - oriX
        offsetY := y - oriY
        toX := (winX + offsetX)
        toY := (winY + offsetY)
        WinMove toX, toY, , , hwnd
        ToolTip Format("P({1}, {2})", toX, toY)
    }
    ToolTip
    CoordMode "Mouse", "Client"
}
; Alt+右键缩放窗口
!RButton::
{
    CoordMode "Mouse", "Screen"
    MouseGetPos &oriX, &oriY, &hwnd
    WinGetPos &winX, &winY, &winW, &winH, hwnd
    ; 拖动的坐标如果小于三分之一则从从对应角落开始缩放
    xM := oriX < (winX + winW * 0.33)
    yM := oriY < (winY + winH * 0.33)
    Loop
    {
        if !GetKeyState("RButton", "P")
            break
        MouseGetPos &x, &y
        offsetX := x - oriX
        offsetY := y - oriY
        ; toX := (winW + offsetX)
        ; toY := (winH + offsetY)
        if xM {
            toX := (winW - offsetX)
            pX := (winX + offsetX)
        } else {
            toX := (winW + offsetX)
            pX := winX
        }
        if yM {
            toY := (winH - offsetY)
            pY := (winY + offsetY)
        } else {
            toY := (winH + offsetY)
            pY := winY
        }


        WinMove pX, pY, toX, toY, hwnd
        ToolTip Format("P({1}, {2}) S({3}, {4})", winX, winY, toX, toY)
    }
    ToolTip
    CoordMode "Mouse", "Client"
}


CapsLock & r:: Reload()
; CapsLock & e:: initHttpClient()
; 静音当前程序
CapsLock & Volume_Mute:: {
    MouseGetPos(, , &hwnd)
    ; hwnd := GetForegroundWindow()
    p := WinGetProcessName(hwnd)
    msg("静音当前程序：" . p . " (" . GetKeyState("Shift", "P") . ")")
    setProgramVol(p, GetKeyState("Shift", "P") ? 1 : 0)
}
; 点取色
CapsLock & c:: {
    CoordMode "Mouse", "Client"
    MouseGetPos &x, &y
    pixelColor := SubStr(PixelGetColor(x, y), -6)
    A_Clipboard := x . ", " . y . ", `"" . pixelColor . "`""
}
; 鼠标连点
CapsLock & x:: {
    ; BlockInput On
    while GetKeyState("x", "P") {
        Click "Down"
        Sleep 22
        Click "Up"
        Sleep 22
    }
    return
}

; 精确移动鼠标
CapsLock & Left:: mouseXY(-1, 0)
CapsLock & Up:: mouseXY(0, -1)
CapsLock & Right:: mouseXY(1, 0)
CapsLock & Down:: mouseXY(0, 1)


; 锁定键盘鼠标
CapsLock & l:: {
    static trigger := 0
    if (trigger = 0) {
        BlockInput 1
        trigger := 1
        msg("BlockInput On")
    }
    else {
        BlockInput 0
        trigger := 0
        msg("BlockInput Off")
    }
}