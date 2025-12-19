#Requires AutoHotkey v2.0
#SingleInstance Force
#Include <RapidOcr/RapidOcr>
#Include <wincapture/wincapture>
#Include <polyfill>
#Include <JSON>

capWindow(hwnd) {
    static wgc := 0
    if (!wgc)
        wgc := wincapture.WGC(hwnd)
    return wgc.capture(1)
}
readText(x1, y1, x2, y2, hwnd) {
    static ocr := 0
    if (!ocr)
        ocr := RapidOcr({ models: A_ScriptDir '\lib\RapidOcr\models' })
    bmp := capWindow(hwnd).range(x1, y1, x2, y2)
    ; bmp.save("debug.png") ; 仅为调试使用
    ; img := cv.imread(A_ScriptDir '\debug.png')
    ; cv.imshow('img', img)
    ; return ocr.ocr_from_file("debug.png")
    return ocr.ocr_from_bitmapdata(bmp.info)
}
; ========== 核心函数：GetCloseMatches（匹配相似文本） ==========
; 功能：Python difflib.get_close_matches 的AHK v2实现
; 参数：
;   inputText: 待匹配文本 | candidates: 候选列表(数组) | n: 返回最多n个结果 | cutoff: 相似度阈值(0-1)
; 返回：按相似度降序排列的匹配结果数组
GetCloseMatches(inputText, candidates, n := 3, cutoff := 0.1) {
    similarityList := []
    inputLen := StrLen(inputText)

    ; 遍历候选列表（A_Index从1开始，对应candidates的索引）
    for _, candidate in candidates {
        candidateLen := StrLen(candidate)
        maxLen := Max(inputLen, candidateLen)

        if (maxLen = 0 || inputText = candidate) {
            similarity := 1.0  ; 空字符串完全匹配
        } else {
            ; 计算编辑距离（核心依赖LevenshteinDistance）
            distance := LevenshteinDistance(inputText, candidate)
            similarity := 1 - (distance / maxLen)  ; 相似度（1为完全匹配）
        }

        ; 筛选符合阈值的结果
        if (similarity >= cutoff) {
            similarityList.Push({ text: candidate, similarity: similarity })
        }
    }

    ; 按相似度从高到低排序
    similarityList.Sort((a, b) => b.similarity - a.similarity)

    ; 提取前n个结果（先初始化数组，再赋值）
    resultCount := Min(n, similarityList.Length)
    result := Array.fromCount(resultCount)  ; 初始化结果数组
    Loop resultCount {
        result[A_Index] := similarityList[A_Index].text  ; 赋值已初始化的成员
    }
    return result
}

; ========== 核心辅助函数：LevenshteinDistance（计算编辑距离） ==========
LevenshteinDistance(str1, str2) {
    len1 := StrLen(str1)
    len2 := StrLen(str2)

    if (len1 = 0)
        return len2
    if (len2 = 0)
        return len1

    ; dp[row][col] with 1-based indexing
    dp := []

    ; Initialize first row (row 0 conceptually, but stored starting at index 1)
    row0 := []
    row0.Push(0) ; dp[0][0]
    loop len2 {
        row0.Push(A_Index) ; dp[0][j] = j
    }
    dp.Push(row0)

    ; Fill rest of matrix
    loop len1 {
        i := A_Index
        row := []
        row.Push(i) ; dp[i][0] = i

        char1 := SubStr(str1, i, 1)

        loop len2 {
            j := A_Index
            char2 := SubStr(str2, j, 1)

            cost := (char1 = char2) ? 0 : 1

            deletion := dp[i - 1 + 1][j + 1] + 1  ; dp[i-1][j]
            insertion := row[j - 1 + 1] + 1  ; dp[i][j-1] (current row)
            replace := dp[i - 1 + 1][j - 1 + 1] + cost

            row.Push(Min(deletion, insertion, replace))
        }
        dp.Push(row)
    }

    Min(a, b, c) {
        minVal := (a < b) ? a : b
        return (minVal < c) ? minVal : c
    }

    return dp[len1 + 1][len2 + 1]
}

httpRequest(url, method := "GET", headers := {}, data := "", userAgent :=
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0") {
    static req := comObject("WinHttp.WinHttpRequest.5.1")
    try {
        req.Open(method, url, true) ;true 表示异步
        req.SetRequestHeader("User-Agent", userAgent)
        for key in headers
            req.SetRequestHeader(key, headers[key])
        req.Send(data)
        req.WaitForResponse()
    }
    catch {
        return ""
    }
    return req.ResponseText
}

token := FileRead(A_ScriptDir "\token")

gqlQuery(url, query, data) {
    body := JSON.stringify({ query: query, variables: data })
    headers := Map()
    headers["Content-Type"] := "application/json"
    return httpRequest(url, "POST", headers, body)
}

class GrabGui {
    __New() {
        pGui := Gui("+AlwaysOnTop +DPIScale", "GrabGui")
        this.pGui := pGui

        pGui.AddText("w200 h20 x10 y10 Section", "抓取模式")
        pGui.AddButton("x8 y+12 w120 hp Section", "重新加载").OnEvent("Click", (*) => Reload())
        btn := pGui.AddButton("x+8 ys w120 hp", "开始抓取")
        btn.OnEvent("Click", (*) => this.Start())
        this.btn := btn
        pGui.Show("x16 y" . (A_ScreenHeight - 120 - 80) . "NoActivate")
        pGui.OnEvent("Close", (*) => ExitApp())
        this.cb := () => this.Grab()
    }
    Start() {
        if (this.btn.Text = "开始抓取") {
            this.btn.Text := "停止抓取"
            SetTimer(this.cb, 1000)
        } else {
            this.btn.Text := "开始抓取"
            SetTimer(this.cb, 0)
        }
    }
    Grab() {
        win := WinExist("jjj")
        if win == 0 {
            SetTimer(this.cb, 0)
            this.btn.Text := "开始抓取"
            MsgBox "窗口不存在"
            return
        }
        ControlGetPos(&cx, &cy, &cw, &ch, "subWin1", win)
        WinGetClientPos(, , &w, &h, win)
        WinGetPos(&x, &y, &wd, &hd, win)
        WinMove(x, y, 360 - w + wd, 640 - h + hd)
        miny := cy + 271
        maxy := cy + 333
        x1 := cx + 24
        x2 := cx + 95
        x3 := cx + 124
        x4 := cx + 192
        x5 := cx + 225
        x6 := cx + 293
        text1 := readText(x1, miny, x2, maxy, win).split("`n").filter(v => v).map(v => this.GetClosedMission(v))
        text2 := readText(x3, miny, x4, maxy, win).split("`n").filter(v => v).map(v => this.GetClosedMission(v))
        text3 := readText(x5, miny, x6, maxy, win).split("`n").filter(v => v).map(v => this.GetClosedMission(v))
        this.Report([text1, text2, text3])
    }
    GetClosedMission(mission) {
        MISSIONS := ["探险/无尽", "驱离", "拆解", "驱逐", "避险", "扼守/无尽", "护送", "勘探/无尽", "追缉", "调停", "迁移"]
        rst := GetCloseMatches(mission, MISSIONS, 1)
        return rst.length > 0 ? rst[1] : ""
    }
    lastReport := ""
    Report(missionsArr) {
        url := "https://xn--chq26veyq.icu/graphql"
        data := JSON.stringify({ mission: missionsArr }, 0)
        if (this.lastReport = data)
            return
        this.lastReport := data
        query := 'mutation($token:String!$missions:[[String!]!]!){addMissionsIngame(token:$token server:"cn" missions:$missions){missions createdAt}}'
        rst := gqlQuery(url, query, { token: token, missions: missionsArr })
    }
}

c := GrabGui()