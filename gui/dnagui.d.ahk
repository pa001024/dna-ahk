class DNAGui {
    gui => Gui
    visible => Boolean := false
    dl_char => DropDownList
    dl_mode => DropDownList
    dl_xbtnFunc => DropDownList
    btn_mute => Checkbox
    btn_melee => Checkbox
    btn_start => Button
    ActiveXBtnFunc() => void
    Show() => void
    Close() => void
    Start() => void
    Mute() => void
    Reload() => void
    static visible() => Boolean
}