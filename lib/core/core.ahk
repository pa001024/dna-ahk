(() {
    init := DllCall('LoadLibrary', 'str', A_LineFile '\..\rust_ahk_dll.dll', 'ptr')
    if (!init)
        Throw OSError()
})()
/**
 * 设置指定程序的音量
 * @param program 程序名称
 * @param vol 音量值，范围为0-1
 */
setProgramVol(program, vol) {
    DllCall("rust_ahk_dll.dll\setProgramVol", "str", program, "float", vol)
}

/**
 * 预测图片的旋转角度
 * @param {HBITMAP} hbitmap 图片句柄
 * @returns {Integer} 预测的旋转角度
 */
PredictRotation(hbitmap) {
    return DllCall("rust_ahk_dll.dll\PredictRotation", "ptr", hbitmap, "int")
}