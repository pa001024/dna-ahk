#Requires AutoHotkey v2.0

#Include dnagui.ahk

GuiMain.Init()
class GuiMain {
    static Init() {
        DllCall("shell32\SetCurrentProcessExplicitAppUserModelID", "wstr", "EM AHKv2")
        A_TrayMenu.Insert("E&xit", "二重", (*) => this.ShowMain())

        try TraySetIcon("l.ico")
        this.Load()
    }

    static ShowMain() {
        if DNAGui.visible() {
            DNAGui.Close()
            IniWrite(0, "dna-ahk.ini", "gui", "show")
        } else {
            DNAGui.Show()
            IniWrite(1, "dna-ahk.ini", "gui", "show")
        }
    }

    static Load() {
        if showCounter := IniRead("dna-ahk.ini", "gui", "show", 0)
            this.ShowMain()
    }
}