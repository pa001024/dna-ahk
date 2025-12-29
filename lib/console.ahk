#Include <JSON>

global console := ConsoleClass()

class ConsoleClass {
    stdout := 0
    hStdOut := 0
    __New() {
        this.hStdOut := DllCall("GetStdHandle", "int", -11, "ptr")
        if !this.hStdOut {
            DllCall("AllocConsole")
            ; 获取新分配的控制台句柄
            this.hStdOut := DllCall("GetStdHandle", "int", -11, "ptr")

            ; 显示控制台窗口
            hConsole := DllCall("GetConsoleWindow", "ptr")
            if hConsole {
                ; 确保控制台窗口可见
                DllCall("ShowWindow", "ptr", hConsole, "int", 5) ; SW_SHOW
            } else {
                return
            }
        }
        this.stdout := FileOpen("*", "w")
    }

    __Delete() {
        if this.stdout {
            this.stdout.Close()
            this.stdout := 0
        }
    }

    static COLOR_BLACK := 0
    static COLOR_DARK_BLUE := 1
    static COLOR_DARK_GREEN := 2
    static COLOR_DARK_CYAN := 3
    static COLOR_DARK_RED := 4
    static COLOR_DARK_PURPLE := 5
    static COLOR_BROWN := 6
    static COLOR_LIGHT_GRAY := 7
    static COLOR_DARK_GRAY := 8
    static COLOR_BLUE := 9
    static COLOR_GREEN := 10
    static COLOR_CYAN := 11
    static COLOR_RED := 12
    static COLOR_PURPLE := 13
    static COLOR_YELLOW := 14
    static COLOR_WHITE := 15

    /**
     * 设置控制台文本颜色
     * 0 = 黑色    8 = 灰色    1 = 淡蓝      9 = 蓝色
     * 2 = 淡绿    A = 绿色    3 = 湖蓝      B = 淡浅绿  
     * C = 红色    4 = 淡红    5 = 紫色      D = 淡紫  
     * 6 = 黄色    E = 淡黄    7 = 白色      F = 亮白
     * @param color 控制台文本颜色，0-15之间的整数
     */
    setColor(textColor, bgColor := 0) {
        DllCall("SetConsoleTextAttribute", "ptr", this.hStdOut, "int", textColor | bgColor * 16)
    }

    log(msgs*) {
        for msg in msgs {
            ; 遍历msgs数组，将每个元素转换为字符串并写入控制台
            switch (o := '', Type(msg)) {
                case 'Map', 'Array', 'Object':
                    o := JSON.stringify(msg)
                default:
                    try o := String(msg)
            }
            this.stdout.Write(o)
        }
        this.stdout.WriteLine()
        this.stdout.Read(0)
    }

    info(msg) {
        this.setColor(ConsoleClass.COLOR_GREEN)
        this.log(msg)
    }

    warn(msg) {
        this.setColor(ConsoleClass.COLOR_YELLOW)
        this.log(msg)
    }

    debug(msg) {
        this.setColor(ConsoleClass.COLOR_LIGHT_GRAY)
        this.log(msg)
    }

    error(msg) {
        this.setColor(ConsoleClass.COLOR_RED)
        this.log(msg)
    }
}