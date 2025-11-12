#Requires AutoHotkey v2.0

; 计数器类
class EMGui {
    static oGui := this.InitGui()
    static visible := false

    ; 初始化GUI窗口
    static InitGui() {
        oGui := Gui("+DPIScale", "二重")
        oGui.OnEvent("Close", (*) => this.Close())

        char := oGui.AddDropDownList("x16 y16 w120 Section", ["水母E", "黎瑟Q", "黎瑟EQ循环"])
        char.Text := IniRead("em-ahk.ini", "gui", "char", "水母E")
        char.OnEvent("Change", (*) => IniWrite(char.Text, "em-ahk.ini", "gui", "char"))
        oGui.char := char
        oGui.AddButton("x+8 ys w120 hp", "重新加载").OnEvent("Click", (*) => this.Reload())

        mode := oGui.AddDropDownList("x16 y+12 w120 Section", ["30线索", "钓鱼", "驱离", "65mod"])
        mode.Text := IniRead("em-ahk.ini", "gui", "mode", "30线索")
        mode.OnEvent("Change", (*) => IniWrite(mode.Text, "em-ahk.ini", "gui", "mode"))
        oGui.mode := mode
        oGui.btn_start := oGui.AddButton("x+8 ys w120 hp", "开始")
        oGui.btn_start.OnEvent("Click", (*) => this.Start())

        mute := oGui.AddCheckbox("x16 y+12 w120 Section", "静音游戏")
        mute.Value := IniRead("em-ahk.ini", "gui", "mute", 0)
        mute.OnEvent("Click", (*) => this.Mute())
        oGui.mute := mute
        melee := oGui.AddCheckbox("x+8 yp w120", "穿引共鸣")
        melee.Value := IniRead("em-ahk.ini", "gui", "melee", 0)
        melee.OnEvent("Click", (*) => IniWrite(melee.Value, "em-ahk.ini", "gui", "melee"))
        oGui.melee := melee

        oGui.AddButton("x60 y+8 w40 Section", "W").OnEvent("Click", (*) => move("w", Integer(len.Text)))
        len := oGui.AddDropDownList("x+56 ys w80", ["0.1", "1", "2"])
        len.Text := "1"
        oGui.AddButton("x12 y+4  w40 Section", "A").OnEvent("Click", (*) => move("a", Integer(len.Text)))
        oGui.AddButton("x+8 ys  w40", "S").OnEvent("Click", (*) => move("s", Integer(len.Text)))
        oGui.AddButton("x+8 ys  w40", "D").OnEvent("Click", (*) => move("d", Integer(len.Text)))
        oGui.AddButton("x+8 ys  w40", "冲").OnEvent("Click", (*) => dash())
        oGui.AddButton("x+8 ys  w40", "M").OnEvent("Click", (*) => mc(0, 0))

        return oGui
    }

    static Show() {
        w := 280
        h := 160
        this.oGui.Show("w" . w . " h" . h . " x16 y" . (A_ScreenHeight - 120 - h) . "NoActivate")
        A_TrayMenu.Check("二重")
        this.visible := true
    }
    static Close() {
        this.oGui.Hide()
        A_TrayMenu.Uncheck("二重")
        this.visible := false
    }
    static Start() {
        if this.oGui.btn_start.Text == "停止" {
            this.oGui.mode.Enabled := 1
            this.oGui.btn_start.Text := "开始"
        } else {
            this.oGui.btn_start.Text := "停止"
            this.oGui.mode.Enabled := 0
        }
        switch this.oGui.mode.Text {
            case "30线索":
                mode_30xiansuo
            case "钓鱼":
                mode_fishing
            case "驱离":
                mode_60mod
            case "65mod":
                mode_65mod
        }
    }
    static Mute() {
        p := "EM-Win64-Shipping.exe"
        IniWrite(this.oGui.mute.Value, "em-ahk.ini", "gui", "mute")
        if this.oGui.mute.Value {
            setProgramVol(p, 0)
        } else {
            setProgramVol(p, 1)
        }
    }
    static Reload() {
        Reload
    }
}