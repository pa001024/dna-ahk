#Requires AutoHotkey v2.0

#Include emgui.ahk

GuiMain.Init()
class GuiMain {
    static Init() {
        DllCall("shell32\SetCurrentProcessExplicitAppUserModelID", "wstr", "EM AHKv2")
        A_TrayMenu.Insert("E&xit", "二重", (*) => this.ShowMain())

        try TraySetIcon("l.ico")
        this.Load()
    }

    static ShowMain() {
        if EMGui.visible {
            EMGui.Close()
            IniWrite(0, "em-ahk.ini", "gui", "show")
        } else {
            EMGui.Show()
            IniWrite(1, "em-ahk.ini", "gui", "show")
        }
    }

    static Load() {
        if showCounter := IniRead("em-ahk.ini", "gui", "show", 0)
            this.ShowMain()
    }
}