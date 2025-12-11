#Requires AutoHotkey v2.0
#Include lib.ahk

kb(k) => (ControlSend(k, hwnd), 0)
xy(x, y) => (mouseXY(x, y), 0)
mc(x, y, c := "", t := 0) => c ? (wc(x, y, c), WindowClick(x, y, hwnd), s(t)) : WindowClick(x, y, hwnd)
md(x, y) => (WindowClickDown(x, y, hwnd), 0)
mu(x, y) => (WindowClickUp(x, y, hwnd), 0)
mr(t) => (WindowRightClick(hwnd, t), 0)
mt() => (WindowMiddleClick(hwnd), 0)
gc(x, y) => GetWindowColor(x, y)
cc(x, y, c) => CheckWindowColor(x, y, c)
wc(x, y, c, t := 8000, s := 3) => WaitWindowColor(x, y, c, s, t)
s(t) => (Sleep(t), 0)