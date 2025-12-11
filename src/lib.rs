use std::os::raw::{c_float, c_int};
use widestring::U16CString;
use windows::Win32::Graphics::Gdi::HBITMAP;

mod submodules;
use crate::submodules::{
    predict_rotation::{hbitmap_to_bgr_mat, predict_rotation},
    setvol::set_program_volume,
};

const DLL_PROCESS_ATTACH: u32 = 1;
const DLL_PROCESS_DETACH: u32 = 0;

// DLL 入口点 (可选)
#[unsafe(no_mangle)]
pub extern "system" fn DllMain(
    _module: isize,
    call_reason: u32,
    _reserved: *mut std::ffi::c_void,
) -> i32 {
    match call_reason {
        DLL_PROCESS_ATTACH => {
            println!("DLL 加载成功");
            1
        }
        DLL_PROCESS_DETACH => 1,
        _ => 1,
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn PredictRotation(hbitmap: HBITMAP) -> c_int {
    // Convert HBITMAP to OpenCV Mat (BGR)
    match hbitmap_to_bgr_mat(hbitmap) {
        Ok(mat_bgr) => match predict_rotation(&mat_bgr) {
            Ok(deg) => deg as c_int,
            Err(_) => -1,
        },
        Err(_) => -1,
    }
}

// 打印Unicode字符串 - 处理UTF-16字符串
#[unsafe(no_mangle)]
pub extern "C" fn println(s: *mut u16) {
    unsafe {
        if !s.is_null() {
            let str = U16CString::from_ptr_str(s).to_string_lossy();
            println!("{}", str);
        }
    }
}

// Audio API相关导入已在文件顶部定义

#[unsafe(no_mangle)]
pub extern "C" fn setProgramVolume(program_name: *const u16, volume: c_float) -> c_int {
    // 如果program_name为空，返回错误
    if program_name.is_null() {
        return -1;
    }

    // 将u16指针转换为UTF-16字符串
    let program_name_str = unsafe { U16CString::from_ptr_str(program_name).to_string_lossy() };
    // println!("尝试设置程序 '{}' 的音量为 {}", program_name_str, volume);
    set_program_volume(program_name_str.to_string(), volume)
}
