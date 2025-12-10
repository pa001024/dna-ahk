AoJia() {
    try {
        return ComObject("AoJia.AoJiaD")
    }
    catch {
        RunWait "regsvr32 /s" NormalizePath(A_LineFile "\..\AoJia64.dll")
    }
    return ComObject("AoJia.AoJiaD")
}

NormalizePath(path) {
    cc := DllCall("GetFullPathName", "str", path, "uint", 0, "ptr", 0, "ptr", 0, "uint")
    buf := Buffer(cc * 2)
    DllCall("GetFullPathName", "str", path, "uint", cc, "ptr", buf, "ptr", 0)
    return StrGet(buf)
}

AJ := AoJia()