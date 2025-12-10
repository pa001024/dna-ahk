#Include lib.ahk


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


drawBorder(100, 100, 200, 200)