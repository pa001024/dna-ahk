#Requires AutoHotkey v2.0
#DllLoad opencv_world490.dll
#Include <WinAPI/Gdi32>
#Include <WinAPI/User32>
#Include <JSON>
#Include <wincapture/wincapture>
#Include <RapidOcr/RapidOcr>
#Include <polyfill>
; #Include <opencv/opencv>
#Include <cv2/cv2>
; #Include <numahk/numahk>
#Include <FindText>
#Include <BTree>
#Include <core/core>
#Include <RectOverlay>
#Include <WebView2/WebView2>
FT := FindTextClass()
; #Include lib/aojia/aojia.ahk

global hwnd := WinExist("ahk_exe EM-Win64-Shipping.exe")
if (hwnd) {
    FT.BindWindow(hwnd)
}
; 测试
if A_ScriptFullPath = A_LineFile {
    ; main := Gui("+Resize -Caption")
    ; main.OnEvent('Close', (*) => (wvc := wv := 0))
    ; main.OnEvent('Size', gui_size)
    ; main.Show(Format('w{} h{}', 800, 600))

    ; wvc := WebView2.CreateControllerAsync(main.Hwnd).await2()
    ; gui_size(GuiObj, MinMax, Width, Height) {
    ;     if (MinMax != -1 && IsSet(wvc)) {
    ;         wvc.Fill()
    ;     }
    ; }
    ; wv := wvc.CoreWebView2
    ; wv.Navigate('http://localhost:1420/')
    ; wv.AddHostObjectToScript('ahk', { str: 'str from ahk', func: MsgBox })
    ; wv.OpenDevToolsWindow()
    ; 从文件"1.png"读取图片数据到HBITMAP
    ; hbitmap := LoadPicture("1.png")
    ; angle := PredictRotation(hbitmap)
    ; MsgBox "预测旋转角度: " angle
}

; 窗口截图
capWindow() {
    static wgc
    if (!wgc)
        wgc := wincapture.WGC(hwnd)
    return wgc.capture(1)
}

; 识别文本
readText(x1, y1, x2, y2) {
    static ocr
    if (!ocr)
        ocr := RapidOcr({ models: A_ScriptDir '\lib\RapidOcr\models' })
    bmp := capWindow().range(x1, y1, x2, y2)
    ; bmp.save("debug.png") ; 仅为调试使用
    ; img := cv.imread(A_ScriptDir '\debug.png')
    ; cv.imshow('img', img)
    ; return ocr.ocr_from_file("debug.png")
    return ocr.ocr_from_bitmapdata(bmp.info)
}


drawBorder(x1, y1, x2, y2, c := 0xFF0000) {
    ; hdc := GetDC(hwnd)
    ; pen := CreatePen(0, 1, c)
    ; SelectObject(hdc, pen)
    ; Rectangle(hdc, x1, y1, x2, y2)
    ; DeleteObject(pen)
    ; ReleaseDC(hwnd, hdc)
    WinGetClientPos &x, &y, &w, &h, hwnd
    c := 0xFF000000 | c
    ro := RectOverlay(c)
    ro.Show(x + x1, y + y1, x2 - x1, y2 - y1)
    SetTimer(() => ro.Delete, -2000)
    ; HighlightOutline(x + x1, y + y1, x + x2, y + y2, 1, , , 2000)
}

mouseXY(x, y) {
    DllCall("mouse_event", "int", 1, "int", x, "int", y, "uint", 0, "uint", 0)
}

msg(text, dur := 2000) {
    ToolTip text
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

GetWindowColor(x, y) { ;取色
    ; hdc := GetDC(hwnd)
    ; ret := GetPixel(hdc, x, y)
    ; ReleaseDC(hwnd, hdc)
    ; return ret
    bmp := capWindow()
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

FindWindowBrightY(x, y, h, bmp, b, rev := false) {
    i := 0
    while ++i <= h {
        color := SubStr(Format("{:0X}", bmp[x, rev ? y + h - i - 1 : y + i - 1]), -6)
        hsl := RGBToHSL(color)
        if hsl[3] > b
            return rev ? h - i - 1 : i - 1
    }
    return -1
}

CheckWindowColor(x, y, v, s := 3) {
    color := GetWindowColor(x, y)
    return CompColor(color, v) < s
}

WaitWindowColor(x, y, v, s := 3, timeout := 1000, interval := 100) {
    s := A_TickCount
    loop {
        if CheckWindowColor(x, y, v, s)
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
WindowClickDown(x, y, hwnd) {
    ControlClick(hwnd, "", "", "Left", 1, "d x" . x . " y" . y)
}
WindowClickUp(x, y, hwnd) {
    ControlClick(hwnd, "", "", "Left", 1, "u x" . x . " y" . y)
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


RGBToHSL(rgb) {
    if Type(rgb) != "Integer" {
        return RGBToHSL(Integer("0x" . rgb))
    }
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
    loop {
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
    loop {
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
    loop {
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
    loop {
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
    loop {
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

httpRequest(url, method := "GET", headers := "", data := "", userAgent :=
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36") {
    static req := comObject("WinHttp.WinHttpRequest.5.1")
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

getIP() {
    rst := httpRequest("https://api.ipify.org?format=json")
    rst := JSON.parse(rst)
    return rst.Get("ip")
}

isConnectedToInternet(flag := 0x40) {
    return DllCall("Wininet.dll\InternetGetConnectedState", "Str", flag, "Int", 0)
}

getTimeStamp() {
    ; datediff 计算现在的utc时间到unix时间戳的起始时间经过的秒数
    return DateDiff(A_NowUTC, '19700101000000', 'S') * 1000 + A_MSec
}

/**
 * 热键按下时定时调用函数
 * @param {String} key 热键
 * @param {Function} func 函数
 * @param {Integer} interval 间隔时间
 * @param {String} title 窗口标题
 */
setHotPress(key, func, interval := 100, title := "") {
    if (title != "")
        HotIfWinActive(title)
    try {
        Hotkey(key, () => (SetTimer(func, interval), 0))
        Hotkey(key " Up", (SetTimer(func, 0), 0))
    }
    if (title != "")
        HotIfWinActive()
}
removeHotPress(key, title := "") {
    if (title != "")
        HotIfWinActive(title)
    try {
        Hotkey(key, , "Off")
        Hotkey(key " Up", , "Off")
    }
    if (title != "")
        HotIfWinActive()
}

getRange(&x, &y, &w, &h) {
    CoordMode "Mouse", "Screen"
    GetRange_begin := true
    loop {
        ToolTip("请按下鼠标左键")
        sleep(50)
        if (GetKeyState("Esc")) {
            ToolTip
            return false
        }
    } until (GetKeyState("LButton"))

    myRect := RectOverlay(0xFFFF0000)
    while GetKeyState("LButton") {
        if (GetRange_begin) {
            GetRange_begin := !GetRange_begin
            MouseGetPos(&begin_x, &begin_y)
        }
        MouseGetPos &now_x, &now_y
        ToolTip begin_x ", " begin_y "`n" Abs(begin_x - now_x) " x " Abs(begin_y - now_y)
        myRect.Show(begin_x, begin_y, now_x - begin_x, now_y - begin_y)
        Sleep 10
    }
    myRect := 0
    x := begin_x, y := begin_y, w := Abs(begin_x - now_x), h := Abs(begin_y - now_y)
    ToolTip
    return true
}