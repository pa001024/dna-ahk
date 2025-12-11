#Requires AutoHotkey v2.0

; 计数器类
class DNAGui {
    static single := DNAGui()

    static Show() {
        this.single.Show()
        this.single.visible := true
    }
    static Close() {
        this.single.Close()
        this.single.visible := false
    }

    static visible() {
        return this.single.visible
    }

    ; 初始化GUI窗口
    __New() {
        this.visible := false
        this.gui := Gui("+DPIScale", "二重")
        this.gui.OnEvent("Close", (*) => this.Close())

        dl_char := this.gui.AddDropDownList("x16 y16 w120 Section", ["水母E", "黎瑟Q", "黎瑟EQ循环", "近战蓄力"])
        dl_char.Text := IniRead("dna-ahk.ini", "gui", "char", "水母E")
        dl_char.OnEvent("Change", (*) => IniWrite(dl_char.Text, "dna-ahk.ini", "gui", "char"))
        this.dl_char := dl_char
        this.gui.AddButton("x+8 ys w120 hp", "重新加载").OnEvent("Click", (*) => this.Reload())

        dl_mode := this.gui.AddDropDownList("x16 y+12 w120 Section", ["30线索", "钓鱼", "驱离", "65mod"])
        dl_mode.Text := IniRead("dna-ahk.ini", "gui", "mode", "30线索")
        dl_mode.OnEvent("Change", (*) => IniWrite(dl_mode.Text, "dna-ahk.ini", "gui", "mode"))
        this.dl_mode := dl_mode
        this.btn_start := btn_start := this.gui.AddButton("x+8 ys w120 hp", "开始")
        btn_start.OnEvent("Click", (*) => this.Start())

        this.btn_mute := btn_mute := this.gui.AddCheckbox("x16 y+12 w120 Section", "静音游戏")
        btn_mute.Value := IniRead("dna-ahk.ini", "gui", "mute", 0)
        btn_mute.OnEvent("Click", (*) => (IniWrite(btn_mute.Value, "dna-ahk.ini", "gui", "mute"), this.Mute()))
        this.btn_melee := btn_melee := this.gui.AddCheckbox("x+8 yp w120", "穿引共鸣")
        btn_melee.Value := IniRead("dna-ahk.ini", "gui", "melee", 0)
        btn_melee.OnEvent("Click", (*) => IniWrite(btn_melee.Value, "dna-ahk.ini", "gui", "melee"))

        ; 添加攻击方式下拉框
        this.dl_xbtnFunc := dl_xbtnFunc := this.gui.AddDropDownList("x16 y+12 w120 Section", ["禁用", "穿引", "左键", "右键"])
        dl_xbtnFunc.Text := IniRead("dna-ahk.ini", "gui", "xbtnFunc", "禁用")
        dl_xbtnFunc.OnEvent("Change", (*) => (IniWrite(dl_xbtnFunc.Text, "dna-ahk.ini", "gui", "xbtnFunc"), this.ActiveXBtnFunc()))
        this.ActiveXBtnFunc()

        ; this.gui.AddButton("x60 y+8 w40 Section", "W").OnEvent("Click", (*) => move("w", Integer(len.Text)))
        ; len := this.gui.AddDropDownList("x+56 ys w80", ["0.1", "1", "2"])
        ; len.Text := "1"
        ; this.gui.AddButton("x12 y+4  w40 Section", "A").OnEvent("Click", (*) => move("a", Integer(len.Text)))
        ; this.gui.AddButton("x+8 ys  w40", "S").OnEvent("Click", (*) => move("s", Integer(len.Text)))
        ; this.gui.AddButton("x+8 ys  w40", "D").OnEvent("Click", (*) => move("d", Integer(len.Text)))
        ; this.gui.AddButton("x+8 ys  w40", "冲").OnEvent("Click", (*) => dash())
        ; this.gui.AddButton("x+8 ys  w40", "M").OnEvent("Click", (*) => mc(0, 0))

        this.gui.AddText("x16 y+12 w120 Section", "当前波次")
        this.lb_wave := lb_wave := this.gui.AddText("x+8 yp w120", "-")
    }

    ActiveXBtnFunc() {
        switch this.dl_xbtnFunc.Text {
            case "穿引":
                setHotPress("XButton2", () {
                    mr 100
                }, 133, "ahk_exe EM-Win64-Shipping.exe")
            case "左键":
                setHotPress("XButton2", () {
                    Click "Down"
                    Sleep 22
                    Click "Up"
                    Sleep 22
                }, 44, "ahk_exe EM-Win64-Shipping.exe")
            case "右键":
                setHotPress("XButton2", () {
                    mr 100
                }, 300, "ahk_exe EM-Win64-Shipping.exe")
            default:
                removeHotPress("XButton2", "ahk_exe EM-Win64-Shipping.exe")
        }
    }

    Show() {
        w := 280
        h := 160
        this.gui.Show("w" . w . " h" . h . " x16 y" . (A_ScreenHeight - 120 - h) . "NoActivate")
        A_TrayMenu.Check("二重")
        this.visible := true
    }
    Close() {
        this.gui.Hide()
        A_TrayMenu.Uncheck("二重")
        this.visible := false
    }
    Start() {
        ; WinMove , , 1600, 900, hwnd
        if this.btn_start.Text == "停止" {
            this.dl_mode.Enabled := 1
            this.btn_start.Text := "开始"
        } else {
            this.btn_start.Text := "停止"
            this.dl_mode.Enabled := 0
        }
        switch this.dl_mode.Text {
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
    Mute() {
        p := "EM-Win64-Shipping.exe"

        if this.btn_mute.Value {
            setProgramVol(p, 0)
        } else {
            setProgramVol(p, 1)
        }
    }
    Reload() {
        Reload()
    }
}