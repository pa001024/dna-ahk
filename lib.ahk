#Include <WinAPI/Gdi32>
#Include <WinAPI/User32>
#Include <JSON>
#Include <wincapture/wincapture>
#Include <RapidOcr/RapidOcr>
#Include <opencv/opencv>
; #Include <cv2/cv2>
#Include <numahk/numahk>
#Include <FindText>
; #Include lib/aojia/aojia.ahk

; 函数
ocr := RapidOcr({ models: A_ScriptDir '\lib\RapidOcr\models' })
readText(x1, y1, x2, y2) {
    bmp := wgc.capture(1).range(x1, y1, x2, y2)
    ; bmp.save("debug.png") ; 仅为调试使用
    ; img := cv.imread(A_ScriptDir '\debug.png')
    ; cv.imshow('img', img)
    ; return ocr.ocr_from_file("debug.png")
    return ocr.ocr_from_bitmapdata(bmp.info)
}

getCharAngle() {
    s := 100
    w := s / 2, h := s / 2, px := 125, py := 125
    bmp := wgc.capture(1).range(px - w, py - h, px + w, py + h)
    drawBorder(px - w, py - h, px + w, py + h)
    img := bmp.cvtMat()
    gray := cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    gray := cv2.subtract(128, gray)
    ; gray := cv2.threshold(gray, 80, 255, cv2.THRESH_BINARY)[2]
    remap := cv2.warpPolar(gray, [s, 360], [s // 2, s // 2], s / 2, cv2.INTER_LINEAR + cv2.WARP_POLAR_LINEAR)
    remap := remap.T()
    ; gradx := cv2.Scharr(remap, cv2.CV_32F, 1, 0)
    edges := cv2.Canny(remap, 100, 150)

    ; lines := cv2.HoughLinesP(edges, 1, cv2.CV_PI / 180, 50, 10, 10)
    ; for i, line in lines {
    ;   x1 := line[0, 0], y1 := line[0, 1], x2 := line[0, 2], y2 := line[0, 3]
    ;   cv2.line(edges, cv2.Point(x1, y1), cv2.Point(x2, y2), 0xFF0000, 1)
    ; }
    cv2.imshow("gray", gray)
    cv2.imshow("img2", edges[0, 60, 360, 40])
}

capWindow() {
    WinGetClientPos , , &wid, &hei, hwnd
    pBits := 0
    hhdc := GetDC(hwnd)
    chdc := CreateCompatibleDC(hhdc)  ; 【调色板函数?】参数hhdc可删除
    ; pBits 指向变量的指针，该变量接收指向 DIB 位值位置的指针
    hbm := CreateDIBSection(wid, hei, chdc, 24, &pBits)  ; 返回hBitmap
    obm := SelectObject(chdc, hbm)
    BitBlt(chdc, 0, 0, wid, hei, hhdc, 0, 0, 0xCC0020)
    val := (wid * 3 + 3) & -4  ; Channels := 3 ; 通道
    img := cv2.MAT_Init().create(hei, wid, 16, pBits, val)
    mat := toMat(cv2.MAT(), img.clone())
    SelectObject(chdc, obm)
    ReleaseDC(hhdc)
    DeleteObject(hbm)
    DeleteDC(hhdc)
    DeleteDC(chdc)
    return mat
}

drawBorder(x1, y1, x2, y2, c := 0xFF0000) {
    ; hdc := GetDC(hwnd)
    ; pen := CreatePen(0, 1, c)
    ; SelectObject(hdc, pen)
    ; Rectangle(hdc, x1, y1, x2, y2)
    ; DeleteObject(pen)
    ; ReleaseDC(hwnd, hdc)
    WinGetClientPos &x, &y, &w, &h, hwnd
    HighlightOutline(x + x1, y + y1, x + x2, y + y2, 1, , , 2000)
}

mouseXY(x, y) {
    DllCall("mouse_event", "int", 1, "int", x, "int", y, "uint", 0, "uint", 0)
}

msg(text, dur := 2000) {
    ToolTip text
    SetTimer endmsg, dur
}
msgl(text, dur := 2000) {
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

CheckWindowColor(x, y, wgc, v, s := 3) {
    color := GetWindowColor(x, y, wgc)
    return CompColor(color, v) < s
}

WaitWindowColor(x, y, wgc, v, s := 3, timeout := 1000, interval := 100) {
    s := A_TickCount
    loop {
        if CheckWindowColor(x, y, wgc, v, s)
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

setProgramVol(program, vol) {
    Run "setvol `"" . program . "`" " . vol, , "Hide"
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

req := comObject("WinHttp.WinHttpRequest.5.1")
initHttpClient() {
    rst := httpRequest("https://api.ipify.org?format=json")
    rst := JSON.parse(rst)
    MsgBox rst.Get("ip")
    MsgBox JSON.stringify(rst)
}

httpRequest(url, method := "GET", headers := "", data := "", userAgent :=
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36") {
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
    return DllCall("Wininet.dll\InternetGetConnectedState", "Str", flag, "Int", 0)
}
getTimeStamp() {
    ; datediff 计算现在的utc时间到unix时间戳的起始时间经过的秒数
    return DateDiff(A_NowUTC, '19700101000000', 'S') * 1000 + A_MSec
}

GetRange(&x, &y, &w, &h) {
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
    while GetKeyState("LButton") {
        if (GetRange_begin) {
            GetRange_begin := !GetRange_begin
            MouseGetPos(&begin_x, &begin_y)
        }
        MouseGetPos &now_x, &now_y
        ToolTip begin_x ", " begin_y "`n" Abs(begin_x - now_x) " x " Abs(begin_y - now_y)
        HighlightOutline(begin_x, begin_y, now_x, now_y, , , , 50)
        Sleep 10
    }
    x := begin_x, y := begin_y, w := Abs(begin_x - now_x), h := Abs(begin_y - now_y)
    ToolTip
    return true
}

class HighlightOutline {
    gui := []
    __New(x1, y1, x2, y2, b := 3, color := "red", Transparent := 255, time_out := unset) {
        this.gui.Length := 4
        loop 4 {
            this.gui[A_index] := Gui("-Caption +AlwaysOnTop +ToolWindow -DPIScale +E0x20 +E0x00080000")
            this.gui[A_index].BackColor := color
            DllCall("SetLayeredWindowAttributes", "Ptr", this.gui[A_index].hwnd, "Uint", 0, "Uchar", Transparent, "int",
                2)
        }
        if (IsSet(time_out)) {
            this.timer := ObjBindMethod(this, "Destroy")
            this.Show(x1, y1, x2, y2, b)
            SetTimer(this.timer, -time_out)
        }
    }
    Show(x1, y1, x2, y2, b := 3) {
        try {
            this.gui[1].Show("NA x" x1 - b " y" y1 - b " w" x2 - x1 + b * 2 " h" b)
            this.gui[2].Show("NA x" x2 " y" y1 " w" b " h" y2 - y1)
            this.gui[3].Show("NA x" x1 - b " y" y2 " w" x2 - x1 + 2 * b " h" b)
            this.gui[4].Show("NA x" x1 - b " y" y1 " w" b " h" y2 - y1)
        }
    }
    Hide() {
        loop (4) {
            try {
                this.gui[A_Index].Hide()
            }
        }
    }
    Destroy() {
        this.timer := 0
        loop (4) {
            try {
                this.gui[A_Index].Destroy()
            }
        }
    }
}

PreReload() {
    ; AJ.GBHouTai()
    Reload()
}
class BTreeNode {
    __New(isLeaf := true) {
        this.keys := []  ; 存储键
        this.values := []  ; 存储对应替换值
        this.children := []  ; 子节点引用
        this.isLeaf := isLeaf  ; 是否为叶节点
    }
}

class BTree {
    __New(minDegree := 3) {
        this.root := BTreeNode()
        this.minDegree := minDegree  ; B树的最小度数
    }

    ; 插入键值对
    Insert(key, value) {
        root := this.root
        if (root.keys.Length = 2 * this.minDegree - 1) {
            newNode := BTreeNode(false)
            this.root := newNode
            newNode.children.Push(root)
            this.SplitChild(newNode, 1)
            this.InsertNonFull(newNode, key, value)
        } else {
            this.InsertNonFull(root, key, value)
        }
    }

    ; 分裂子节点
    SplitChild(parent, index) {
        minDegree := this.minDegree
        child := parent.children[index]
        newChild := BTreeNode(child.isLeaf)

        ; 复制后半部分键值对
        newChild.keys := child.keys.Slice(minDegree, 2 * minDegree - 1)
        newChild.values := child.values.Slice(minDegree, 2 * minDegree - 1)

        ; 复制子节点（非叶节点时）
        if (!child.isLeaf) {
            newChild.children := child.children.Slice(minDegree, 2 * minDegree)
        }

        ; 调整原节点大小（保留前minDegree-1个元素）
        child.keys := child.keys.Slice(1, minDegree - 1)
        child.values := child.values.Slice(1, minDegree - 1)

        ; 插入新子节点（在index后插入）
        parent.children.InsertAt(index + 1, newChild)
        parent.keys.InsertAt(index, child.keys[minDegree - 1])  ; 中间元素上移
        parent.values.InsertAt(index, child.values[minDegree - 1])
    }

    ; 非满节点插入
    InsertNonFull(node, key, value) {
        i := node.keys.Length  ; 从最后一个元素开始
        if (node.isLeaf) {
            ; 叶节点直接插入（从后向前查找位置）
            while (i > 1 && StrCompare(key, node.keys[i - 1]) < 0) {
                node.keys[i] := node.keys[i - 1]
                node.values[i] := node.values[i - 1]
                i--
            }
            node.keys.Push(key)
            node.values.Push(value)
        } else {
            ; 内部节点查找子节点
            while (i > 1 && StrCompare(key, node.keys[i - 1]) < 0) {
                i--
            }
            i++  ; 修正：子节点索引=键索引+1
            child := node.children[i]
            if (child.keys.Length = 2 * this.minDegree - 1) {
                this.SplitChild(node, i)
                if (StrCompare(key, node.keys[i]) > 0) {
                    i++
                    child := node.children[i]
                }
            }
            this.InsertNonFull(child, key, value)
        }
    }

    ; 查找最长匹配键（修正字符串索引）
    FindLongestMatch(str, startPos) {
        current := this.root
        matchLength := 0
        matchValue := ""
        currentPos := startPos

        while (true) {
            i := 1
            found := false
            ; 在当前节点查找匹配键
            while (i <= current.keys.Length) {
                key := current.keys[i]
                keyLen := StrLen(key)
                ; 检查剩余字符串是否足够匹配
                if (currentPos + keyLen - 1 > StrLen(str)) {
                    i++
                    continue
                }
                ; 提取子串比较（SubStr第3个参数是长度）
                sub := SubStr(str, currentPos, keyLen)
                if (sub = key && keyLen > matchLength) {
                    matchLength := keyLen
                    matchValue := current.values[i]
                    found := true
                    break  ; 找到最长匹配后跳出
                }
                i++
            }

            if (found || current.isLeaf) {
                break  ; 叶节点或找到匹配时停止
            }

            ; 进入子节点继续查找
            nextChar := SubStr(str, currentPos + matchLength, 1)
            i := 1
            while (i <= current.keys.Length && StrCompare(nextChar, current.keys[i]) > 0) {
                i++
            }
            current := current.children[i]
            currentPos += matchLength
        }

        return { length: matchLength, value: matchValue }
    }
}

class BTreeReplacer {
    index := BTree()
    __New(replaceTexts*) {
        ; 构建B树索引
        for key, value in Map(replaceTexts*) {
            this.index.Insert(key, value)
        }
    }
    /**
     * 基于B树的批量替换函数
     * @param {String} str 
     * @param {Map} replaceTexts 
     * @returns {String} 
     * @example
     * replacer := BTreeReplacer("涅樂", "涅槃", "錯別字", "错别字", "測試", "测试")
     * originalStr := "这是一个測試，包含涅樂和錯別字的文本。"
     * resultStr := replacer.replace(originalStr, replaceMap)
     * MsgBox(resultStr)  ; 输出："这是一个测试，包含涅槃和错别字的文本。"
     */
    replace(str) {
        result := ""
        currentPos := 1
        len := StrLen(str)

        while (currentPos <= len) {
            ; 查找最长匹配
            match := this.index.FindLongestMatch(str, currentPos)
            if (match.length > 0) {
                result .= match.value
                currentPos += match.length
            } else {
                ; 无匹配则复制当前字符
                result .= SubStr(str, currentPos, 1)
                currentPos++
            }
        }

        return result
    }
}
({}.DefineProp)("".base, "Length", { get: StrLen })
Array.Prototype.Slice := (this, start, end := "") {
    result := []
    if (this.Length = 0)
        return result

    ; 处理默认结束索引
    if (end = "")
        end := this.Length

    ; 边界检查
    start := (start < 1) ? 1 : start
    end := (end > this.Length) ? this.Length : end

    ; 复制元素（1-based遍历）
    loop end - start + 1 {
        result.Push(this[A_Index + start - 1])
    }
    return result
}