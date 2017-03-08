# Copyright (c) 2012 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

# Regular expression to transform these constants to a form
# that can be later pasted to wiki page:
# (http://code.google.com/p/cefpython/wiki/VirtualKey)
#
# Find what: (VK_\w+) = \w+[ ]*([^\r\n]*)
# Replace with: cefpython.`\1` <i>\2</i> <br>

VK_0 = 0x30
VK_1 = 0x31
VK_2 = 0x32
VK_3 = 0x33
VK_4 = 0x34
VK_5 = 0x35
VK_6 = 0x36
VK_7 = 0x37
VK_8 = 0x38
VK_9 = 0x39

VK_A = 0x041
VK_B = 0x042
VK_C = 0x043
VK_D = 0x044
VK_E = 0x045
VK_F = 0x046
VK_G = 0x047
VK_H = 0x048
VK_I = 0x049
VK_J = 0x04A
VK_K = 0x04B
VK_L = 0x04C
VK_M = 0x04D
VK_N = 0x04E
VK_O = 0x04F
VK_P = 0x050
VK_Q = 0x051
VK_R = 0x052
VK_S = 0x053
VK_T = 0x054
VK_U = 0x055
VK_V = 0x056
VK_W = 0x057
VK_X = 0x058
VK_Y = 0x059
VK_Z = 0x05A

VK_F1 = 0x70
VK_F2 = 0x71
VK_F3 = 0x72
VK_F4 = 0x73
VK_F5 = 0x74
VK_F6 = 0x75
VK_F7 = 0x76
VK_F8 = 0x77
VK_F9 = 0x78
VK_F10 = 0x79
VK_F11 = 0x7A
VK_F12 = 0x7B
VK_F13 = 0x7C
VK_F14 = 0x7D
VK_F15 = 0x7E
VK_F16 = 0x7F
VK_F17 = 0x80
VK_F18 = 0x81
VK_F19 = 0x82
VK_F20 = 0x83
VK_F21 = 0x84
VK_F22 = 0x85
VK_F23 = 0x86
VK_F24 = 0x87

VK_LEFT = 0x25 # Left arrow key
VK_UP = 0x26 # Up arrow key
VK_RIGHT = 0x27 # Right arrow key
VK_DOWN = 0x28 # Down arrow key

VK_LSHIFT = 0xA0 # Left shift
VK_RSHIFT = 0xA1 # Right shift
VK_LCONTROL = 0xA2 # Left Ctrl
VK_RCONTROL = 0xA3 # Right Ctrl
VK_LMENU = 0xA4 # Left Alt
VK_RMENU = 0xA5 # Right Alt
VK_LALT = VK_LMENU
VK_RALT = VK_RMENU

VK_BACK = 0x08 # Backspace key
VK_RETURN = 0x0D # Enter key
VK_TAB = 0x09
VK_SPACE = 0x20 # Space bar key
VK_ESCAPE = 0x1B

VK_SHIFT = 0x10 # Shift key
VK_CONTROL = 0x11 # Ctrl key
VK_MENU = 0x12 # Alt key
VK_LWIN = 0x5B # Left Windows key
VK_RWIN = 0x5C # Right Windows key
VK_CAPITAL = 0x14 # Caps Lock key
VK_CAPSLOCK = VK_CAPITAL

VK_PRIOR = 0x21 # Page up
VK_NEXT = 0x22 # Page down
VK_PAGEUP = VK_PRIOR
VK_PAGEDOWN = VK_NEXT
VK_END = 0x23
VK_HOME = 0x24
VK_INSERT = 0x2D
VK_DELETE = 0x2E

VK_NUMLOCK = 0x90
VK_SCROLL = 0x91 # Scroll Lock key

VK_SELECT = 0x29
VK_PRINT = 0x2A
VK_EXECUTE = 0x2B
VK_SNAPSHOT = 0x2C # Print Screen key
VK_PRINTSCREEN = VK_SNAPSHOT
VK_HELP = 0x2F
VK_PAUSE = 0x13
VK_CLEAR = 0x0C
VK_APPS = 0x5D # Applications key (Natural keyboard)
VK_SLEEP = 0x5F # Computer Sleep key

VK_NUMPAD0 = 0x60 # Numeric keypad 0 key
VK_NUMPAD1 = 0x61 # Numeric keypad 1 key
VK_NUMPAD2 = 0x62 # Numeric keypad 2 key
VK_NUMPAD3 = 0x63 # Numeric keypad 3 key
VK_NUMPAD4 = 0x64 # Numeric keypad 4 key
VK_NUMPAD5 = 0x65 # Numeric keypad 5 key
VK_NUMPAD6 = 0x66 # Numeric keypad 6 key
VK_NUMPAD7 = 0x67 # Numeric keypad 7 key
VK_NUMPAD8 = 0x68 # Numeric keypad 8 key
VK_NUMPAD9 = 0x69 # Numeric keypad 9 key

VK_BROWSER_BACK = 0xA6
VK_BROWSER_FORWARD = 0xA7
VK_BROWSER_REFRESH = 0xA8
VK_BROWSER_STOP = 0xA9
VK_BROWSER_SEARCH = 0xAA
VK_BROWSER_FAVORITES = 0xAB
VK_BROWSER_HOME = 0xAC

VK_PLAY = 0xFA
VK_ZOOM = 0xFB

VK_VOLUME_MUTE = 0xAD
VK_VOLUME_DOWN = 0xAE
VK_VOLUME_UP = 0xAF
VK_MEDIA_NEXT_TRACK = 0xB0
VK_MEDIA_PREV_TRACK = 0xB1
VK_MEDIA_STOP = 0xB2
VK_MEDIA_PLAY_PAUSE = 0xB3
VK_LAUNCH_MAIL = 0xB4
VK_LAUNCH_MEDIA_SELECT = 0xB5
VK_LAUNCH_APP1 = 0xB6 # Start Application 1 key
VK_LAUNCH_APP2 = 0xB7 # Start Application 2 key

VK_MULTIPLY = 0x6A
VK_ADD = 0x6B
VK_SEPARATOR = 0x6C
VK_SUBTRACT = 0x6D
VK_DECIMAL = 0x6E
VK_DIVIDE = 0x6F

VK_LBUTTON = 0x01 # Left mouse button
VK_RBUTTON = 0x02 # Right mouse button
VK_CANCEL = 0x03 # Control-break processing
VK_MBUTTON = 0x04 # Middle mouse button (three-button mouse)

VK_XBUTTON1 = 0x05 # X1 mouse button
VK_XBUTTON2 = 0x06 # X2 mouse button

VK_KANA = 0x15 # IME Kana mode
VK_HANGUL = 0x15 # IME Hangul mode
VK_JUNJA = 0x17 # IME Junja mode
VK_FINAL = 0x18 # IME final mode
VK_HANJA = 0x19 # IME Hanja mode
VK_KANJI = 0x19 # IME Kanji mode
VK_CONVERT = 0x1C # IME convert
VK_NONCONVERT = 0x1D # IME nonconvert
VK_ACCEPT = 0x1E # IME accept
VK_MODECHANGE = 0x1F # IME mode change request

VK_PROCESSKEY = 0xE5
VK_PACKET = 0xE7
VK_ICO_HELP = 0xE3
VK_ICO_00 = 0xE4
VK_ICO_CLEAR = 0xE6
