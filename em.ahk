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

#Include basic.ahk
#Include gui.ahk

#HotIf WinActive("ahk_exe EM-Win64-Shipping.exe")


XButton2:: {
  ; BlockInput On
  while GetKeyState("XButton2", "P") {
    Click "Down"
    Sleep 22
    Click "Up"
    Sleep 22
  }
  return
}

; 黎瑟E枪
XButton1:: {
  kb "e"
  s 100
  mr 300
  Click
}


#HotIf

hwnd := WinExist("ahk_exe EM-Win64-Shipping.exe")
wgc := wincapture.WGC(hwnd)
kb(k) => ControlSend(k, hwnd)
mc(x, y) => WindowClick(x, y, hwnd)
mr(t) => WindowRightClick(hwnd, t)
mt() => WindowMiddleClick(hwnd)
gc(x, y) => GetWindowColor(x, y, wgc)
cc(x, y, c) => CheckWindowColor(x, y, wgc, c)
wc(x, y, c, t := 8000) => WaitWindowColor(x, y, wgc, c, t)
s(t) => Sleep(t)

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
  mc 1132, 798 ; 重新
  wc 498, 504, "000000"
  mc 924, 603 ; 确认
  wc 51, 30, "FFFFFF"
  s 3000
}

resetPos() {
  openMenu()
  mc 1164, 825 ; 设置
  wc 171, 24, "000000"
  s 300
  mc 559, 25 ; 其他
  wc 880, 191, "F.F.F.", 3000
  mc 950, 270 ; 重置
  wc 490, 406, "0.0.0.", 1500
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
  if EMGui.oGui.melee.Value {
    mr 700
    s 22
  } else {
    move "w", 3.8
  }
}


buff() {
  mt
  switch EMGui.oGui.char.Text {
    case "水母E":
      kb "e"
    case "黎瑟EQE循环":
      kb "e"
      s 200
      kb "{Space}"
      s 500
      kb "{s Down}"
      s 100
      kb "{s Up}"
  }
}

autobuff() {
  if cc(51, 30, "FFFFFF") {
    buff
  }
}

battle() {
  switch EMGui.oGui.char.Text {
    case "水母E":
      kb "e"
    case "黎瑟Q":
      kb "q"
    case "黎瑟EQE循环":
      kb "e"
      s 100
      kb "q"
  }

  ; 自动放技能
  SetTimer autobuff, 5000
}

CapsLock & F9:: mode_60mod()
mode_60mod() {
  c := 0

  runMap60() {
    dash
    dash
    s 1800
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
  triggerLoop("自动驱离", f, 1000)
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

    wc 1362, 873, "000000", 2000
    s 100
    kb "{Space Down}"
    kstate := 1

    ; 自动拉鱼
    loop {
      ; 钓鱼完成
      while not cc(1362, 873, "000000") {
        ; msg "钓鱼完成"
        kb "{Space Up}"
        s 1000
        loop 3 {
          mc 953, 680
          s 500
        }
        return
      }
      time := A_TickCount
      bmp := wgc.capture(1)
      fish := FindWindowColorY(1360, 281, 250, bmp, "FFFFFF")
      hook1 := FindWindowColorY(1369, 281, 250, bmp, "D9EDFF", 10)
      hook2 := FindWindowColorY(1369, 281, 250, bmp, "D3E2E9", 10)
      hook := -1
      if hook1 != -1 {
        hook := hook1
      } else if hook2 != -1 {
        hook := hook2
      }
      ; msg fish . ", " . hook . ", " . (A_TickCount - time)
      if hook == -1 {
        s 10
        continue
      }

      if fish - 35 < hook {
        if kstate != 1 {
          kstate := 1
          kb "{Space Down}"
        }
      } else {
        if kstate != 0 {
          kstate := 0
          kb "{Space Up}"
        }
      }

      s 10
    }
  }
  triggerLoop("自动钓鱼", f, 1000)
}

CapsLock & F11:: mode_30xiansuo()
mode_30xiansuo() {
  c := 0
  wave := 0

  main30() {
    ; 冲两次
    dash
    dash
    s 3800
    move "a", 0.2
    move "w", 2.3
    move "d", 2.6
    move "w", 4.5
    ; 开机关
    if wc(930, 449, "000000", 500) {
      kb "f"
      s 500
      kb "f"
      s 1000
      ; 往后走
      move "s", 2.7
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
      c := 0
      ; 波数
      if ++wave >= 13 {
        wave := 0
         loop 10 {
          mc 693, 624 ; 撤离
          s 200
        }
      } else {
        mc 895, 614 ; 继续
        wc 500, 504, "000000"
        loop 5 {
          mc 895, 614 ; 继续
          s 200
        }
      }
    }
    if cc(500, 504, "000000") {
      mc 895, 614 ; 开始挑战
    }
    if cc(1045, 795, "E1B454") {
      c := 0
      wave := 0
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
CapsLock & F12:: mode_65mod()
mode_65mod() {
  c := 0

  runMap65() {
    dash
    dash
    s 800
    ; 往左走
    kb "{a Down}"
    loop 3 {
      kb "{LShift}"
      s 2000
    }
    kb "{LShift}"
    kb "{w Down}"
    s 3500
    kb "{w Up}"

    s 1000
    kb "{Space}"
    s 1000
    loop 4 {
      kb "{LShift}"
      s 2000
    }
    kb "{a Up}"
    s 500
    resetPos
  }

  f() {
    ; 超时检测
    if ++c > 120 {
      c := 0
      exit
    }
    if cc(1045, 795, "E1B454") {
      restart
      runMap65
      battle
    }
  }
  f()
  triggerLoop("自动65本", f, 1000)
}