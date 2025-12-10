#Include <JSON>
;exsample
;   log.is_out_console := true
;   log.is_out_file := true
;   log.info("hello log")
;   log.warn("hello log")
;   log.error("hello log")
;   log.critical("hello log")
class log {
    static line := true
    static file := true
    static func := true
    static is_extern_info := true
    static is_log_open := true
    static is_out_console := true
    static is_out_file := false
    static console_create_flag := false
    static log_mode := 1
    static is_formate := true
    static log_strim := ""
    static is_dll_load := false
    static is_use_cmder := false
    static is_use_editor := true
    static is_console_config := false
    static LOG4AHK_G_MY_DLL_USE_MAP := map("cpp2ahk.dll", map("cpp2ahk", 0, "log_simple", 0, "log_simple_mt_color", 0, "set_console_transparency", 0))
    static log4ahk_load_all_dll_path() {
        SplitPath(A_LineFile, , &dir)
        path := ""
        lib_path := dir
        if (A_IsCompiled) {
            path := (A_PtrSize == 4) ? A_ScriptDir . "\lib\dll_32\" : A_ScriptDir . "\lib\dll_64\"
            lib_path := A_ScriptDir . "\lib"
        }
        else {
            path := (A_PtrSize == 4) ? dir . "\dll_32\" : dir . "\dll_64\"
        }
        DllCall("SetDllDirectory", "Str", path)
        for k, v in this.LOG4AHK_G_MY_DLL_USE_MAP {
            for k1, v1 in v {
                this.LOG4AHK_G_MY_DLL_USE_MAP[k][k1] := DllCall("GetProcAddress", "Ptr", DllCall("LoadLibrary", "Str", k, "Ptr"), "AStr", k1, "Ptr")
            }
        }
        this.is_dll_load := true
        if (this.is_use_cmder && this.is_out_console) {
            this.attach_cmder(lib_path)
        }
        DllCall("SetConsoleTitle", "Str", A_ScriptName)
        DllCall("SetDllDirectory", "Str", A_ScriptDir)
    }
    static attach_cmder(condum_path) {
        app_pid := DllCall("GetCurrentProcessId")
        condum_path := condum_path . "\cmder\vendor\conemu-maximus5\ConEmu\ConEmuC.exe"
        if (FileExist(condum_path)) {
            DllCall(this.LOG4AHK_G_MY_DLL_USE_MAP["cpp2ahk.dll"]["set_console_transparency"], "Int", 0, "cdecl int")
            console4log.show_console()
            Run(condum_path " /ATTACH /CONPID=" app_pid)
        }
    }
    static __new() {
        this.log4ahk_load_all_dll_path()
    }
    static __delete() {
        DllCall("FreeConsole")
    }
    static log_out(para*) {
        if (this.is_dll_load == false) {
            this.log4ahk_load_all_dll_path()
        }
        if (this.is_log_open == false || (this.is_out_console == false && this.is_out_file == false)) {
            return
        }
        if (this.is_out_console == true && this.console_create_flag == false) {
            this.console_create_flag := true
        }
        if (!this.is_use_editor && this.is_out_console && !this.is_console_config) {
            DllCall("AllocConsole")
            DllCall("SetConsoleOutputCP", "int", 65001)
            consoleHandle := DllCall("CreateFile", "str", "CONOUT$", "int", 0x80000000 | 0x40000000, "int", 0x00000002, "int", 0, "int", 3, "int", 0, "int", 0)
            DllCall("SetStdHandle", "int", -11, "Ptr", consoleHandle)
            bk := CallbackCreate(console_close_callback)
            DllCall("SetConsoleCtrlHandler", "Ptr", bk, "Int", 1)
            console_close_callback(dwCtrlType) {
                return true
            }
            this.is_console_config := true
        }
        if (A_IsCompiled) {
            this.line := false
        }
        file_info := ""
        line_info := ""
        func_info := ""
        if (this.is_extern_info) {
            if (this.line || this.file) {
                err_obj := error("", -2)
                SplitPath(err_obj.file, &file_info)
                line_info := err_obj.line
            }
            if (this.func) {
                err_obj_up := error("", -3)
                func_info := err_obj_up.what
            }
            if (this.is_formate) {
                file_info := this.file ? "[" StrReplace(Format("{:-15}", substr(file_info, 1, 15)), A_Space, ".") "] " : ""
                line_info := this.line ? "[" Format("{:04}", substr(line_info, 1, 4)) "] " : ""
                func_info := this.func ? "[" StrReplace(Format("{:-15}", substr(func_info, 1, 15)), A_Space, ".") "] " : ""
            }
            else {
                file_info := this.file ? "[" file_info "] " : ""
                line_info := this.line ? "[" line_info "] " : ""
                func_info := this.func ? "[" func_info "] " : ""
            }
        }
        log_str := ""
        for k, v in para {
            log_str .= this.log4ahk_to_str(v) . " "
        }
        log_str := file_info func_info line_info "| " this.log_strim log_str
        buf := this.strbuf(log_str, "utf-8")
        result := DllCall(this.LOG4AHK_G_MY_DLL_USE_MAP["cpp2ahk.dll"]["log_simple"], "ptr", buf, "int", this.log_mode, "int", this.is_out_file, "int", this.is_out_console, "cdecl int")

        if (result != 0) {
            msgbox("dll call error!")
        }

    }
    static info(para*) {
        this.log_strim := ""
        this.log_mode := 1
        this.log_out(para*)
    }
    static warn(para*) {
        this.log_strim := ""
        this.log_mode := 2
        this.log_out(para*)
    }
    static err(para*) {
        this.log_strim := ""
        this.log_mode := 3
        this.log_out(para*)
    }
    static critical(para*) {
        this.log_strim := ""
        this.log_mode := 4
        this.log_out(para*)
    }
    static get_trim_position() {
        this.log_mode := 1
        stack_position := 0
        index_position := 0
        while (1) {
            stack_position++
            func_stack := Error("", index_position--)
            if (RegExMatch(func_stack.what, "^-[0-9]+$")) {
                break
            }
            if (stack_position > 20) {
                break
            }
        }
        return stack_position
    }
    static in(para*) {
        stack_position := this.get_trim_position()
        loop (stack_position - 3) {
            strim .= ">"
        }
        this.log_strim := strim
        this.log_out(para*)
    }
    static out(para*) {
        stack_position := this.get_trim_position()
        loop (stack_position - 3) {
            strim .= "<"
        }
        this.log_strim := strim
        this.log_out(para*)
    }
    static log4ahk_to_str(str) {
        rtn := ""
        if (isobject(str)) {
            rtn := JSON.stringify(str)
            rtn := strreplace(rtn, "`n")
            rtn := strreplace(rtn, " ")
        }
        else {
            try rtn := string(str)
        }
        return rtn
    }
    static strbuf(str, encoding) {
        buf := buffer(strput(str, encoding))
        strput(str, buf, encoding)
        return buf
    }
}
log4ahk_switch_console(*) {
    console4log.switch_console()
}
class console4log
{
    static switch_console() {
        if (this.IsConsoleVisible()) {
            this.hide_console()
        }
        else {
            this.show_console()
        }
    }
    static get_console_hwnd() {
        ConsoleHWnd := DllCall("GetConsoleWindow")
        return ConsoleHWnd
    }
    static hide_console() {
        DllCall("ShowWindow", "Int", this.get_console_hwnd(), "Int", 0)
    }
    static show_console() {
        DllCall("ShowWindow", "Int", this.get_console_hwnd(), "Int", 5)
    }
    static IsConsoleVisible() {
        return DllCall("IsWindowVisible", "Int", this.get_console_hwnd())
    }
}