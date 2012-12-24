#
# Browser.SaveImage()
#

cpdef py_bool SaveImage(self, py_string filePath,
        str imageType="bitmap"):
    assert IsCurrentThread(TID_UI), (
            "Browser.SaveImage(): this method should only be called "
            "on the UI thread")

    cdef tuple size = self.GetSize(PET_VIEW)
    cdef int width, height
    if size:
        (width, height) = size
    else:
        return False

    cdef char* charFilePath = filePath
    cdef int filePathLength = strlen(charFilePath)
    cdef wchar_t* widecharFilePath = <wchar_t*>calloc(
            filePathLength, wchar_t_size)
    CharToWidechar(charFilePath, widecharFilePath, filePathLength)

    cdef void* bits

    cdef BITMAPINFOHEADER bitmapInfoHeader
    bitmapInfoHeader.biSize = sizeof(BITMAPINFOHEADER)
    bitmapInfoHeader.biWidth = width
    bitmapInfoHeader.biHeight = -height # minus means top-down bitmap
    bitmapInfoHeader.biPlanes = 1
    bitmapInfoHeader.biBitCount = 32
    bitmapInfoHeader.biCompression = BI_RGB # no compression
    bitmapInfoHeader.biSizeImage = 0
    bitmapInfoHeader.biXPelsPerMeter = 1
    bitmapInfoHeader.biYPelsPerMeter = 1
    bitmapInfoHeader.biClrUsed = 0
    bitmapInfoHeader.biClrImportant = 0

    cdef BITMAPINFO* bitmapInfo
    bitmapInfo = <BITMAPINFO*>calloc(1, sizeof(BITMAPINFO))
    bitmapInfo.bmiHeader = bitmapInfoHeader

    cdef HDC screen_dc = GetDC(NULL)
    cdef HBITMAP bitmap = CreateDIBSection(
            screen_dc, bitmapInfo, DIB_RGB_COLORS, &bits, NULL, 0)
    ReleaseDC(NULL, screen_dc)

    cdef PaintBuffer

    if bitmap:
        # cefclient_win.cpp > UIT_RunGetImageTest
        # TODO...

    free(widecharFilePath)
    free(bitmapInfo)

    return True

#
# windows.pxd:
#

    ctypedef struct BITMAPINFOHEADER:
        DWORD biSize
        LONG  biWidth
        LONG  biHeight
        WORD  biPlanes
        WORD  biBitCount
        DWORD biCompression
        DWORD biSizeImage
        LONG  biXPelsPerMeter
        LONG  biYPelsPerMeter
        DWORD biClrUsed
        DWORD biClrImportant
    ctypedef struct RGBQUAD:
        pass
    ctypedef struct BITMAPINFO:
        BITMAPINFOHEADER bmiHeader
        RGBQUAD          bmiColors[1]
    cdef DWORD BI_RGB
    cdef HDC GetDC(HWND hWnd)
    cdef HBITMAP CreateDIBSection(
        HDC hdc,
        BITMAPINFO *pbmi,
        UINT iUsage,
        void **ppvBits,
        HANDLE hSection,
        DWORD dwOffset)
    cdef UINT DIB_RGB_COLORS
    cdef int ReleaseDC(HWND hWnd,HDC hDC)