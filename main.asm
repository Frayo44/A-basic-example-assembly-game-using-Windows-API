  .486                                      ; create 32 bit code
      .model flat, stdcall                      ; 32 bit memory model
      option casemap :none                      ; case sensitive
 
include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\user32.inc
include \masm32\include\gdi32.inc
include \masm32\include\Advapi32.inc
;include \masm32\include\masm32rt.inc
include \masm32\include\winmm.inc
includelib \masm32\lib\winmm.lib
      include \masm32\include\dialogs.inc       ; macro file for dialogs
      include \masm32\macros\macros.asm         ; masm32 macro file
          includelib \masm32\lib\gdi32.lib
     includelib \masm32\lib\user32.lib
      includelib \masm32\lib\kernel32.lib
      includelib \masm32\lib\Comctl32.lib
      includelib \masm32\lib\comdlg32.lib
      includelib \masm32\lib\shell32.lib
      includelib \masm32\lib\oleaut32.lib
      includelib \masm32\lib\ole32.lib
      includelib \masm32\lib\msvcrt.lib
 
.const
VEL_X equ 3
VEL_Y equ 3
RECT_WIDTH_BACKUP       equ     30
RECT_HEIGHT_BACKUP    equ     20
WINDOW_WIDTH    equ     800
WINDOW_HEIGHT   equ     600
RIGHT   equ     1
DOWN    equ     2
LEFT    equ     3
UP              equ     4
MAIN_TIMER_ID equ 0
.data
RECT_WIDTH       DB     30
RECT_HEIGHT       DB     20
PlayerX DWORD   400
PlayerY DWORD   400
;Facing DWORD   LEFT    ;1      -       Right,  2       -Down,  3       -       Left,   4       -       Up
ClassName       DB      "TheClass",0
windowTitle     DB      "A Game!",0
JumpState DWORD 0
StartY DWORD 400
 
.code
BUILDRECT       PROC,   x:DWORD,        y:DWORD, h:DWORD,       w:DWORD,        hdc:HDC,        brush:HBRUSH
LOCAL rectangle:RECT
mov eax, x
mov rectangle.left, eax
add eax, w
mov     rectangle.right, eax
 
mov eax, y
mov     rectangle.top, eax
add     eax, h
mov rectangle.bottom, eax
 
invoke FillRect, hdc, addr rectangle, brush
ret
BUILDRECT ENDP
 
ProjectWndProc  PROC,   hWnd:HWND, message:UINT, wParam:WPARAM, lParam:LPARAM
        local paint:PAINTSTRUCT
        local hdc:HDC
        local brushcolouring:HBRUSH
 
       
        invoke GetAsyncKeyState, VK_LEFT
        cmp eax, 0
        jne moveleft
        invoke GetAsyncKeyState, VK_RIGHT
        cmp eax, 0
        jne moveright
        checkupdown:
        invoke GetAsyncKeyState, VK_UP
        cmp eax, 0
        jne moveup
        invoke GetAsyncKeyState, VK_DOWN
        cmp eax, 0
        jne movedown      
        jmp endmovement
moveleft:
    mov RECT_HEIGHT, RECT_HEIGHT_BACKUP
    mov RECT_WIDTH, RECT_WIDTH_BACKUP
        mov eax, PlayerX
        sub eax, VEL_X
        mov PlayerX,    eax
        jmp checkupdown
moveright:
    mov RECT_HEIGHT, RECT_HEIGHT_BACKUP
        mov RECT_WIDTH, RECT_WIDTH_BACKUP
        mov eax, PlayerX
        add eax, VEL_X
        mov PlayerX, eax      
        jmp checkupdown
movedown:
    mov RECT_HEIGHT, RECT_WIDTH_BACKUP
    mov RECT_WIDTH, RECT_HEIGHT_BACKUP
        mov eax, PlayerY
        add eax, VEL_Y
        mov PlayerY, eax      
        jmp endmovement
moveup:
    mov RECT_HEIGHT, RECT_WIDTH_BACKUP
    mov RECT_WIDTH, RECT_HEIGHT_BACKUP
        mov eax, PlayerY
        sub eax, VEL_X
        mov PlayerY, eax      
        jmp endmovement
 
endmovement:
       
 
        cmp     message,        WM_PAINT
        je      painting
        cmp message,    WM_CLOSE
        je      closing
        ;cmp message,    WM_KEYDOWN
        ;je      movement
        ;cmp message,   WM_KEYUP
        ;je     stopmovement
        cmp message,    WM_TIMER
        je      timing
        jmp OtherInstances
       
       
        closing:
        invoke ExitProcess, 0
 
 
 
        painting:
        invoke  BeginPaint,     hWnd,   addr paint
        mov hdc, eax
        invoke GetStockObject,  DC_BRUSH
        mov brushcolouring, eax
        invoke SetDCBrushColor, hdc,    000000FF0000h
        mov brushcolouring, eax
       
        jmp endhere
 
endhere:
        cmp PlayerY, 600
        jge BottomBorder
        cmp PlayerY, 0
        jle TopBorder
        cmp PlayerX, 800
        jge RightBorder
        cmp PlayerX, 0
        jle LeftBorder
        jmp realend
BottomBorder:
        mov eax, 0
        mov PlayerY, eax
        jmp realend
TopBorder:
        mov eax, 600
        mov PlayerY, eax
        jmp realend
RightBorder:
        mov eax, 0
        mov PlayerX, eax
        jmp realend
LeftBorder:
        mov eax, 800
        mov PlayerX, eax
        jmp realend
realend:
        invoke BUILDRECT, PlayerX,      PlayerY,  RECT_HEIGHT,  RECT_WIDTH,     hdc,  brushcolouring
        invoke EndPaint, hWnd,  addr paint
        ret
 
 
timing:
        invoke InvalidateRect, hWnd, NULL, TRUE
        ret
OtherInstances:
        invoke DefWindowProc, hWnd, message, wParam, lParam
        ret
ProjectWndProc  ENDP
 
main PROC
 
LOCAL wndcls:WNDCLASSA ; Class struct for the window
LOCAL hWnd:HWND ;Handle to the window
LOCAL msg:MSG
invoke RtlZeroMemory, addr wndcls, SIZEOF wndcls ;Empty the window class
mov eax, offset ClassName
mov wndcls.lpszClassName, eax ;Set the class name
invoke GetStockObject, BLACK_BRUSH
mov wndcls.hbrBackground, eax ;Set the background color as black
mov eax, ProjectWndProc
mov wndcls.lpfnWndProc, eax ;Set the procedure that handles the window messages
invoke RegisterClassA, addr wndcls ;Register the class
invoke CreateWindowExA, WS_EX_COMPOSITED, addr ClassName, addr windowTitle, WS_SYSMENU, 100, 100, WINDOW_WIDTH, WINDOW_HEIGHT, 0, 0, 0, 0 ;Create the window
mov hWnd, eax ;Save the handle
invoke ShowWindow, eax, SW_SHOW ;Show it
invoke SetTimer, hWnd, MAIN_TIMER_ID, 20, NULL ;Set the repaint timer
 
msgLoop:
 ; PeekMessage
invoke GetMessage, addr msg, hWnd, 0, 0 ;Retrieve the messages from the window
mov eax, 55
invoke DispatchMessage, addr msg ;Dispatches a message to the window procedure
jmp msgLoop
invoke ExitProcess, 1
main ENDP
end main
