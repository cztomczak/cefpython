#pragma once

// DialogTemplate - taken from here: 
// http://www.flipcode.com/archives/Dialog_Template.shtml
// http://www.flipcode.com/archives/An_assert_Replacement.shtml

#include <windows.h>

class DialogTemplate
{

public:

    DialogTemplate(LPCSTR caption, DWORD style, DWORD exStyle, int x, int y, int w, int h,
        LPCSTR font, WORD fontSize);

    void AddComponent(LPCSTR type, LPCSTR caption, DWORD style, DWORD exStyle,
        int x, int y, int w, int h, WORD id);

    void AddButton(LPCSTR caption, DWORD style, DWORD exStyle, int x, int y,
        int w, int h, WORD id);

    void AddEditBox(LPCSTR caption, DWORD style, DWORD exStyle, int x, int y,
        int w, int h, WORD id);

    void AddStatic(LPCSTR caption, DWORD style, DWORD exStyle, int x, int y,
        int w, int h, WORD id);

    void AddListBox(LPCSTR caption, DWORD style, DWORD exStyle, int x, int y,
        int w, int h, WORD id);
    
    void AddScrollBar(LPCSTR caption, DWORD style, DWORD exStyle, int x, int y,
        int w, int h, WORD id);

    void AddComboBox(LPCSTR caption, DWORD style, DWORD exStyle, int x, int y,
        int w, int h, WORD id);

    operator const DLGTEMPLATE*() const
    {
        return dialogTemplate;
    }

    virtual ~DialogTemplate()
    {
        free(dialogTemplate);
    }

protected:

    void AddStandardComponent(WORD type, LPCSTR caption, DWORD style,
        DWORD exStyle, int x, int y, int w, int h, WORD id);

    void AlignData(int size);

    void AppendString(LPCSTR string);

    void AppendData(void* data, int dataLength);

    void EnsureSpace(int length);

private:

    DLGTEMPLATE* dialogTemplate;

    int totalBufferLength;
    int usedBufferLength;
    
};