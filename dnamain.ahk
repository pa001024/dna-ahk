#Requires AutoHotkey v2.0
;; 自动执行段
;; 脚本设置
#SingleInstance force
SendMode "Input" ; 设置模拟方式
SetKeyDelay 30, 25 ; SendPlay模式延迟
SetWorkingDir A_ScriptDir ; 设置工作目录
SetTitleMatchMode 3
SetCapsLockState 0
SetWinDelay 20
CoordMode "Mouse", "Client"

#Include lib.ahk
#Include Hotkey\basic.ahk
#Include Hotkey\short.ahk
#Include Gui\gui.ahk
#Include <MouseHook>


{
    dx := 0, dy := 0
    lx := -1, ly := -1
    mh := MouseHook((*) {
        global dx, dy, lx, ly
        if mh.Action == "Move" {
            dx := lx == -1 ? dx : dx + mh.x - lx, dy := ly == -1 ? dy : dy + mh.y - ly
            msg dx ", " dy
            lx := mh.x, ly := mh.y
        }
        return false
    })
    F3:: {
        global dx, dy, lx, ly
        if mh.Ptr == 0 {
            dx := 0, dy := 0
            mh.Start()
        }
        else {
            msg dx ", " dy
            A_Clipboard := "xy " dx ", " dy
            mh.Stop()
        }
    }
}

#HotIf WinActive("ahk_exe EM-Win64-Shipping.exe")


; 黎瑟E枪
XButton1:: {
    kb "e"
    s 200
    ; mr 300 ; 2.25
    mr 400 ; 1.75
    Click
}


; F4::
capmod() {
    checkSize()
    mc 805, 172
    mc 905, 178, "000000"
    s 500
    text := A_Clipboard
    i := 0
    ; C035X13LF13LE13OZ000013LB13LD13CQ13CV0OB2
    item := SubStr(text, 2 + (i++) * 4, 4)
    mod1 := SubStr(text, 2 + (i++) * 4, 4)
    mod4 := SubStr(text, 2 + (i++) * 4, 4)
    mod2 := SubStr(text, 2 + (i++) * 4, 4)
    mod3 := SubStr(text, 2 + (i++) * 4, 4)
    mod5 := SubStr(text, 2 + (i++) * 4, 4)
    mod8 := SubStr(text, 2 + (i++) * 4, 4)
    mod6 := SubStr(text, 2 + (i++) * 4, 4)
    mod7 := SubStr(text, 2 + (i++) * 4, 4)
    mod9 := SubStr(text, 2 + (i++) * 4, 4)

    replacer := BTreeReplacer(
        "涅樂", "涅槃",
        "涅架", "涅槃",
        "核浪", "骇浪",
        "该浪", "骇浪",
        "只灼", "炽灼",
        "涅·", "涅槃·",
        "楚炎", "焚炎",
        "蔡风", "凛风",
        "壶无", "虚无",
        "底佑", "庇佑"
    )
    p(str) {
        str := RegExReplace(str, "\+.*|\s", "")
        str := replacer.replace(str)
        return str || "空"
    }
    t1 := p(readText(245, 370, 352, 391))
    t2 := p(readText(399, 369, 526, 392))
    t3 := p(readText(800, 367, 927, 393))
    t4 := p(readText(965, 368, 1101, 393))
    t5 := p(readText(187, 564, 309, 588))
    t6 := p(readText(348, 565, 479, 587))
    t7 := p(readText(849, 564, 980, 590))
    t8 := p(readText(1028, 564, 1139, 590))
    t9 := p(readText(624, 478, 708, 501))
    out := ""
    loop 9 {
        if mod%A_Index% != "0000" && mod%A_Index% != ""
            out .= t%A_Index% "	" mod%A_Index% "`r`n"
    }

    msg out, 3000
    ; A_Clipboard := out
    A_Clipboard := item
}

; F5:: switchspeed()
switchspeed() {
    CoordMode "Mouse", "Client"
    Send "{F11 Down}"
    s 30
    Send "{F11 Up}"
    Send "{LAlt Down}"
    s 30
    Click 1286, 110
    s 300
    Send "{LAlt Up}"
    Send "{F11 Down}"
    s 30
    Send "{F11 Up}"
}

#HotIf

checkSize() {
    WinGetClientPos &x, &y, &w, &h, hwnd
    WinGetPos &wx, &wy, &ww, &wh, hwnd
    if (w != 1600 or h != 900) {
        WinMove(0, 0, 1600 + ww - w, 900 + wh - h, hwnd)
    }
}

openMenu() {
    while not cc(1482, 805, "FFFFFF") {
        mt
        kb "{Escape}"
        Sleep 500
    }
}

exit() {
    openMenu()
    mc 1470, 817 ; 退出
    s 500
    mc 955, 501 ; 确认
    wc 1045, 795, "E1B454"
}

restart() {
    确认选择 := "|<确认选择>*86$71.yTzzbzzwztzyMztzDySNznU0k7tyTwQnzb07CTtwzwE0Q3DANzntzxU0s6Ak0TznzyCTwC3k0sTXzywztw2aRkz7w803m1103tyDsE07UAm07nsTwwnw7toFDbmTttbsQ09bTDYznnBos0E0yKQzbCNtzCU1w8tz8w7n01AvsXtw/wTa00NbmDlk7zzDttmDcTla00QTnnwztzrzU1tzbU"

    if (ok := FT.FindText(&x, &y, 0, 0, 0, 0, 0, 0, 确认选择)) {
        msg x "," y
        mc 1236, 808
        s 500
    }

    mc 1132, 798 ; 重新
    wc 498, 504, "000000"
    s 500
    mc 946, 602 ; 确认
    wc(51, 30, "FFFFFF")
    s 3000
}

resetPos() {
    openMenu()
    mc 1164, 825 ; 设置
    wc 171, 24, "000000"
    s 300
    mc 559, 25 ; 其他
    wc 880, 191, "FFFFFF", 3000
    mc 950, 270 ; 重置
    wc 490, 406, "000000", 1500
    mc 941, 502 ; 确认
    s 500
}

; 使用冲刺移动 相当于走动的秒数
move(d := "w", t := 2) {
    kb "{" . d . " Down}"
    dashT := 1600
    t *= 1000
    while t > 0 {
        if t <= dashT {
            s t
            t -= dashT
        } else {
            s 5
            kb "{LShift}"
            t -= dashT
            if t > 2000 {
                s 2000
                t -= 2000
            } else {
                s t
            }
        }
    }
    kb "{" . d . " Up}"
}

; 走动
walk(d := "w", t := 2) {
    kb "{" . d . " Down}"
    t *= 1000
    s t
    kb "{" . d . " Up}"
}

dash() {
    if DNAGui.single.melee.Value {
        mr 700
        s 22
    } else {
        move "w", 3.8
    }
}


buff() {
    switch DNAGui.single.char.Text {
        case "水母E":
            kb "e"
        case "黎瑟EQ循环":
            kb "e"
            s 200
            kb "{Space}"
            s 550
            kb "{s Down}"
            s 80
            kb "{s Up}"
        case "近战蓄力":
            mr 500
    }
}

autobuff() {
    if cc(51, 30, "FFFFFF") {
        buff
    }
}

battle() {
    switch DNAGui.single.char.Text {
        case "水母E":
            kb "e"
        case "黎瑟Q":
            kb "q"
        case "黎瑟EQ循环":
            kb "e"
            s 100
            kb "q"
        case "近战蓄力":
            mr 500
            s 300
    }

    ; 自动放技能
    SetTimer autobuff, 3000
}

CapsLock & F9:: mode_60mod()
mode_60mod() {
    c := 0

    runMap60() {
        ; dash
        ; dash
        s 1800
        kb "4"
        s 1000
    }

    f() {
        if ++c > 90 {
            c := 0
            exit
        }
        if cc(1045, 795, "E1B454") {
            c := 0
            restart
            runMap60
            battle
        }
    }
    triggerLoop("自动驱离", f, 500)
}

; 自动钓鱼
CapsLock & F10:: mode_fishing()
mode_fishing() {
    f() {
        while not cc(1362, 873, "000000") {
            ; msg "开始钓鱼"
            mc 953, 680
            ; 自动下饵
            loop 10 {
                if cc(1491, 785, "FFFFFF") or cc(1347, 702, "FFFFFF") {
                    break
                }
                s 200
            }
            kb "e"
            mc 1359, 695
            s 2000
            ; 等待鱼咬钩
            loop 40 {
                ; 提竿
                mc 1359, 695
                s 100
                if cc(1362, 873, "000000") {
                    break
                }
            }
        }

        wc 1362, 873, "000000", 5000
        s 100
        md 1360, 701
        kstate := 1

        ; 自动拉鱼
        loop {
            ; 钓鱼完成
            while not cc(1362, 873, "000000") {
                ; msg "钓鱼完成"
                mc 953, 680
                s 1000
                loop 3 {
                    mc 953, 680
                    s 500
                }
                return
            }
            time := A_TickCount
            bmp := capWindow()
            fish := FindWindowBrightY(1360, 281, 250, bmp, 0.95)
            hook := FindWindowBrightY(1353, 287, 250, bmp, 0.8)
            hook2 := FindWindowBrightY(1353, 287, 250, bmp, 0.8, true)
            w := (hook2 - hook) // 2

            ; msg fish . ", " . hook . ", " . RGBToHSL(SubStr(Format("{:0X}", bmp[1353, 287 + hook]), -6))[3] ", " . (A_TickCount - time)
            if hook == -1 {
                s 10
                continue
            }

            if fish - w < hook {
                if kstate != 1 {
                    kstate := 1
                    md 1360, 701
                }
            } else {
                if kstate != 0 {
                    kstate := 0
                    mu 1360, 701
                }
            }

            s 10
        }
    }
    triggerLoop("自动钓鱼", f, 1000)
}

; CapsLock & F11:: mode_30xiansuo()
mode_30xiansuo() {
    c := 0
    wave := 1

    main30() {
        ; 冲两次
        dash
        dash
        s 3800
        move "a", 0.2
        move "w", 2.3
        move "d", 2.65
        move "w", 5.2
        ; 开机关
        if wc(930, 449, "000000", 500) {
            kb "f"
            s 500
            kb "f"
            s 1000
            ; 往后走
            move "s", 5.3
        } else {
            exit
            restart
            main30
        }
    }

    f() {
        ; 超时检测
        if ++c > 120 {
            c := 0
            exit
        }
        if cc(854, 323, "FFFFFF") {
            SetTimer autobuff, 0
            c := 0
            ; 波数
            if ++wave > 139 {
                wave := 0
                loop 10 {
                    mc 693, 624 ; 撤离
                    s 200
                }
            } else {
                DNAGui.single.wave.Text := wave
                mc 895, 614 ; 继续
                wc 500, 504, "000000"
                loop {
                    mc 895, 614 ; 继续
                    s 200
                } until cc(47, 25, "FFFFFF")
                s 1500
                try {
                    ocrWave := readText(120, 234, 140, 250)
                    msg Integer(ocrWave)
                    if Integer(ocrWave) > wave {
                        DNAGui.single.wave.Text := wave := Integer(ocrWave)
                    }
                }
                SetTimer autobuff, 4000
            }
        }
        if cc(500, 504, "000000") {
            mc 895, 614 ; 开始挑战
        }
        if cc(1045, 795, "E1B454") {
            c := 0
            wave := 1
            SetTimer autobuff, 0
            restart
            main30
            battle
        }
    }
    SetTimer autobuff, 0
    triggerLoop("自动30线索", f, 1000)
}

; 65mod
CapsLock & F11:: mode_65mod()
mode_65mod() {
    c := 0

    runMap65() {
        ; dash
        ; dash
        ; s 800
        ; ; 往左走R
        ; kb "{a Down}"
        ; loop 3 {
        ;   kb "{LShift}"
        ;   s 2000
        ; }
        ; kb "{LShift}"
        ; kb "{w Down}"
        ; s 3500
        ; kb "{w Up}"

        ; s 1000
        ; kb "{Space}"
        ; s 1000
        ; loop 4 {
        ;   kb "{LShift}"
        ;   s 2000
        ; }
        ; kb "{a Up}"
        ; s 500
        ; resetPos

        mt
        s 100
        xy -419, -13
        while not cc(44, 290, "8FD19E") {
            Send "y"
            s 500
            if A_Index > 10 {
                break
            }
        }
    }

    f() {
        ; 超时检测y
        if ++c > 30 {
            SetTimer autobuff, 0
            c := 0
            exit
        }
        if cc(1045, 795, "E1B454") {
            SetTimer autobuff, 0
            c := 0
            restart
            wc(51, 30, "FFFFFF")
            s 3000
            msg "开始跑图"
            runMap65
            msg "完成跑图"
            battle
        }
    }
    if cc(51, 30, "FFFFFF") {
        exit
        restart
    }
    SetTimer autobuff, 0
    triggerLoop("自动65本", f, 1000)
}

CapsLock & F12:: mode_x()
mode_x() {
    c := 0
    f() {
        if cc(51, 30, "FFFFFF") {
            mr 300
            ; if ++c > 6 {
            ;   loop 4 {
            ;     kb "e"
            ;     s 300
            ;   }
            ;   kb "q"
            ;   c := 0
            ; }
            Send "{F2}"
        }
    }
    f()
    triggerLoop("自动x", f, 1000)
}