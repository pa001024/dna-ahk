global MyVJoy := VJoy()
MyVJoy.Init()

class VJoy {
    ; ========== 常量定义：Xbox 360按键位掩码（与DLL中的Xbox360Button枚举对应） ==========
    static XBOX_A := 4096          ; A键
    static XBOX_B := 8192          ; B键
    static XBOX_X := 16384          ; X键
    static XBOX_Y := 32768          ; Y键
    static XBOX_LB := 256        ; 左肩键
    static XBOX_RB := 512        ; 右肩键
    static XBOX_BACK := 32      ; 返回键
    static XBOX_START := 16    ; 开始键
    static XBOX_LSB := 64      ; 左摇杆按下
    static XBOX_RSB := 128      ; 右摇杆按下
    static XBOX_UP := 1      ; 方向上
    static XBOX_DOWN := 2    ; 方向下
    static XBOX_LEFT := 4    ; 方向左
    static XBOX_RIGHT := 8   ; 方向右
    static XBOX_GUIDE := 1024   ; 方向右

    _dllPath := ""
    _isInitialized := false

    ; ========== 构造函数：初始化类并加载DLL ==========
    __New() {
        this._dllPath := "ahk_vjoy.dll"
        ; 加载DLL（若加载失败直接抛出异常）
        if !DllCall("LoadLibrary", "Str", A_LineFile "\..\" this._dllPath, "Ptr") {
            throw Error("无法加载DLL文件：" this._dllPath "`n请检查DLL路径和32/64位匹配", "DLL加载失败")
        }
    }

    ; ========== 析构函数：程序退出时自动关闭手柄 ==========
    __Delete() {
        if this._isInitialized {
            this.Close()
        }
    }

    ; ========== 公开方法：初始化虚拟Xbox 360手柄 ==========
    Init() {
        if this._isInitialized {
            return true  ; 已初始化直接返回成功
        }
        ; 调用DLL的InitXbox360Controller函数（StdCall调用约定）
        local result := DllCall(
            this._dllPath "\InitXbox360Controller",
            "Int"
        )
        switch result {
            case 0:
                this._isInitialized := true
                return true
            case 1:
                this._isInitialized := true
                return true
            case -1:
                throw Error("初始化虚拟手柄失败！`n请确认：`n1. 已安装ViGEmBus驱动`n2. 脚本以管理员运行`n3. DLL与AHK版本（32/64位）匹配", "初始化失败")
            default:
                throw Error("未知错误，返回码：" result, "初始化失败")
        }
    }

    KeyToVCode(keyName) {
        vkey := 0
        switch keyName {
            case "A":
                vkey := VJoy.XBOX_A
            case "B":
                vkey := VJoy.XBOX_B
            case "X":
                vkey := VJoy.XBOX_X
            case "Y":
                vkey := VJoy.XBOX_Y
            case "LB":
                vkey := VJoy.XBOX_LB
            case "RB":
                vkey := VJoy.XBOX_RB
            case "BACK":
                vkey := VJoy.XBOX_BACK
            case "START":
                vkey := VJoy.XBOX_START
            case "LSB":
                vkey := VJoy.XBOX_LSB
            case "RSB":
                vkey := VJoy.XBOX_RSB
            case "UP":
                vkey := VJoy.XBOX_UP
            case "DOWN":
                vkey := VJoy.XBOX_DOWN
            case "LEFT":
                vkey := VJoy.XBOX_LEFT
            case "RIGHT":
                vkey := VJoy.XBOX_RIGHT
            default:
                throw Error("未知按键：" keyName, "按键错误")
        }
        return vkey
    }


    HoldKeyLeftAxis(keyName, x, y, t := 100) {
        vkey := this.KeyToVCode(keyName)
        this.SendInput(vkey, x, y, 0, 0, 0, 0)
        Sleep(t)
        this.SendInput(0, 0, 0, 0, 0, 0, 0)
    }

    HoldKeyRightAxis(keyName, x, y, t := 100) {
        vkey := this.KeyToVCode(keyName)
        this.SendInput(vkey, 0, 0, x, y, 0, 0)
        Sleep(t)
        this.SendInput(0, 0, 0, 0, 0, 0, 0)
    }
    Press(keyName, t := 100) {
        vkey := this.KeyToVCode(keyName)
        this.SendInput(vkey)
        Sleep(t)
        this.SendInput(0)
    }

    PressA(t := 100) {
        this.SendInput(VJoy.XBOX_A)
        Sleep(t)
        this.SendInput(0)
    }

    PressB(t := 100) {
        this.SendInput(VJoy.XBOX_B)
        Sleep(t)
        this.SendInput(0)
    }

    PressX(t := 100) {
        this.SendInput(VJoy.XBOX_X)
        Sleep(t)
        this.SendInput(0)
    }

    PressLBX(t := 100) {
        this.SendInput(VJoy.XBOX_LB)
        Sleep(50)
        this.SendInput(VJoy.XBOX_LB + VJoy.XBOX_X)
        Sleep(t)
        this.SendInput(0)
    }

    PressLBY(t := 100) {
        this.SendInput(VJoy.XBOX_LB)
        Sleep(50)
        this.SendInput(VJoy.XBOX_LB + VJoy.XBOX_Y)
        Sleep(t)
        this.SendInput(0)
    }

    PressLBB(t := 100) {
        this.SendInput(VJoy.XBOX_LB)
        Sleep(50)
        this.SendInput(VJoy.XBOX_LB + VJoy.XBOX_B)
        Sleep(t)
        this.SendInput(0)
    }

    PressY(t := 100) {
        this.SendInput(VJoy.XBOX_Y)
        Sleep(t)
        this.SendInput(0)
    }

    PressLB(t := 100) {
        this.SendInput(VJoy.XBOX_LB)
        Sleep(t)
        this.SendInput(0)
    }

    PressRB(t := 100) {
        this.SendInput(VJoy.XBOX_RB)
        Sleep(t)
        this.SendInput(0)
    }

    PressBack(t := 100) {
        this.SendInput(VJoy.XBOX_BACK)
        Sleep(t)
        this.SendInput(0)
    }

    PressStart(t := 100) {
        this.SendInput(VJoy.XBOX_START)
        Sleep(t)
        this.SendInput(0)
    }

    PressLSB(t := 100) {
        this.SendInput(VJoy.XBOX_LSB)
        Sleep(t)
        this.SendInput(0)
    }

    PressRSB(t := 100) {
        this.SendInput(VJoy.XBOX_RSB)
        Sleep(t)
        this.SendInput(0)
    }

    PressUp(t := 100) {
        this.SendInput(VJoy.XBOX_UP)
        Sleep(t)
        this.SendInput(0)
    }

    PressDown(t := 100) {
        this.SendInput(VJoy.XBOX_DOWN)
        Sleep(t)
        this.SendInput(0)
    }

    PressLeft(t := 100) {
        this.SendInput(VJoy.XBOX_LEFT)
        Sleep(t)
        this.SendInput(0)
    }

    PressRight(t := 100) {
        this.SendInput(VJoy.XBOX_RIGHT)
        Sleep(t)
        this.SendInput(0)
    }

    LeftAxis(x, y, t := 100) {
        this.SendInput(0, x, y, 0, 0, 0, 0)
        Sleep(t)
        this.SendInput(0, 0, 0, 0, 0, 0, 0)
    }

    RightAxis(x, y, t := 100) {
        this.SendInput(0, 0, 0, x, y, 0, 0)
        Sleep(t)
        this.SendInput(0, 0, 0, 0, 0, 0, 0)
    }

    LeftTrigger(t := 100) {
        this.SendInput(0, 0, 0, 0, 0, 255, 0)
        Sleep(t)
        this.SendInput(0, 0, 0, 0, 0, 0, 0)
    }

    RightTrigger(t := 100) {
        this.SendInput(0, 0, 0, 0, 0, 0, 255)
        Sleep(t)
        this.SendInput(0, 0, 0, 0, 0, 0, 0)
    }

    ; ========== 公开方法：发送手柄输入 ==========
    ; 参数说明：
    ;   buttons: 按键组合（可叠加，如VJoy.XBOX_A | VJoy.XBOX_B）
    ;   leftX/leftY: 左摇杆轴（-32768~32767）
    ;   rightX/rightY: 右摇杆轴（-32768~32767）
    ;   leftTrigger/rightTrigger: 扳机（0~255）
    SendInput(buttons := 0, leftX := 0, leftY := 0, rightX := 0, rightY := 0, leftTrigger := 0, rightTrigger := 0) {
        if !this._isInitialized {
            throw Error("请先调用Init()初始化虚拟手柄", "未初始化")
        }
        ; 类型校验（避免非法参数）
        if !IsInteger(buttons) || buttons < 0 || buttons > 65535 {
            throw Error("按键值必须是0~65535的整数", "参数错误")
        }
        if !IsInteger(leftX) || leftX < -32768 || leftX > 32767 {
            throw Error("左摇杆X轴值必须是-32768~32767的整数", "参数错误")
        }
        ; 调用DLL的SendXbox360Input函数
        local result := DllCall(
            this._dllPath "\SendXbox360Input",
            "Int", buttons,       ; 按键位掩码
            "Short", leftX,             ; 左摇杆X
            "Short", leftY,             ; 左摇杆Y
            "Short", rightX,            ; 右摇杆X
            "Short", rightY,            ; 右摇杆Y
            "UChar", leftTrigger,       ; 左扳机
            "UChar", rightTrigger,      ; 右扳机
            "Int"                       ; 返回值类型
        )
        switch result {
            case 0:
                return true
            case -1:
                throw Error("手柄未初始化", "发送输入失败")
            case -2:
                throw Error("发送输入数据失败", "发送输入失败")
            default:
                throw Error("未知错误，返回码：" result, "发送输入失败")
        }
    }

    ; ========== 公开方法：重置所有手柄输入（释放按键/摇杆归位） ==========
    ResetInput() {
        if !this._isInitialized {
            throw Error("请先调用Init()初始化虚拟手柄", "未初始化")
        }
        local result := DllCall(
            this._dllPath "\ResetXbox360Input",
            "Cdecl Int"
        )
        if result != 0 {
            throw Error("重置手柄输入失败", "重置失败")
        }
        return true
    }

    ; ========== 公开方法：关闭虚拟手柄并释放资源 ==========
    Close() {
        if !this._isInitialized {
            return true
        }
        local result := DllCall(
            this._dllPath "\CloseXbox360Controller",
            "Int"
        )
        if result == 0 {
            this._isInitialized := false
            return true
        } else {
            throw Error("关闭手柄失败，返回码：" result, "关闭失败")
        }
    }
}