.486                                      ; create 32 bit code
.model flat, stdcall                      ; 32 bit memory model
option casemap :none                      ; case sensitive
 
include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
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
include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\user32.inc
include \masm32\include\gdi32.inc
include \masm32\include\Advapi32.inc
include \masm32\include\masm32rt.inc
include \masm32\include\winmm.inc
includelib \masm32\lib\winmm.lib
 
.const
	VEL_X equ 3
	VEL_Y equ 3
	RECT_WIDTH_BACKUP       equ     30
	RECT_HEIGHT_BACKUP    equ     20
	WINDOW_WIDTH    equ     900
	WINDOW_HEIGHT   equ     600
	RIGHT   equ     1
	DOWN    equ     2
	LEFT    equ     3
	UP              equ     4
	MAIN_TIMER_ID equ 0
.data
	RECT_WIDTH DB 30
	RECT_HEIGHT DB 20
	PlayerX DWORD 0
	PlayerY DWORD 5
	;Facing DWORD LEFT    ;1      -       Right,  2       -Down,  3       -       Left,   4       -       Up
	ClassName DB      "TheClass",0
	windowTitle DB "A Game!",0
	JumpState DWORD 0
	StartY DWORD 400
	scoreText DB "score:        ",0
	maze DWORD 1, 569 dup (0)
	;maze DWORD 00000001,29 dup (1), 100 dup (0), 30 dup (0)
	counter DWORD 0
	yellow DWORD 0
	counter2 DWORD 0
	speed DWORD 0
	PlayerX2 DWORD 0
	PlayerY2 DWORD 0
.code
BUILDRECT       PROC,   x:DWORD,        y:DWORD, h:DWORD,       w:DWORD,        hdc:HDC,        brush:HBRUSH
	LOCAL rectangle:RECT
	mov eax, x
	mov rectangle.left, eax
	add eax, w
	mov    rectangle.right, eax
 
	mov eax, y
	mov     rectangle.top, eax
	add     eax, h
	mov rectangle.bottom, eax
 
	invoke FillRect, hdc, addr rectangle, brush
	ret
BUILDRECT ENDP

FillFields PROC, index:DWORD

	xor ecx, ecx
	mov esi, offset maze

	mov edx, LENGTHOF maze

	mov ecx, index

	mov ebx, [esi + ecx * 4]
	
	.if(ebx == 3 || ebx == 2)
		 jmp enddd
	.endif

	mov eax, 2
	mov [esi + ecx * 4], eax

	push eax
	push ecx
	push ebx
	push ecx
	push ecx
	push ecx
	push ecx
	mov eax, PlayerX ; eax, end result eax / ebx
	mov ebx, 30
	sub edx, edx          ;set edx to zero
	div ebx	

	pop ecx
	.if (edx > 0)
		dec ecx
		invoke FillFields , ecx
	.endif
	pop ecx
	.if (edx < 19)
		inc ecx
		invoke FillFields , ecx
	.endif

	pop ecx
	.if (eax > 0)
		sub ecx, 30
		invoke FillFields , ecx
	.endif
	pop ecx
	.if (eax < 29)
		add ecx, 30
		invoke FillFields , ecx
	.endif

	pop ebx
	pop ecx
	pop eax

	endd:
	

	enddd:
	ret
FillFields ENDP

CheckBounds PROC
	





	ret
CheckBounds ENDP

DoChangesInPainting PROC, index:LONG
	

	


	xor ecx, ecx
	mov esi, offset maze
	mov ecx, LENGTHOF maze
	L122:
		push ecx ; Push ecx to the stack
			

		mov edx, [esi + ecx * 4] 
		cmp edx, 1
		jne dntChange

		push ecx


		change:
			push ecx

			mov ebx, [esi + ecx * 4]

			.if (ebx == 3 || ebx == 3)
				jmp continue
			.endif

			mov eax, 2
			mov [esi + ecx * 4], eax
			
			pop ecx
			sub ecx, 30

			mov edx, [esi + ecx * 4] 
			.if (edx == 1) ; Every one (1), sWING IT
				mov eax, 3
				mov [esi + ecx * 4], eax
			
				
			.endif
			cmp edx, 1
			jne change
		continue:
		pop ecx
		dntChange:


		enddraw:
		pop ecx
		sub ecx, 1
		cmp ecx, 0
		jne L122




	ret
DoChangesInPainting ENDP
 
ProjectWndProc  PROC,   hWnd:HWND, message:UINT, wParam:WPARAM, lParam:LPARAM
        local paint:PAINTSTRUCT
        local hdc:HDC
        local brushcolouring:HBRUSH
		;local counter:LONG

		
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
		;invoke Sleep, 50
		
		mov speed, -1


        jmp checkupdown
moveright:
		mov speed, 1
		
        
		   
        jmp checkupdown
movedown:
	
		mov speed, 30
    
        jmp endmovement
moveup:
		mov speed, -30
    
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

		add counter2, 1

		.if(counter2 >= 5)
			mov ecx, 1

			.while(ecx)
			push ecx

			mov eax, PlayerX         ; get current index at the maze, add the speed to it
			add eax, speed
			
			mov PlayerX,    eax


			mov esi, offset maze     ; take addr of  maze array

			mov eax, PlayerX
			mov ecx, 1
			mov [esi + eax * 4], ecx    ; Change index in maze to one 1 - > Black


			mov eax, PlayerX ; eax, end result eax / ebx
			mov ebx, 30
			sub edx, edx          ;set edx to zero
			div ebx				; calulate col ------> index / numberOfRows
			
;			add eax, 1

			imul eax, 30

			;mov PlayerX2, eax
			mov PlayerY2, eax


			mov eax, PlayerX ; eax, end result eax / ebx
			mov ebx, 30
			sub edx, edx          ;set edx to zero
			div ebx				; calulate row ------> index / numberOfRows
			
		
			;sun edx, 1
			imul edx, 30

			mov PlayerX2, edx

			.if (speed == -1)
				mov ecx, PlayerX
				add ecx, -1
			.elseif (speed == 1)
				mov ecx, PlayerX
				add ecx, 1
			.elseif (speed == 30)
				mov ecx, PlayerX
				add ecx, 30
			.elseif (speed == -30)
				mov ecx, PlayerX
				add ecx, -30
			.endif
				
			mov eax, [esi + ecx * 4]
			.if(eax == 3) ||  eax == 2
				invoke DoChangesInPainting, 1 
				
				
			.endif


			mov counter2, 0
				pop ecx
				dec ecx
			.endw
		.endif



		.if(counter2 >= 180)
			mov counter, 0
		.endif

        invoke  BeginPaint,     hWnd,   addr paint
        mov hdc, eax

       	invoke GetStockObject,  DC_BRUSH
		mov brushcolouring, eax
		invoke SelectObject, hdc,brushcolouring
	
		invoke SetDCBrushColor, hdc, 00000027ae60h
		mov yellow, eax

		

		xor ecx, ecx
		mov esi, offset maze
		
		L122:
			push ecx ; Push ecx to the stack
			push ecx

			mov eax, ecx ; eax, end result eax / ebx
			mov ebx, 30
			sub edx, edx          ;set edx to zero
			div ebx				; calulate row
			
			add eax, 1

			imul eax, 30
			push eax

			mov eax, ecx ; eax, end result eax / ebx
			mov ebx, 30
			sub edx, edx          ;set edx to zero
			div ebx
			mov ecx, edx

			
			imul ecx, 30

			pop eax
			sub eax, 30

			pop edx

			cmp ecx, 0
			jne con1

			mov ebx, 3 ; Blue
			mov [esi + edx * 4], ebx

			con1:
			cmp ecx, 870
			jne con2

			mov ebx, 3 ; Blue
			mov [esi + edx * 4], ebx

			con2:
			cmp eax, 0
			jne con3

			mov ebx, 3 ; Blue
			mov [esi + edx * 4], ebx

			con3:
			cmp eax, 540
			jne dntChange

			mov ebx, 3 ; Blue
			mov [esi + edx * 4], ebx
		
			dntChange:
		
			mov ebx, [esi + edx * 4]    ; Check if state one
			cmp ebx, 1
			je drawGreen
			mov ebx, [esi + edx * 4]    ; Check if state one
			cmp ebx, 3
			je drawBlue

			mov ebx, [esi + edx * 4]    ; Check if state one
			cmp ebx, 2
			je drawBlue

			

			push eax
			push ecx
			push edx
			invoke SetDCBrushColor, hdc, 000000ffffffh
			mov brushcolouring, eax
			pop edx
			pop ecx
			pop eax

			
			invoke BUILDRECT, ecx , eax ,  28,  28,     hdc,  brushcolouring
			jmp enddraw

			drawBlue:
			
			push eax
			push ecx
			push edx
			invoke SetDCBrushColor, hdc, 000000f00000h
			mov brushcolouring, eax
			pop edx
			pop ecx
			pop eax

			invoke BUILDRECT, ecx , eax ,  28,  28,     hdc,  brushcolouring
			JMP enddraw

			drawGreen:

			push eax
			push ecx
			push edx
			invoke SetDCBrushColor, hdc, 0000000f0000h
			mov brushcolouring, eax
			pop edx
			pop ecx
			pop eax

			
			invoke BUILDRECT, ecx , eax ,  28,  28,     hdc,  brushcolouring
		
		


			enddraw:
			pop ecx
			add ecx, 1
			cmp ecx, LENGTHOF maze
			jne L122

	

			invoke BUILDRECT, PlayerX2 , PlayerY2 ,  28,  28,     hdc,  3



		invoke crt__itoa, counter, addr scoreText + 7, 10 ; Convert integer to string
		invoke crt_strlen, addr scoreText ;Get the length of the scoreText string
		invoke TextOutA, hdc, 10, 10, addr scoreText, eax ;Print the score


      

    ;    jmp endhere
 
		
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
mov wndcls.hbrBackground, (HBRUSH)(9) ;Set the background color as black
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
