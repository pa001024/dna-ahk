#Requires AutoHotkey v2.0
#Include <CGdip>

; ==============================================================================
; RectOverlay 类定义
; ==============================================================================
class RectOverlay {
    ; color: ARGB (0xAARRGGBB), thickness: 线宽(浮点可)
    __New(color := 0xFFFF0000, thickness := 1) {
        this.color := color
        this.thickness := thickness
        this.gui := 0
        this.hwnd := 0
        this._started := 0
        if !CGdip.pToken {
            CGdip.Startup() this._started := 1
        }
    }

    ; 显示并绘制空心矩形
    Show(x, y, w, h) {
        color := this.color
        thickness := this.thickness
        if (w <= 0 || h <= 0)
            return false
        if !this.gui {
            ex := 0x80000 | 0x20 ; WS_EX_LAYERED | WS_EX_TRANSPARENT
            this.gui := Gui(Format("+AlwaysOnTop -Caption +ToolWindow +E0x{:X}", ex))
            this.hwnd := this.gui.Hwnd
        }
        ; 创建 GDI+ 位图并绘制
        pBmp := CGdip.Bitmap.Create(w, h) ; 32bpp ARGB
        g := CGdip.Graphics.FromBitmap(pBmp)
        g.SetSmoothingMode(3) ; 无平滑
        g.SetCompositingMode(0) ; SourceOver ; 清透明背景
        ; br := CGdip.Brush.SolidFill(0x00000000)
        ; g.FillRectangle(br, 0, 0, w, h) ; 画边框（居中对齐，避免裁剪）
        pen := CGdip.Pen.Create(color, thickness)
        ; pen.SetLineJoin(0) ; LineJoinMiter
        ; pen.SetStartCap(1) ; LineCapSquare
        off := floor(thickness / 2.0)
        rw := w - thickness
        rh := h - thickness
        if (rw > 0 && rh > 0)
            g.DrawRectangle(pen, off, off, rw, rh) ; 显示窗口（不激活），并用 UpdateLayeredWindow 推送像素
        this.gui.Show("NA")
        this._UpdateLayered(pBmp, x, y, w, h)
        return true
    }
    ; 隐藏窗口
    Hide() {
        if this.gui
            this.gui.Hide()
    }
    ; 可选: 销毁窗口（如不再使用）
    Destroy() {
        if this.gui {
            this.gui.Destroy()
            this.gui := 0
            this.hwnd := 0
        }
    }
    ; 内部：把位图推送到分层窗口
    _UpdateLayered(pBmp, x, y, w, h) {
        hdc := DllCall("GetDC", "Ptr", 0, "Ptr")
        mdc := DllCall("CreateCompatibleDC", "Ptr", hdc, "Ptr")
        hbm := pBmp.CreateHBITMAP(0x00000000) ; 保留 alpha
        obm := DllCall("SelectObject", "Ptr", mdc, "Ptr", hbm, "Ptr")
        psize := this._SIZE(w, h)
        pptDst := this._POINT(x, y)
        pptSrc := this._POINT(0, 0)
        blend := this._BLENDFUNCTION(255, true) ; 全不透明，使用源 alpha
        DllCall("UpdateLayeredWindow", "Ptr", this.hwnd, "Ptr", hdc, "Ptr", pptDst, "Ptr", psize, "Ptr", mdc, "Ptr", pptSrc, "Uint", 0, "Ptr", blend, "Uint", 2) ; ULW_ALPHA
        DllCall("SelectObject", "Ptr", mdc, "Ptr", obm, "Ptr")
        DllCall("DeleteObject", "Ptr", hbm)
        DllCall("DeleteDC", "Ptr", mdc)
        DllCall("ReleaseDC", "Ptr", 0, "Ptr", hdc)
    }
    ; 结构体助手
    _POINT(x, y) {
        buf := Buffer(8, 0), NumPut("Int", x, buf, 0), NumPut("Int", y, buf, 4)
        return buf
    }
    _SIZE(w, h) {
        buf := Buffer(8, 0), NumPut("Int", w, buf, 0), NumPut("Int", h, buf, 4)
        return buf
    }
    _BLENDFUNCTION(alpha := 255, useSrcAlpha := true) {
        buf := Buffer(4, 0), NumPut("UChar", 0, buf, 0) ; AC_SRC_OVER
        NumPut("UChar", 0, buf, 1)
        NumPut("UChar", alpha, buf, 2) ; SourceConstantAlpha
        NumPut("UChar", useSrcAlpha ? 1 : 0, buf, 3) ; AC_SRC_ALPHA
        return buf
    }
    __Delete() {
        this.Destroy()
        if (this._started && CGdip.pToken)
            CGdip.Shutdown()
    }
}