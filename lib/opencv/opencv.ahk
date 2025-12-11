/************************************************************************
 * @description [ahk binding for opencv](https://github.com/MonoEven/All-My-Lib/tree/main/cv2)
 * [opencv_world*.dll](https://github.com/opencv/opencv/releases)
 * @tutorial https://docs.opencv.org/4.x/index.html
 ***********************************************************************/

#Include <CGdip>


try
	ComObject("OpenCV.CV")
catch {
	(() {
		init := DllCall('LoadLibrary', 'str', A_LineFile '\..\autoit_opencv_com490.dll', 'ptr')
		if (!init)
			Throw OSError()
	})()
	DllCall("autoit_opencv_com490.dll\DllInstall", "Int", 1, "WStr", A_IsAdmin = 0 ? "user" : "", "cdecl")
}
Class None {

}


/**
 * 窗口截图并转换为Mat
 * 
 * @return {Mat}
 */
capWindowMat() {
	global hwnd
	WinGetClientPos , , &wid, &hei, hwnd
	pBits := 0
	hhdc := GetDC(hwnd)
	chdc := CreateCompatibleDC(hhdc)  ; 【调色板函数?】参数hhdc可删除
	; pBits 指向变量的指针，该变量接收指向 DIB 位值位置的指针
	hbm := CreateDIBSection(wid, hei, chdc, 24, &pBits)  ; 返回hBitmap
	obm := SelectObject(chdc, hbm)
	BitBlt(chdc, 0, 0, wid, hei, hhdc, 0, 0, 0xCC0020)
	val := (wid * 3 + 3) & -4  ; Channels := 3 ; 通道
	img := cv2.MAT_Init().create(hei, wid, 16, pBits, val)
	mat := toMat(cv2.MAT(), img.clone())
	SelectObject(chdc, obm)
	ReleaseDC(hhdc)
	DeleteObject(hbm)
	DeleteDC(hhdc)
	DeleteDC(chdc)
	return mat
}

DllCall("QueryPerformanceFrequency", "Int64*", &CLOCKS_PER_SEC := 0)

clock() {
	DllCall("QueryPerformanceCounter", "Int64*", &Time := 0)

	return Time
}

int(num) {
	return Integer(num)
}

isinstance(object, classinfo) {
	if Type(object) == "cv2.MAT"
		object := object.MAT

	return object is classinfo
}

lpcstr(pszSound) {
	return FileRead(pszSound, "RAW")
}

lstClone(Lst) {
	tmp := []

	if !(Lst is Array)
		return Lst

	For i in Lst {
		if i is Array
			tmp.Push(lstclone(i))
		else
			tmp.Push(i)
	}

	return tmp
}

matRelease(src) {
	if Type(src.MAT) == "Mat_Object" {
		Try {
			src.At.At.MAT := ""
			src.At.At := ""
			src.At := ""
		}
		src.Channels := ""
		src.Data := ""
		src.Depth := ""
		src.Shape := ""
		src.Size := ""
		src.Step1 := ""
		src.Total := ""
		src.Type := ""
	}

	src.Cols := ""
	src.Dims := ""
	src.Rows := ""

	return src
}

matToBitmap(img) {
	if img.MAT.depth !== cv2.CV_8U
		MsgBox "Unable to Change"

	if img.MAT.channels == 1
		img := cv2.cvtcolor(img, cv2.COLOR_GRAY2BGRA)
	else if img.MAT.channels == 3
		img := cv2.cvtcolor(img, cv2.COLOR_BGR2BGRA)

	si := Buffer(A_PtrSize = 8 ? 24 : 16, 0)
	NumPut("UInt", 1, si, 0)
	DllCall("gdiplus\GdiplusStartup", "Ptr*", &pToken := 0, "Ptr", si, "Ptr", 0)
	DllCall("gdiplus\GdipCreateBitmapFromScan0", "Int", img.Cols, "Int", img.Rows, "Int", img.Step1, "Int", 2498570, "Ptr", img.data, "Ptr*", &pBitmap := 0)

	return pBitmap
}

multiple(Lst, Number) {
	tmp := lstclone(Lst)

	Loop Number - 1 {
		For i in tmp
			Lst.Push(lstclone(i))
	}

	return Lst
}

noArray(uflag := 0) {

	if uflag {
		dst := cv2.UMAT()
		dst.MAT := cv2.UMAT_Init()
	}
	else {
		dst := cv2.MAT()
		dst.MAT := cv2.MAT_Init()
	}

	return dst
}

; fdwSound
NULL := 0x00
SND_ASYNC := 0x01
SND_LOOP := 0x08
SND_MEMORY := 0x04
SND_NODEFAULT := 0x02
SND_NOSTOP := 0x10
SND_SYNC := 0x00
SND_NOWAIT := 0x002000
SND_ALIAS := 0x010000
SND_ALIAS_ID := 0x110000
SND_FILENAME := 0x020000
SND_RESOURCE := 0x040004
SND_PURGE := 0x40
SND_APPLICATION := 0x80

playSound(pszSound, hmod, fdwSound) {
	if pszSound is String
		pszSound := FileRead(pszSound, "RAW")

	DllCall("winmm.dll\PlaySound", "Ptr", pszSound, "UInt", hmod, "UInt", fdwSound)
}

printc(args*) {
	str := ""

	For i in args
		str .= i

	MsgBox str
}

sprintc(args) {
	str := ""

	For i in args
		str .= i

	return str
}

printf(fs, args*) {
	MsgBox sprintf(fs, args*)
}

rand() {
	return Random(0, 32767)
}

roiMethod(src, size, value) {
	NewCols := ComObjArray(VT_VARIANT := 12, src.Cols)

	x := size[1]
	y := size[2]
	Width := size[3]
	Height := size[4]

	cropw := (value.Cols > src.Cols - x) ? src.Cols - x : value.Cols
	croph := (value.Rows > src.Rows - y) ? src.Rows - y : value.Rows

	value.MAT := value[0, 0, cropw, croph].MAT

	Loop src.Cols {
		index := A_Index - 1
		if A_Index - 1 < x || A_Index > width + x
			NewCols[A_Index - 1] := src.Col(A_Index - 1).MAT
		else {
			tmpRows := ComObjArray(VT_VARIANT := 12, src.Rows)

			Loop src.Rows {
				if A_Index - 1 < y || A_Index > height + y
					tmpRows[A_Index - 1] := src.Col(index).MAT.Row(A_Index - 1)
				else
					tmpRows[A_Index - 1] := value.Col(index - x).MAT.Row(A_Index - 1 - y)
			}

			NewCols[A_Index - 1] := cv2.CV.vconcat(tmpRows)
		}
	}

	src.MAT := cv2.CV.hconcat(NewCols)
}

scalar(args*) {
	return ComArrayMake(args)
}

GWL_EXSTYLE := -20
GWL_HINSTANCE := -6
GWL_HWNDPARENT := -8
GWL_ID := -12
GWL_STYLE := -16
GWL_USERDATA := -21
GWL_WNDPROC := -4
DWL_DLGPROC := 4
DWL_MSGRESULT := 0
DWL_USER := 8
WS_EX_ACCEPTFILES := 0x00000010
WS_EX_APPWINDOW := 0x00040000
WS_EX_CLIENTEDGE := 0x00000200
WS_EX_COMPOSITED := 0x02000000
WS_EX_CONTEXTHELP := 0x00000400
WS_EX_CONTROLPARENT := 0x00010000
WS_EX_DLGMODALFRAME := 0x00000001
WS_EX_LAYERED := 0x00080000
WS_EX_LAYOUTRTL := 0x00400000
WS_EX_LEFT := 0x00000000
WS_EX_LEFTSCROLLBAR := 0x00004000
WS_EX_LTRREADING := 0x00000000
WS_EX_MDICHILD := 0x00000040
WS_EX_NOACTIVATE := 0x08000000
WS_EX_NOINHERITLAYOUT := 0x00100000
WS_EX_NOPARENTNOTIFY := 0x00000004
WS_EX_TOOLWINDOW := 0x00000080
WS_EX_TOPMOST := 0x00000008
WS_EX_WINDOWEDGE := 0x00000100
WS_EX_OVERLAPPEDWINDOW := (WS_EX_WINDOWEDGE | WS_EX_CLIENTEDGE)
WS_EX_PALETTEWINDOW := (WS_EX_WINDOWEDGE | WS_EX_TOOLWINDOW | WS_EX_TOPMOST)
WS_EX_RIGHT := 0x00001000
WS_EX_RIGHTSCROLLBAR := 0x00000000
WS_EX_RTLREADING := 0x00002000
WS_EX_staticEDGE := 0x00020000
WS_EX_TRANSPARENT := 0x00000020
SW_HIDE := 0
SW_SHOWNORMAL := 1
SW_NORMAL := 1
SW_SHOWMINIMIZED := 2
SW_SHOWMAXIMIZED := 3
SW_MAXIMIZE := 3
SW_SHOWNOACTIVATE := 4
SW_SHOW := 5
SW_MINIMIZE := 6
SW_SHOWMINNOACTIVE := 7
SW_SHOWNA := 8
SW_RESTORE := 9
SW_SHOWDEFAULT := 10
SW_FORCEMINIMIZE := 11
SW_MAX := 11
WM_NULL := 0x0000
WM_CREATE := 0x0001
WM_DESTROY := 0x0002
WM_MOVE := 0x0003
WM_SIZE := 0x0005
WS_OVERLAPPED := 0x00000000
WS_POPUP := 0x80000000
WS_CHILD := 0x40000000
WS_MINIMIZE := 0x20000000
WS_VISIBLE := 0x10000000
WS_DISABLED := 0x08000000
WS_CLIPSIBLINGS := 0x04000000
WS_CLIPCHILDREN := 0x02000000
WS_MAXIMIZE := 0x01000000
WS_BORDER := 0x00800000
WS_DLGFRAME := 0x00400000
WS_CAPTION := WS_BORDER | WS_DLGFRAME
WS_VSCROLL := 0x00200000
WS_HSCROLL := 0x00100000
WS_SYSMENU := 0x00080000
WS_THICKFRAME := 0x00040000
WS_GROUP := 0x00020000
WS_TABSTOP := 0x00010000
setBorderless(Winhwnd) {
	dwNewLong := DllCall("GetWindowLong", "UInt", Winhwnd, "Int", GWL_EXSTYLE) | WS_EX_TOPMOST
	DllCall("SetWindowLong", "UInt", Winhwnd, "Int", GWL_STYLE, "UInt", dwNewLong)
	DllCall("ShowWindow", "UInt", Winhwnd, "UInt", SW_SHOW)
}

showBitmap(pBitmap, ShowCase := 1, img := "", title := "Default", show := 1, delete := 1) {
	if ShowCase == 1 {
		DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", "Ptr", pBitmap, "Ptr*", &hbm := 0, "Int", Background := 0xffffffff)
		MyGui := Gui()
		MyGui.Title := title
		MyGui.Add("Picture", "", "HBITMAP:" hbm)

		if show
			MyGui.Show()

		if delete {
			DllCall("DeleteObject", "Ptr", hbm)
			DllCall("gdiplus\GdipDisposeImage", "Ptr", pBitmap)
		}

		return MyGui
	}

	; Need to Include CGdip.ahk
	else if ShowCase == 2 {
		if isSet(CreateCompatibleDC) && isSet(CreateDIBSection) && isSet(SelectObject) && isSet(CGdip) && isSet(UpdateLayeredWindow) {
			hdc := CreateCompatibleDC()
			hbm := CreateDIBSection(img.Cols, img.Rows)
			obm := SelectObject(hdc, hbm)
			canvas := CGdip.Graphics.FromHDC(hdc)
			canvas.SetSmoothingMode(4)
			canvas.DrawImage(pBitmap, 0, 0, img.Cols, img.Rows, 0, 0, img.Cols, img.Rows)

			AHKGui := Gui()
			AHKGui.Title := title
			AHKGui.Opt("-Caption +E0x80000")

			if show {
				AHKGui.Show("NA")
				UpdateLayeredWindow(AHKGui.hwnd, hdc, 0, 0, img.Cols, img.Rows)
			}

			if delete {
				DllCall("DeleteDC", "Ptr", hdc)
				DllCall("DeleteObject", "Ptr", hbm)
				DllCall("DeleteObject", "Ptr", obm)
				DllCall("gdiplus\GdipDeleteGraphics", "Ptr", canvas)
				DllCall("gdiplus\GdipDisposeImage", "Ptr", pBitmap)
			}

			return AHKGui
		}
	}
}

sprintf(fs, args*) {
	if args.Length && args[1] is Array
		args := args[1]

	if RegExMatch(fs, "i)%\.(.*)LF", &Num := 0)
		return Round(args[-1], Num[1])

	if RegExMatch(fs, "i)%\.(.*)F", &Num := 0)
		return Round(args[-1], Num[1])

	fs := StrReplace(fs, "\t", "`t")
	fs := StrReplace(fs, "\n", "`n")
	fs := StrReplace(fs, "%d", "{:d}")
	fs := StrReplace(fs, "%i", "{:i}")
	fs := StrReplace(fs, "%x", "{:x}")
	fs := StrReplace(fs, "%o", "{:o}")
	fs := StrReplace(fs, "%f", "{:f}")
	fs := StrReplace(fs, "%e", "{:e}")
	fs := StrReplace(fs, "%E", "{:E}")
	fs := StrReplace(fs, "%g", "{:g}")
	fs := StrReplace(fs, "%G", "{:G}")
	fs := StrReplace(fs, "%a", "{:a}")
	fs := StrReplace(fs, "%A", "{:A}")
	fs := StrReplace(fs, "%p", "{:p}")
	fs := StrReplace(fs, "%s", "{:s}")
	fs := StrReplace(fs, "%c", "{:c}")
	s := Format(fs, args*)

	return s
}

memcpy(target, source, bytes) {
	DllCall("Ntdll\memcpy", "ptr", target, "ptr", source, "uint", bytes)
}

bitmapToMat(bmp) {
	bmp := bmp.cvtBytes(3)
	mat := cv2.MAT()
	val := (bmp.width * bmp.bytespixel + bmp.bytespixel) & -4  ; Channels := 3 ; 通道
	img := cv2.MAT_Init().create(bmp.height, bmp.width, cv2.CV_8UC3, bmp.ptr, val)
	return toMat(mat, img.clone())
}

toMat(src, img) {
	src.MAT := img

	if Type(src.MAT) == "Cv_Mat_Object" {
		src.At := cv2.MAT.At(src)
		src.Channels := src.MAT.Channels
		src.Data := src.MAT.Data
		src.Depth := src.MAT.Depth
		src.Height := src.MAT.Height
		src.Shape := [src.MAT.Rows, src.MAT.Cols, src.MAT.Channels]
		src.Size := src.MAT.Size
		src.Step1 := src.MAT.Step1
		src.Total := src.MAT.Total
		src.Type := src.MAT.Type
		src.Width := src.MAT.Width
	}

	src.Cols := src.MAT.Cols
	src.Dims := src.MAT.Dims
	src.Rows := src.MAT.Rows

	return src
}

BitShift(value, shift) {
	return shift < 0 ? value << -shift : value >> shift
}
BitOR(value1, value2) {
	return value1 | value2
}
BitAND(value1, value2) {
	return value1 & value2
}
BitXOR(value1, value2) {
	return value1 ^ value2
}
BitNOT(value) {
	return ~value
}
ComArrayMake(InputArray) {
	if Type(InputArray) == "ComObjArray"
		return InputArray

	if Type(InputArray) == "Array" {
		Arr := ComObjArray(VT_VARIANT := 12, InputArray.Length)

		Loop InputArray.Length {
			if Type(InputArray[A_Index]) == "Array"
				Arr[A_Index - 1] := ComArrayMake(InputArray[A_Index])
			else
				Arr[A_Index - 1] := InputArray[A_Index]
		}
	}
	else
		Arr := InputArray

	return Arr
}
ComArrayToArray(arr) {
	dst := []
	if Type(arr) == "ComObjArray" {
		t := ""
		Loop arr.MaxIndex() + 1
			dst.Push(arr[A_Index - 1])
	}
	return dst
}

CV_Char(Char) {
	return Ord(Char)
}

CV_Bool(InputBool) {
	return ComValue(0XB, InputBool == True ? -1 : 0)
}

CV_ConstPointConst(InputArray) {
	pts := cv2.VectorOfpoint_Init()

	Loop InputArray.Length() {
		pts.Push_Back(ComArrayMake(InputArray[A_Index]))
	}

	return pts
}

CV_ConstScalar(InputArray) {
	return ComArrayMake(InputArray)
}

CV_Double(Number) {
	NumPut("Double", fps := Number, Temp := Buffer(8))
	return fps := NumGet(Temp, "Double")
}

CV_Point(InputArray) {
	return ComArrayMake(InputArray)
}

CV_OutputArray() {
	return cv2.MAT_Init()
}

CV_Size(InputArray) {
	return ComArrayMake(InputArray)
}

class OpenCV {
	; static __New() => (cv, 0)
	static true := ComValue(0xB, -1)
	static false := ComValue(0xB, 0)
	; opencv constants namespace

	static CV_PI := 3.1415926535897932384626433832795
	static CV_2PI := 6.283185307179586476925286766559
	static CV_LOG2 := 0.69314718055994530941723212145818

	static HAL_ERROR_OK := 0
	static HAL_ERROR_NOT_IMPLEMENTED := 1
	static HAL_ERROR_UNKNOWN := -1
	static CV_CN_MAX := 512
	static CV_CN_SHIFT := 3
	static CV_DEPTH_MAX := 1 << cv2.CV_CN_SHIFT

	static CV_8U := 0
	static CV_8S := 1
	static CV_16U := 2
	static CV_16S := 3
	static CV_32S := 4
	static CV_32F := 5
	static CV_64F := 6
	static CV_16F := 7
	static MAT_DEPTH_MASK := cv2.CV_DEPTH_MAX - 1

	static CV_8UC1 := cv2.CV_MAKETYPE(cv2.CV_8U, 1)
	static CV_8UC2 := cv2.CV_MAKETYPE(cv2.CV_8U, 2)
	static CV_8UC3 := cv2.CV_MAKETYPE(cv2.CV_8U, 3)
	static CV_8UC4 := cv2.CV_MAKETYPE(cv2.CV_8U, 4)

	static CV_8SC1 := cv2.CV_MAKETYPE(cv2.CV_8S, 1)
	static CV_8SC2 := cv2.CV_MAKETYPE(cv2.CV_8S, 2)
	static CV_8SC3 := cv2.CV_MAKETYPE(cv2.CV_8S, 3)
	static CV_8SC4 := cv2.CV_MAKETYPE(cv2.CV_8S, 4)

	static CV_16UC1 := cv2.CV_MAKETYPE(cv2.CV_16U, 1)
	static CV_16UC2 := cv2.CV_MAKETYPE(cv2.CV_16U, 2)
	static CV_16UC3 := cv2.CV_MAKETYPE(cv2.CV_16U, 3)
	static CV_16UC4 := cv2.CV_MAKETYPE(cv2.CV_16U, 4)

	static CV_16SC1 := cv2.CV_MAKETYPE(cv2.CV_16S, 1)
	static CV_16SC2 := cv2.CV_MAKETYPE(cv2.CV_16S, 2)
	static CV_16SC3 := cv2.CV_MAKETYPE(cv2.CV_16S, 3)
	static CV_16SC4 := cv2.CV_MAKETYPE(cv2.CV_16S, 4)

	static CV_32SC1 := cv2.CV_MAKETYPE(cv2.CV_32S, 1)
	static CV_32SC2 := cv2.CV_MAKETYPE(cv2.CV_32S, 2)
	static CV_32SC3 := cv2.CV_MAKETYPE(cv2.CV_32S, 3)
	static CV_32SC4 := cv2.CV_MAKETYPE(cv2.CV_32S, 4)

	static CV_32FC1 := cv2.CV_MAKETYPE(cv2.CV_32F, 1)
	static CV_32FC2 := cv2.CV_MAKETYPE(cv2.CV_32F, 2)
	static CV_32FC3 := cv2.CV_MAKETYPE(cv2.CV_32F, 3)
	static CV_32FC4 := cv2.CV_MAKETYPE(cv2.CV_32F, 4)


	static CV_64FC1 := cv2.CV_MAKETYPE(cv2.CV_64F, 1)
	static CV_64FC2 := cv2.CV_MAKETYPE(cv2.CV_64F, 2)
	static CV_64FC3 := cv2.CV_MAKETYPE(cv2.CV_64F, 3)
	static CV_64FC4 := cv2.CV_MAKETYPE(cv2.CV_64F, 4)

	static CV_16FC1 := cv2.CV_MAKETYPE(cv2.CV_16F, 1)
	static CV_16FC2 := cv2.CV_MAKETYPE(cv2.CV_16F, 2)
	static CV_16FC3 := cv2.CV_MAKETYPE(cv2.CV_16F, 3)
	static CV_16FC4 := cv2.CV_MAKETYPE(cv2.CV_16F, 4)

	static HAL_CMP_EQ := 0
	static HAL_CMP_GT := 1
	static HAL_CMP_GE := 2
	static HAL_CMP_LT := 3
	static HAL_CMP_LE := 4
	static HAL_CMP_NE := 5

	static HAL_BORDER_CONSTANT := 0
	static HAL_BORDER_REPLICATE := 1
	static HAL_BORDER_REFLECT := 2
	static HAL_BORDER_WRAP := 3
	static HAL_BORDER_REFLECT_101 := 4
	static HAL_BORDER_TRANSPARENT := 5
	static HAL_BORDER_ISOLATED := 16

	static HAL_DFT_INVERSE := 1
	static HAL_DFT_SCALE := 2
	static HAL_DFT_ROWS := 4
	static HAL_DFT_COMPLEX_OUTPUT := 16
	static HAL_DFT_REAL_OUTPUT := 32
	static HAL_DFT_TWO_STAGE := 64
	static HAL_DFT_STAGE_COLS := 128
	static HAL_DFT_IS_CONTINUOUS := 512
	static HAL_DFT_IS_INPLACE := 1024

	static HAL_SVD_NO_UV := 1
	static HAL_SVD_SHORT_UV := 2
	static HAL_SVD_MODIFY_A := 4
	static HAL_SVD_FULL_UV := 8

	static HAL_GEMM_1_T := 1
	static HAL_GEMM_2_T := 2
	static HAL_GEMM_3_T := 4

	static MAT_CN_MASK := ((cv2.CV_CN_MAX - 1) << cv2.CV_CN_SHIFT)

	static MAT_TYPE_MASK := cv2.CV_DEPTH_MAX * cv2.CV_CN_MAX - 1

	static MAT_CONT_FLAG_SHIFT := 14
	static MAT_CONT_FLAG := (1 << cv2.MAT_CONT_FLAG_SHIFT)

	static SUBMAT_FLAG_SHIFT := 15
	static SUBMAT_FLAG := (1 << cv2.SUBMAT_FLAG_SHIFT)

	static MAT_DEPTH(flags)
	{
		Return flags & cv2.MAT_DEPTH_MASK
	}

	static CV_MAKETYPE(depth, cn)
	{
		Return cv2.MAT_DEPTH(depth) + (((cn) - 1) << cv2.CV_CN_SHIFT)
	}

	static CV_8UC(n)
	{
		Return cv2.CV_MAKETYPE(cv2.CV_8U, n)
	}

	static CV_8SC(n)
	{
		Return cv2.CV_MAKETYPE(cv2.CV_8S, n)
	}

	static CV_16UC(n)
	{
		Return cv2.CV_MAKETYPE(cv2.CV_16U, n)
	}

	static CV_16SC(n)
	{
		Return cv2.CV_MAKETYPE(cv2.CV_16S, n)
	}

	static CV_32SC(n)
	{
		Return cv2.CV_MAKETYPE(cv2.CV_32S, n)
	}

	static CV_32FC(n)
	{
		Return cv2.CV_MAKETYPE(cv2.CV_32F, n)
	}

	static CV_64FC(n)
	{
		Return cv2.CV_MAKETYPE(cv2.CV_64F, n)
	}

	static CV_16FC(n)
	{
		Return cv2.CV_MAKETYPE(cv2.CV_16F, n)
	}

	static MAT_CN(flags)
	{
		Return ((((flags) & cv2.MAT_CN_MASK) >> cv2.CV_CN_SHIFT) + 1)
	}

	static MAT_TYPE(flags)
	{
		Return flags & cv2.MAT_TYPE_MASK
	}

	static IS_MAT_CONT(flags)
	{
		Return flags & cv2.MAT_CONT_FLAG
	}

	static IS_SUBMAT(flags)
	{
		Return flags & cv2.SUBMAT_FLAG
	}
	static SORT_EVERY_ROW := 0
	static SORT_EVERY_COLUMN := 1
	static SORT_ASCENDING := 0
	static SORT_DESCENDING := 16

	; CovarFlags
	static COVAR_SCRAMBLED := 0
	static COVAR_NORMAL := 1
	static COVAR_USE_AVG := 2
	static COVAR_SCALE := 4
	static COVAR_ROWS := 8
	static COVAR_COLS := 16

	; KmeansFlags
	static KMEANS_RANDOM_CENTERS := 0
	static KMEANS_PP_CENTERS := 2
	static KMEANS_USE_INITIAL_LABELS := 1

	; ReduceTypes
	static REDUCE_SUM := 0
	static REDUCE_AVG := 1
	static REDUCE_MAX := 2
	static REDUCE_MIN := 3

	; RotateFlags
	static ROTATE_90_CLOCKWISE := 0
	static ROTATE_180 := 1
	static ROTATE_90_COUNTERCLOCKWISE := 2

	; Flags
	static PCA_DATA_AS_ROW := 0
	static PCA_DATA_AS_COL := 1
	static PCA_USE_AVG := 2

	; Flags
	static SVD_MODIFY_A := 1
	static SVD_NO_UV := 2
	static SVD_FULL_UV := 4

	; anonymous
	static RNG_UNIFORM := 0
	static RNG_NORMAL := 1

	; FormatType
	static FORMATTER_FMT_DEFAULT := 0
	static FORMATTER_FMT_MATLAB := 1
	static FORMATTER_FMT_CSV := 2
	static FORMATTER_FMT_PYTHON := 3
	static FORMATTER_FMT_NUMPY := 4
	static FORMATTER_FMT_C := 5

	; Param
	static PARAM_INT := 0
	static PARAM_BOOLEAN := 1
	static PARAM_REAL := 2
	static PARAM_STRING := 3
	static PARAM_MAT := 4
	static PARAM_MAT_VECTOR := 5
	static PARAM_ALGORITHM := 6
	static PARAM_FLOAT := 7
	static PARAM_UNSIGNED_INT := 8
	static PARAM_UINT64 := 9
	static PARAM_UCHAR := 11
	static PARAM_SCALAR := 12

	; Code
	static ERROR_StsOk := 0
	static ERROR_StsBackTrace := -1
	static ERROR_StsError := -2
	static ERROR_StsInternal := -3
	static ERROR_StsNoMem := -4
	static ERROR_StsBadArg := -5
	static ERROR_StsBadFunc := -6
	static ERROR_StsNoConv := -7
	static ERROR_StsAutoTrace := -8
	static ERROR_HeaderIsNull := -9
	static ERROR_BadImageSize := -10
	static ERROR_BadOffset := -11
	static ERROR_BadDataPtr := -12
	static ERROR_BadStep := -13
	static ERROR_BadModelOrChSeq := -14
	static ERROR_BadNumChannels := -15
	static ERROR_BadNumChannel1U := -16
	static ERROR_BadDepth := -17
	static ERROR_BadAlphaChannel := -18
	static ERROR_BadOrder := -19
	static ERROR_BadOrigin := -20
	static ERROR_BadAlign := -21
	static ERROR_BadCallBack := -22
	static ERROR_BadTileSize := -23
	static ERROR_BadCOI := -24
	static ERROR_BadROISize := -25
	static ERROR_MaskIsTiled := -26
	static ERROR_StsNullPtr := -27
	static ERROR_StsVecLengthErr := -28
	static ERROR_StsFilterStructContentErr := -29
	static ERROR_StsKernelStructContentErr := -30
	static ERROR_StsFilterOffsetErr := -31
	static ERROR_StsBadSize := -201
	static ERROR_StsDivByZero := -202
	static ERROR_StsInplaceNotSupported := -203
	static ERROR_StsObjectNotFound := -204
	static ERROR_StsUnmatchedFormats := -205
	static ERROR_StsBadFlag := -206
	static ERROR_StsBadPoint := -207
	static ERROR_StsBadMask := -208
	static ERROR_StsUnmatchedSizes := -209
	static ERROR_StsUnsupportedFormat := -210
	static ERROR_StsOutOfRange := -211
	static ERROR_StsParseError := -212
	static ERROR_StsNotImplemented := -213
	static ERROR_StsBadMemBlock := -214
	static ERROR_StsAssert := -215
	static ERROR_GpuNotSupported := -216
	static ERROR_GpuApiCallError := -217
	static ERROR_OpenGlNotSupported := -218
	static ERROR_OpenGlApiCallError := -219
	static ERROR_OpenCLApiCallError := -220
	static ERROR_OpenCLDoubleNotSupported := -221
	static ERROR_OpenCLInitError := -222
	static ERROR_OpenCLNoAMDBlasFft := -223

	; DecompTypes
	static DECOMP_LU := 0
	static DECOMP_SVD := 1
	static DECOMP_EIG := 2
	static DECOMP_CHOLESKY := 3
	static DECOMP_QR := 4
	static DECOMP_NORMAL := 16

	; NormTypes
	static NORM_INF := 1
	static NORM_L1 := 2
	static NORM_L2 := 4
	static NORM_L2SQR := 5
	static NORM_HAMMING := 6
	static NORM_HAMMING2 := 7
	static NORM_TYPE_MASK := 7
	static NORM_RELATIVE := 8
	static NORM_MINMAX := 32

	; CmpTypes
	static CMP_EQ := 0
	static CMP_GT := 1
	static CMP_GE := 2
	static CMP_LT := 3
	static CMP_LE := 4
	static CMP_NE := 5

	; GemmFlags
	static GEMM_1_T := 1
	static GEMM_2_T := 2
	static GEMM_3_T := 4

	; DftFlags
	static DFT_INVERSE := 1
	static DFT_SCALE := 2
	static DFT_ROWS := 4
	static DFT_COMPLEX_OUTPUT := 16
	static DFT_REAL_OUTPUT := 32
	static DFT_COMPLEX_INPUT := 64
	static DCT_INVERSE := cv2.DFT_INVERSE
	static DCT_ROWS := cv2.DFT_ROWS

	; BorderTypes
	static BORDER_CONSTANT := 0
	static BORDER_REPLICATE := 1
	static BORDER_REFLECT := 2
	static BORDER_WRAP := 3
	static BORDER_REFLECT_101 := 4
	static BORDER_TRANSPARENT := 5
	static BORDER_REFLECT101 := cv2.BORDER_REFLECT_101
	static BORDER_DEFAULT := cv2.BORDER_REFLECT_101
	static BORDER_ISOLATED := 16

	; TestOp
	static DETAIL_TEST_CUSTOM := 0
	static DETAIL_TEST_EQ := 1
	static DETAIL_TEST_NE := 2
	static DETAIL_TEST_LE := 3
	static DETAIL_TEST_LT := 4
	static DETAIL_TEST_GE := 5
	static DETAIL_TEST_GT := 6

	; AllocType
	static CUDA_HOST_MEM_PAGE_LOCKED := 1
	static CUDA_HOST_MEM_SHARED := 2
	static CUDA_HOST_MEM_WRITE_COMBINED := 4

	; CreateFlags
	static CUDA_EVENT_DEFAULT := 0x00
	static CUDA_EVENT_BLOCKING_SYNC := 0x01
	static CUDA_EVENT_DISABLE_TIMING := 0x02
	static CUDA_EVENT_INTERPROCESS := 0x04

	; FeatureSet
	static CUDA_FEATURE_SET_COMPUTE_10 := 10
	static CUDA_FEATURE_SET_COMPUTE_11 := 11
	static CUDA_FEATURE_SET_COMPUTE_12 := 12
	static CUDA_FEATURE_SET_COMPUTE_13 := 13
	static CUDA_FEATURE_SET_COMPUTE_20 := 20
	static CUDA_FEATURE_SET_COMPUTE_21 := 21
	static CUDA_FEATURE_SET_COMPUTE_30 := 30
	static CUDA_FEATURE_SET_COMPUTE_32 := 32
	static CUDA_FEATURE_SET_COMPUTE_35 := 35
	static CUDA_FEATURE_SET_COMPUTE_50 := 50
	static CUDA_GLOBAL_ATOMICS := cv2.CUDA_FEATURE_SET_COMPUTE_11
	static CUDA_SHARED_ATOMICS := cv2.CUDA_FEATURE_SET_COMPUTE_12
	static CUDA_NATIVE_DOUBLE := cv2.CUDA_FEATURE_SET_COMPUTE_13
	static CUDA_WARP_SHUFFLE_FUNCTIONS := cv2.CUDA_FEATURE_SET_COMPUTE_30
	static CUDA_DYNAMIC_PARALLELISM := cv2.CUDA_FEATURE_SET_COMPUTE_35

	; ComputeMode
	static CUDA_DEVICE_INFO_ComputeModeDefault := 0
	static CUDA_DEVICE_INFO_ComputeModeExclusive := 1
	static CUDA_DEVICE_INFO_ComputeModeProhibited := 2
	static CUDA_DEVICE_INFO_ComputeModeExclusiveProcess := 3

	; AccessFlag
	static ACCESS_READ := BitShift(1, -24)
	static ACCESS_WRITE := BitShift(1, -25)
	static ACCESS_RW := BitShift(3, -24)
	static ACCESS_MASK := cv2.ACCESS_RW
	static ACCESS_FAST := BitShift(1, -26)

	; KindFlag
	static _INPUT_ARRAY_KIND_SHIFT := 16
	static _INPUT_ARRAY_FIXED_TYPE := BitShift(0x8000, -cv2._INPUT_ARRAY_KIND_SHIFT)
	static _INPUT_ARRAY_FIXED_SIZE := BitShift(0x4000, -cv2._INPUT_ARRAY_KIND_SHIFT)
	static _INPUT_ARRAY_KIND_MASK := BitShift(31, -cv2._INPUT_ARRAY_KIND_SHIFT)
	static _INPUT_ARRAY_NONE := BitShift(0, -cv2._INPUT_ARRAY_KIND_SHIFT)
	static _INPUT_ARRAY_MAT := BitShift(1, -cv2._INPUT_ARRAY_KIND_SHIFT)
	static _INPUT_ARRAY_MATX := BitShift(2, -cv2._INPUT_ARRAY_KIND_SHIFT)
	static _INPUT_ARRAY_STD_VECTOR := BitShift(3, -cv2._INPUT_ARRAY_KIND_SHIFT)
	static _INPUT_ARRAY_STD_VECTOR_VECTOR := BitShift(4, -cv2._INPUT_ARRAY_KIND_SHIFT)
	static _INPUT_ARRAY_STD_VECTOR_MAT := BitShift(5, -cv2._INPUT_ARRAY_KIND_SHIFT)
	static _INPUT_ARRAY_EXPR := BitShift(6, -cv2._INPUT_ARRAY_KIND_SHIFT)
	static _INPUT_ARRAY_OPENGL_BUFFER := BitShift(7, -cv2._INPUT_ARRAY_KIND_SHIFT)
	static _INPUT_ARRAY_CUDA_HOST_MEM := BitShift(8, -cv2._INPUT_ARRAY_KIND_SHIFT)
	static _INPUT_ARRAY_CUDA_GPU_MAT := BitShift(9, -cv2._INPUT_ARRAY_KIND_SHIFT)
	static _INPUT_ARRAY_UMAT := BitShift(10, -cv2._INPUT_ARRAY_KIND_SHIFT)
	static _INPUT_ARRAY_STD_VECTOR_UMAT := BitShift(11, -cv2._INPUT_ARRAY_KIND_SHIFT)
	static _INPUT_ARRAY_STD_BOOL_VECTOR := BitShift(12, -cv2._INPUT_ARRAY_KIND_SHIFT)
	static _INPUT_ARRAY_STD_VECTOR_CUDA_GPU_MAT := BitShift(13, -cv2._INPUT_ARRAY_KIND_SHIFT)
	static _INPUT_ARRAY_STD_ARRAY := BitShift(14, -cv2._INPUT_ARRAY_KIND_SHIFT)
	static _INPUT_ARRAY_STD_ARRAY_MAT := BitShift(15, -cv2._INPUT_ARRAY_KIND_SHIFT)

	; DepthMask
	static _OUTPUT_ARRAY_DEPTH_MASK_8U := BitShift(1, -cv2.CV_8U)
	static _OUTPUT_ARRAY_DEPTH_MASK_8S := BitShift(1, -cv2.CV_8S)
	static _OUTPUT_ARRAY_DEPTH_MASK_16U := BitShift(1, -cv2.CV_16U)
	static _OUTPUT_ARRAY_DEPTH_MASK_16S := BitShift(1, -cv2.CV_16S)
	static _OUTPUT_ARRAY_DEPTH_MASK_32S := BitShift(1, -cv2.CV_32S)
	static _OUTPUT_ARRAY_DEPTH_MASK_32F := BitShift(1, -cv2.CV_32F)
	static _OUTPUT_ARRAY_DEPTH_MASK_64F := BitShift(1, -cv2.CV_64F)
	static _OUTPUT_ARRAY_DEPTH_MASK_16F := BitShift(1, -cv2.CV_16F)
	static _OUTPUT_ARRAY_DEPTH_MASK_ALL := (BitShift(cv2._OUTPUT_ARRAY_DEPTH_MASK_64F, -1)) - 1
	static _OUTPUT_ARRAY_DEPTH_MASK_ALL_BUT_8S := BitAND(cv2._OUTPUT_ARRAY_DEPTH_MASK_ALL, BitNOT(cv2._OUTPUT_ARRAY_DEPTH_MASK_8S))
	static _OUTPUT_ARRAY_DEPTH_MASK_ALL_16F := (BitShift(cv2._OUTPUT_ARRAY_DEPTH_MASK_16F, -1)) - 1
	static _OUTPUT_ARRAY_DEPTH_MASK_FLT := cv2._OUTPUT_ARRAY_DEPTH_MASK_32F + cv2._OUTPUT_ARRAY_DEPTH_MASK_64F

	; UMatUsageFlags
	static USAGE_DEFAULT := 0
	static USAGE_ALLOCATE_HOST_MEMORY := BitShift(1, -0)
	static USAGE_ALLOCATE_DEVICE_MEMORY := BitShift(1, -1)
	static USAGE_ALLOCATE_SHARED_MEMORY := BitShift(1, -2)
	static __UMAT_USAGE_FLAGS_32BIT := 0x7fffffff

	; MemoryFlag
	static UMAT_DATA_COPY_ON_MAP := 1
	static UMAT_DATA_HOST_COPY_OBSOLETE := 2
	static UMAT_DATA_DEVICE_COPY_OBSOLETE := 4
	static UMAT_DATA_TEMP_UMAT := 8
	static UMAT_DATA_TEMP_COPIED_UMAT := 24
	static UMAT_DATA_USER_ALLOCATED := 32
	static UMAT_DATA_DEVICE_MEM_MAPPED := 64
	static UMAT_DATA_ASYNC_CLEANUP := 128

	; anonymous
	static MAT_MAGIC_VAL := 0x42FF0000
	static MAT_AUTO_STEP := 0
	static MAT_CONTINUOUS_FLAG := cv2.MAT_CONT_FLAG
	static MAT_SUBMATRIX_FLAG := cv2.SUBMAT_FLAG
	static MAT_MAGIC_MASK := 0xFFFF0000

	; anonymous
	static UMAT_MAGIC_VAL := 0x42FF0000
	static UMAT_AUTO_STEP := 0
	static UMAT_CONTINUOUS_FLAG := cv2.MAT_CONT_FLAG
	static UMAT_SUBMATRIX_FLAG := cv2.SUBMAT_FLAG
	static UMAT_MAGIC_MASK := 0xFFFF0000
	static UMAT_TYPE_MASK := 0x00000FFF
	static UMAT_DEPTH_MASK := 7

	; anonymous
	static SPARSE_MAT_MAGIC_VAL := 0x42FD0000
	static SPARSE_MAT_MAX_DIM := 32
	static SPARSE_MAT_HASH_SCALE := 0x5bd1e995
	static SPARSE_MAT_HASH_BIT := 0x80000000

	; anonymous
	static OCL_DEVICE_TYPE_DEFAULT := (BitShift(1, -0))
	static OCL_DEVICE_TYPE_CPU := (BitShift(1, -1))
	static OCL_DEVICE_TYPE_GPU := (BitShift(1, -2))
	static OCL_DEVICE_TYPE_ACCELERATOR := (BitShift(1, -3))
	static OCL_DEVICE_TYPE_DGPU := cv2.OCL_DEVICE_TYPE_GPU + (BitShift(1, -16))
	static OCL_DEVICE_TYPE_IGPU := cv2.OCL_DEVICE_TYPE_GPU + (BitShift(1, -17))
	static OCL_DEVICE_TYPE_ALL := 0xFFFFFFFF
	static OCL_DEVICE_FP_DENORM := (BitShift(1, -0))
	static OCL_DEVICE_FP_INF_NAN := (BitShift(1, -1))
	static OCL_DEVICE_FP_ROUND_TO_NEAREST := (BitShift(1, -2))
	static OCL_DEVICE_FP_ROUND_TO_ZERO := (BitShift(1, -3))
	static OCL_DEVICE_FP_ROUND_TO_INF := (BitShift(1, -4))
	static OCL_DEVICE_FP_FMA := (BitShift(1, -5))
	static OCL_DEVICE_FP_SOFT_FLOAT := (BitShift(1, -6))
	static OCL_DEVICE_FP_CORRECTLY_ROUNDED_DIVIDE_SQRT := (BitShift(1, -7))
	static OCL_DEVICE_EXEC_KERNEL := (BitShift(1, -0))
	static OCL_DEVICE_EXEC_NATIVE_KERNEL := (BitShift(1, -1))
	static OCL_DEVICE_NO_CACHE := 0
	static OCL_DEVICE_READ_ONLY_CACHE := 1
	static OCL_DEVICE_READ_WRITE_CACHE := 2
	static OCL_DEVICE_NO_LOCAL_MEM := 0
	static OCL_DEVICE_LOCAL_IS_LOCAL := 1
	static OCL_DEVICE_LOCAL_IS_GLOBAL := 2
	static OCL_DEVICE_UNKNOWN_VENDOR := 0
	static OCL_DEVICE_VENDOR_AMD := 1
	static OCL_DEVICE_VENDOR_INTEL := 2
	static OCL_DEVICE_VENDOR_NVIDIA := 3

	; anonymous
	static OCL_KERNEL_ARG_LOCAL := 1
	static OCL_KERNEL_ARG_READ_ONLY := 2
	static OCL_KERNEL_ARG_WRITE_ONLY := 4
	static OCL_KERNEL_ARG_READ_WRITE := 6
	static OCL_KERNEL_ARG_CONSTANT := 8
	static OCL_KERNEL_ARG_PTR_ONLY := 16
	static OCL_KERNEL_ARG_NO_SIZE := 256

	; OclVectorStrategy
	static OCL_OCL_VECTOR_OWN := 0
	static OCL_OCL_VECTOR_MAX := 1
	static OCL_OCL_VECTOR_DEFAULT := cv2.OCL_OCL_VECTOR_OWN

	; Target
	static OGL_BUFFER_ARRAY_BUFFER := 0x8892
	static OGL_BUFFER_ELEMENT_ARRAY_BUFFER := 0x8893
	static OGL_BUFFER_PIXEL_PACK_BUFFER := 0x88EB
	static OGL_BUFFER_PIXEL_UNPACK_BUFFER := 0x88EC

	; Access
	static OGL_BUFFER_READ_ONLY := 0x88B8
	static OGL_BUFFER_WRITE_ONLY := 0x88B9
	static OGL_BUFFER_READ_WRITE := 0x88BA

	; Format
	static OGL_TEXTURE2D_NONE := 0
	static OGL_TEXTURE2D_DEPTH_COMPONENT := 0x1902
	static OGL_TEXTURE2D_RGB := 0x1907
	static OGL_TEXTURE2D_RGBA := 0x1908

	; RenderModes
	static OGL_POINTS := 0x0000
	static OGL_LINES := 0x0001
	static OGL_LINE_LOOP := 0x0002
	static OGL_LINE_STRIP := 0x0003
	static OGL_TRIANGLES := 0x0004
	static OGL_TRIANGLE_STRIP := 0x0005
	static OGL_TRIANGLE_FAN := 0x0006
	static OGL_QUADS := 0x0007
	static OGL_QUAD_STRIP := 0x0008
	static OGL_POLYGON := 0x0009

	; SolveLPResult
	static SOLVELP_UNBOUNDED := -2
	static SOLVELP_UNFEASIBLE := -1
	static SOLVELP_SINGLE := 0
	static SOLVELP_MULTI := 1

	; Mode
	static FILE_STORAGE_READ := 0
	static FILE_STORAGE_WRITE := 1
	static FILE_STORAGE_APPEND := 2
	static FILE_STORAGE_MEMORY := 4
	static FILE_STORAGE_FORMAT_MASK := (BitShift(7, -3))
	static FILE_STORAGE_FORMAT_AUTO := 0
	static FILE_STORAGE_FORMAT_XML := (BitShift(1, -3))
	static FILE_STORAGE_FORMAT_YAML := (BitShift(2, -3))
	static FILE_STORAGE_FORMAT_JSON := (BitShift(3, -3))
	static FILE_STORAGE_BASE64 := 64
	static FILE_STORAGE_WRITE_BASE64 := BitOR(cv2.FILE_STORAGE_BASE64, cv2.FILE_STORAGE_WRITE)

	; State
	static FILE_STORAGE_UNDEFINED := 0
	static FILE_STORAGE_VALUE_EXPECTED := 1
	static FILE_STORAGE_NAME_EXPECTED := 2
	static FILE_STORAGE_INSIDE_MAP := 4

	; anonymous
	static FILE_NODE_NONE := 0
	static FILE_NODE_INT := 1
	static FILE_NODE_REAL := 2
	static FILE_NODE_FLOAT := cv2.FILE_NODE_REAL
	static FILE_NODE_STR := 3
	static FILE_NODE_STRING := cv2.FILE_NODE_STR
	static FILE_NODE_SEQ := 4
	static FILE_NODE_MAP := 5
	static FILE_NODE_TYPE_MASK := 7
	static FILE_NODE_FLOW := 8
	static FILE_NODE_UNIFORM := 8
	static FILE_NODE_EMPTY := 16
	static FILE_NODE_NAMED := 32

	; QuatAssumeType
	static QUAT_ASSUME_NOT_UNIT := 0
	static QUAT_ASSUME_UNIT := 1

	; EulerAnglesType
	static QUAT_ENUM_INT_XYZ := 0
	static QUAT_ENUM_INT_XZY := 1
	static QUAT_ENUM_INT_YXZ := 2
	static QUAT_ENUM_INT_YZX := 3
	static QUAT_ENUM_INT_ZXY := 4
	static QUAT_ENUM_INT_ZYX := 5
	static QUAT_ENUM_INT_XYX := 6
	static QUAT_ENUM_INT_XZX := 7
	static QUAT_ENUM_INT_YXY := 8
	static QUAT_ENUM_INT_YZY := 9
	static QUAT_ENUM_INT_ZXZ := 10
	static QUAT_ENUM_INT_ZYZ := 11
	static QUAT_ENUM_EXT_XYZ := 12
	static QUAT_ENUM_EXT_XZY := 13
	static QUAT_ENUM_EXT_YXZ := 14
	static QUAT_ENUM_EXT_YZX := 15
	static QUAT_ENUM_EXT_ZXY := 16
	static QUAT_ENUM_EXT_ZYX := 17
	static QUAT_ENUM_EXT_XYX := 18
	static QUAT_ENUM_EXT_XZX := 19
	static QUAT_ENUM_EXT_YXY := 20
	static QUAT_ENUM_EXT_YZY := 21
	static QUAT_ENUM_EXT_ZXZ := 22
	static QUAT_ENUM_EXT_ZYZ := 23
	static QUAT_ENUM_EULER_ANGLES_MAX_VALUE := 24

	; Type
	static TERM_CRITERIA_COUNT := 1
	static TERM_CRITERIA_MAX_ITER := cv2.TERM_CRITERIA_COUNT
	static TERM_CRITERIA_EPS := 2

	; FlannIndexType
	static FLANN_FLANN_INDEX_TYPE_8U := cv2.CV_8U
	static FLANN_FLANN_INDEX_TYPE_8S := cv2.CV_8S
	static FLANN_FLANN_INDEX_TYPE_16U := cv2.CV_16U
	static FLANN_FLANN_INDEX_TYPE_16S := cv2.CV_16S
	static FLANN_FLANN_INDEX_TYPE_32S := cv2.CV_32S
	static FLANN_FLANN_INDEX_TYPE_32F := cv2.CV_32F
	static FLANN_FLANN_INDEX_TYPE_64F := cv2.CV_64F
	static FLANN_FLANN_INDEX_TYPE_STRING := cv2.CV_64F + 1
	static FLANN_FLANN_INDEX_TYPE_BOOL := cv2.CV_64F + 2
	static FLANN_FLANN_INDEX_TYPE_ALGORITHM := cv2.CV_64F + 3
	static FLANN_LAST_VALUE_FLANN_INDEX_TYPE := cv2.FLANN_FLANN_INDEX_TYPE_ALGORITHM

	; SpecialFilter
	static FILTER_SCHARR := -1

	; MorphTypes
	static MORPH_ERODE := 0
	static MORPH_DILATE := 1
	static MORPH_OPEN := 2
	static MORPH_CLOSE := 3
	static MORPH_GRADIENT := 4
	static MORPH_TOPHAT := 5
	static MORPH_BLACKHAT := 6
	static MORPH_HITMISS := 7

	; MorphShapes
	static MORPH_RECT := 0
	static MORPH_CROSS := 1
	static MORPH_ELLIPSE := 2

	; InterpolationFlags
	static INTER_NEAREST := 0
	static INTER_LINEAR := 1
	static INTER_CUBIC := 2
	static INTER_AREA := 3
	static INTER_LANCZOS4 := 4
	static INTER_LINEAR_EXACT := 5
	static INTER_NEAREST_EXACT := 6
	static INTER_MAX := 7
	static WARP_FILL_OUTLIERS := 8
	static WARP_INVERSE_MAP := 16

	; WarpPolarMode
	static WARP_POLAR_LINEAR := 0
	static WARP_POLAR_LOG := 256

	; InterpolationMasks
	static INTER_BITS := 5
	static INTER_BITS2 := cv2.INTER_BITS * 2
	static INTER_TAB_SIZE := BitShift(1, -cv2.INTER_BITS)
	static INTER_TAB_SIZE2 := cv2.INTER_TAB_SIZE * cv2.INTER_TAB_SIZE

	; DistanceTypes
	static DIST_USER := -1
	static DIST_L1 := 1
	static DIST_L2 := 2
	static DIST_C := 3
	static DIST_L12 := 4
	static DIST_FAIR := 5
	static DIST_WELSCH := 6
	static DIST_HUBER := 7

	; DistanceTransformMasks
	static DIST_MASK_3 := 3
	static DIST_MASK_5 := 5
	static DIST_MASK_PRECISE := 0

	; ThresholdTypes
	static THRESH_BINARY := 0
	static THRESH_BINARY_INV := 1
	static THRESH_TRUNC := 2
	static THRESH_TOZERO := 3
	static THRESH_TOZERO_INV := 4
	static THRESH_MASK := 7
	static THRESH_OTSU := 8
	static THRESH_TRIANGLE := 16

	; AdaptiveThresholdTypes
	static ADAPTIVE_THRESH_MEAN_C := 0
	static ADAPTIVE_THRESH_GAUSSIAN_C := 1

	; GrabCutClasses
	static GC_BGD := 0
	static GC_FGD := 1
	static GC_PR_BGD := 2
	static GC_PR_FGD := 3

	; GrabCutModes
	static GC_INIT_WITH_RECT := 0
	static GC_INIT_WITH_MASK := 1
	static GC_EVAL := 2
	static GC_EVAL_FREEZE_MODEL := 3

	; DistanceTransformLabelTypes
	static DIST_LABEL_CCOMP := 0
	static DIST_LABEL_PIXEL := 1

	; FloodFillFlags
	static FLOODFILL_FIXED_RANGE := BitShift(1, -16)
	static FLOODFILL_MASK_ONLY := BitShift(1, -17)

	; ConnectedComponentsTypes
	static CC_STAT_LEFT := 0
	static CC_STAT_TOP := 1
	static CC_STAT_WIDTH := 2
	static CC_STAT_HEIGHT := 3
	static CC_STAT_AREA := 4
	static CC_STAT_MAX := 5

	; ConnectedComponentsAlgorithmsTypes
	static CCL_DEFAULT := -1
	static CCL_WU := 0
	static CCL_GRANA := 1
	static CCL_BOLELLI := 2
	static CCL_SAUF := 3
	static CCL_BBDT := 4
	static CCL_SPAGHETTI := 5

	; RetrievalModes
	static RETR_EXTERNAL := 0
	static RETR_LIST := 1
	static RETR_CCOMP := 2
	static RETR_TREE := 3
	static RETR_FLOODFILL := 4

	; ContourApproximationModes
	static CHAIN_APPROX_NONE := 1
	static CHAIN_APPROX_SIMPLE := 2
	static CHAIN_APPROX_TC89_L1 := 3
	static CHAIN_APPROX_TC89_KCOS := 4

	; ShapeMatchModes
	static CONTOURS_MATCH_I1 := 1
	static CONTOURS_MATCH_I2 := 2
	static CONTOURS_MATCH_I3 := 3

	; HoughModes
	static HOUGH_STANDARD := 0
	static HOUGH_PROBABILISTIC := 1
	static HOUGH_MULTI_SCALE := 2
	static HOUGH_GRADIENT := 3
	static HOUGH_GRADIENT_ALT := 4

	; LineSegmentDetectorModes
	static LSD_REFINE_NONE := 0
	static LSD_REFINE_STD := 1
	static LSD_REFINE_ADV := 2

	; HistCompMethods
	static HISTCMP_CORREL := 0
	static HISTCMP_CHISQR := 1
	static HISTCMP_INTERSECT := 2
	static HISTCMP_BHATTACHARYYA := 3
	static HISTCMP_HELLINGER := cv2.HISTCMP_BHATTACHARYYA
	static HISTCMP_CHISQR_ALT := 4
	static HISTCMP_KL_DIV := 5

	; ColorConversionCodes
	static COLOR_BGR2BGRA := 0
	static COLOR_RGB2RGBA := cv2.COLOR_BGR2BGRA
	static COLOR_BGRA2BGR := 1
	static COLOR_RGBA2RGB := cv2.COLOR_BGRA2BGR
	static COLOR_BGR2RGBA := 2
	static COLOR_RGB2BGRA := cv2.COLOR_BGR2RGBA
	static COLOR_RGBA2BGR := 3
	static COLOR_BGRA2RGB := cv2.COLOR_RGBA2BGR
	static COLOR_BGR2RGB := 4
	static COLOR_RGB2BGR := cv2.COLOR_BGR2RGB
	static COLOR_BGRA2RGBA := 5
	static COLOR_RGBA2BGRA := cv2.COLOR_BGRA2RGBA
	static COLOR_BGR2GRAY := 6
	static COLOR_RGB2GRAY := 7
	static COLOR_GRAY2BGR := 8
	static COLOR_GRAY2RGB := cv2.COLOR_GRAY2BGR
	static COLOR_GRAY2BGRA := 9
	static COLOR_GRAY2RGBA := cv2.COLOR_GRAY2BGRA
	static COLOR_BGRA2GRAY := 10
	static COLOR_RGBA2GRAY := 11
	static COLOR_BGR2BGR565 := 12
	static COLOR_RGB2BGR565 := 13
	static COLOR_BGR5652BGR := 14
	static COLOR_BGR5652RGB := 15
	static COLOR_BGRA2BGR565 := 16
	static COLOR_RGBA2BGR565 := 17
	static COLOR_BGR5652BGRA := 18
	static COLOR_BGR5652RGBA := 19
	static COLOR_GRAY2BGR565 := 20
	static COLOR_BGR5652GRAY := 21
	static COLOR_BGR2BGR555 := 22
	static COLOR_RGB2BGR555 := 23
	static COLOR_BGR5552BGR := 24
	static COLOR_BGR5552RGB := 25
	static COLOR_BGRA2BGR555 := 26
	static COLOR_RGBA2BGR555 := 27
	static COLOR_BGR5552BGRA := 28
	static COLOR_BGR5552RGBA := 29
	static COLOR_GRAY2BGR555 := 30
	static COLOR_BGR5552GRAY := 31
	static COLOR_BGR2XYZ := 32
	static COLOR_RGB2XYZ := 33
	static COLOR_XYZ2BGR := 34
	static COLOR_XYZ2RGB := 35
	static COLOR_BGR2YCrCb := 36
	static COLOR_RGB2YCrCb := 37
	static COLOR_YCrCb2BGR := 38
	static COLOR_YCrCb2RGB := 39
	static COLOR_BGR2HSV := 40
	static COLOR_RGB2HSV := 41
	static COLOR_BGR2Lab := 44
	static COLOR_RGB2Lab := 45
	static COLOR_BGR2Luv := 50
	static COLOR_RGB2Luv := 51
	static COLOR_BGR2HLS := 52
	static COLOR_RGB2HLS := 53
	static COLOR_HSV2BGR := 54
	static COLOR_HSV2RGB := 55
	static COLOR_Lab2BGR := 56
	static COLOR_Lab2RGB := 57
	static COLOR_Luv2BGR := 58
	static COLOR_Luv2RGB := 59
	static COLOR_HLS2BGR := 60
	static COLOR_HLS2RGB := 61
	static COLOR_BGR2HSV_FULL := 66
	static COLOR_RGB2HSV_FULL := 67
	static COLOR_BGR2HLS_FULL := 68
	static COLOR_RGB2HLS_FULL := 69
	static COLOR_HSV2BGR_FULL := 70
	static COLOR_HSV2RGB_FULL := 71
	static COLOR_HLS2BGR_FULL := 72
	static COLOR_HLS2RGB_FULL := 73
	static COLOR_LBGR2Lab := 74
	static COLOR_LRGB2Lab := 75
	static COLOR_LBGR2Luv := 76
	static COLOR_LRGB2Luv := 77
	static COLOR_Lab2LBGR := 78
	static COLOR_Lab2LRGB := 79
	static COLOR_Luv2LBGR := 80
	static COLOR_Luv2LRGB := 81
	static COLOR_BGR2YUV := 82
	static COLOR_RGB2YUV := 83
	static COLOR_YUV2BGR := 84
	static COLOR_YUV2RGB := 85
	static COLOR_YUV2RGB_NV12 := 90
	static COLOR_YUV2BGR_NV12 := 91
	static COLOR_YUV2RGB_NV21 := 92
	static COLOR_YUV2BGR_NV21 := 93
	static COLOR_YUV420sp2RGB := cv2.COLOR_YUV2RGB_NV21
	static COLOR_YUV420sp2BGR := cv2.COLOR_YUV2BGR_NV21
	static COLOR_YUV2RGBA_NV12 := 94
	static COLOR_YUV2BGRA_NV12 := 95
	static COLOR_YUV2RGBA_NV21 := 96
	static COLOR_YUV2BGRA_NV21 := 97
	static COLOR_YUV420sp2RGBA := cv2.COLOR_YUV2RGBA_NV21
	static COLOR_YUV420sp2BGRA := cv2.COLOR_YUV2BGRA_NV21
	static COLOR_YUV2RGB_YV12 := 98
	static COLOR_YUV2BGR_YV12 := 99
	static COLOR_YUV2RGB_IYUV := 100
	static COLOR_YUV2BGR_IYUV := 101
	static COLOR_YUV2RGB_I420 := cv2.COLOR_YUV2RGB_IYUV
	static COLOR_YUV2BGR_I420 := cv2.COLOR_YUV2BGR_IYUV
	static COLOR_YUV420p2RGB := cv2.COLOR_YUV2RGB_YV12
	static COLOR_YUV420p2BGR := cv2.COLOR_YUV2BGR_YV12
	static COLOR_YUV2RGBA_YV12 := 102
	static COLOR_YUV2BGRA_YV12 := 103
	static COLOR_YUV2RGBA_IYUV := 104
	static COLOR_YUV2BGRA_IYUV := 105
	static COLOR_YUV2RGBA_I420 := cv2.COLOR_YUV2RGBA_IYUV
	static COLOR_YUV2BGRA_I420 := cv2.COLOR_YUV2BGRA_IYUV
	static COLOR_YUV420p2RGBA := cv2.COLOR_YUV2RGBA_YV12
	static COLOR_YUV420p2BGRA := cv2.COLOR_YUV2BGRA_YV12
	static COLOR_YUV2GRAY_420 := 106
	static COLOR_YUV2GRAY_NV21 := cv2.COLOR_YUV2GRAY_420
	static COLOR_YUV2GRAY_NV12 := cv2.COLOR_YUV2GRAY_420
	static COLOR_YUV2GRAY_YV12 := cv2.COLOR_YUV2GRAY_420
	static COLOR_YUV2GRAY_IYUV := cv2.COLOR_YUV2GRAY_420
	static COLOR_YUV2GRAY_I420 := cv2.COLOR_YUV2GRAY_420
	static COLOR_YUV420sp2GRAY := cv2.COLOR_YUV2GRAY_420
	static COLOR_YUV420p2GRAY := cv2.COLOR_YUV2GRAY_420
	static COLOR_YUV2RGB_UYVY := 107
	static COLOR_YUV2BGR_UYVY := 108
	static COLOR_YUV2RGB_Y422 := cv2.COLOR_YUV2RGB_UYVY
	static COLOR_YUV2BGR_Y422 := cv2.COLOR_YUV2BGR_UYVY
	static COLOR_YUV2RGB_UYNV := cv2.COLOR_YUV2RGB_UYVY
	static COLOR_YUV2BGR_UYNV := cv2.COLOR_YUV2BGR_UYVY
	static COLOR_YUV2RGBA_UYVY := 111
	static COLOR_YUV2BGRA_UYVY := 112
	static COLOR_YUV2RGBA_Y422 := cv2.COLOR_YUV2RGBA_UYVY
	static COLOR_YUV2BGRA_Y422 := cv2.COLOR_YUV2BGRA_UYVY
	static COLOR_YUV2RGBA_UYNV := cv2.COLOR_YUV2RGBA_UYVY
	static COLOR_YUV2BGRA_UYNV := cv2.COLOR_YUV2BGRA_UYVY
	static COLOR_YUV2RGB_YUY2 := 115
	static COLOR_YUV2BGR_YUY2 := 116
	static COLOR_YUV2RGB_YVYU := 117
	static COLOR_YUV2BGR_YVYU := 118
	static COLOR_YUV2RGB_YUYV := cv2.COLOR_YUV2RGB_YUY2
	static COLOR_YUV2BGR_YUYV := cv2.COLOR_YUV2BGR_YUY2
	static COLOR_YUV2RGB_YUNV := cv2.COLOR_YUV2RGB_YUY2
	static COLOR_YUV2BGR_YUNV := cv2.COLOR_YUV2BGR_YUY2
	static COLOR_YUV2RGBA_YUY2 := 119
	static COLOR_YUV2BGRA_YUY2 := 120
	static COLOR_YUV2RGBA_YVYU := 121
	static COLOR_YUV2BGRA_YVYU := 122
	static COLOR_YUV2RGBA_YUYV := cv2.COLOR_YUV2RGBA_YUY2
	static COLOR_YUV2BGRA_YUYV := cv2.COLOR_YUV2BGRA_YUY2
	static COLOR_YUV2RGBA_YUNV := cv2.COLOR_YUV2RGBA_YUY2
	static COLOR_YUV2BGRA_YUNV := cv2.COLOR_YUV2BGRA_YUY2
	static COLOR_YUV2GRAY_UYVY := 123
	static COLOR_YUV2GRAY_YUY2 := 124
	static COLOR_YUV2GRAY_Y422 := cv2.COLOR_YUV2GRAY_UYVY
	static COLOR_YUV2GRAY_UYNV := cv2.COLOR_YUV2GRAY_UYVY
	static COLOR_YUV2GRAY_YVYU := cv2.COLOR_YUV2GRAY_YUY2
	static COLOR_YUV2GRAY_YUYV := cv2.COLOR_YUV2GRAY_YUY2
	static COLOR_YUV2GRAY_YUNV := cv2.COLOR_YUV2GRAY_YUY2
	static COLOR_RGBA2mRGBA := 125
	static COLOR_mRGBA2RGBA := 126
	static COLOR_RGB2YUV_I420 := 127
	static COLOR_BGR2YUV_I420 := 128
	static COLOR_RGB2YUV_IYUV := cv2.COLOR_RGB2YUV_I420
	static COLOR_BGR2YUV_IYUV := cv2.COLOR_BGR2YUV_I420
	static COLOR_RGBA2YUV_I420 := 129
	static COLOR_BGRA2YUV_I420 := 130
	static COLOR_RGBA2YUV_IYUV := cv2.COLOR_RGBA2YUV_I420
	static COLOR_BGRA2YUV_IYUV := cv2.COLOR_BGRA2YUV_I420
	static COLOR_RGB2YUV_YV12 := 131
	static COLOR_BGR2YUV_YV12 := 132
	static COLOR_RGBA2YUV_YV12 := 133
	static COLOR_BGRA2YUV_YV12 := 134
	static COLOR_BayerBG2BGR := 46
	static COLOR_BayerGB2BGR := 47
	static COLOR_BayerRG2BGR := 48
	static COLOR_BayerGR2BGR := 49
	static COLOR_BayerRGGB2BGR := cv2.COLOR_BayerBG2BGR
	static COLOR_BayerGRBG2BGR := cv2.COLOR_BayerGB2BGR
	static COLOR_BayerBGGR2BGR := cv2.COLOR_BayerRG2BGR
	static COLOR_BayerGBRG2BGR := cv2.COLOR_BayerGR2BGR
	static COLOR_BayerRGGB2RGB := cv2.COLOR_BayerBGGR2BGR
	static COLOR_BayerGRBG2RGB := cv2.COLOR_BayerGBRG2BGR
	static COLOR_BayerBGGR2RGB := cv2.COLOR_BayerRGGB2BGR
	static COLOR_BayerGBRG2RGB := cv2.COLOR_BayerGRBG2BGR
	static COLOR_BayerBG2RGB := cv2.COLOR_BayerRG2BGR
	static COLOR_BayerGB2RGB := cv2.COLOR_BayerGR2BGR
	static COLOR_BayerRG2RGB := cv2.COLOR_BayerBG2BGR
	static COLOR_BayerGR2RGB := cv2.COLOR_BayerGB2BGR
	static COLOR_BayerBG2GRAY := 86
	static COLOR_BayerGB2GRAY := 87
	static COLOR_BayerRG2GRAY := 88
	static COLOR_BayerGR2GRAY := 89
	static COLOR_BayerRGGB2GRAY := cv2.COLOR_BayerBG2GRAY
	static COLOR_BayerGRBG2GRAY := cv2.COLOR_BayerGB2GRAY
	static COLOR_BayerBGGR2GRAY := cv2.COLOR_BayerRG2GRAY
	static COLOR_BayerGBRG2GRAY := cv2.COLOR_BayerGR2GRAY
	static COLOR_BayerBG2BGR_VNG := 62
	static COLOR_BayerGB2BGR_VNG := 63
	static COLOR_BayerRG2BGR_VNG := 64
	static COLOR_BayerGR2BGR_VNG := 65
	static COLOR_BayerRGGB2BGR_VNG := cv2.COLOR_BayerBG2BGR_VNG
	static COLOR_BayerGRBG2BGR_VNG := cv2.COLOR_BayerGB2BGR_VNG
	static COLOR_BayerBGGR2BGR_VNG := cv2.COLOR_BayerRG2BGR_VNG
	static COLOR_BayerGBRG2BGR_VNG := cv2.COLOR_BayerGR2BGR_VNG
	static COLOR_BayerRGGB2RGB_VNG := cv2.COLOR_BayerBGGR2BGR_VNG
	static COLOR_BayerGRBG2RGB_VNG := cv2.COLOR_BayerGBRG2BGR_VNG
	static COLOR_BayerBGGR2RGB_VNG := cv2.COLOR_BayerRGGB2BGR_VNG
	static COLOR_BayerGBRG2RGB_VNG := cv2.COLOR_BayerGRBG2BGR_VNG
	static COLOR_BayerBG2RGB_VNG := cv2.COLOR_BayerRG2BGR_VNG
	static COLOR_BayerGB2RGB_VNG := cv2.COLOR_BayerGR2BGR_VNG
	static COLOR_BayerRG2RGB_VNG := cv2.COLOR_BayerBG2BGR_VNG
	static COLOR_BayerGR2RGB_VNG := cv2.COLOR_BayerGB2BGR_VNG
	static COLOR_BayerBG2BGR_EA := 135
	static COLOR_BayerGB2BGR_EA := 136
	static COLOR_BayerRG2BGR_EA := 137
	static COLOR_BayerGR2BGR_EA := 138
	static COLOR_BayerRGGB2BGR_EA := cv2.COLOR_BayerBG2BGR_EA
	static COLOR_BayerGRBG2BGR_EA := cv2.COLOR_BayerGB2BGR_EA
	static COLOR_BayerBGGR2BGR_EA := cv2.COLOR_BayerRG2BGR_EA
	static COLOR_BayerGBRG2BGR_EA := cv2.COLOR_BayerGR2BGR_EA
	static COLOR_BayerRGGB2RGB_EA := cv2.COLOR_BayerBGGR2BGR_EA
	static COLOR_BayerGRBG2RGB_EA := cv2.COLOR_BayerGBRG2BGR_EA
	static COLOR_BayerBGGR2RGB_EA := cv2.COLOR_BayerRGGB2BGR_EA
	static COLOR_BayerGBRG2RGB_EA := cv2.COLOR_BayerGRBG2BGR_EA
	static COLOR_BayerBG2RGB_EA := cv2.COLOR_BayerRG2BGR_EA
	static COLOR_BayerGB2RGB_EA := cv2.COLOR_BayerGR2BGR_EA
	static COLOR_BayerRG2RGB_EA := cv2.COLOR_BayerBG2BGR_EA
	static COLOR_BayerGR2RGB_EA := cv2.COLOR_BayerGB2BGR_EA
	static COLOR_BayerBG2BGRA := 139
	static COLOR_BayerGB2BGRA := 140
	static COLOR_BayerRG2BGRA := 141
	static COLOR_BayerGR2BGRA := 142
	static COLOR_BayerRGGB2BGRA := cv2.COLOR_BayerBG2BGRA
	static COLOR_BayerGRBG2BGRA := cv2.COLOR_BayerGB2BGRA
	static COLOR_BayerBGGR2BGRA := cv2.COLOR_BayerRG2BGRA
	static COLOR_BayerGBRG2BGRA := cv2.COLOR_BayerGR2BGRA
	static COLOR_BayerRGGB2RGBA := cv2.COLOR_BayerBGGR2BGRA
	static COLOR_BayerGRBG2RGBA := cv2.COLOR_BayerGBRG2BGRA
	static COLOR_BayerBGGR2RGBA := cv2.COLOR_BayerRGGB2BGRA
	static COLOR_BayerGBRG2RGBA := cv2.COLOR_BayerGRBG2BGRA
	static COLOR_BayerBG2RGBA := cv2.COLOR_BayerRG2BGRA
	static COLOR_BayerGB2RGBA := cv2.COLOR_BayerGR2BGRA
	static COLOR_BayerRG2RGBA := cv2.COLOR_BayerBG2BGRA
	static COLOR_BayerGR2RGBA := cv2.COLOR_BayerGB2BGRA
	static COLOR_COLORCVT_MAX := 143

	; RectanglesIntersectTypes
	static INTERSECT_NONE := 0
	static INTERSECT_PARTIAL := 1
	static INTERSECT_FULL := 2

	; LineTypes
	static FILLED := -1
	static LINE_4 := 4
	static LINE_8 := 8
	static LINE_AA := 16

	; HersheyFonts
	static FONT_HERSHEY_SIMPLEX := 0
	static FONT_HERSHEY_PLAIN := 1
	static FONT_HERSHEY_DUPLEX := 2
	static FONT_HERSHEY_COMPLEX := 3
	static FONT_HERSHEY_TRIPLEX := 4
	static FONT_HERSHEY_COMPLEX_SMALL := 5
	static FONT_HERSHEY_SCRIPT_SIMPLEX := 6
	static FONT_HERSHEY_SCRIPT_COMPLEX := 7
	static FONT_ITALIC := 16

	; MarkerTypes
	static MARKER_CROSS := 0
	static MARKER_TILTED_CROSS := 1
	static MARKER_STAR := 2
	static MARKER_DIAMOND := 3
	static MARKER_SQUARE := 4
	static MARKER_TRIANGLE_UP := 5
	static MARKER_TRIANGLE_DOWN := 6

	; anonymous
	static SUBDIV2D_PTLOC_ERROR := -2
	static SUBDIV2D_PTLOC_OUTSIDE_RECT := -1
	static SUBDIV2D_PTLOC_INSIDE := 0
	static SUBDIV2D_PTLOC_VERTEX := 1
	static SUBDIV2D_PTLOC_ON_EDGE := 2
	static SUBDIV2D_NEXT_AROUND_ORG := 0x00
	static SUBDIV2D_NEXT_AROUND_DST := 0x22
	static SUBDIV2D_PREV_AROUND_ORG := 0x11
	static SUBDIV2D_PREV_AROUND_DST := 0x33
	static SUBDIV2D_NEXT_AROUND_LEFT := 0x13
	static SUBDIV2D_NEXT_AROUND_RIGHT := 0x31
	static SUBDIV2D_PREV_AROUND_LEFT := 0x20
	static SUBDIV2D_PREV_AROUND_RIGHT := 0x02

	; TemplateMatchModes
	static TM_SQDIFF := 0
	static TM_SQDIFF_NORMED := 1
	static TM_CCORR := 2
	static TM_CCORR_NORMED := 3
	static TM_CCOEFF := 4
	static TM_CCOEFF_NORMED := 5

	; ColormapTypes
	static COLORMAP_AUTUMN := 0
	static COLORMAP_BONE := 1
	static COLORMAP_JET := 2
	static COLORMAP_WINTER := 3
	static COLORMAP_RAINBOW := 4
	static COLORMAP_OCEAN := 5
	static COLORMAP_SUMMER := 6
	static COLORMAP_SPRING := 7
	static COLORMAP_COOL := 8
	static COLORMAP_HSV := 9
	static COLORMAP_PINK := 10
	static COLORMAP_HOT := 11
	static COLORMAP_PARULA := 12
	static COLORMAP_MAGMA := 13
	static COLORMAP_INFERNO := 14
	static COLORMAP_PLASMA := 15
	static COLORMAP_VIRIDIS := 16
	static COLORMAP_CIVIDIS := 17
	static COLORMAP_TWILIGHT := 18
	static COLORMAP_TWILIGHT_SHIFTED := 19
	static COLORMAP_TURBO := 20
	static COLORMAP_DEEPGREEN := 21

	; VariableTypes
	static ML_VAR_NUMERICAL := 0
	static ML_VAR_ORDERED := 0
	static ML_VAR_CATEGORICAL := 1

	; ErrorTypes
	static ML_TEST_ERROR := 0
	static ML_TRAIN_ERROR := 1

	; SampleTypes
	static ML_ROW_SAMPLE := 0
	static ML_COL_SAMPLE := 1

	; Flags
	static ML_STAT_MODEL_UPDATE_MODEL := 1
	static ML_STAT_MODEL_RAW_OUTPUT := 1
	static ML_STAT_MODEL_COMPRESSED_INPUT := 2
	static ML_STAT_MODEL_PREPROCESSED_INPUT := 4

	; Types
	static ML_KNEAREST_BRUTE_FORCE := 1
	static ML_KNEAREST_KDTREE := 2

	; Types
	static ML_SVM_C_SVC := 100
	static ML_SVM_NU_SVC := 101
	static ML_SVM_ONE_CLASS := 102
	static ML_SVM_EPS_SVR := 103
	static ML_SVM_NU_SVR := 104

	; KernelTypes
	static ML_SVM_CUSTOM := -1
	static ML_SVM_LINEAR := 0
	static ML_SVM_POLY := 1
	static ML_SVM_RBF := 2
	static ML_SVM_SIGMOID := 3
	static ML_SVM_CHI2 := 4
	static ML_SVM_INTER := 5

	; ParamTypes
	static ML_SVM_C := 0
	static ML_SVM_GAMMA := 1
	static ML_SVM_P := 2
	static ML_SVM_NU := 3
	static ML_SVM_COEF := 4
	static ML_SVM_DEGREE := 5

	; Types
	static ML_EM_COV_MAT_SPHERICAL := 0
	static ML_EM_COV_MAT_DIAGONAL := 1
	static ML_EM_COV_MAT_GENERIC := 2
	static ML_EM_COV_MAT_DEFAULT := cv2.ML_EM_COV_MAT_DIAGONAL

	; anonymous
	static ML_EM_DEFAULT_NCLUSTERS := 5
	static ML_EM_DEFAULT_MAX_ITERS := 100
	static ML_EM_START_E_STEP := 1
	static ML_EM_START_M_STEP := 2
	static ML_EM_START_AUTO_STEP := 0

	; Flags
	static ML_DTREES_PREDICT_AUTO := 0
	static ML_DTREES_PREDICT_SUM := (BitShift(1, -8))
	static ML_DTREES_PREDICT_MAX_VOTE := (BitShift(2, -8))
	static ML_DTREES_PREDICT_MASK := (BitShift(3, -8))

	; Types
	static ML_BOOST_DISCRETE := 0
	static ML_BOOST_REAL := 1
	static ML_BOOST_LOGIT := 2
	static ML_BOOST_GENTLE := 3

	; TrainingMethods
	static ML_ANN_MLP_BACKPROP := 0
	static ML_ANN_MLP_RPROP := 1
	static ML_ANN_MLP_ANNEAL := 2

	; ActivationFunctions
	static ML_ANN_MLP_IDENTITY := 0
	static ML_ANN_MLP_SIGMOID_SYM := 1
	static ML_ANN_MLP_GAUSSIAN := 2
	static ML_ANN_MLP_RELU := 3
	static ML_ANN_MLP_LEAKYRELU := 4

	; TrainFlags
	static ML_ANN_MLP_UPDATE_WEIGHTS := 1
	static ML_ANN_MLP_NO_INPUT_SCALE := 2
	static ML_ANN_MLP_NO_OUTPUT_SCALE := 4

	; RegKinds
	static ML_LOGISTIC_REGRESSION_REG_DISABLE := -1
	static ML_LOGISTIC_REGRESSION_REG_L1 := 0
	static ML_LOGISTIC_REGRESSION_REG_L2 := 1

	; Methods
	static ML_LOGISTIC_REGRESSION_BATCH := 0
	static ML_LOGISTIC_REGRESSION_MINI_BATCH := 1

	; SvmsgdType
	static ML_SVMSGD_SGD := 0
	static ML_SVMSGD_ASGD := 1

	; MarginType
	static ML_SVMSGD_SOFT_MARGIN := 0
	static ML_SVMSGD_HARD_MARGIN := 1

	; anonymous
	static INPAINT_NS := 0
	static INPAINT_TELEA := 1
	static LDR_SIZE := 256
	static NORMAL_CLONE := 1
	static MIXED_CLONE := 2
	static MONOCHROME_TRANSFER := 3
	static RECURS_FILTER := 1
	static NORMCONV_FILTER := 2
	static CAP_PROP_DC1394_OFF := -4
	static CAP_PROP_DC1394_MODE_MANUAL := -3
	static CAP_PROP_DC1394_MODE_AUTO := -2
	static CAP_PROP_DC1394_MODE_ONE_PUSH_AUTO := -1
	static CAP_PROP_DC1394_MAX := 31
	static CAP_OPENNI_DEPTH_GENERATOR := BitShift(1, -31)
	static CAP_OPENNI_IMAGE_GENERATOR := BitShift(1, -30)
	static CAP_OPENNI_IR_GENERATOR := BitShift(1, -29)
	static CAP_OPENNI_GENERATORS_MASK := cv2.CAP_OPENNI_DEPTH_GENERATOR + cv2.CAP_OPENNI_IMAGE_GENERATOR + cv2.CAP_OPENNI_IR_GENERATOR
	static CAP_PROP_OPENNI_OUTPUT_MODE := 100
	static CAP_PROP_OPENNI_FRAME_MAX_DEPTH := 101
	static CAP_PROP_OPENNI_BASELINE := 102
	static CAP_PROP_OPENNI_FOCAL_LENGTH := 103
	static CAP_PROP_OPENNI_REGISTRATION := 104
	static CAP_PROP_OPENNI_REGISTRATION_ON := cv2.CAP_PROP_OPENNI_REGISTRATION
	static CAP_PROP_OPENNI_APPROX_FRAME_SYNC := 105
	static CAP_PROP_OPENNI_MAX_BUFFER_SIZE := 106
	static CAP_PROP_OPENNI_CIRCLE_BUFFER := 107
	static CAP_PROP_OPENNI_MAX_TIME_DURATION := 108
	static CAP_PROP_OPENNI_GENERATOR_PRESENT := 109
	static CAP_PROP_OPENNI2_SYNC := 110
	static CAP_PROP_OPENNI2_MIRROR := 111
	static CAP_OPENNI_IMAGE_GENERATOR_PRESENT := cv2.CAP_OPENNI_IMAGE_GENERATOR + cv2.CAP_PROP_OPENNI_GENERATOR_PRESENT
	static CAP_OPENNI_IMAGE_GENERATOR_OUTPUT_MODE := cv2.CAP_OPENNI_IMAGE_GENERATOR + cv2.CAP_PROP_OPENNI_OUTPUT_MODE
	static CAP_OPENNI_DEPTH_GENERATOR_PRESENT := cv2.CAP_OPENNI_DEPTH_GENERATOR + cv2.CAP_PROP_OPENNI_GENERATOR_PRESENT
	static CAP_OPENNI_DEPTH_GENERATOR_BASELINE := cv2.CAP_OPENNI_DEPTH_GENERATOR + cv2.CAP_PROP_OPENNI_BASELINE
	static CAP_OPENNI_DEPTH_GENERATOR_FOCAL_LENGTH := cv2.CAP_OPENNI_DEPTH_GENERATOR + cv2.CAP_PROP_OPENNI_FOCAL_LENGTH
	static CAP_OPENNI_DEPTH_GENERATOR_REGISTRATION := cv2.CAP_OPENNI_DEPTH_GENERATOR + cv2.CAP_PROP_OPENNI_REGISTRATION
	static CAP_OPENNI_DEPTH_GENERATOR_REGISTRATION_ON := cv2.CAP_OPENNI_DEPTH_GENERATOR_REGISTRATION
	static CAP_OPENNI_IR_GENERATOR_PRESENT := cv2.CAP_OPENNI_IR_GENERATOR + cv2.CAP_PROP_OPENNI_GENERATOR_PRESENT
	static CAP_OPENNI_DEPTH_MAP := 0
	static CAP_OPENNI_POINT_CLOUD_MAP := 1
	static CAP_OPENNI_DISPARITY_MAP := 2
	static CAP_OPENNI_DISPARITY_MAP_32F := 3
	static CAP_OPENNI_VALID_DEPTH_MASK := 4
	static CAP_OPENNI_BGR_IMAGE := 5
	static CAP_OPENNI_GRAY_IMAGE := 6
	static CAP_OPENNI_IR_IMAGE := 7
	static CAP_OPENNI_VGA_30HZ := 0
	static CAP_OPENNI_SXGA_15HZ := 1
	static CAP_OPENNI_SXGA_30HZ := 2
	static CAP_OPENNI_QVGA_30HZ := 3
	static CAP_OPENNI_QVGA_60HZ := 4
	static CAP_PROP_GSTREAMER_QUEUE_LENGTH := 200
	static CAP_PROP_PVAPI_MULTICASTIP := 300
	static CAP_PROP_PVAPI_FRAMESTARTTRIGGERMODE := 301
	static CAP_PROP_PVAPI_DECIMATIONHORIZONTAL := 302
	static CAP_PROP_PVAPI_DECIMATIONVERTICAL := 303
	static CAP_PROP_PVAPI_BINNINGX := 304
	static CAP_PROP_PVAPI_BINNINGY := 305
	static CAP_PROP_PVAPI_PIXELFORMAT := 306
	static CAP_PVAPI_FSTRIGMODE_FREERUN := 0
	static CAP_PVAPI_FSTRIGMODE_SYNCIN1 := 1
	static CAP_PVAPI_FSTRIGMODE_SYNCIN2 := 2
	static CAP_PVAPI_FSTRIGMODE_FIXEDRATE := 3
	static CAP_PVAPI_FSTRIGMODE_SOFTWARE := 4
	static CAP_PVAPI_DECIMATION_OFF := 1
	static CAP_PVAPI_DECIMATION_2OUTOF4 := 2
	static CAP_PVAPI_DECIMATION_2OUTOF8 := 4
	static CAP_PVAPI_DECIMATION_2OUTOF16 := 8
	static CAP_PVAPI_PIXELFORMAT_MONO8 := 1
	static CAP_PVAPI_PIXELFORMAT_MONO16 := 2
	static CAP_PVAPI_PIXELFORMAT_BAYER8 := 3
	static CAP_PVAPI_PIXELFORMAT_BAYER16 := 4
	static CAP_PVAPI_PIXELFORMAT_RGB24 := 5
	static CAP_PVAPI_PIXELFORMAT_BGR24 := 6
	static CAP_PVAPI_PIXELFORMAT_RGBA32 := 7
	static CAP_PVAPI_PIXELFORMAT_BGRA32 := 8
	static CAP_PROP_XI_DOWNSAMPLING := 400
	static CAP_PROP_XI_DATA_FORMAT := 401
	static CAP_PROP_XI_OFFSET_X := 402
	static CAP_PROP_XI_OFFSET_Y := 403
	static CAP_PROP_XI_TRG_SOURCE := 404
	static CAP_PROP_XI_TRG_SOFTWARE := 405
	static CAP_PROP_XI_GPI_SELECTOR := 406
	static CAP_PROP_XI_GPI_MODE := 407
	static CAP_PROP_XI_GPI_LEVEL := 408
	static CAP_PROP_XI_GPO_SELECTOR := 409
	static CAP_PROP_XI_GPO_MODE := 410
	static CAP_PROP_XI_LED_SELECTOR := 411
	static CAP_PROP_XI_LED_MODE := 412
	static CAP_PROP_XI_MANUAL_WB := 413
	static CAP_PROP_XI_AUTO_WB := 414
	static CAP_PROP_XI_AEAG := 415
	static CAP_PROP_XI_EXP_PRIORITY := 416
	static CAP_PROP_XI_AE_MAX_LIMIT := 417
	static CAP_PROP_XI_AG_MAX_LIMIT := 418
	static CAP_PROP_XI_AEAG_LEVEL := 419
	static CAP_PROP_XI_TIMEOUT := 420
	static CAP_PROP_XI_EXPOSURE := 421
	static CAP_PROP_XI_EXPOSURE_BURST_COUNT := 422
	static CAP_PROP_XI_GAIN_SELECTOR := 423
	static CAP_PROP_XI_GAIN := 424
	static CAP_PROP_XI_DOWNSAMPLING_TYPE := 426
	static CAP_PROP_XI_BINNING_SELECTOR := 427
	static CAP_PROP_XI_BINNING_VERTICAL := 428
	static CAP_PROP_XI_BINNING_HORIZONTAL := 429
	static CAP_PROP_XI_BINNING_PATTERN := 430
	static CAP_PROP_XI_DECIMATION_SELECTOR := 431
	static CAP_PROP_XI_DECIMATION_VERTICAL := 432
	static CAP_PROP_XI_DECIMATION_HORIZONTAL := 433
	static CAP_PROP_XI_DECIMATION_PATTERN := 434
	static CAP_PROP_XI_TEST_PATTERN_GENERATOR_SELECTOR := 587
	static CAP_PROP_XI_TEST_PATTERN := 588
	static CAP_PROP_XI_IMAGE_DATA_FORMAT := 435
	static CAP_PROP_XI_SHUTTER_TYPE := 436
	static CAP_PROP_XI_SENSOR_TAPS := 437
	static CAP_PROP_XI_AEAG_ROI_OFFSET_X := 439
	static CAP_PROP_XI_AEAG_ROI_OFFSET_Y := 440
	static CAP_PROP_XI_AEAG_ROI_WIDTH := 441
	static CAP_PROP_XI_AEAG_ROI_HEIGHT := 442
	static CAP_PROP_XI_BPC := 445
	static CAP_PROP_XI_WB_KR := 448
	static CAP_PROP_XI_WB_KG := 449
	static CAP_PROP_XI_WB_KB := 450
	static CAP_PROP_XI_WIDTH := 451
	static CAP_PROP_XI_HEIGHT := 452
	static CAP_PROP_XI_REGION_SELECTOR := 589
	static CAP_PROP_XI_REGION_MODE := 595
	static CAP_PROP_XI_LIMIT_BANDWIDTH := 459
	static CAP_PROP_XI_SENSOR_DATA_BIT_DEPTH := 460
	static CAP_PROP_XI_OUTPUT_DATA_BIT_DEPTH := 461
	static CAP_PROP_XI_IMAGE_DATA_BIT_DEPTH := 462
	static CAP_PROP_XI_OUTPUT_DATA_PACKING := 463
	static CAP_PROP_XI_OUTPUT_DATA_PACKING_TYPE := 464
	static CAP_PROP_XI_IS_COOLED := 465
	static CAP_PROP_XI_COOLING := 466
	static CAP_PROP_XI_TARGET_TEMP := 467
	static CAP_PROP_XI_CHIP_TEMP := 468
	static CAP_PROP_XI_HOUS_TEMP := 469
	static CAP_PROP_XI_HOUS_BACK_SIDE_TEMP := 590
	static CAP_PROP_XI_SENSOR_BOARD_TEMP := 596
	static CAP_PROP_XI_CMS := 470
	static CAP_PROP_XI_APPLY_CMS := 471
	static CAP_PROP_XI_IMAGE_IS_COLOR := 474
	static CAP_PROP_XI_COLOR_FILTER_ARRAY := 475
	static CAP_PROP_XI_GAMMAY := 476
	static CAP_PROP_XI_GAMMAC := 477
	static CAP_PROP_XI_SHARPNESS := 478
	static CAP_PROP_XI_CC_MATRIX_00 := 479
	static CAP_PROP_XI_CC_MATRIX_01 := 480
	static CAP_PROP_XI_CC_MATRIX_02 := 481
	static CAP_PROP_XI_CC_MATRIX_03 := 482
	static CAP_PROP_XI_CC_MATRIX_10 := 483
	static CAP_PROP_XI_CC_MATRIX_11 := 484
	static CAP_PROP_XI_CC_MATRIX_12 := 485
	static CAP_PROP_XI_CC_MATRIX_13 := 486
	static CAP_PROP_XI_CC_MATRIX_20 := 487
	static CAP_PROP_XI_CC_MATRIX_21 := 488
	static CAP_PROP_XI_CC_MATRIX_22 := 489
	static CAP_PROP_XI_CC_MATRIX_23 := 490
	static CAP_PROP_XI_CC_MATRIX_30 := 491
	static CAP_PROP_XI_CC_MATRIX_31 := 492
	static CAP_PROP_XI_CC_MATRIX_32 := 493
	static CAP_PROP_XI_CC_MATRIX_33 := 494
	static CAP_PROP_XI_DEFAULT_CC_MATRIX := 495
	static CAP_PROP_XI_TRG_SELECTOR := 498
	static CAP_PROP_XI_ACQ_FRAME_BURST_COUNT := 499
	static CAP_PROP_XI_DEBOUNCE_EN := 507
	static CAP_PROP_XI_DEBOUNCE_T0 := 508
	static CAP_PROP_XI_DEBOUNCE_T1 := 509
	static CAP_PROP_XI_DEBOUNCE_POL := 510
	static CAP_PROP_XI_LENS_MODE := 511
	static CAP_PROP_XI_LENS_APERTURE_VALUE := 512
	static CAP_PROP_XI_LENS_FOCUS_MOVEMENT_VALUE := 513
	static CAP_PROP_XI_LENS_FOCUS_MOVE := 514
	static CAP_PROP_XI_LENS_FOCUS_DISTANCE := 515
	static CAP_PROP_XI_LENS_FOCAL_LENGTH := 516
	static CAP_PROP_XI_LENS_FEATURE_SELECTOR := 517
	static CAP_PROP_XI_LENS_FEATURE := 518
	static CAP_PROP_XI_DEVICE_MODEL_ID := 521
	static CAP_PROP_XI_DEVICE_SN := 522
	static CAP_PROP_XI_IMAGE_DATA_FORMAT_RGB32_ALPHA := 529
	static CAP_PROP_XI_IMAGE_PAYLOAD_SIZE := 530
	static CAP_PROP_XI_TRANSPORT_PIXEL_FORMAT := 531
	static CAP_PROP_XI_SENSOR_CLOCK_FREQ_HZ := 532
	static CAP_PROP_XI_SENSOR_CLOCK_FREQ_INDEX := 533
	static CAP_PROP_XI_SENSOR_OUTPUT_CHANNEL_COUNT := 534
	static CAP_PROP_XI_FRAMERATE := 535
	static CAP_PROP_XI_COUNTER_SELECTOR := 536
	static CAP_PROP_XI_COUNTER_VALUE := 537
	static CAP_PROP_XI_ACQ_TIMING_MODE := 538
	static CAP_PROP_XI_AVAILABLE_BANDWIDTH := 539
	static CAP_PROP_XI_BUFFER_POLICY := 540
	static CAP_PROP_XI_LUT_EN := 541
	static CAP_PROP_XI_LUT_INDEX := 542
	static CAP_PROP_XI_LUT_VALUE := 543
	static CAP_PROP_XI_TRG_DELAY := 544
	static CAP_PROP_XI_TS_RST_MODE := 545
	static CAP_PROP_XI_TS_RST_SOURCE := 546
	static CAP_PROP_XI_IS_DEVICE_EXIST := 547
	static CAP_PROP_XI_ACQ_BUFFER_SIZE := 548
	static CAP_PROP_XI_ACQ_BUFFER_SIZE_UNIT := 549
	static CAP_PROP_XI_ACQ_TRANSPORT_BUFFER_SIZE := 550
	static CAP_PROP_XI_BUFFERS_QUEUE_SIZE := 551
	static CAP_PROP_XI_ACQ_TRANSPORT_BUFFER_COMMIT := 552
	static CAP_PROP_XI_RECENT_FRAME := 553
	static CAP_PROP_XI_DEVICE_RESET := 554
	static CAP_PROP_XI_COLUMN_FPN_CORRECTION := 555
	static CAP_PROP_XI_ROW_FPN_CORRECTION := 591
	static CAP_PROP_XI_SENSOR_MODE := 558
	static CAP_PROP_XI_HDR := 559
	static CAP_PROP_XI_HDR_KNEEPOINT_COUNT := 560
	static CAP_PROP_XI_HDR_T1 := 561
	static CAP_PROP_XI_HDR_T2 := 562
	static CAP_PROP_XI_KNEEPOINT1 := 563
	static CAP_PROP_XI_KNEEPOINT2 := 564
	static CAP_PROP_XI_IMAGE_BLACK_LEVEL := 565
	static CAP_PROP_XI_HW_REVISION := 571
	static CAP_PROP_XI_DEBUG_LEVEL := 572
	static CAP_PROP_XI_AUTO_BANDWIDTH_CALCULATION := 573
	static CAP_PROP_XI_FFS_FILE_ID := 594
	static CAP_PROP_XI_FFS_FILE_SIZE := 580
	static CAP_PROP_XI_FREE_FFS_SIZE := 581
	static CAP_PROP_XI_USED_FFS_SIZE := 582
	static CAP_PROP_XI_FFS_ACCESS_KEY := 583
	static CAP_PROP_XI_SENSOR_FEATURE_SELECTOR := 585
	static CAP_PROP_XI_SENSOR_FEATURE_VALUE := 586
	static CAP_PROP_ARAVIS_AUTOTRIGGER := 600
	static CAP_PROP_IOS_DEVICE_FOCUS := 9001
	static CAP_PROP_IOS_DEVICE_EXPOSURE := 9002
	static CAP_PROP_IOS_DEVICE_FLASH := 9003
	static CAP_PROP_IOS_DEVICE_WHITEBALANCE := 9004
	static CAP_PROP_IOS_DEVICE_TORCH := 9005
	static CAP_PROP_GIGA_FRAME_OFFSET_X := 10001
	static CAP_PROP_GIGA_FRAME_OFFSET_Y := 10002
	static CAP_PROP_GIGA_FRAME_WIDTH_MAX := 10003
	static CAP_PROP_GIGA_FRAME_HEIGH_MAX := 10004
	static CAP_PROP_GIGA_FRAME_SENS_WIDTH := 10005
	static CAP_PROP_GIGA_FRAME_SENS_HEIGH := 10006
	static CAP_PROP_INTELPERC_PROFILE_COUNT := 11001
	static CAP_PROP_INTELPERC_PROFILE_IDX := 11002
	static CAP_PROP_INTELPERC_DEPTH_LOW_CONFIDENCE_VALUE := 11003
	static CAP_PROP_INTELPERC_DEPTH_SATURATION_VALUE := 11004
	static CAP_PROP_INTELPERC_DEPTH_CONFIDENCE_THRESHOLD := 11005
	static CAP_PROP_INTELPERC_DEPTH_FOCAL_LENGTH_HORZ := 11006
	static CAP_PROP_INTELPERC_DEPTH_FOCAL_LENGTH_VERT := 11007
	static CAP_INTELPERC_DEPTH_GENERATOR := BitShift(1, -29)
	static CAP_INTELPERC_IMAGE_GENERATOR := BitShift(1, -28)
	static CAP_INTELPERC_IR_GENERATOR := BitShift(1, -27)
	static CAP_INTELPERC_GENERATORS_MASK := cv2.CAP_INTELPERC_DEPTH_GENERATOR + cv2.CAP_INTELPERC_IMAGE_GENERATOR + cv2.CAP_INTELPERC_IR_GENERATOR
	static CAP_INTELPERC_DEPTH_MAP := 0
	static CAP_INTELPERC_UVDEPTH_MAP := 1
	static CAP_INTELPERC_IR_MAP := 2
	static CAP_INTELPERC_IMAGE := 3
	static CAP_PROP_GPHOTO2_PREVIEW := 17001
	static CAP_PROP_GPHOTO2_WIDGET_ENUMERATE := 17002
	static CAP_PROP_GPHOTO2_RELOAD_CONFIG := 17003
	static CAP_PROP_GPHOTO2_RELOAD_ON_CHANGE := 17004
	static CAP_PROP_GPHOTO2_COLLECT_MSGS := 17005
	static CAP_PROP_GPHOTO2_FLUSH_MSGS := 17006
	static CAP_PROP_SPEED := 17007
	static CAP_PROP_APERTURE := 17008
	static CAP_PROP_EXPOSUREPROGRAM := 17009
	static CAP_PROP_VIEWFINDER := 17010
	static CAP_PROP_IMAGES_BASE := 18000
	static CAP_PROP_IMAGES_LAST := 19000
	static LMEDS := 4
	static RANSAC := 8
	static RHO := 16
	static USAC_DEFAULT := 32
	static USAC_PARALLEL := 33
	static USAC_FM_8PTS := 34
	static USAC_FAST := 35
	static USAC_ACCURATE := 36
	static USAC_PROSAC := 37
	static USAC_MAGSAC := 38
	static CALIB_CB_ADAPTIVE_THRESH := 1
	static CALIB_CB_NORMALIZE_IMAGE := 2
	static CALIB_CB_FILTER_QUADS := 4
	static CALIB_CB_FAST_CHECK := 8
	static CALIB_CB_EXHAUSTIVE := 16
	static CALIB_CB_ACCURACY := 32
	static CALIB_CB_LARGER := 64
	static CALIB_CB_MARKER := 128
	static CALIB_CB_SYMMETRIC_GRID := 1
	static CALIB_CB_ASYMMETRIC_GRID := 2
	static CALIB_CB_CLUSTERING := 4
	static CALIB_NINTRINSIC := 18
	static CALIB_USE_INTRINSIC_GUESS := 0x00001
	static CALIB_FIX_ASPECT_RATIO := 0x00002
	static CALIB_FIX_PRINCIPAL_POINT := 0x00004
	static CALIB_ZERO_TANGENT_DIST := 0x00008
	static CALIB_FIX_FOCAL_LENGTH := 0x00010
	static CALIB_FIX_K1 := 0x00020
	static CALIB_FIX_K2 := 0x00040
	static CALIB_FIX_K3 := 0x00080
	static CALIB_FIX_K4 := 0x00800
	static CALIB_FIX_K5 := 0x01000
	static CALIB_FIX_K6 := 0x02000
	static CALIB_RATIONAL_MODEL := 0x04000
	static CALIB_THIN_PRISM_MODEL := 0x08000
	static CALIB_FIX_S1_S2_S3_S4 := 0x10000
	static CALIB_TILTED_MODEL := 0x40000
	static CALIB_FIX_TAUX_TAUY := 0x80000
	static CALIB_USE_QR := 0x100000
	static CALIB_FIX_TANGENT_DIST := 0x200000
	static CALIB_FIX_INTRINSIC := 0x00100
	static CALIB_SAME_FOCAL_LENGTH := 0x00200
	static CALIB_ZERO_DISPARITY := 0x00400
	static CALIB_USE_LU := (BitShift(1, -17))
	static CALIB_USE_EXTRINSIC_GUESS := (BitShift(1, -22))
	static FM_7POINT := 1
	static FM_8POINT := 2
	static FM_LMEDS := 4
	static FM_RANSAC := 8
	static CASCADE_DO_CANNY_PRUNING := 1
	static CASCADE_SCALE_IMAGE := 2
	static CASCADE_FIND_BIGGEST_OBJECT := 4
	static CASCADE_DO_ROUGH_SEARCH := 8
	static OPTFLOW_USE_INITIAL_FLOW := 4
	static OPTFLOW_LK_GET_MIN_EIGENVALS := 8
	static OPTFLOW_FARNEBACK_GAUSSIAN := 256
	static MOTION_TRANSLATION := 0
	static MOTION_EUCLIDEAN := 1
	static MOTION_AFFINE := 2
	static MOTION_HOMOGRAPHY := 3

	; Backend
	static DNN_DNN_BACKEND_DEFAULT := 0
	static DNN_DNN_BACKEND_HALIDE := 0 + 1
	static DNN_DNN_BACKEND_INFERENCE_ENGINE := 0 + 2
	static DNN_DNN_BACKEND_OPENCV := 0 + 3
	static DNN_DNN_BACKEND_VKCOM := 0 + 4
	static DNN_DNN_BACKEND_CUDA := 0 + 5
	static DNN_DNN_BACKEND_WEBNN := 0 + 6

	; Target
	static DNN_DNN_TARGET_CPU := 0
	static DNN_DNN_TARGET_OPENCL := 0 + 1
	static DNN_DNN_TARGET_OPENCL_FP16 := 0 + 2
	static DNN_DNN_TARGET_MYRIAD := 0 + 3
	static DNN_DNN_TARGET_VULKAN := 0 + 4
	static DNN_DNN_TARGET_FPGA := 0 + 5
	static DNN_DNN_TARGET_CUDA := 0 + 6
	static DNN_DNN_TARGET_CUDA_FP16 := 0 + 7
	static DNN_DNN_TARGET_HDDL := 0 + 8

	; SoftNMSMethod
	static DNN_SOFT_NMSMETHOD_SOFTNMS_LINEAR := 1
	static DNN_SOFT_NMSMETHOD_SOFTNMS_GAUSSIAN := 2

	; ScoreType
	static ORB_HARRIS_SCORE := 0
	static ORB_FAST_SCORE := 1

	; DetectorType
	static FAST_FEATURE_DETECTOR_TYPE_5_8 := 0
	static FAST_FEATURE_DETECTOR_TYPE_7_12 := 1
	static FAST_FEATURE_DETECTOR_TYPE_9_16 := 2

	; anonymous
	static FAST_FEATURE_DETECTOR_THRESHOLD := 10000
	static FAST_FEATURE_DETECTOR_NONMAX_SUPPRESSION := 10001
	static FAST_FEATURE_DETECTOR_FAST_N := 10002

	; DetectorType
	static AGAST_FEATURE_DETECTOR_AGAST_5_8 := 0
	static AGAST_FEATURE_DETECTOR_AGAST_7_12d := 1
	static AGAST_FEATURE_DETECTOR_AGAST_7_12s := 2
	static AGAST_FEATURE_DETECTOR_OAST_9_16 := 3

	; anonymous
	static AGAST_FEATURE_DETECTOR_THRESHOLD := 10000
	static AGAST_FEATURE_DETECTOR_NONMAX_SUPPRESSION := 10001

	; DiffusivityType
	static KAZE_DIFF_PM_G1 := 0
	static KAZE_DIFF_PM_G2 := 1
	static KAZE_DIFF_WEICKERT := 2
	static KAZE_DIFF_CHARBONNIER := 3

	; DescriptorType
	static AKAZE_DESCRIPTOR_KAZE_UPRIGHT := 2
	static AKAZE_DESCRIPTOR_KAZE := 3
	static AKAZE_DESCRIPTOR_MLDB_UPRIGHT := 4
	static AKAZE_DESCRIPTOR_MLDB := 5

	; MatcherType
	static DESCRIPTOR_MATCHER_FLANNBASED := 1
	static DESCRIPTOR_MATCHER_BRUTEFORCE := 2
	static DESCRIPTOR_MATCHER_BRUTEFORCE_L1 := 3
	static DESCRIPTOR_MATCHER_BRUTEFORCE_HAMMING := 4
	static DESCRIPTOR_MATCHER_BRUTEFORCE_HAMMINGLUT := 5
	static DESCRIPTOR_MATCHER_BRUTEFORCE_SL2 := 6

	; DrawMatchesFlags
	static DRAW_MATCHES_FLAGS_DEFAULT := 0
	static DRAW_MATCHES_FLAGS_DRAW_OVER_OUTIMG := 1
	static DRAW_MATCHES_FLAGS_NOT_DRAW_SINGLE_POINTS := 2
	static DRAW_MATCHES_FLAGS_DRAW_RICH_KEYPOINTS := 4

	; ImreadModes
	static IMREAD_UNCHANGED := -1
	static IMREAD_GRAYSCALE := 0
	static IMREAD_COLOR := 1
	static IMREAD_ANYDEPTH := 2
	static IMREAD_ANYCOLOR := 4
	static IMREAD_LOAD_GDAL := 8
	static IMREAD_REDUCED_GRAYSCALE_2 := 16
	static IMREAD_REDUCED_COLOR_2 := 17
	static IMREAD_REDUCED_GRAYSCALE_4 := 32
	static IMREAD_REDUCED_COLOR_4 := 33
	static IMREAD_REDUCED_GRAYSCALE_8 := 64
	static IMREAD_REDUCED_COLOR_8 := 65
	static IMREAD_IGNORE_ORIENTATION := 128

	; ImwriteFlags
	static IMWRITE_JPEG_QUALITY := 1
	static IMWRITE_JPEG_PROGRESSIVE := 2
	static IMWRITE_JPEG_OPTIMIZE := 3
	static IMWRITE_JPEG_RST_INTERVAL := 4
	static IMWRITE_JPEG_LUMA_QUALITY := 5
	static IMWRITE_JPEG_CHROMA_QUALITY := 6
	static IMWRITE_PNG_COMPRESSION := 16
	static IMWRITE_PNG_STRATEGY := 17
	static IMWRITE_PNG_BILEVEL := 18
	static IMWRITE_PXM_BINARY := 32
	static IMWRITE_EXR_TYPE := (BitShift(3, -4)) + 0
	static IMWRITE_EXR_COMPRESSION := (BitShift(3, -4)) + 1
	static IMWRITE_WEBP_QUALITY := 64
	static IMWRITE_PAM_TUPLETYPE := 128
	static IMWRITE_TIFF_RESUNIT := 256
	static IMWRITE_TIFF_XDPI := 257
	static IMWRITE_TIFF_YDPI := 258
	static IMWRITE_TIFF_COMPRESSION := 259
	static IMWRITE_JPEG2000_COMPRESSION_X1000 := 272

	; ImwriteEXRTypeFlags
	static IMWRITE_EXR_TYPE_HALF := 1
	static IMWRITE_EXR_TYPE_FLOAT := 2

	; ImwriteEXRCompressionFlags
	static IMWRITE_EXR_COMPRESSION_NO := 0
	static IMWRITE_EXR_COMPRESSION_RLE := 1
	static IMWRITE_EXR_COMPRESSION_ZIPS := 2
	static IMWRITE_EXR_COMPRESSION_ZIP := 3
	static IMWRITE_EXR_COMPRESSION_PIZ := 4
	static IMWRITE_EXR_COMPRESSION_PXR24 := 5
	static IMWRITE_EXR_COMPRESSION_B44 := 6
	static IMWRITE_EXR_COMPRESSION_B44A := 7
	static IMWRITE_EXR_COMPRESSION_DWAA := 8
	static IMWRITE_EXR_COMPRESSION_DWAB := 9

	; ImwritePNGFlags
	static IMWRITE_PNG_STRATEGY_DEFAULT := 0
	static IMWRITE_PNG_STRATEGY_FILTERED := 1
	static IMWRITE_PNG_STRATEGY_HUFFMAN_ONLY := 2
	static IMWRITE_PNG_STRATEGY_RLE := 3
	static IMWRITE_PNG_STRATEGY_FIXED := 4

	; ImwritePAMFlags
	static IMWRITE_PAM_FORMAT_NULL := 0
	static IMWRITE_PAM_FORMAT_BLACKANDWHITE := 1
	static IMWRITE_PAM_FORMAT_GRAYSCALE := 2
	static IMWRITE_PAM_FORMAT_GRAYSCALE_ALPHA := 3
	static IMWRITE_PAM_FORMAT_RGB := 4
	static IMWRITE_PAM_FORMAT_RGB_ALPHA := 5

	; VideoCaptureAPIs
	static CAP_ANY := 0
	static CAP_VFW := 200
	static CAP_V4L := 200
	static CAP_V4L2 := cv2.CAP_V4L
	static CAP_FIREWIRE := 300
	static CAP_FIREWARE := cv2.CAP_FIREWIRE
	static CAP_IEEE1394 := cv2.CAP_FIREWIRE
	static CAP_DC1394 := cv2.CAP_FIREWIRE
	static CAP_CMU1394 := cv2.CAP_FIREWIRE
	static CAP_QT := 500
	static CAP_UNICAP := 600
	static CAP_DSHOW := 700
	static CAP_PVAPI := 800
	static CAP_OPENNI := 900
	static CAP_OPENNI_ASUS := 910
	static CAP_ANDROID := 1000
	static CAP_XIAPI := 1100
	static CAP_AVFOUNDATION := 1200
	static CAP_GIGANETIX := 1300
	static CAP_MSMF := 1400
	static CAP_WINRT := 1410
	static CAP_INTELPERC := 1500
	static CAP_REALSENSE := 1500
	static CAP_OPENNI2 := 1600
	static CAP_OPENNI2_ASUS := 1610
	static CAP_OPENNI2_ASTRA := 1620
	static CAP_GPHOTO2 := 1700
	static CAP_GSTREAMER := 1800
	static CAP_FFMPEG := 1900
	static CAP_IMAGES := 2000
	static CAP_ARAVIS := 2100
	static CAP_OPENMJPEG := 2200
	static CAP_INTEL_MFX := 2300
	static CAP_XINE := 2400
	static CAP_UEYE := 2500

	; VideoCaptureProperties
	static CAP_PROP_POS_MSEC := 0
	static CAP_PROP_POS_FRAMES := 1
	static CAP_PROP_POS_AVI_RATIO := 2
	static CAP_PROP_FRAME_WIDTH := 3
	static CAP_PROP_FRAME_HEIGHT := 4
	static CAP_PROP_FPS := 5
	static CAP_PROP_FOURCC := 6
	static CAP_PROP_FRAME_COUNT := 7
	static CAP_PROP_FORMAT := 8
	static CAP_PROP_MODE := 9
	static CAP_PROP_BRIGHTNESS := 10
	static CAP_PROP_CONTRAST := 11
	static CAP_PROP_SATURATION := 12
	static CAP_PROP_HUE := 13
	static CAP_PROP_GAIN := 14
	static CAP_PROP_EXPOSURE := 15
	static CAP_PROP_CONVERT_RGB := 16
	static CAP_PROP_WHITE_BALANCE_BLUE_U := 17
	static CAP_PROP_RECTIFICATION := 18
	static CAP_PROP_MONOCHROME := 19
	static CAP_PROP_SHARPNESS := 20
	static CAP_PROP_AUTO_EXPOSURE := 21
	static CAP_PROP_GAMMA := 22
	static CAP_PROP_TEMPERATURE := 23
	static CAP_PROP_TRIGGER := 24
	static CAP_PROP_TRIGGER_DELAY := 25
	static CAP_PROP_WHITE_BALANCE_RED_V := 26
	static CAP_PROP_ZOOM := 27
	static CAP_PROP_FOCUS := 28
	static CAP_PROP_GUID := 29
	static CAP_PROP_ISO_SPEED := 30
	static CAP_PROP_BACKLIGHT := 32
	static CAP_PROP_PAN := 33
	static CAP_PROP_TILT := 34
	static CAP_PROP_ROLL := 35
	static CAP_PROP_IRIS := 36
	static CAP_PROP_SETTINGS := 37
	static CAP_PROP_BUFFERSIZE := 38
	static CAP_PROP_AUTOFOCUS := 39
	static CAP_PROP_SAR_NUM := 40
	static CAP_PROP_SAR_DEN := 41
	static CAP_PROP_BACKEND := 42
	static CAP_PROP_CHANNEL := 43
	static CAP_PROP_AUTO_WB := 44
	static CAP_PROP_WB_TEMPERATURE := 45
	static CAP_PROP_CODEC_PIXEL_FORMAT := 46
	static CAP_PROP_BITRATE := 47
	static CAP_PROP_ORIENTATION_META := 48
	static CAP_PROP_ORIENTATION_AUTO := 49
	static CAP_PROP_HW_ACCELERATION := 50
	static CAP_PROP_HW_DEVICE := 51
	static CAP_PROP_HW_ACCELERATION_USE_OPENCL := 52
	static CAP_PROP_OPEN_TIMEOUT_MSEC := 53
	static CAP_PROP_READ_TIMEOUT_MSEC := 54
	static CAP_PROP_STREAM_OPEN_TIME_USEC := 55
	static CAP_PROP_VIDEO_TOTAL_CHANNELS := 56
	static CAP_PROP_VIDEO_STREAM := 57
	static CAP_PROP_AUDIO_STREAM := 58
	static CAP_PROP_AUDIO_POS := 59
	static CAP_PROP_AUDIO_SHIFT_NSEC := 60
	static CAP_PROP_AUDIO_DATA_DEPTH := 61
	static CAP_PROP_AUDIO_SAMPLES_PER_SECOND := 62
	static CAP_PROP_AUDIO_BASE_INDEX := 63
	static CAP_PROP_AUDIO_TOTAL_CHANNELS := 64
	static CAP_PROP_AUDIO_TOTAL_STREAMS := 65
	static CAP_PROP_AUDIO_SYNCHRONIZE := 66
	static CAP_PROP_LRF_HAS_KEY_FRAME := 67
	static CAP_PROP_CODEC_EXTRADATA_INDEX := 68

	; VideoWriterProperties
	static VIDEOWRITER_PROP_QUALITY := 1
	static VIDEOWRITER_PROP_FRAMEBYTES := 2
	static VIDEOWRITER_PROP_NSTRIPES := 3
	static VIDEOWRITER_PROP_IS_COLOR := 4
	static VIDEOWRITER_PROP_DEPTH := 5
	static VIDEOWRITER_PROP_HW_ACCELERATION := 6
	static VIDEOWRITER_PROP_HW_DEVICE := 7
	static VIDEOWRITER_PROP_HW_ACCELERATION_USE_OPENCL := 8

	; VideoAccelerationType
	static VIDEO_ACCELERATION_NONE := 0
	static VIDEO_ACCELERATION_ANY := 1
	static VIDEO_ACCELERATION_D3D11 := 2
	static VIDEO_ACCELERATION_VAAPI := 3
	static VIDEO_ACCELERATION_MFX := 4

	; SolvePnPMethod
	static SOLVEPNP_ITERATIVE := 0
	static SOLVEPNP_EPNP := 1
	static SOLVEPNP_P3P := 2
	static SOLVEPNP_DLS := 3
	static SOLVEPNP_UPNP := 4
	static SOLVEPNP_AP3P := 5
	static SOLVEPNP_IPPE := 6
	static SOLVEPNP_IPPE_SQUARE := 7
	static SOLVEPNP_SQPNP := 8
	static SOLVEPNP_MAX_COUNT := 8 + 1

	; HandEyeCalibrationMethod
	static CALIB_HAND_EYE_TSAI := 0
	static CALIB_HAND_EYE_PARK := 1
	static CALIB_HAND_EYE_HORAUD := 2
	static CALIB_HAND_EYE_ANDREFF := 3
	static CALIB_HAND_EYE_DANIILIDIS := 4

	; RobotWorldHandEyeCalibrationMethod
	static CALIB_ROBOT_WORLD_HAND_EYE_SHAH := 0
	static CALIB_ROBOT_WORLD_HAND_EYE_LI := 1

	; SamplingMethod
	static SAMPLING_UNIFORM := 0
	static SAMPLING_PROGRESSIVE_NAPSAC := 1
	static SAMPLING_NAPSAC := 2
	static SAMPLING_PROSAC := 3

	; LocalOptimMethod
	static LOCAL_OPTIM_NULL := 0
	static LOCAL_OPTIM_INNER_LO := 1
	static LOCAL_OPTIM_INNER_AND_ITER_LO := 2
	static LOCAL_OPTIM_GC := 3
	static LOCAL_OPTIM_SIGMA := 4

	; ScoreMethod
	static SCORE_METHOD_RANSAC := 0
	static SCORE_METHOD_MSAC := 1
	static SCORE_METHOD_MAGSAC := 2
	static SCORE_METHOD_LMEDS := 3

	; NeighborSearchMethod
	static NEIGH_FLANN_KNN := 0
	static NEIGH_GRID := 1
	static NEIGH_FLANN_RADIUS := 2

	; GridType
	static CIRCLES_GRID_FINDER_PARAMETERS_SYMMETRIC_GRID := 0
	static CIRCLES_GRID_FINDER_PARAMETERS_ASYMMETRIC_GRID := 1

	; anonymous
	static STEREO_MATCHER_DISP_SHIFT := 4
	static STEREO_MATCHER_DISP_SCALE := (BitShift(1, -cv2.STEREO_MATCHER_DISP_SHIFT))

	; anonymous
	static STEREO_BM_PREFILTER_NORMALIZED_RESPONSE := 0
	static STEREO_BM_PREFILTER_XSOBEL := 1

	; anonymous
	static STEREO_SGBM_MODE_SGBM := 0
	static STEREO_SGBM_MODE_HH := 1
	static STEREO_SGBM_MODE_SGBM_3WAY := 2
	static STEREO_SGBM_MODE_HH4 := 3

	; UndistortTypes
	static PROJ_SPHERICAL_ORTHO := 0
	static PROJ_SPHERICAL_EQRECT := 1

	; anonymous
	static FISHEYE_CALIB_USE_INTRINSIC_GUESS := BitShift(1, -0)
	static FISHEYE_CALIB_RECOMPUTE_EXTRINSIC := BitShift(1, -1)
	static FISHEYE_CALIB_CHECK_COND := BitShift(1, -2)
	static FISHEYE_CALIB_FIX_SKEW := BitShift(1, -3)
	static FISHEYE_CALIB_FIX_K1 := BitShift(1, -4)
	static FISHEYE_CALIB_FIX_K2 := BitShift(1, -5)
	static FISHEYE_CALIB_FIX_K3 := BitShift(1, -6)
	static FISHEYE_CALIB_FIX_K4 := BitShift(1, -7)
	static FISHEYE_CALIB_FIX_INTRINSIC := BitShift(1, -8)
	static FISHEYE_CALIB_FIX_PRINCIPAL_POINT := BitShift(1, -9)
	static FISHEYE_CALIB_ZERO_DISPARITY := BitShift(1, -10)
	static FISHEYE_CALIB_FIX_FOCAL_LENGTH := BitShift(1, -11)

	; WindowFlags
	static WINDOW_NORMAL := 0x00000000
	static WINDOW_AUTOSIZE := 0x00000001
	static WINDOW_OPENGL := 0x00001000
	static WINDOW_FULLSCREEN := 1
	static WINDOW_FREERATIO := 0x00000100
	static WINDOW_KEEPRATIO := 0x00000000
	static WINDOW_GUI_EXPANDED := 0x00000000
	static WINDOW_GUI_NORMAL := 0x00000010

	; WindowPropertyFlags
	static WND_PROP_FULLSCREEN := 0
	static WND_PROP_AUTOSIZE := 1
	static WND_PROP_ASPECT_RATIO := 2
	static WND_PROP_OPENGL := 3
	static WND_PROP_VISIBLE := 4
	static WND_PROP_TOPMOST := 5
	static WND_PROP_VSYNC := 6

	; MouseEventTypes
	static EVENT_MOUSEMOVE := 0
	static EVENT_LBUTTONDOWN := 1
	static EVENT_RBUTTONDOWN := 2
	static EVENT_MBUTTONDOWN := 3
	static EVENT_LBUTTONUP := 4
	static EVENT_RBUTTONUP := 5
	static EVENT_MBUTTONUP := 6
	static EVENT_LBUTTONDBLCLK := 7
	static EVENT_RBUTTONDBLCLK := 8
	static EVENT_MBUTTONDBLCLK := 9
	static EVENT_MOUSEWHEEL := 10
	static EVENT_MOUSEHWHEEL := 11

	; MouseEventFlags
	static EVENT_FLAG_LBUTTON := 1
	static EVENT_FLAG_RBUTTON := 2
	static EVENT_FLAG_MBUTTON := 4
	static EVENT_FLAG_CTRLKEY := 8
	static EVENT_FLAG_SHIFTKEY := 16
	static EVENT_FLAG_ALTKEY := 32

	; QtFontWeights
	static QT_FONT_LIGHT := 25
	static QT_FONT_NORMAL := 50
	static QT_FONT_DEMIBOLD := 63
	static QT_FONT_BOLD := 75
	static QT_FONT_BLACK := 87

	; QtFontStyles
	static QT_STYLE_NORMAL := 0
	static QT_STYLE_ITALIC := 1
	static QT_STYLE_OBLIQUE := 2

	; QtButtonTypes
	static QT_PUSH_BUTTON := 0
	static QT_CHECKBOX := 1
	static QT_RADIOBOX := 2
	static QT_NEW_BUTTONBAR := 1024

	; HistogramNormType
	static HOGDESCRIPTOR_L2Hys := 0

	; anonymous
	static HOGDESCRIPTOR_DEFAULT_NLEVELS := 64

	; DescriptorStorageFormat
	static HOGDESCRIPTOR_DESCR_FORMAT_COL_BY_COL := 0
	static HOGDESCRIPTOR_DESCR_FORMAT_ROW_BY_ROW := 1

	; EncodeMode
	static QRCODE_ENCODER_MODE_AUTO := -1
	static QRCODE_ENCODER_MODE_NUMERIC := 1
	static QRCODE_ENCODER_MODE_ALPHANUMERIC := 2
	static QRCODE_ENCODER_MODE_BYTE := 4
	static QRCODE_ENCODER_MODE_ECI := 7
	static QRCODE_ENCODER_MODE_KANJI := 8
	static QRCODE_ENCODER_MODE_STRUCTURED_APPEND := 3

	; CorrectionLevel
	static QRCODE_ENCODER_CORRECT_LEVEL_L := 0
	static QRCODE_ENCODER_CORRECT_LEVEL_M := 1
	static QRCODE_ENCODER_CORRECT_LEVEL_Q := 2
	static QRCODE_ENCODER_CORRECT_LEVEL_H := 3

	; ECIEncodings
	static QRCODE_ENCODER_ECI_UTF8 := 26

	; DisType
	static FACE_RECOGNIZER_SF_FR_COSINE := 0
	static FACE_RECOGNIZER_SF_FR_NORM_L2 := 1

	; Status
	static STITCHER_OK := 0
	static STITCHER_ERR_NEED_MORE_IMGS := 1
	static STITCHER_ERR_HOMOGRAPHY_EST_FAIL := 2
	static STITCHER_ERR_CAMERA_PARAMS_ADJUST_FAIL := 3

	; Mode
	static STITCHER_PANORAMA := 0
	static STITCHER_SCANS := 1

	; anonymous
	static DETAIL_BLENDER_NO := 0
	static DETAIL_BLENDER_FEATHER := 1
	static DETAIL_BLENDER_MULTI_BAND := 2

	; anonymous
	static DETAIL_EXPOSURE_COMPENSATOR_NO := 0
	static DETAIL_EXPOSURE_COMPENSATOR_GAIN := 1
	static DETAIL_EXPOSURE_COMPENSATOR_GAIN_BLOCKS := 2
	static DETAIL_EXPOSURE_COMPENSATOR_CHANNELS := 3
	static DETAIL_EXPOSURE_COMPENSATOR_CHANNELS_BLOCKS := 4

	; WaveCorrectKind
	static DETAIL_WAVE_CORRECT_HORIZ := 0
	static DETAIL_WAVE_CORRECT_VERT := 1
	static DETAIL_WAVE_CORRECT_AUTO := 2

	; anonymous
	static DETAIL_SEAM_FINDER_NO := 0
	static DETAIL_SEAM_FINDER_VORONOI_SEAM := 1
	static DETAIL_SEAM_FINDER_DP_SEAM := 2

	; CostFunction
	static DETAIL_DP_SEAM_FINDER_COLOR := 0
	static DETAIL_DP_SEAM_FINDER_COLOR_GRAD := 1

	; CostType
	static DETAIL_GRAPH_CUT_SEAM_FINDER_BASE_COST_COLOR := 0
	static DETAIL_GRAPH_CUT_SEAM_FINDER_BASE_COST_COLOR_GRAD := 1

	; anonymous
	static DETAIL_TIMELAPSER_AS_IS := 0
	static DETAIL_TIMELAPSER_CROP := 1

	; anonymous
	static DISOPTICAL_FLOW_PRESET_ULTRAFAST := 0
	static DISOPTICAL_FLOW_PRESET_FAST := 1
	static DISOPTICAL_FLOW_PRESET_MEDIUM := 2

	; MODE
	static DETAIL_TRACKER_SAMPLER_CSC_MODE_INIT_POS := 1
	static DETAIL_TRACKER_SAMPLER_CSC_MODE_INIT_NEG := 2
	static DETAIL_TRACKER_SAMPLER_CSC_MODE_TRACK_POS := 3
	static DETAIL_TRACKER_SAMPLER_CSC_MODE_TRACK_NEG := 4
	static DETAIL_TRACKER_SAMPLER_CSC_MODE_DETECT := 5

	; Kind
	static GFLUID_KERNEL_KIND_Filter := 0
	static GFLUID_KERNEL_KIND_Resize := 1
	static GFLUID_KERNEL_KIND_YUV420toRGB := 2

	; OpaqueKind
	static DETAIL_OPAQUE_KIND_UNKNOWN := 0
	static DETAIL_OPAQUE_KIND_BOOL := 1
	static DETAIL_OPAQUE_KIND_INT := 2
	static DETAIL_OPAQUE_KIND_INT64 := 3
	static DETAIL_OPAQUE_KIND_DOUBLE := 4
	static DETAIL_OPAQUE_KIND_FLOAT := 5
	static DETAIL_OPAQUE_KIND_UINT64 := 6
	static DETAIL_OPAQUE_KIND_STRING := 7
	static DETAIL_OPAQUE_KIND_POINT := 8
	static DETAIL_OPAQUE_KIND_POINT2F := 9
	static DETAIL_OPAQUE_KIND_SIZE := 10
	static DETAIL_OPAQUE_KIND_RECT := 11
	static DETAIL_OPAQUE_KIND_SCALAR := 12
	static DETAIL_OPAQUE_KIND_MAT := 13
	static DETAIL_OPAQUE_KIND_DRAW_PRIM := 14

	; GShape
	static GSHAPE_GMAT := 0
	static GSHAPE_GSCALAR := 1
	static GSHAPE_GARRAY := 2
	static GSHAPE_GOPAQUE := 3
	static GSHAPE_GFRAME := 4

	; MediaFormat
	static MEDIA_FORMAT_BGR := 0
	static MEDIA_FORMAT_NV12 := 0 + 1

	; ArgKind
	static DETAIL_ARG_KIND_OPAQUE_VAL := 0
	static DETAIL_ARG_KIND_OPAQUE := cv2.DETAIL_ARG_KIND_OPAQUE_VAL
	static DETAIL_ARG_KIND_GOBJREF := cv2.DETAIL_ARG_KIND_OPAQUE_VAL + 1
	static DETAIL_ARG_KIND_GMAT := cv2.DETAIL_ARG_KIND_OPAQUE_VAL + 2
	static DETAIL_ARG_KIND_GMATP := cv2.DETAIL_ARG_KIND_OPAQUE_VAL + 3
	static DETAIL_ARG_KIND_GFRAME := cv2.DETAIL_ARG_KIND_OPAQUE_VAL + 4
	static DETAIL_ARG_KIND_GSCALAR := cv2.DETAIL_ARG_KIND_OPAQUE_VAL + 5
	static DETAIL_ARG_KIND_GARRAY := cv2.DETAIL_ARG_KIND_OPAQUE_VAL + 6
	static DETAIL_ARG_KIND_GOPAQUE := cv2.DETAIL_ARG_KIND_OPAQUE_VAL + 7

	; TraitAs
	static GAPI_IE_TRAIT_AS_TENSOR := 0
	static GAPI_IE_TRAIT_AS_IMAGE := 1

	; Kind
	static GAPI_IE_DETAIL_PARAM_DESC_KIND_Load := 0
	static GAPI_IE_DETAIL_PARAM_DESC_KIND_Import := 1

	; TraitAs
	static GAPI_ONNX_TRAIT_AS_TENSOR := 0
	static GAPI_ONNX_TRAIT_AS_IMAGE := 1

	; Access
	static MEDIA_FRAME_ACCESS_R := 0
	static MEDIA_FRAME_ACCESS_W := 1

	; anonymous
	static GAPI_OWN_DETAIL_MAT_HEADER_AUTO_STEP := 0
	static GAPI_OWN_DETAIL_MAT_HEADER_TYPE_MASK := 0x00000FFF

	; Access
	static RMAT_ACCESS_R := 0
	static RMAT_ACCESS_W := 1

	; StereoOutputFormat
	static GAPI_STEREO_OUTPUT_FORMAT_DEPTH_FLOAT16 := 0
	static GAPI_STEREO_OUTPUT_FORMAT_DEPTH_FLOAT32 := 1
	static GAPI_STEREO_OUTPUT_FORMAT_DISPARITY_FIXED16_11_5 := 2
	static GAPI_STEREO_OUTPUT_FORMAT_DISPARITY_FIXED16_12_4 := 3
	static GAPI_STEREO_OUTPUT_FORMAT_DEPTH_16F := cv2.GAPI_STEREO_OUTPUT_FORMAT_DEPTH_FLOAT16
	static GAPI_STEREO_OUTPUT_FORMAT_DEPTH_32F := cv2.GAPI_STEREO_OUTPUT_FORMAT_DEPTH_FLOAT32
	static GAPI_STEREO_OUTPUT_FORMAT_DISPARITY_16Q_10_5 := cv2.GAPI_STEREO_OUTPUT_FORMAT_DISPARITY_FIXED16_11_5
	static GAPI_STEREO_OUTPUT_FORMAT_DISPARITY_16Q_11_4 := cv2.GAPI_STEREO_OUTPUT_FORMAT_DISPARITY_FIXED16_12_4

	; OutputType
	static GAPI_WIP_GST_GSTREAMER_SOURCE_OUTPUT_TYPE_FRAME := 0
	static GAPI_WIP_GST_GSTREAMER_SOURCE_OUTPUT_TYPE_MAT := 1

	; AccelType
	static GAPI_WIP_ONEVPL_ACCEL_TYPE_HOST := 0
	static GAPI_WIP_ONEVPL_ACCEL_TYPE_DX11 := 1
	static GAPI_WIP_ONEVPL_ACCEL_TYPE_LAST_VALUE := 0xFF

	; sync_policy
	static GAPI_STREAMING_SYNC_POLICY_dont_sync := 0
	static GAPI_STREAMING_SYNC_POLICY_drop := 1

	; BackgroundSubtractorType
	static GAPI_VIDEO_TYPE_BS_MOG2 := 0
	static GAPI_VIDEO_TYPE_BS_KNN := 1

	; flann_algorithm_t
	static FLANN_FLANN_INDEX_LINEAR := 0
	static FLANN_FLANN_INDEX_KDTREE := 1
	static FLANN_FLANN_INDEX_KMEANS := 2
	static FLANN_FLANN_INDEX_COMPOSITE := 3
	static FLANN_FLANN_INDEX_KDTREE_SINGLE := 4
	static FLANN_FLANN_INDEX_HIERARCHICAL := 5
	static FLANN_FLANN_INDEX_LSH := 6
	static FLANN_FLANN_INDEX_SAVED := 254
	static FLANN_FLANN_INDEX_AUTOTUNED := 255
	static FLANN_LINEAR := 0
	static FLANN_KDTREE := 1
	static FLANN_KMEANS := 2
	static FLANN_COMPOSITE := 3
	static FLANN_KDTREE_SINGLE := 4
	static FLANN_SAVED := 254
	static FLANN_AUTOTUNED := 255

	; flann_centers_Init_t
	static FLANN_FLANN_CENTERS_RANDOM := 0
	static FLANN_FLANN_CENTERS_GONZALES := 1
	static FLANN_FLANN_CENTERS_KMEANSPP := 2
	static FLANN_FLANN_CENTERS_GROUPWISE := 3
	static FLANN_CENTERS_RANDOM := 0
	static FLANN_CENTERS_GONZALES := 1
	static FLANN_CENTERS_KMEANSPP := 2

	; flann_log_level_t
	static FLANN_FLANN_LOG_NONE := 0
	static FLANN_FLANN_LOG_FATAL := 1
	static FLANN_FLANN_LOG_ERROR := 2
	static FLANN_FLANN_LOG_WARN := 3
	static FLANN_FLANN_LOG_INFO := 4

	; flann_distance_t
	static FLANN_FLANN_DIST_EUCLIDEAN := 1
	static FLANN_FLANN_DIST_L2 := 1
	static FLANN_FLANN_DIST_MANHATTAN := 2
	static FLANN_FLANN_DIST_L1 := 2
	static FLANN_FLANN_DIST_MINKOWSKI := 3
	static FLANN_FLANN_DIST_MAX := 4
	static FLANN_FLANN_DIST_HIST_INTERSECT := 5
	static FLANN_FLANN_DIST_HELLINGER := 6
	static FLANN_FLANN_DIST_CHI_SQUARE := 7
	static FLANN_FLANN_DIST_CS := 7
	static FLANN_FLANN_DIST_KULLBACK_LEIBLER := 8
	static FLANN_FLANN_DIST_KL := 8
	static FLANN_FLANN_DIST_HAMMING := 9
	static FLANN_FLANN_DIST_DNAMMING := 10
	static FLANN_EUCLIDEAN := 1
	static FLANN_MANHATTAN := 2
	static FLANN_MINKOWSKI := 3
	static FLANN_MAX_DIST := 4
	static FLANN_HIST_INTERSECT := 5
	static FLANN_HELLINGER := 6
	static FLANN_CS := 7
	static FLANN_KL := 8
	static FLANN_KULLBACK_LEIBLER := 8

	; flann_datatype_t
	static FLANN_FLANN_INT8 := 0
	static FLANN_FLANN_INT16 := 1
	static FLANN_FLANN_INT32 := 2
	static FLANN_FLANN_INT64 := 3
	static FLANN_FLANN_UINT8 := 4
	static FLANN_FLANN_UINT16 := 5
	static FLANN_FLANN_UINT32 := 6
	static FLANN_FLANN_UINT64 := 7
	static FLANN_FLANN_FLOAT32 := 8
	static FLANN_FLANN_FLOAT64 := 9

	; anonymous
	static FLANN_FLANN_CHECKS_UNLIMITED := -1
	static FLANN_FLANN_CHECKS_AUTOTUNED := -2

	; load com obj
	static CV_Init() {
		return ComObject("OpenCV.CV")
	}
	static AFFINEFEATURE_Init() => ComObject("OpenCV.CV.AFFINEFEATURE")
	static AGASTFEATUREDETECTOR_Init() => ComObject("OpenCV.CV.AGASTFEATUREDETECTOR")
	static ALGORITHM_Init() => ComObject("OpenCV.CV.ALGORITHM")
	static BFMATCHER_Init() => ComObject("OpenCV.CV.BFMATCHER")
	static BOWIMGDESCRIPTOREXTRACTOR_Init() => ComObject("OpenCV.CV.BOWIMGDESCRIPTOREXTRACTOR")
	static BRISK_Init() => ComObject("OpenCV.CV.BRISK")
	static CASCADECLASSIFIER_Init() => ComObject("OpenCV.CV.CASCADECLASSIFIER")

	static crop(Img, Pos) {
		CV := cv2.CV_Init()
		Mat := cv2.MAT_Init()

		Img := Mat.Create(Img, Pos)

		return Img
	}

	static CUDA_Init() => ComObject("OpenCV.CV.CUDA")
	static CUDABUFFERPOOL_Init() => ComObject("OpenCV.CV.CUDA.BUFFERPOOL")
	static CUDAGPUMAT_Init() => ComObject("OpenCV.CV.CUDA.GPUMAT")
	static CUDAGPUMATND_Init() => ComObject("OpenCV.CV.CUDA.GPUMATND")
	static CUDAHOSTMEM_Init() => ComObject("OpenCV.CV.CUDA.CUDAHOSTMEM")
	static CUDATARGETARCHS_Init() => ComObject("OpenCV.CV.CUDA.TARGETARCHS")

	static DESCRIPTORMATCHER_Init() => ComObject("OpenCV.CV.DESCRIPTORMATCHER")
	static DMATCH_Init() => ComObject("OpenCV.CV.DMATCH")
	static DNN_Init() => ComObject("OpenCV.CV.DNN")
	static FASTFEATUREDETECTOR_Init() => ComObject("OpenCV.CV.FASTFEATUREDETECTOR")
	static FILESTORAGE_Init() => ComObject("OpenCV.CV.FILESTORAGE")
	static FLANN_Init() => ComObject("OpenCV.CV.FLANN")
	static FLANNBASEDMATCHER_Init() => ComObject("OpenCV.CV.FLANNBASEDMATCHER")
	static FORMATTER_Init() => ComObject("OpenCV.CV.FORMATTER")
	static GENERALIZEDHOUGHGUIL_Init() => ComObject("OpenCV.CV.GENERALIZEDHOUGHGUIL")
	static GFTTDETECTOR_Init() => ComObject("OpenCV.CV.GFTTDETECTOR")
	static LINESEGMENTDETECTOR_Init() => ComObject("OpenCV.CV.LINESEGMENTDETECTOR")
	static KAZE_Init() => ComObject("OpenCV.CV.KAZE")
	static KEYPOINT_Init() => ComObject("OpenCV.CV.KEYPOINT")
	static MAT_Init() => ComObject("OpenCV.CV.MAT")
	static ML_Init() => ComObject("OpenCV.CV.ML")
	static MLKNEAREST_Init() => ComObject("OpenCV.CV.ML.KNEAREST")
	static MLTRAINDATA_Init() => ComObject("OpenCV.CV.ML.TrainData")
	static OCL_Init() => ComObject("OpenCV.CV.OCL")
	static OCLDEVICE_Init() => ComObject("OpenCV.CV.OCL.DEVICE")
	static OCLKERNELARG_Init() => ComObject("OpenCV.CV.OCL.KERNELARG")
	static OCLOPENCLEXECUTIONCONTEXT_Init() => ComObject("OpenCV.CV.OCL.OPENCLEXECUTIONCONTEXT")
	static ORB_Init() => ComObject("OpenCV.CV.ORB")
	static PCA_Init() => ComObject("OpenCV.CV.PCA")
	static QRCODEDETECTOR_Init() => ComObject("OpenCV.CV.QRCODEDETECTOR")
	static RANGE_Init() => ComObject("OpenCV.CV.RANGE")

	static CV_Resize(Img, Width := -1, Height := -1) {
		CV := cv2.CV_Init()

		if Width == -1
			Sizew := 1
		else
			Sizew := Width / Img.Cols()

		if Height == -1
			Sizeh := 1
		else
			Sizeh := Height / Img.Rows()

		Resized := CV.resize(Img, ComArrayMake([]), Sizew, Sizeh)

		return Resized
	}

	static RNG_Init() => ComObject("OpenCV.CV.RNG")
	static ROTATEDRECT_Init() => ComObject("OpenCV.CV.ROTATEDRECT")
	static SIFT_Init() => ComObject("OpenCV.CV.SIFT")
	static SIMPLEBLOBDETECTOR_Init() => ComObject("OpenCV.CV.SIMPLEBLOBDETECTOR")
	static SIMPLEBLOBDETECTOR_PARAMS_Init() => ComObject("OpenCV.CV.SIMPLEBLOBDETECTOR.PARAMS")
	static SPARSEMAT_Init() => ComObject("OpenCV.CV.SPARSEMAT")
	static STATMODEL_Init() => ComObject("OpenCV.CV.ML.STATMODEL")
	static STEREOBM_Init() => ComObject("OpenCV.CV.STEREOBM")
	static SUBDIV2D_Init() => ComObject("OpenCV.CV.SUBDIV2D")
	static SVD_Init() => ComObject("OpenCV.CV.ML.SVD")
	static SVM_Init() => ComObject("OpenCV.CV.ML.SVM")

	static TermCriteria(type, maxCount, epsilon) {
		criteria := ComObject("OpenCV.CV.TERMCRITERIA")
		criteria.type := type
		criteria.maxCount := maxCount
		criteria.epsilon := epsilon

		return criteria
	}

	static TERMCRITERIA_Init() => ComObject("OpenCV.CV.TERMCRITERIA")
	static TICKMETER_Init() => ComObject("OpenCV.CV.TICKMETER")
	static UMAT_Init() => ComObject("OpenCV.CV.UMAT")
	static UMATDATA_Init() => ComObject("OpenCV.CV.UMATDATA")
	static VECTOROFPOINT_Init() => ComObject("OpenCV.VECTOROFPOINT")
	static VIDEOCAPTURE_Init() => ComObject("OpenCV.CV.VIDEOCAPTURE")
	static VIDEOWRITER_Init() => ComObject("OpenCV.CV.VIDEOWRITER")

	static VIDEOWRITER_Fourcc_Init(Lst_Codec*) {
		Out := ComObject("OpenCV.CV.VIDEOWRITER")

		if Lst_Codec.Length !== 4
			return 0
		else {
			Codec := Out.fourcc(Ord(Lst_Codec[1]), Ord(Lst_Codec[2]), Ord(Lst_Codec[3]), Ord(Lst_Codec[4]))

			return Codec
		}
	}
}

class cv2 extends OpenCV {
	static CV := OpenCV.CV_Init()
	static none := None()

	static absdiff(src1, src2) {
		dst := this.MAT()
		toMat(dst, this.CV.Absdiff(src1.MAT, src2.MAT))

		return dst
	}

	static adaptiveThreshold(src, maxValue, adaptiveMethod := cv2.ADAPTIVE_THRESH_MEAN_C, thresholdType := cv2.THRESH_BINARY, blockSize := 3, param1 := 5) {
		dst := this.MAT()

		if Mod(blockSize, 2) == 0
			blockSize += 1

		if (src.channels() == 3)
			src := cv2.cvtColor(src, cv2.COLOR_BGR2GRAY)

		toMat(dst, this.CV.AdaptiveThreshold(src.MAT, maxValue, adaptiveMethod, thresholdType, blockSize, param1))

		return dst
	}

	static add(src1, src2) {
		dst := this.MAT()
		toMat(dst, this.CV.Add(src1.MAT, src2.MAT))

		return dst
	}

	static addWeighted(src1, alpha, src2, beta, gamma) {
		dst := this.MAT()
		toMat(dst, this.CV.AddWeighted(src1.MAT, alpha, src2.MAT, beta, gamma))

		return dst
	}

	static adjustGamma(src, gamma := 1) {
		invGamma := 1 / gamma
		table := cv2.MAT(1, 256, cv2.CV_8U)

		Loop 256 {
			table.At[0, A_Index - 1] := (((A_Index - 1) / 255.0) ** invGamma) * 255
		}

		return cv2.LUT(src, table)
	}

	static applyColorMap(src, colormap) {
		dst := this.MAT()
		toMat(dst, this.CV.ApplyColorMap(src.MAT, colormap))

		return dst
	}

	static bilateralFilter(src, d, sigmaColor, sigmaSpace, borderType := cv2.BORDER_DEFAULT) {
		dst := this.MAT()
		toMat(dst, this.CV.BilateralFilter(src.MAT, d, sigmaColor, sigmaSpace, borderType))

		return dst
	}

	static bitwise_and(src1, src2, dst, mask := noArray()) {
		this.CV.Bitwise_And(src1.MAT, src2.MAT, mask.MAT, dst.MAT)
		toMat(dst, dst.MAT)

		return dst
	}

	static bitwise_not(src, dst, mask := noArray()) {
		this.CV.Bitwise_Not(src.MAT, mask.MAT, dst.MAT)
		toMat(dst, dst.MAT)

		return dst
	}

	static bitwise_or(src1, src2, dst, mask := noArray()) {
		this.CV.Bitwise_Or(src1.MAT, src2.MAT, mask.MAT, dst.MAT)
		toMat(dst, dst.MAT)

		return dst
	}

	static bitwise_xor(src1, src2, dst, mask := noArray()) {
		this.CV.Bitwise_Xor(src1.MAT, src2.MAT, mask.MAT, dst.MAT)
		toMat(dst, dst.MAT)

		return dst
	}

	static blur(src, ksize, anchor := [-1, -1], borderType := cv2.BORDER_DEFAULT) {
		ksize := ComArrayMake(ksize)
		anchor := ComArrayMake(anchor)
		dst := this.MAT()
		toMat(dst, this.CV.Blur(src.MAT, ksize, anchor, borderType))

		return dst
	}

	static cascadeClassifier(addr := "") {
		faceCascade := this.Classifier()

		if !addr
			faceCascade.Classifier := cv2.CascadeClassifier_Init()
		else {
			faceCascade.Classifier := cv2.CascadeClassifier_Init()
			faceCascade.Classifier.load(addr)
		}

		return faceCascade
	}

	static Canny(image, threshold1, threshold2, apertureSize := 3, L2gradient := False) {
		threshold1 := (threshold1 is Array) ? threshold1[1] : threshold1
		threshold2 := (threshold2 is Array) ? threshold2[1] : threshold2

		L2gradient := CV_Bool(L2gradient)
		edges := noArray()
		this.CV.Canny(image.MAT, threshold1, threshold2, edges.MAT, apertureSize, L2gradient)
		toMat(edges, edges.MAT)

		return edges
	}

	static circle(img, center, radius, color, thickness := 1, lineType := cv2.LINE_8, shift := 0) {
		center := ComArrayMake(center)
		color := ComArrayMake(color)
		this.CV.Circle(img.MAT, center, radius, color, thickness, lineType, shift)

		return img
	}

	static close(binaryImage, ksize, kernelMode) {
		element := cv2.getStructuringElement(kernelMode, [ksize, ksize])
		dst := cv2.morphologyEx(binaryImage, 3, element)

		return dst
	}

	static contourArea(contour, oriented := False) {
		oriented := CV_Bool(oriented)

		return this.CV.ContourArea(contour, oriented)
	}

	static copyMakeBorder(src, top, bottom, left, right, borderType, value := []) {
		value := ComArrayMake(value)
		dst := this.MAT()
		toMat(dst, this.CV.CopyMakeBorder(src.MAT, top, bottom, left, right, borderType, value))

		return dst
	}

	static cornerHarris(src, blockSize, ksize, k, borderType) {
		return this.CV.cornerHarris(src, blockSize, ksize, k, borderType)
	}

	static createTrackbar(trackbarname, winname, value, count, onChange := 0) {
		if !onChange
			onChange := temp

		tmp := Buffer(8)
		tmpChange := CallbackCreate(onChange, "CDecl")
		DllCall("opencv_world490.dll\cvCreateTrackbar", "Astr", trackbarname, "Astr", winname, "ptr", tmp, "int", count, "ptr", tmpChange)

		temp(*) {
			return
		}
	}

	static cvtColor(src, code, dstCn := noArray()) {
		dst := this.MAT()
		toMat(dst, this.CV.CvtColor(src.MAT, code, dstCn.MAT))

		return dst
	}

	static destroyAllWindows() {
		this.CV.DestroyAllWindows()
	}

	static destroyWindow(wname) {
		if WinExist(wname)
			this.CV.DestroyWindow(wname)
	}

	static dft(src, flage := 0, nonzeroRow := 0) {
		dst := this.MAT()
		toMat(dst, this.CV.Dft(src.MAT, flage, nonzeroRow))

		return dst
	}

	static dilate(src, kernel, anchor := [-1, -1], iterations := 0, BorderTypes := cv2.BORDER_CONSTANT) {
		anchor := ComArrayMake(anchor)
		dst := this.MAT()
		toMat(dst, this.CV.Dilate(src.MAT, kernel.MAT, anchor, iterations, BorderTypes))

		return dst
	}

	static distanceTransform(src, distanceType, maskSize, dstType := cv2.CV_32F) {
		dst := this.MAT()
		toMat(dst, this.CV.DistanceTransform(src.MAT, distanceType, maskSize, dstType))

		return dst
	}

	static divide(src1, src2) {
		dst := this.MAT()
		toMat(dst, this.CV.Divide(src1.MAT, src2.MAT))

		return dst
	}

	static drawContours(image, contours, contourIdx, color, thickness := 1, lineType := 8, hierarchy := cv2.MAT()) {
		contours := ComArrayMake(contours)
		color := ComArrayMake(color)
		this.CV.DrawContours(image.MAT, contours, contourIdx, color, thickness, lineType, hierarchy.MAT)

		return image
	}

	static drawKeypoints(image, keypoints, outImage, color := [-1, -1, -1], flags := cv2.CV_DRAW_MATCHES_FLAGS_DEFAULT) {
		color := ComArrayMake(color)
		this.CV.DrawKeypoints(image.MAT, keypoints, outImage.MAT, color, flags)
		toMat(outImage, outImage.MAT)

		return outImage
	}

	static ellipse(img, center, axes, angle, startAngle, endAngle, color, thickness := 1, lineType := cv2.LINE_8, shift := 0) {
		center := ComArrayMake(center)
		axes := ComArrayMake(axes)
		color := ComArrayMake(color)
		this.CV.Ellipse(img.MAT, center, axes, angle, startAngle, endAngle, color, thickness, lineType, shift)

		return img
	}

	static equalizeHist(src) {
		dst := this.MAT()
		toMat(dst, this.CV.EqualizeHist(src.MAT))

		return dst
	}

	static erode(src, kernel, anchor := [-1, -1], iterations := 0, BorderTypes := cv2.BORDER_CONSTANT) {
		anchor := ComArrayMake(anchor)
		dst := this.MAT()
		toMat(dst, this.CV.Erode(src.MAT, kernel.MAT, anchor, iterations, BorderTypes))

		return dst
	}

	static fastNlMeansDenoisingColored(src, h := 3, hColor := 3, templateWindowSize := 7, searchWindowSize := 21) {
		dst := noArray()
		this.CV.FastNlMeansDenoisingColored(src.MAT, dst.MAT, h, hColor, templateWindowSize, searchWindowSize)
		toMat(dst, dst.MAT)

		return dst
	}

	static fillPoly(img, pts, color, lineType := cv2.LINE_8, shift := 0, offset := []) {
		pts := ComArrayMake([pts.MAT])
		color := ComArrayMake(color)
		offset := ComArrayMake(offset)
		dst := this.MAT()
		toMat(dst, this.CV.FillPoly(img.MAT, pts, color, lineType, shift, offset))

		return dst
	}

	static filter2D(src, ddepth, kernel, anchor := [-1, -1], delta := 0, BorderTypes := cv2.BORDER_DEFAULT) {
		anchor := ComArrayMake(anchor)
		dst := this.MAT()
		toMat(dst, this.CV.Filter2D(src.MAT, ddepth, kernel.MAT, anchor, delta, BorderTypes))

		return dst
	}

	static findContours(image, mode, method) {
		contours := this.CV.FindContours(image.MAT, mode, method)
		hierarchy := this.MAT()
		toMat(hierarchy, this.CV.extended()[1])

		return [contours, hierarchy]
	}

	static flip(img, flipcode) {
		imgflip := this.MAT()
		toMat(imgflip, this.CV.Flip(img.MAT, flipcode))

		return imgflip
	}

	static gaussianBlur(src, ksize, sigmaX, sigmaY := 0, borderType := cv2.BORDER_DEFAULT) {
		ksize := ComArrayMake(ksize)
		dst := this.MAT()
		toMat(dst, this.CV.GaussianBlur(src.MAT, ksize, sigmaX, sigmaY, borderType))

		return dst
	}

	static getNumThreads() {
		return this.CV.GetNumThreads()
	}

	static getOptimalDFTSize(vecsize) {
		return this.CV.GetOptimalDFTSize(vecsize)
	}

	static getRotationMatrix2D(center, angle, scale) {
		center := ComArrayMake(center)
		dst := this.MAT()
		toMat(dst, this.CV.GetRotationMatrix2D(center, angle, scale))

		return dst
	}

	static getStructuringElement(shape, ksize, anchor := [-1, -1]) {
		ksize := ComArrayMake(ksize)
		anchor := ComArrayMake(anchor)
		kernel := this.MAT()
		toMat(kernel, this.CV.GetStructuringElement(shape, ksize, anchor))

		return kernel
	}

	static getTextSize(text, fontFace, fontScale, thickness) {
		retval := cv2.CV.GetTextSize(text, fontFace, fontScale, thickness)
		baseLine := cv2.CV.extended()[1]

		return [retval, baseLine]
	}

	static getTickCount() {
		return this.CV.GetTickCount()
	}

	static getTickFrequency() {
		return this.CV.GetTickFrequency()
	}

	static getTrackbarPos(trackbarname, winname) {
		return this.CV.GetTrackbarPos(trackbarname, winname)
	}

	static getWindowProperty(winname, prop_id) {
		return WinExist(winname) ? this.CV.GetWindowProperty(winname, prop_id) : -1
	}

	static hConcat(arr) {
		Loop arr.Length
			arr[A_Index] := arr[A_Index].MAT

		dst := this.MAT()
		toMat(dst, this.CV.HConcat(ComArrayMake(arr)))

		return dst
	}

	static HoughLines(image, rho, theta, threshold, srn := 0, stn := 0) {
		lines := this.MAT()
		toMat(lines, this.CV.HoughLines(image.MAT, rho, theta, threshold, srn, stn))

		return lines
	}

	static HoughLinesP(image, rho, theta, threshold, minLineLegth := 0, maxLineGap := 0) {
		lines := this.MAT()
		toMat(lines, this.CV.HoughLinesP(image.MAT, rho, theta, threshold, minLineLegth, maxLineGap))

		return lines
	}

	static imdecode(buf, flags) {
		retval := this.MAT()
		toMat(retval, this.CV.Imdecode(buf, flags))

		return retval
	}

	static imdelete(img) {
		img.MAT := ""

		return img
	}

	static imencode(ext, img, params := []) {
		params := ComArrayMake(params)
		retval := this.CV.Imencode(ext, img.MAT, params)
		buf := this.CV.extended()[1]

		return [retval, buf]
	}

	static imread(filepath, flags := cv2.IMREAD_COLOR) {
		img := this.MAT()
		toMat(img, this.CV.Imread(filepath, flags))

		return img
	}

	static imshow(wname, img := "") {
		if !img {
			img := wname
			wname := "Default"
		}
		try {
			this.CV.Imshow(wname, img.MAT)
		}
	}

	static imwrite(file, img, num := -1) {
		if !InStr(file, ":")
			file := A_ScriptDir "/" file

		this.CV.Imwrite(file, img.MAT)
	}

	static inpaint(src, inpaintMask, inpaintRadius, flags) {
		dst := this.MAT()
		toMat(dst, this.CV.Inpaint(src.MAT, inpaintMask.MAT, inpaintRadius, flags))

		return dst
	}

	static inRange(src, lowerb, upperb) {
		lowerb := ComArrayMake(lowerb)
		upperb := ComArrayMake(upperb)
		dst := this.MAT()
		toMat(dst, this.CV.InRange(src.MAT, lowerb, upperb))

		return dst
	}

	static invert(src, flags := cv2.DECOMP_LU) {
		dst := this.MAT()
		toMat(dst, this.CV.Invert(src.MAT, flags))

		return dst
	}

	static laplacian(src, ddepth, ksize := 1, scale := 1, delta := 0, borderType := cv2.BORDER_DEFAULT) {
		dst := this.MAT()
		toMat(dst, this.CV.Laplacian(src.MAT, ddepth, ksize, scale, delta, borderType))

		return dst
	}

	static line(img, pt1, pt2, color, thickness := 1, lineType := cv2.LINE_8, shift := 0) {
		pt1 := ComArrayMake(pt1)
		pt2 := ComArrayMake(pt2)
		color := ComArrayMake(color)
		this.CV.Line(img.MAT, pt1, pt2, color, thickness, lineType, shift)

		return img
	}

	static loadFromCSV(filename, headerLineCount, responseStartIdx := -1, responseEndIdx := -1, varTypeSpec := "", delimiter := ',', missch := '?') {
		traindata := cv2.MLTRAINDATA_Init()
		dstdata := this.ML.TrainData()
		dstdata.traindata := traindata.LoadFromCSV(filename, headerLineCount, responseStartIdx, responseEndIdx, varTypeSpec, delimiter, missch)

		return dstdata
	}

	static log(src) {
		dst := this.MAT()
		toMat(dst, this.CV.Log(src.MAT))

		return dst
	}

	static LUT(src, lut) {
		dst := this.MAT()
		toMat(dst, this.CV.LUT(src.MAT, lut.MAT))

		return dst
	}

	static magnitude(x, y) {
		magnitude := this.MAT()
		toMat(magnitude, this.CV.Magnitude(x.MAT, y.MAT))

		return magnitude
	}

	static MAT_(param*) {
		if !param.Length {
			MAT_ := cv2.MAT()
			MAT_.MAT := cv2.MAT_Init()

			return MAT_
		}
		else {
			x := 0
			y := 0
			flag := (param[1] * param[2] == param.Length - 2) || (param[3] is Array)
			index := flag ? 2 : 3
			cvtype := (index == 2) ? cv2.CV_8UC1 : param[3]
			MAT_ := cv2.MAT()
			MAT_.MAT := cv2.MAT_Init().Create(param[1], param[2], cvtype)
			MAT_.Shape := [MAT_.MAT.Rows, MAT_.MAT.Cols, MAT_.MAT.Channels]
			MAT_.At := cv2.MAT.At(MAT_)
			if param.length = index {
				toMat(MAT_, MAT_.MAT)
				return MAT_
			}
			if param[index + 1] is Array {
				Loop param[index + 1].Length {
					if y == param[2] {
						y := 0
						x++
					}

					MAT_.At[x, y++] := param[index + 1][A_Index]
				}
			}
			else {
				Loop param.Length - index {
					if y == param[2] {
						y := 0
						x++
					}

					MAT_.At[x, y++] := param[A_Index + index]
				}
			}

			toMat(MAT_, MAT_.MAT)

			return MAT_
		}
	}

	static matchTemplate(image, templ, method) {
		result := this.MAT()
		toMat(result, this.CV.MatchTemplate(image.MAT, templ.MAT, method))

		return result
	}

	static meanStdDev(src, mask := noArray()) {
		mean := this.MAT()
		stddev := this.MAT()
		this.CV.MeanStdDev(src.MAT, mask.MAT)
		toMat(mean, this.CV.extended()[0])
		toMat(stddev, this.CV.extended()[1])

		return [mean, stddev]
	}

	static medianBlur(src, ksize) {
		dst := this.MAT()
		toMat(dst, this.CV.MedianBlur(src.MAT, ksize))

		return dst
	}

	static merge(mv) {
		Loop mv.Length
			mv[A_Index] := mv[A_Index].MAT

		dst := this.MAT()
		toMat(dst, this.CV.Merge(ComArrayMake(mv)))

		return dst
	}

	static minMaxLoc(src, mask := noArray()) {
		this.CV.MinMaxLoc(src.MAT, mask.MAT)
		min_val := this.CV.extended()[0]
		max_val := this.CV.extended()[1]
		min_loc := this.CV.extended()[2]
		max_loc := this.CV.extended()[3]

		return [min_val, max_val, min_loc, max_loc]
	}

	static morphologyEx(src, op, kernel, anchor := [-1, -1], iterations := 1, borderType := cv2.BORDER_CONSTANT, borderValue := []) {
		anchor := ComArrayMake(anchor)
		borderValue := ComArrayMake(borderValue)
		dst := this.MAT()
		this.CV.MorphologyEx(src.MAT, op, kernel.MAT, dst.MAT, anchor, iterations, borderType, borderValue)
		toMat(dst, dst.MAT)

		return dst
	}

	static multiply(src1, src2) {
		dst := this.MAT()
		toMat(dst, this.CV.Multiply(src1.MAT, src2.MAT))

		return dst
	}

	static moveWindow(winname, x, y) {
		this.CV.MoveWindow(winname, x, y)
	}

	static namedWindow(name, flags := 0) {
		this.CV.NamedWindow(name, flags)
	}

	static normalize(src, dst, alpha := 1, beta := 0, norm_type := cv2.NORM_L2, dtype := -1) {
		this.CV.Normalize(src.MAT, dst.MAT, alpha, beta, norm_type, dtype)
		toMat(dst, dst.MAT)

		return dst
	}

	static open(binaryImage, ksize, kernelMode) {
		element := cv2.getStructuringElement(kernelMode, [ksize, ksize])
		dst := cv2.morphologyEx(binaryImage, 2, element)

		return dst
	}

	static otsu(src) {
		gray := cv2.cvtColor(src, cv2.COLOR_BGR2GRAY)
		tmp := cv2.threshold(gray, 0, 255, cv2.THRESH_BINARY | cv2.THRESH_OTSU)

		return tmp
	}

	static Point(args*) {
		return ComArrayMake(args)
	}

	static polylines(img, pts, flags, color, lineType := cv2.LINE_8, shift := 0, offset := []) {
		pts := ComArrayMake([pts.MAT])
		flags := CV_Bool(flags)
		color := ComArrayMake(color)
		dst := this.MAT()
		toMat(dst, this.CV.Polylines(img.MAT, pts, flags, color, lineType, shift, offset))

		return dst
	}

	static putText(image, text, org, font, fontScale, color, thickness := 1, lineType := cv2.LINE_8) {
		org := ComArrayMake(org)
		color := ComArrayMake(color)

		this.CV.PutText(image.MAT, text, org, font, fontScale, color, thickness, lineType)
		toMat(image, image.MAT)

		return image
	}

	static QRCodeDetector() {
		qrcode := this.Detector.QRCode()
		qrcode.qrcode := cv2.QRCodeDetector_Init()

		return qrcode
	}

	static randu(src, low, high) {
		if low is Integer || low is Float
			low := ComArrayMake([low])
		else
			low := ComArrayMake(low)

		if high is Integer || high is Float
			high := ComArrayMake([high])
		else
			high := ComArrayMake(high)

		dst := this.MAT()
		toMat(dst, this.CV.Randu(src.MAT, low, high))

		return dst
	}

	static rect(args*) {
		return ComArrayMake(args)
	}

	static rectangle(img, pt1, pt2, color, thickness := 1, lineType := 8, shift := 0) {
		pt1 := ComArrayMake(pt1)
		pt2 := ComArrayMake(pt2)
		color := ComArrayMake(color)
		this.CV.Rectangle(img.MAT, pt1, pt2, color, thickness, lineType, shift)

		return img
	}

	static resize(src, dsize, fx := 0, fy := 0, interpolation := cv2.INTER_LINEAR) {
		if InStr(fx, "interpolation") {
			interpolation := Integer(Trim(StrSplit(fx, "=")[2]))
			fx := 0
		}

		dsize := ComArrayMake(dsize)
		dst := this.MAT()
		toMat(dst, this.CV.CV_Resize(src.MAT, dsize))

		return dst
	}

	static resizeWindow(name, width, height) {
		this.CV.ResizeWindow(name, width, height)
	}

	static selectROI(windowName, img := noArray(), showCrosshair := cv2.True, fromCenter := cv2.False) {
		if windowName is String
			return this.CV.SelectROI(windowName, img.MAT, showCrosshair, fromCenter)
		else {
			showCrosshair := img is ComValue ? showCrosshair : cv2.False

			return this.CV.SelectROI(windowName.MAT, img := img is ComValue ? img : cv2.True, showCrosshair)
		}
	}

	static setMouseCallback(winname, onMouse, userdata := 0) {
		if !onMouse
			onMouse := temp

		;if userdata
		;tmpdata := ObjPtrAddRef(userdata)

		tmpMouse := CallbackCreate(onMouse)
		DllCall("opencv_world490.dll\cvSetMouseCallback", "Astr", winname, "ptr", tmpMouse, "ptr", 0)

		temp(*) {
			return
		}
	}

	static setNumThreads(nthreads) {
		this.CV.SetNumThreads(nthreads)
	}

	static setTrackbarPos(trackbarname, winname, pos) {
		this.CV.SetTrackbarPos(trackbarname, winname, pos)
	}

	static setUseOptimized(bool) {
		this.CV.SetUseOptimized(CV_Bool(bool))
	}

	static setWindowProperty(winname, prop_id, prop_value) {
		this.CV.SetWindowProperty(winname, prop_id, prop_value)
	}

	static size(args*) {
		return ComArrayMake(args)
	}

	static Scharr(src, ddepth, dx, dy, scale := 1, delta := 0, borderType := cv2.BORDER_DEFAULT) {
		dst := this.MAT()
		this.CV.Scharr(src.MAT, ddepth, dx, dy, dst.MAT(), scale, delta, borderType)
		toMat(dst, dst.MAT())

		return dst
	}

	static Sobel(src, ddepth, dx, dy, ksize := 3, scale := 1, delta := 0, borderType := cv2.BORDER_DEFAULT) {
		dst := this.MAT()
		toMat(dst, this.CV.Sobel(src.MAT, ddepth, dx, dy, ksize, scale, delta, borderType))

		return dst
	}

	static Sobel_X(src, ksize := 3) {
		dst := this.MAT()
		toMat(dst, this.CV.Sobel(src.MAT, cv2.CV_64F, 1, 0, ksize))

		return dst
	}

	static Sobel_Y(src, ksize := 3) {
		dst := this.MAT()
		toMat(dst, this.CV.Sobel(src.MAT, cv2.CV_64F, 0, 1, ksize))

		return dst
	}

	static Sobel_XY(src, ksize := 3) {
		sobel_x := cv2.Sobel_X(src, ksize)
		sobel_y := cv2.Sobel_Y(src, ksize)
		dst := this.MAT()
		toMat(dst, cv2.addWeighted(sobel_x, 0.5, sobel_y, 0.5, 0))

		return dst
	}

	static split(m) {
		mv := this.CV.Split(m.MAT)
		mvl := []

		Loop mv.MaxIndex() + 1 {
			tmp := this.MAT()
			toMat(tmp, mv[A_Index - 1])
			mvl.Push(tmp)
		}

		return mvl
	}

	static startWindowThread() {
		return this.CV.StartWindowThread()
	}

	static subtract(src1, src2) {
		dst := this.MAT()
		toMat(dst, this.CV.Subtract(src1 is Integer ? cv2.MAT_Init().create(src2.MAT.Rows, src2.MAT.Cols, src2.MAT.Type, src1) : src1.MAT, src2.MAT))

		return dst
	}

	static threshold(src, thresh, maxval, type) {
		dst := this.MAT()
		ret := this.CV.Threshold(src.MAT, thresh, maxval, type)
		toMat(dst, this.CV.extended()[1])

		return [ret, dst]
	}

	static useOptimized() {
		return this.CV.UseOptimized()
	}

	static vConcat(arr) {
		Loop arr.Length
			arr[A_Index] := arr[A_Index].MAT

		dst := this.MAT()
		toMat(dst, this.CV.VConcat(ComArrayMake(arr)))

		return dst
	}

	static videoCapture(video := "") {
		Cap := this.Video()
		Cap.Video := cv2.VideoCapture_Init()

		if video !== ""
			Cap.Video.Open(video)

		return Cap
	}

	static videoWriter(filename, fourcc, fps, frame_size) {
		video := this.Video()
		video.Video := cv2.VideoWriter_Init()
		frame_size := ComArrayMake(frame_size)
		video.Video.Open(filename, fourcc, fps, frame_size)

		return video
	}

	static videoWriter_fourcc(Lst_Codec*) {
		return cv2.VideoWriter_Fourcc_Init(Lst_Codec*)
	}

	static waitKey(num := 0) {
		return cv2.CV.WaitKey(num)
	}

	static warpAffine(src, M, dsize, flags := cv2.INTER_LINEAR, borderMode := cv2.BORDER_CONSTANT, borderValue := []) {
		dsize := ComArrayMake(dsize)
		borderValue := ComArrayMake(borderValue)
		dst := this.MAT()
		this.CV.WarpAffine(src.MAT, M.MAT, dsize, dst.MAT, flags, borderMode, borderValue)
		toMat(dst, dst.MAT)

		return dst
	}

	static warpPolar(src, dsize, center, maxRadius, flags := cv2.WARP_POLAR_LINEAR) {
		dsize := ComArrayMake(dsize)
		center := ComArrayMake(center)
		dst := this.MAT()
		this.CV.WarpPolar(src.MAT, dsize, center, maxRadius, flags, dst.MAT)
		toMat(dst, dst.MAT)

		return dst
	}

	Class Classifier {
		detectMultiScale(image, scaleFactor := 1.1, minNeighbors := 3, flags := 0, minSize := [], maxSize := []) {
			minSize := ComArrayMake(minSize)
			maxSize := ComArrayMake(maxSize)

			return this.Classifier.detectMultiScale(image.MAT, scaleFactor, minNeighbors, flags, minSize, maxSize)
		}
	}

	Class Detector {
		Class QRCode {
			qrcode := 0
			detectAndDecode(img) {
				this.qrcode.detectAndDecode(img.MAT)
				Ret := []

				Loop 3
					Ret.Push(cv2.CV.extended()[A_Index - 1])

				return Ret
			}

		}
	}

	Class MAT {
		__New(param*) {
			if !param.Length {
				this.MAT := cv2.MAT_Init()

				return this
			}
			else if Type(param[1]) == "cv2.MAT" {
				this.MAT := param[1].MAT

				return this
			}
			else {
				While param.Length < 4
					param.Push(0)

				if Type(param[-1]) == "Array"
					param[-1] := ComArrayMake(param[-1])
				else
					param[-1] := ComArrayMake([param[-1]])

				toMat(this, cv2.MAT_Init().Create(param[1], param[2], param[3], param[-1]))

				return this
			}
		}

		__Delete() {
			this.MAT := ""
		}

		__Item[size*] {
			Get => this.GetMethod(this, size)
			Set => ROIMethod(this, size, value)
		}

		Clone() {
			imgclone := cv2.MAT()
			toMat(imgclone, this.MAT.Clone())

			return imgclone
		}

		Col(column) {
			imgcol := cv2.MAT()
			toMat(imgcol, this.MAT.Col(column))

			return imgcol
		}

		Copy() {
			imgcopy := cv2.MAT()
			toMat(imgcopy, this.MAT.Copy())

			return imgcopy
		}

		Copyto(dst, mask := 0) {
			if !HasProp(dst, "MAT")
				dst.MAT := cv2.MAT_Init()

			if !mask
				this.MAT.Copyto(dst.MAT)
			else
				this.MAT.Copyto(dst.MAT, mask.MAT)

			toMat(dst, dst.MAT)

			return dst
		}

		ConvertTo(rtype, alpha := 1, beta := 0) {
			dst := noArray()
			this.MAT.ConvertTo(rtype, dst.MAT, alpha, beta)
			toMat(dst, dst.MAT)

			return dst
		}

		Empty() {
			return this.MAT.Empty()
		}

		GetMethod(src, size) {
			size := ComArrayMake(size)
			dst := cv2.MAT()
			dst.MAT := (src.Cols == size[2] && src.Rows == size[3]) ? src.MAT : cv2.Crop(src.MAT, size)
			toMat(dst, dst.MAT)

			return dst
		}

		isContinuous() {
			return this.MAT.isContinuous()
		}

		Release() {
			matRelease(this)
		}

		Reshape(cn, rows := 0) {
			dst := cv2.MAT()
			toMat(dst, this.MAT.Reshape(cn, rows))

			return dst
		}

		Row(rowing) {
			imgrow := cv2.MAT()
			toMat(imgrow, this.MAT.Row(rowing))

			return imgrow
		}

		SetMethod(src, size, value) {
			NewCols := Array()

			x := size[1]
			y := size[2]
			Width := size[3]
			Height := size[4]

			cropw := (value.Cols > src.Cols - x) ? src.Cols - x : value.Cols
			croph := (value.Rows > src.Rows - y) ? src.Rows - y : value.Rows

			value := value[0, 0, cropw, croph]

			Loop src.Cols {
				index := A_Index - 1
				if A_Index - 1 < x || A_Index > width + x
					NewCols.Push(src.Col(A_Index - 1).MAT)
				else {
					tmpRows := Array()

					Loop src.Rows {
						if A_Index - 1 < y || A_Index > height + y
							tmpRows.Push(src.Col(index).MAT.Row(A_Index - 1))
						else
							tmpRows.Push(value.Col(index - x).MAT.Row(A_Index - 1 - y))
					}

					NewCols.Push(cv2.CV.vconcat(ComArrayMake(tmpRows)))
				}
			}

			src.MAT := cv2.CV.hconcat(ComArrayMake(NewCols))
		}

		SetTo(value, mask := 0) {
			value := ComArrayMake(value)

			if !mask
				this.MAT.SetTo(value)
			else
				this.MAT.SetTo(value, mask.MAT)
		}

		T() {
			dst := cv2.MAT()
			toMat(dst, this.MAT.T())

			return dst
		}

		toNumahk() {
			if isset(numahk) {
				Switch this.MAT.Type {
					Case cv2.CV_8SC1, cv2.CV_8SC2, cv2.CV_8SC3, cv2.CV_8SC4:
						dtype := numahk.int8
					Case cv2.CV_8UC1, cv2.CV_8UC2, cv2.CV_8UC3, cv2.CV_8UC4:
						dtype := numahk.uint8
					Case cv2.CV_16SC1, cv2.CV_16SC2, cv2.CV_16SC3, cv2.CV_16SC4:
						dtype := numahk.int16
					Case cv2.CV_16UC1, cv2.CV_16UC2, cv2.CV_16UC3, cv2.CV_16UC4:
						dtype := numahk.uint16
					Case cv2.CV_32SC1, cv2.CV_32SC2, cv2.CV_32SC3, cv2.CV_32SC4:
						dtype := numahk.int32
						; Case cv2.CV_32UC1, cv2.CV_32UC2, cv2.CV_32UC3, cv2.CV_32UC4:
						; 	dtype := numahk.uint32
					Case cv2.CV_32FC1, cv2.CV_32FC2, cv2.CV_32FC3, cv2.CV_32FC4:
						dtype := numahk.float32
					Case cv2.CV_64FC1, cv2.CV_64FC2, cv2.CV_64FC3, cv2.CV_64FC4:
						dtype := numahk.float64
				}
				ndarray := numahk.zeros(this.MAT.Total * this.MAT.Channels, dtype)
				memcpy(ndarray.data, this.MAT.Data, this.MAT.Total * this.MAT.Channels * numahk.type_dict[ndarray.dtype])
				return ndarray.resize(this.MAT.Shape)
			}
		}

		static zeros(rows, cols, type := -1) {
			src := cv2.MAT()

			if type !== -1
				src.MAT := cv2.MAT_Init().Zeros(rows, cols, type)
			else
				src.MAT := cv2.MAT_Init().Zeros(ComArrayMake(rows), cols)

			toMat(src, src.MAT)

			return src
		}

		static eye(rows, cols, type := -1) {
			src := cv2.MAT()

			if type !== -1
				src.MAT := cv2.MAT_Init().Eye(rows, cols, type)
			else
				src.MAT := cv2.MAT_Init().Eye(ComArrayMake(rows), cols)

			toMat(src, src.MAT)

			return src
		}

		static ones(rows, cols, type := -1) {
			src := cv2.MAT()

			if type !== -1
				src.MAT := cv2.MAT_Init().Ones(rows, cols, type)
			else
				src.MAT := cv2.MAT_Init().Ones(ComArrayMake(rows), cols)

			toMat(src, src.MAT)

			return src
		}

		Class At {
			__New(MAT) {
				this.At := MAT
			}

			__Item[x, y] {
				Get => this.GetMethod(x, y)
				Set => this.SetMethod(x, y, value)
			}

			GetMethod(x, y) {
				flag := (this.At.Type // 8) + 1
				arr := []
				loop flag
					arr.push(NumGet(this.At.Data, x * this.At.Width * flag + y * flag + A_Index - 1, "UChar"))

				return (arr.Length = 1) ? arr[1] : arr
			}

			SetMethod(x, y, value) {
				flag := (this.At.Type // 8) + 1
				value := (value is Number) ? [value] : value
				loop flag
					NumPut("UChar", value[A_Index], this.At.Data, x * this.At.Width * flag + y * flag + A_Index - 1)
			}
		}

		ToString() {
			return format("
            (
                cv2.MAT
                Channels: {}
                Data: {}
                Depth: {}
                Height: {}
                Shape: [{}, {}, {}]
                Size: [{}, {}]
                Step1: {}
                Total: {}
                Type: {}
                Width: {}
                Cols: {}
                Dims: {}
                Rows: {}
            )", this.MAT.Channels, this.MAT.Data, this.MAT.Depth, this.MAT.Height, this.MAT.Rows, this.MAT.Cols, this.MAT.Channels, this.MAT.Rows, this.MAT.Cols, this.MAT.Step1, this.MAT.Total, this.MAT.Type, this.MAT.Width, this.MAT.Cols, this.MAT.Dims, this.MAT.Rows)
		}
	}

	Class ML {
		Class SVM {
			GetUncompressedSupportVectors() {
				return this.svm.GetUncompressedSupportVectors()
			}

			Predict(samples, flags := 0) {
				dst := noArray()
				this.svm.Predict(samples.MAT, dst.MAT, flags)
				toMat(dst, dst.MAT)

				return dst
			}

			SetC(val) {
				this.svm.SetC(val)
			}

			SetGamma(val) {
				this.svm.SetGamma(val)
			}

			SetKernel(kernelType) {
				this.svm.SetKernel(kernelType)
			}

			SetTermCriteria(val*) {
				if val.Length == 3
					this.svm.SetTermCriteria(cv2.TermCriteria(val*))
				else
					this.svm.SetTermCriteria(val[1])
			}

			SetType(val) {
				this.svm.SetType(val)
			}

			Train(trainingDataMat, ROW_SAMPLE, labelsMat) {
				return this.svm.Train(trainingDataMat.MAT, ROW_SAMPLE, labelsMat.MAT)
			}

			TrainAuto(samples, layout, responses, kFold, Cgrid, gammaGrid, pGrid, nuGrid, coeffGrid, degreeGrid, balanced) {

			}

			static create() {
				svm := cv2.ML.SVM()
				svm.svm := cv2.SVM_Init().Create()

				return svm
			}

			static load(svm_file) {
				svm := cv2.ML.SVM()
				svm.svm := cv2.SVM_Init().Load(svm_file)

				return svm
			}
		}

		Class TrainData {
			getTrainSamples() {
				dst := cv2.MAT()
				toMat(dst, this.traindata.getTrainSamples())

				return dst
			}
		}
	}

	Class UMAT {
		GetMAT(flags) {
			dst := cv2.MAT()
			toMat(dst, this.MAT.GetMAT(flags))

			return dst
		}
	}

	Class Video {
		Get(propId := "") {
			if !propId
				this.Video.Get()

			return this.Video.Get(propId)
		}

		Grab() {
			return this.Video.Grab()
		}

		Open(video) {
			this.Video.Open(video)
		}

		Read() {
			Frame := cv2.MAT()
			Frame.MAT := cv2.MAT_Init()
			Ret := this.Video.Read(Frame.MAT)
			toMat(Frame, Frame.MAT)

			return [Ret, Frame]
		}

		Release() {
			Try
				this.Video.Release()
		}

		Retrieve() {
			Frame := cv2.MAT()
			Retval := this.Video.Retrieve()
			toMat(Frame, cv2.CV.extended()[1])

			return [Retval, Frame]
		}

		Set(propId, value) {
			return this.Video.Set(propId, value)
		}

		Write(frame) {
			this.Video.Write(frame.MAT)
		}
	}
}