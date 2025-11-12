#Include lib/WinAPI/Gdi32.ahk
#Include lib/WinAPI/User32.ahk
#Include lib/JSON.ahk
#Include lib/wincapture/wincapture.ahk

; 函数

mouseXY(x, y) {
  DllCall("mouse_event", "int", 1, "int", x, "int", y, "uint", 0, "uint", 0)
}

msg(text, dur := 1000) {
  ToolTip text
  SetTimer endmsg, dur
}
msgl(text, dur := 1000) {
  ToolTip text, 0, 0
  SetTimer endmsg, dur
}
savePos(restore := false) {
  static mx, my
  if restore {
    MouseMove(mx, my)
  } else {
    MouseGetPos(&mx, &my)
  }
}
restorePos() {
  savePos true
}

GetWindowColor(x, y, wgc) { ;取色
  ; hdc := GetDC(hwnd)
  ; ret := GetPixel(hdc, x, y)
  ; ReleaseDC(hwnd, hdc)
  ; return ret
  bmp := wgc.capture(1)
  ret := Format("{:0X}", bmp[x, y])
  ; bmp.save("debug.png") ; 仅为调试使用
  return SubStr(ret, -6)
}

FindWindowColorY(x, y, h, bmp, v, s := 5) {
  i := 0
  while ++i <= h {
    color := SubStr(Format("{:0X}", bmp[x, y + i - 1]), -6)
    if CompColor(color, v) < s
      return i - 1
  }
  return -1
}

CheckWindowColor(x, y, wgc, v) {
  color := GetWindowColor(x, y, wgc)
  return RegExMatch(color, v) != 0
}

WaitWindowColor(x, y, wgc, v, timeout := 1000, interval := 100) {
  s := A_TickCount
  Loop {
    if CheckWindowColor(x, y, wgc, v)
      return true
    else
      Sleep interval
    if timeout > 0 and A_TickCount - s > timeout
      return false
  }
}

WindowClick(x, y, hwnd) {
  ControlClick(hwnd, "", "", "Left", 1, "x" . x . " y" . y)
}

WindowMiddleClick(hwnd) {
  ControlClick(hwnd, "", "", "Middle", 1)
}

WindowRightClick(win := "", t := 1) {
  ControlClick(win, "", "", "Right", 1, "D")
  Sleep t
  ControlClick(win, "", "", "Right", 1, "U")
}

triggerLoopMap := Map()
triggerLoop(name, func, interval := 100) {
  newVal := !triggerLoopMap.Get(name, false)
  triggerLoopMap.Set(name, newVal)
  if newVal {
    msg(name . "启动", 1000)
    SetTimer func, interval
  }
  else {
    msg(name . "结束", 1000)
    SetTimer func, 0
  }
}

setProgramVol(program, vol) {
  Run "setvol `"" . program . "`" " . vol, , "Hide"
}

RGBToHSL(rgb) {
  ; 将 RGB 从 0-255 转换为 0-1 范围
  r := Float(rgb >> 16 & 255) / 255
  g := Float(rgb >> 8 & 255) / 255
  b := Float(rgb & 255) / 255

  ; 计算最大和最小值
  vmax := max(r, g, b)
  vmin := min(r, g, b)
  delta := vmax - vmin

  ; 计算亮度
  luminance := (vmax + vmin) / 2

  ; 计算饱和度
  saturation := 0
  if (delta != 0) {
    saturation := (luminance > 0.5) ? (delta / (2 - vmax - vmin)) : (delta / (vmax + vmin))
  }

  ; 计算色相
  hue := 0
  if (delta != 0) {
    if (vmax == r) {
      hue := (g < b) ? (60 * ((g - b) / delta + 6)) : (60 * ((g - b) / delta))
    } else if (vmax == g) {
      hue := 60 * ((b - r) / delta + 2)
    } else {
      hue := 60 * ((r - g) / delta + 4)
    }
  }

  ; 返回 HSL 值
  ; 注意：这里我们将 hue 和 saturation 转换为百分比形式
  return [hue, saturation, luminance]
}


GetHSL(x, y) {
  color := Integer(PixelGetColor(x, y)) ; 0xRRGGBB
  return RGBToHSL(color)
}

CheckHSL(x, y, rgb) {
  hsl := GetHSL(x, y)
  v := RGBToHSL(rgb)
  return abs(hsl[1] - v[1]) + abs(hsl[2] - v[2]) * 180 + abs(hsl[3] - v[3]) * 75
}

CompColor(c1, c2) {
  v1 := RGBToHSL(Integer("0x" . c1))
  v2 := RGBToHSL(Integer("0x" . c2))
  return abs(v1[1] - v2[1]) + abs(v1[2] - v2[2]) * 180 + abs(v1[3] - v2[3]) * 75
}

WaitHSL(x, y, rgb, t := 100, timeout := 1000, interval := 100) {
  s := A_TickCount
  Loop {
    if CheckHSL(x, y, rgb) < t
      return true
    else
      Sleep interval
    if timeout > 0 and A_TickCount - s > timeout
      return false
  }
}

WaitNotHSL(x, y, rgb, t := 100, timeout := 1000, interval := 100) {
  s := A_TickCount
  Loop {
    if !(CheckHSL(x, y, rgb) < t)
      return true
    else
      Sleep interval
    if timeout > 0 and A_TickCount - s > timeout
      return false
  }
}

GetColor(x, y) {
  color := PixelGetColor(x, y)
  return SubStr(color, -10)
}

CheckColor(x, y, v) {
  color := PixelGetColor(x, y)
  return RegExMatch(SubStr(color, 3, 6), v) == 1
}

WaitColor(x, y, v, timeout := 1000, interval := 100) {
  s := A_TickCount
  Loop {
    if CheckColor(x, y, v)
      return true
    else
      Sleep interval
    if timeout > 0 and A_TickCount - s > timeout
      return false
  }
}

WaitNotColor(x, y, v, timeout := 1000, interval := 100) {
  s := A_TickCount
  Loop {
    if !CheckColor(x, y, v)
      return true
    else
      Sleep interval
    if timeout > 0 and A_TickCount - s > timeout
      return false
  }
}

SendAndWaitColor(x, y, v, key, timeout := 1000, interval := 100) {
  s := A_TickCount
  Loop {
    if CheckColor(x, y, v)
      return true
    else {
      Send key
      Sleep interval
    }
    if timeout > 0 and A_TickCount - s > timeout
      return false
  }
}

endmsg() {
  ToolTip
  SetTimer , 0
}

SendText2(text) {
  bak := ClipboardAll()
  A_Clipboard := text
  SendEvent "^v"
  Sleep 200
  A_Clipboard := bak
}

req := comObject("WinHttp.WinHttpRequest.5.1")
initHttpClient() {
  rst := httpRequest("https://api.ipify.org?format=json")
  rst := JSON.parse(rst)
  MsgBox rst.Get("ip")
  MsgBox JSON.stringify(rst)
}

httpRequest(url, method := "GET", headers := "", data := "", userAgent := "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36") {
  try {
    req.Open(method, url, true) ;true 表示异步
    req.SetRequestHeader("User-Agent", userAgent)
    req.Send()
    req.WaitForResponse()
  }
  catch {
    return ""
  }
  return req.ResponseText
}

ConnectedToInternet(flag := 0x40) {
  Return DllCall("Wininet.dll\InternetGetConnectedState", "Str", flag, "Int", 0)
}
getTimeStamp() {
  ; datediff 计算现在的utc时间到unix时间戳的起始时间经过的秒数
  return DateDiff(A_NowUTC, '19700101000000', 'S') * 1000 + A_MSec
}