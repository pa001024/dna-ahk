#Requires AutoHotkey v2.0
#SingleInstance Force

#Include <Base64>
class Capture {
    static refCount := 0
    __New(hwnd := 0) {
        this.hwnd := hwnd
        Capture.refCount++
        if (Capture.refCount == 1) {
            this.token := this.Gdip_Startup()
        }
    }
    __Delete() {
        Capture.refCount--
        if (this.token && Capture.refCount == 0) {
            this.Gdip_Shutdown(this.token)
        }
    }
    ; ========== 1. Gdip 基础初始化（保留，修正可选参数写法） ==========
    Gdip_Startup() {
        static token := 0
        if !token {
            hModule := DllCall("LoadLibrary", "Str", "gdiplus.dll", "Ptr")
            si := Buffer(16, 0)
            NumPut("UInt", 1, si, 0)   ; 偏移量0：GdiplusVersion = 1
            ; NumPut("UInt", 0, si, 4)   ; 偏移量4：DebugEventCallback = NULL
            ; NumPut("UInt", 0, si, 8)   ; 偏移量8：SuppressBackgroundThread = FALSE
            ; NumPut("UInt", 0, si, 12)  ; 偏移量12：SuppressExternalCodecs = FALSE
            DllCall("gdiplus\GdiplusStartup", "PtrP", token, "Ptr", si, "Ptr", 0)
        }
        return token
    }

    Gdip_Shutdown(token) {
        DllCall("gdiplus\GdiplusShutdown", "Ptr", token)
        DllCall("FreeLibrary", "Ptr", DllCall("GetModuleHandle", "Str", "gdiplus.dll", "Ptr"))
    }
    ; ========== 4. 封装：截图并返回完整 BITMAP_DATA（修正可选参数+直接坐标） ==========
    ; 参数：
    ;   &pitch/&width/&height/&bytespixel: 按引用返回的位图参数（可选）
    ;   x/y/w/h: 截图区域坐标（可选，不传则全屏）
    ;   hwnd: 窗口句柄（可选，优先级高于x/y/w/h）
    ; 返回值：存储位图像素的原生 Buffer 对象
    HBitmapFromHWND(hwnd := 0, x := 0, y := 0, w := 0, h := 0) {
        if (!hwnd)
            hwnd := this.hwnd
        if (!w || !h) {
            WinGetClientPos(, , &w, &h, hwnd)
        }
        hSourceDC := DllCall('GetDC', 'ptr', hwnd)
        hMemDC := DllCall("CreateCompatibleDC", "Ptr", 0)
        hBitmap := DllCall("CreateCompatibleBitmap", "ptr", hSourceDC, "int", w, "int", h)
        hOldBitmap := DllCall("SelectObject", "Ptr", hMemDC, "Ptr", hBitmap)
        DllCall("BitBlt"
            , "Ptr", hMemDC, "int", 0, "int", 0, "int", w, "int", h
            , "Ptr", hSourceDC, "int", x, "int", y
            , "uint", 0xCC0020)
        DllCall("SelectObject", "Ptr", hMemDC, "Ptr", hOldBitmap)
        DllCall('DeleteDC', 'ptr', hMemDC)
        DllCall('ReleaseDC', 'int', 0, 'ptr', hSourceDC)
        return hBitmap
    }

    BitmapFromHWND(hwnd := 0, x := 0, y := 0, w := 0, h := 0) {
        if (!hwnd)
            hwnd := this.hwnd
        hBitmap := this.HBitmapFromHWND(hwnd, x, y, w, h)
        DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "Ptr", hBitmap, "Ptr", 0, "Ptr*", &pBitmap := 0)
        return pBitmap
    }

    Capture(x := 0, y := 0, w := 0, h := 0) {
        hBitmap := this.HBitmapFromHWND(this.hwnd, x, y, w, h)
        return ABitmap.fromHBitmap(hBitmap)
    }

    GetWindowRectWithoutShadow(hwnd, &x, &y, &w, &h) {
        rect := Buffer(16)
        DllCall('dwmapi\DwmGetWindowAttribute'
            , 'ptr', hwnd, 'uint', 0x9
            , 'ptr', rect, 'int', rect.Size)
        x := NumGet(rect, 'int'), y := NumGet(rect, 4, 'int')
        w := NumGet(rect, 8, 'int') - x, h := NumGet(rect, 12, 'int') - y
    }
}

class ABitmap {
    __New(bits, pitch, width, height, bytespixel := 4) {
        NumPut("ptr", bits, "uint", pitch, "uint", width, "uint", height, "uint", bytespixel, this.info := Buffer(40, 0))
        this.ptr := bits
        this.updateDesc()
    }

    static fromHBitmap(hBitmap) {
        static bmBitsoffset := 16 + A_PtrSize
        DllCall("GetObject", "ptr", hBitmap, "int", 32, "ptr", bitmap := Buffer(32, 0))
        ptr := NumGet(bitmap, bmBitsoffset, "ptr") ; 这里为0
        width := NumGet(bitmap, 4, "int")
        height := NumGet(bitmap, 8, "int")
        pitch := NumGet(bitmap, 12, "int")
        bits := NumGet(bitmap, 18, "ushort")

        ; 步骤3：创建DIB信息头，用于GetDIBits提取像素数据
        dibHeader := Buffer(40, 0) ; BITMAPINFOHEADER
        NumPut("uint", 40, dibHeader, 0) ; biSize
        NumPut("int", width, dibHeader, 4) ; biWidth
        NumPut("int", -height, dibHeader, 8) ; biHeight（负数表示正向扫描，避免翻转）
        NumPut("ushort", 1, dibHeader, 12) ; biPlanes
        NumPut("ushort", 32, dibHeader, 14) ; biBitCount（32位）
        NumPut("uint", 0, dibHeader, 16) ; biCompression（BI_RGB）
        NumPut("uint", 0, dibHeader, 20) ; biSizeImage
        NumPut("int", 0, dibHeader, 24) ; biXPelsPerMeter
        NumPut("int", 0, dibHeader, 28) ; biYPelsPerMeter
        NumPut("uint", 0, dibHeader, 32) ; biClrUsed
        NumPut("uint", 0, dibHeader, 36) ; biClrImportant

        totalSize := pitch * height
        pixelBuffer := Buffer(totalSize, 0)
        hDC := DllCall("GetDC", "ptr", 0) ; 获取屏幕DC
        ; 提取像素数据到pixelBuffer
        DllCall("GetDIBits"
            , "ptr", hDC
            , "ptr", hBitmap
            , "uint", 0 ; uStartScan
            , "uint", height ; cScanLines
            , "ptr", pixelBuffer ; lpvBits
            , "ptr", dibHeader ; lpbi
            , "uint", 0 ; uUsage (DIB_RGB_COLORS)
        )
        DllCall("ReleaseDC", "ptr", 0, "ptr", hDC) ; 释放DC

        bb := ABitmap(pixelBuffer.Ptr, pitch, width, height, 4)
        bb.data := pixelBuffer ; 持有缓冲区引用，避免被回收
        return bb
    }
    static fromGpBitmap(pBitmap) {
        DllCall("gdiplus\GdipBitmapLockBits", "ptr", pBitmap, "ptr", 0, "uint", 1, "int", 0x26200a, "ptr", bmpdata := Buffer(32, 0))
        width := NumGet(bmpdata, "uint")
        height := NumGet(bmpdata, 4, "uint")
        stride := NumGet(bmpdata, 8, "int")
        scan0 := NumGet(bmpdata, 16, "ptr")
        data := ClipboardAll(scan0, stride * height)
        DllCall("gdiplus\GdipBitmapUnlockBits", "ptr", bmpdata)
        bb := ABitmap(data.Ptr, stride, width, height)
        bb.data := data
        return bb
    }

    HBITMAP() {
        sw := this.width, sh := this.height, bytespixel := 4, pitch := (sw * bytespixel + 3) & -4
        hbm := DllCall("CreateBitmap", "int", sw, "int", sh, "uint", 1, "uint", bytespixel * 8, "ptr", this, "ptr")
        return { ptr: hbm, __Delete: (s) => DllCall("DeleteObject", "ptr", s) }
    }

    updateDesc(update := true) {
        static bmBitsoffset := 16 + A_PtrSize
        if (update) {
            this.pitch := NumGet(b := this.info, o := A_PtrSize, "int")
            this.width := NumGet(b, o += 4, "int")
            this.height := NumGet(b, o += 4, "int")
            this.bytespixel := NumGet(b, o += 4, "int")
            ; this.offsetx := NumGet(b, o += 4, "int")
            ; this.offsety := NumGet(b, o += 4, "int")
            this.size := this.pitch * this.height
        }
        pitch := this.pitch
        switch bytespixel := this.bytespixel {
            case 4: tp := "uint"
            case 2: ; tp := "ushort"
                throw TypeError("unsupported bitmap type")
            case 1: tp := "uchar"
            case 3: this.DefineProp("__Item", { get: (s, x, y) => NumGet(s, y * pitch + x * 3, "uint") & 0xffffff, set: (s, v, x, y) => NumPut("uint", v, s, y * pitch + x * 3) })
            default:
                throw ValueError("invalid bytespixel: " bytespixel)
        }
        if (bytespixel != 3)
            this.DefineProp("__Item", { get: (s, x, y) => NumGet(s, y * pitch + x * bytespixel, tp), set: (s, v, x, y) => NumPut(tp, v, s, y * pitch + x * bytespixel) })
    }
    getHexColor(x, y) => Format("{:06X}", this[x, y] & 0xFFFFFF)
    range(x1 := 0, y1 := 0, x2 := unset, y2 := unset) {
        if !IsSet(x2)
            x2 := this.width
        if !IsSet(y2)
            y2 := this.height
        w := x2 - x1, h := y2 - y1

        bytespixel := this.bytespixel
        ; 2. 为子区域重新计算对齐后的pitch
        newPitch := (w * bytespixel + 3) & -4  ; 对齐到4字节边界

        ; 3. 分配新的像素缓冲区，复制子区域数据（避免复用原内存）
        newPixelBuffer := Buffer(newPitch * h, 0)
        srcPtr := this.ptr + y1 * this.pitch + x1 * bytespixel
        dstPtr := newPixelBuffer.Ptr

        ; 逐行复制有效像素（跳过原pitch的填充字节）
        loop h {
            ; 复制当前行的有效区域：w × bytespixel 字节
            DllCall("RtlMoveMemory", "Ptr", dstPtr, "Ptr", srcPtr, "UInt", w * bytespixel)
            ; 移动指针到下一行（原位图用原pitch，新位图用新pitch）
            srcPtr += this.pitch
            dstPtr += newPitch
        }
        bb := ABitmap(newPixelBuffer.Ptr, newPitch, w, h, this.bytespixel)
        bb.data := newPixelBuffer
        return bb
    }
    save(sOutput, quality := 75) {
        hBitmap := this.HBITMAP()
        DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "Ptr", hBitmap, "Ptr", 0, "Ptr*", &pBitmap := 0)
        SplitPath(sOutput, , , &ext, &name)
        if !(ext ~= "i)^(BMP|DIB|RLE|JPG|JPEG|JPE|JFIF|GIF|TIF|TIFF|PNG)$")
            return -1
        DllCall("gdiplus\GdipGetImageEncodersSize", "uint*", &nCount := 0, "uint*", &nSize := 0)
        DllCall("gdiplus\GdipGetImageEncoders", "uint", nCount, "uint", nSize, "Ptr", ci := Buffer(nSize))
        if !(nCount && nSize)
            return -2
        ext := '.' ext
        loop nCount {
            sString := StrGet(NumGet(ci, (idx := (48 + 7 * A_PtrSize) * (A_Index - 1)) + 32 + 3 * A_PtrSize, "Ptr"), "UTF-16")
            if !InStr(sString, "*" ext)
                continue
            pCodec := ci.Ptr + idx
            break
        }
        if !pCodec
            return -3
        if quality != 75 and ext ~= 'i)^(\.JPG|\.JPEG|\.JPE|\.JFIF)$' {
            quality := (quality < 0) ? 0 : (quality > 100) ? 100 : quality
            DllCall("gdiplus\GdipGetEncoderParameterListSize", "Ptr", pBitmap, "Ptr", pCodec, "uint*", &nSize := 0)
            DllCall("gdiplus\GdipGetEncoderParameterList", "Ptr", pBitmap, "Ptr", pCodec, "uint", nSize, "Ptr", emt := Buffer(nSize, 0))
            loop NumGet(emt, "uint") {
                elem := (24 + A_PtrSize) * (A_Index - 1) + A_PtrSize
                if (NumGet(emt, elem + 16, "uint") = 1) && (NumGet(emt, elem + 20, "uint") = 6) {
                    ep := emt.ptr + elem - A_PtrSize
                    NumPut("uptr", 1, ep), NumPut("uint", 4, ep, 20 + A_PtrSize)
                    NumPut("uint", quality, NumGet(ep + 24 + A_PtrSize, "uptr"))
                    break
                }
            }
        }
        r := DllCall("gdiplus\GdipSaveImageToFile", "ptr", pBitmap, "ptr", StrPtr(sOutput), "ptr", pCodec, "uint", 0)
        DllCall("gdiplus\GdipDisposeImage", 'uptr', pBitmap)
        return r ? -5 : 0
    }
    base64() {
        this.save(sOutput := A_Temp "\__Capture__.png")
        buf := FileRead(sOutput, "RAW")
        sBase64 := Base64.Encode(buf)
        FileDelete(sOutput)
        return sBase64
    }

    static fromFile(sFile) {
        ; 使用GDI+加载图像
        hResult := DllCall("gdiplus\GdipCreateBitmapFromFile", "ptr", StrPtr(sFile), "ptr*", &pBitmap)
        if (hResult != 0) {
            throw Error("Failed to create bitmap from file", -1)
        }

        ; 从GpBitmap创建ABitmap对象
        result := this.fromGpBitmap(pBitmap)

        ; 清理资源
        DllCall("gdiplus\GdipDisposeImage", "ptr", pBitmap)

        return result
    }

    static fromBase64(sBase64) {
        sBase64 := Base64.Decode(sBase64)
        sTempFile := A_Temp "\__base64_image__.png"
        buf := FileOpen(sTempFile, "w")
        buf.Write(sBase64)
        buf.Close()
        try {
            return this.fromFile(sTempFile)
        } finally {
            FileDelete(sTempFile)
        }
    }
}