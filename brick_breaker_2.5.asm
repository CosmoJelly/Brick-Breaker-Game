;GROUP MEMBERS:
;WALEED NOUMAN
;WAJEEH UL HASSAN
;HYSEM KHAN
;MAHEEN KAMAL

dosseg 
.model small
.stack 100h

.data  

;-------USED BY MACROS-------------
me db "wajeeeh"
scoreCount dw 04
count dw 04
count1 db 51
livesCount dw 03,03,03
str_score db 'Score: $' ; score string
score dw 0 
str_lives db '              Lives: $'
lifelines db 03    ; ascii of three
start_pos_x dw ? ; start x
start_pos_y dw ? ; start y
end_pos_x dw ? ; end x
end_pos_y dw ? ; end y
color db ?
ball_left db 1 ; ball left direction
ball_up db 1 ; ball up direction
start_pos db 0
striker_x dw 140 ; striker X position
striker_y dw 170 ; striker Y position
internal_delay db 0 ; inner delay
bound_end dw 250
bound_start dw 30
lives db '              Lives: '
delay_counter db 3 ; delay counter
ball_vel dw 2

;GAME OVER MSG:

str_game_over_func  db "  G A M E     O V E R "   ; 22 chars
str_level1 db "L E V E L   1"
str_level2 db "L E V E L   2"
str_level3 db "L E V E L   3"

striker_width_increase dw 0  ; with of striker increases by 15 in each level
striker_width dw 40
brick1x dw 45
brick1y dw 25
brick2x dw 85
brick2y dw 25
brick3x dw 125
brick3y dw 25
brick4x dw 165
brick4y dw 25
brick5x dw 205
brick5y dw 25
brick6x dw 245
brick6y dw 25

bricks_x_cordinates dw 45, 85, 125, 165, 205, 245, 45, 85, 125, 165, 205, 245
bricks_y_cordinates dw 25, 25, 25, 25, 25, 25, 45, 45, 45, 45, 45, 45



brick7x dw 45
brick7y dw 45
brick8x dw 85
brick8y dw 45
brick9x dw 125
brick9y dw 45
brick10x dw 165
brick10y dw 45
brick11x dw 205
brick11y dw 45
brick12x dw 245
brick12y dw 45

temp_x dw ?
temp_y dw ?

;-----------------------------------

ball_reset_x DW 163d                       ;current X position (column) of the ball
ball_reset_y DW 158d                        ;current Y position (line) of the ball

level dw 0


paddle_x DW 140                 ;current X position of the left paddle
paddle_y DW 170                 ;current Y position of the left paddle
paddle_height DW 06h                  ;default paddle width
paddle_width DW 25h                 ;default paddle height
paddle_velocity DW 4h               ;default paddle velocity

;-------SCREEN MODE-------------

_welcome db "THE BRICK BREAKER GAME" 
_enter db "ENTER YOUR NAME UPTO 8 LETTERS"
_name db 8 DUP('$')
_over db "GAME OVER"
_again db "Press ESC to Start Again"
_quit db "Press ENTER to Quit"
_level db "Level:"
_score db "Score:"
_cursor db 6

;-----------------------------------

FNAME db "name.txt", 0
FNAME1 db "score.txt", 0

fsaver db 500 DUP('$')

FHANDLE dw 0
FHANDLE1 dw 0
rhandle dw 0
rhandle1 dw 0

menu        db "    ", 13, 10
            db "    THE  BRICK BREAKER", 13, 10
            db "    ", 13, 10
            db "    ENTER YOUR CHOICE OF LEVEL!", 13, 10
            db "    ", 13, 10
            db "      	 1. LEVEL 1", 13, 10
			db "    ", 13, 10
            db "      	 2. LEVEL 2", 13, 10
			db "    ", 13, 10
            db "       	 3. LEVEL 3", 13, 10
			db "    ", 13, 10
			db "       	 4. SCOREBOARD", 13, 10
			db "    ", 13, 10
			db "       	 ESC. EXIT GAME", 13, 10
			db "    ", 13, 10
			db "    ", 13, 10
			db "    ", 13, 10
			db "    ", 13, 10
			db "    ", 13, 10
			db "    ", 13, 10
			db "    ", 13, 10
			db "    ", 13, 10
            db "    ", 13, 10, '$'







.code 
;------------------MACROS-----------------------
build_brick_func macro  A, B ; build brick macro
    push ax 
    push bx 
    mov ax, A ; set x
    mov bx, B ; set y
    call create_brick_func ; add brick function defined below
    pop bx 
    pop ax
endm ; end build brick macro

destroy_brick_func macro  A, B ; destroy brick macro

    push ax 
    push bx
    mov ax, A ; set x
    mov bx, B ; set y

    mov temp_x, ax
    mov temp_y, bx
    call remove_brick_func ; remove brick function defined below
    call play_sound 
    inc score
    call draw_lives_scores_func
    pop bx
    pop ax
endm

brick_collision_func MACRO X, Y ;brick collision macro
local bop 
    push ax 
    push bx
    push cx
    push dx
    mov ax, ball_reset_y   
    mov bx, ball_reset_x
    mov cx, X
    mov dx, Y
    
    cmp dx, ball_reset_y
    jl bop             ;  Y cord brick > Y cord of ball 
    sub dx, 7              
    
    cmp ball_reset_y, dx
    jl bop
    
    
    mov dx, X            
    
    cmp ball_reset_x, dx        ; x cord of ball > x cord of the brick 
    jl bop
    add dx, 30
    cmp dx, ball_reset_x
    jl bop
    
    ;; collisoin 
    destroy_brick_func X, Y
    mov Y, 300
    cmp score, 12
    jne bop

    

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    inc level
    call call_next_level

    bop:
    pop dx
    pop cx
    pop bx
    pop ax                      
    
endm

redraw_striker_func macro visColor ; redraw striker macro

mov color, visColor ; set color
call draw_striker_func ; draw striker
endm ; end redraw striker macro

redraw_ball_func macro visColor ; redraw ball macro
    mov color, visColor ; set color
    call draw_ball ; draw ball
endm ; end redraw ball macro

;------------------------------------------------

Main proc
	mov ax, @data
	mov ds, ax  

    
    CALL frame_update_set

	CALL video_mode_set

	call clear_screen_set
    ;--testing----
    
    ;-------------
	call read_name_func
	call clear_screen_set
	call start_screen_func
	call clear_screen_set
	call display_menu
	


	mov ah, 4ch 
	int 21h

Main endp

video_mode_set proc 
    
    mov ah, 0   ; set display mode function.
    mov al, 13h ; mode 13h = 320x200 pixels, 256 colors.
    int 10h     
    ret

video_mode_set endp

clear_screen_set PROC  ;clear screen 

		;CALL video_mode_set
	
		mov ah, 06h 
		mov al, 0
		mov bh, 00h
		mov bl, 0
		mov cx,0
		mov dh,50
		mov dl,50
		int 10h

	ret 	
clear_screen_set ENDP

frame_update_set PROC  ;clear the screen by restarting the video mode
	
			MOV AH,00h                   ;set the configuration to video mode
			MOV AL,13h                   ;choose the video mode
			INT 10h    					 ;execute the configuration 
		
			MOV AH,0Bh 					 ;set the configuration
			MOV BH,00h 					 ;to the background color
			MOV BL,00h 					 ;choose black as background color
			INT 10h    					 ;execute the configuration
			
			RET
			

frame_update_set ENDP	

display_menu PROC
    

    xor dx, dx
    mov  dx, offset menu
    mov  ah, 9
    int  21h

	
	xor ax,ax ; same as mov ax, 0 , but with additional capability of setting the flag to zero and clearing carry
	mov  ah, 7   ; single character input
    int  21h

	
	cmp al, 49D

	je ll1

    cmp al, 50D
    je ll2


    cmp al, 51d
    je ll3


	

	ll1: 
    call level1
    

    ll2: 
    call level2

    ll3:
    call level3
	
    ret
display_menu ENDP

start_screen_func PROC
	

	mov ah,02h  ;set cursor
	mov dh,8
	mov dl,_cursor
	int 10h
	mov cx,22 ; length of _welcome string
	mov si,offset _welcome

	LoopWelcome:
	    push cx
	    mov al,[si]
	    mov bh,0
	    mov bl,15
	    mov cx,1
	    mov ah,0Ah
	    int 10h
	    add si, TYPE _welcome
	    add _cursor,1
	    mov ah,02h
	    mov dh,8
	    mov dl,_cursor
	    int 10h

	    pop cx
	LOOP LoopWelcome

	mov _cursor,5
	mov ah,02h  ;set cursor
	mov dh,10
	mov dl,_cursor
	int 10h
	mov cx,30
	mov si,offset _enter

	LoopEnter:
	    push cx

	    mov al,[si]
	    mov bh,0
	    mov bl,15
	    mov cx,1
	    mov ah,0Ah
	    int 10h
	    add si, TYPE _enter
	    inc _cursor
	    mov ah,02h
	    mov dh,10
	    mov dl,_cursor
	    int 10h

	    pop cx
	LOOP LoopEnter


	mov _cursor,16
	mov ah,02h  ;set cursor
	mov dh,12
	mov dl,_cursor
	int 10h
	mov cx,8
	mov si,offset _name
	LoopName:
	    push cx

	    mov ah,01h
	    int 21h
	    mov [si],al
	    add si, TYPE _name
	    inc _cursor
	    mov ah,02h
	    mov dh,12
	    mov dl,_cursor
	    int 10h

	    pop cx
	LOOP LoopName
    ;========================file handling========================
			;===========file creation=====================
	MOV AH,3CH 		;3ch: file creation, 3eh: file closes
	MOV CL,2		;to write/read
	
	MOV DX, OFFSET FNAME
	INT 21H
	MOV FHANDLE,AX


	;LOAD FILE HANDLE
		lea dx, fname         ; Load address of String “file”
		mov al, 2                   ; Open file (write/read)
		mov ah, 3Dh                 ; Load File Handler and store in ax
		int 21h
		mov fhandle, ax
	
			
;WRITE IN FILE
		mov cx, LENGTH _name       ; Number of bytes to write
		mov bx, fhandle              ; Move file Handle to bx
		lea dx, _name               ; Load offset of string which is to be written to file
		mov ah, 40h                 ; Write to file
		int 21h
		
ret
start_screen_func endp

level1 proc
    
    ;----------- RESET VALUES OF VARIABLES ---------------
    mov al, 51
    mov lifelines, al
    mov al, 0
    mov start_pos, al
    mov ax, 0 
    mov score, ax

    mov ax, 140
    mov striker_x, ax
    mov ax, 170
    mov striker_y, ax ; striker Y position
   
    mov ax, 250
    mov bound_end, ax 
    mov ax, 30
    mov bound_start, ax
    xor ax, ax

    ;----------------------------------------------------

    ;----------------------Approach 1---------------------------------------
	
    call video_mode_set
	call clear_screen_set
	call draw_bricks
	call draw_boundary_func
    redraw_striker_func 7
    redraw_ball_func 3                
    call draw_lives_scores_func
    call display_level1
    
    repeat:
    infinite_loop:
    

    CALL    input_check_func    ; to move the striker and ball waghaira
    cmp start_pos,1
    jne repeat    ; to not start game until space pressed and start_pos bool value becomes 1

    
    call wall_collision_func               ; check collision with wall
    call striker_collision_func            ; check collision with stricker
    call check_brick_collision
    CALL baller                      ; balll movement waghaira
    CALL sleep

    
    jmp infinite_loop


ret

level1 endp

level2 proc

     
	
    ;----------- RESET VALUES OF VARIABLES ---------------
   
    
    mov ax, striker_x    ; BALL BUILD ON STRIKER
    mov ball_reset_x,ax
    add ball_reset_x,18
     
    mov ball_reset_y,  163
    
    redraw_ball_func 3
    mov ball_up, 1     ;monis
    mov ball_left,0  ; now ball reset



    mov al, 51
    mov lifelines, al
    mov al, 0
    mov start_pos, al
    mov ax, 0 
    mov score, ax

    mov ax, 140
    mov striker_x, ax
    mov ax, 170
    mov striker_y, ax ; striker Y position
   
    mov ax, 250
    
    mov bound_end, ax 
    mov ax, 30
    mov bound_start, ax
    xor ax, ax

    redraw_ball_func 0
    redraw_striker_func 0

    ;---------------------------------------------------

    ;----------------------Approach 1---------------------------------------
    
	add ball_vel, 2
    add striker_width, 15
    sub bound_end, 15
    

    call video_mode_set
	call clear_screen_set
	call draw_bricks
	call draw_boundary_func
    redraw_striker_func 7
    redraw_ball_func 3                
    call draw_lives_scores_func
    call level2_display


    repeat2:
    infinite_loop2:

    CALL    input_check_func    ; to move the striker and ball waghaira
    cmp start_pos,1
    jne repeat2    ; to not start game until space pressed and start_pos bool value becomes 1

    
    call wall_collision_func               ; check collision with wall
    call striker_collision_func            ; check collision with stricker
    call check_brick_collision
    CALL baller                      ; balll movement waghaira
    CALL sleep


    jmp infinite_loop2


ret

level2 endp

level3 proc

     
	
    ;----------- RESET VALUES OF VARIABLES ---------------
    
    
    mov ax, striker_x    ; BALL BUILD ON STRIKER
    mov ball_reset_x,ax
    add ball_reset_x,18
    
    mov ball_reset_y,  163
    
    redraw_ball_func 3
    mov ball_up, 1     ;monis
    mov ball_left,0

    

    mov al, 51
    mov lifelines, al
    mov al, 0
    mov start_pos, al
    mov ax, 0 
    mov score, ax

    mov ax, 140
    mov striker_x, ax
    mov ax, 170
    mov striker_y, ax ; striker Y position
   
    mov ax, 250
    
    mov bound_end, ax 
    mov ax, 30
    mov bound_start, ax
    xor ax, ax
    redraw_ball_func 0
    redraw_striker_func 0

    ;---------------------------------------------------

    ;----------------------Approach 1---------------------------------------
    
	add ball_vel, 2
    add striker_width, 15
    sub bound_end, 15
    

    call video_mode_set
	call clear_screen_set
	call draw_bricks
	call draw_boundary_func
    redraw_striker_func 7
    redraw_ball_func 3                
    call draw_lives_scores_func
    call display_level3
    repeat3:
    
    infinite_loop3:

    CALL    input_check_func    ; to move the striker and ball waghaira
    cmp start_pos,1
    jne repeat3    ; to not start game until space pressed and start_pos bool value becomes 1

    
    call wall_collision_func               ; check collision with wall
    call striker_collision_func            ; check collision with stricker
    call check_brick_collision
    CALL baller                      ; balll movement waghaira
    CALL sleep


    jmp infinite_loop3


ret

level3 endp

;----------------------------------------

read_name_func proc

		lea dx, fname1           ; Load address of String “file”
		mov al, 0                   ; Open file (read)
		mov ah, 3Dh                 ; Load File Handler and store in ax

		MOV DX, OFFSET FNAME
		int 21h
		mov rhandle, ax
	
	;READ FROM FILE
		mov bx, rhandle              ; Move file Handle to bx
		lea dx, fsaver         ; Load             
		mov ah, 3Fh                 ; Function to read from file
		int 21h
ret
read_name_func endp

save_score_func PROC
call clear_screen_set
xor ah,ah
	;setting graphic mode back to text mode
	mov al,3
	int 10h
	    ;================== SCORE SAVING
		MOV AH,3CH 		;3ch: file creation, 3eh: file closes
		MOV CL,2		;to write/read
	
		MOV DX, OFFSET FNAME1
		INT 21H
		MOV FHANDLE1,AX


		;LOAD FILE HANDLE
		lea dx, fname1         ; Load address of String “file”
		mov al, 2                   ; Open file (write/read)
		mov ah, 3Dh                 ; Load File Handler and store in ax
		int 21h
		mov fhandle1, ax
	
			
		;WRITE IN FILE
		mov cx, LENGTH score      ; Number of bytes to write
		mov bx, fhandle1   
		mov ax,score           ; Move file Handle to bx
		add ax,'0'
		mov score,ax
		lea dx, score            ; Load offset of string which is to be written to file
		mov ah, 40h                 ; Write to file
		int 21h

		;CLOSE FILE HANDLE
		mov ah, 3Eh
		mov bx, fhandle1
		int 21h
		;=========================================

save_score_func ENDP

;-----------------------------------------

;-------------MACRO FUNCS----------------------

create_brick_func proc
    push ax
    push bx    
    mov start_pos_x, ax
    mov color, 3 
    mov ax, bx
    mov bx, start_pos_x
    
    add bx, 30
    
    mov end_pos_x,bx
    
    mov start_pos_y, ax 
    
    mov bx,start_pos_y
                    
    add bx,7
    mov end_pos_y,bx
     
    call draw
    pop bx
    pop ax 
    ret
create_brick_func endp

remove_brick_func proc 
    
    push ax
    push bx
    push cx
    push dx
       
    mov start_pos_x, ax
    mov color, 0  
    mov ax, bx
    mov bx, start_pos_x
    
    add bx, 30
    
    mov end_pos_x,bx
    
    mov start_pos_y, ax 
    
    mov bx,start_pos_y
    
    add bx,7
    mov end_pos_y,bx
     
    call draw 
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
remove_brick_func endp

print_score proc
    push ax
    push bx
    push cx
    push dx

    
    mov cx,0
    
    mov ax, scoreCount
    ll:
    mov bx,10D
    mov dx,0
    div bx
    push dx
    inc cx
    cmp ax,0
    jne ll
    
    l2:
    pop dx
    mov ah,2
    add dl,'0'
    int 21h
    loop l2
    
    pop dx
    pop cx
    pop bx
    pop ax
    
    ret
    print_score endp

draw proc
    push ax
    push cx
    push dx
     
    mov dx,start_pos_y
    mov cx,start_pos_x
    mov ah,0ch
    mov al,color
    c:
    inc cx
    int 10h
    cmp cx,end_pos_x
    jne c

    mov cx,start_pos_x
    inc dx
    cmp dx,end_pos_y
    jne c 
    
    pop dx
    pop cx
    pop ax
    ret
draw endp

draw_bricks proc 
    push cx
    push si 
    push bx
  
    ;---- -----

    mov cx, 12 
    mov si, 0

    cout_bricks:
        
        build_brick_func bricks_x_cordinates[si] bricks_y_cordinates[si]

    
        add si, 2
        add bx, 2



    loop cout_bricks
    ;----------

    pop bx
    pop si 
    pop cx


	ret
draw_bricks endp

check_brick_collision proc  ; functionality works manually but 
    



    brick_collision_func Brick1x Brick1y
   	brick_collision_func Brick2x Brick2y
   	brick_collision_func Brick3x Brick3y
   	brick_collision_func Brick4x Brick4y
   	brick_collision_func Brick5x Brick5y
   	brick_collision_func Brick6x Brick6y 
   	brick_collision_func Brick7x Brick7y
   	brick_collision_func Brick8x Brick8y
    brick_collision_func Brick9x Brick9y
   	brick_collision_func Brick10x Brick10y
   	brick_collision_func Brick11x Brick11y
  	brick_collision_func Brick12x Brick12y

	ret
check_brick_collision endp

sleep proc

mov cx,111111111111111b 

l:
loop l
ret
sleep endp

draw_ball proc                                   
    push bx
    mov bx, ball_reset_x
    mov start_pos_x, bx
    add bx, 4 
    mov end_pos_x,   bx
    mov bx, ball_reset_y
    mov start_pos_y, bx
    add bx, 4
    mov end_pos_y,   bx
    
    pop bx
    
    call draw
ret
draw_ball endp

striker_collision_func proc                               ; $ball
    push ax
    push bx
    push cx
    push dx
    
    mov dx, ball_reset_y
    cmp dx, 165 ; striker surface check
    jge chalou
    pop dx
    pop cx
    pop bx
    pop ax
    ret

    chalou:
    cmp dx, 170 ; striker missed
    jg fail 
    
    mov cx,striker_x   
    mov ax, ball_reset_x   
    cmp ax, cx  
    jl bhaag
    add cx , striker_width;40 
    cmp ax, cx
    jg bhaag
    
    mov ball_up, 1
    jmp bhaag
    
    fail:
    mov start_pos,0 
    mov si,count
    mov livesCount[si],0
    sub count,2
    dec count1
    cmp count1,48
    je khatam
    push ax
    push bx
    push cx
    push dx
    
    redraw_ball_func 0
    
    mov ax, striker_x    ; BALL BUILD ON STRIKER
    mov ball_reset_x,ax
    add ball_reset_x,18
    
    mov ball_reset_y,  163
    
    redraw_ball_func 3
    mov ball_up, 1     ;monis
    mov ball_left,0
    
    pop dx
    pop cx
    pop bx
    pop ax
    
    call draw_lives_scores_func
    jmp bhaag
    
    khatam:    
    call game_over_func
    mov ah,4ch
    int 21h 
                  
bhaag:  
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret

striker_collision_func endp

wall_collision_func proc                   ; $ball
    
    mov bx, ball_reset_x
    mov cx, ball_reset_y
    
    checkLeftRight:
    cmp bx, 25; max left
    jl goRight
    cmp bx, 290; Max Right
    jg goLeft
    jmp checkUpDown
    goRight:
    mov ball_left, 0 
    jmp checkUpDown;
    goLeft:
    mov ball_left, 1
    checkUpDown:
    
    cmp cx, 13;max top
    jl goDown
    cmp cx, 184;max bottom
    jg goUp
    
    
    jmp noInput
    goUp:                                            
    mov ball_up,1
    jmp noInput
    goDown: 
    mov ball_up, 0
  
    ret
    wall_collision_func endp

ajeebse:
ret
baller proc                             ; $ball
    
	inc internal_delay
    mov bh, internal_delay
	cmp bh, delay_counter
	jne ajeebse 
	mov internal_delay, 0
    redraw_ball_func 0  
    
	mov bx,ball_reset_x 
	cmp ball_left, 1
	je Left
	jne Right
	
	Left:   
	sub bx, ball_vel;2 
	jmp P2;  
	Right:   
	add bx, ball_vel;2
	
	P2:
	mov ball_reset_x,  bx
	mov bx, ball_reset_y
	cmp ball_up, 1   
	je Up
	jne Down
	Up:
    sub bx, ball_vel;2
	jmp P3
	Down:
    add bx, ball_vel;2
	P3:
    mov ball_reset_y,  bx
   
    redraw_ball_func 3
    
ret
baller endp   

input_check_func proc
    mov     ah,     1h
    int     16h         ; check keypress
    jz      noInput     ; no keypress
    mov     ah,     0h
    int     16h
    cmp     ax,     4D00h
    je      rightKey
    cmp     ax,     4B00h
    je      leftKey
    cmp     al,     27D
    jne      continue
    mov ah, 4ch
    int 21h
    continue:
    cmp     ax,     3920h;space to start_pos
    je      beg
    jne     noInput
    
    beg:
    mov start_pos,1
    
    noInput:
    ret  

    rightKey:     
    mov bx, bound_end
    sub bx ,striker_width_increase
    cmp     striker_x, bx ;max right limit
    jg      noInput
    redraw_striker_func 0
    add     striker_x, 5
    redraw_striker_func 7
    cmp start_pos,0
    jz moveBallRight
    jmp     noInput
    
    
    leftKey:   
    mov bx, bound_start                            
    cmp     striker_x, bx ;max left limit
    jl      noInput
    redraw_striker_func 0
    sub     striker_x, 5
    redraw_striker_func 7
    cmp start_pos,0
    jz moveball_left
    jmp     noInput
    
    
    moveball_left:
    redraw_ball_func 0
    sub     ball_reset_x, 5
    redraw_ball_func 3
    jmp     noInput
    
    
    moveBallRight:
    redraw_ball_func 0
    add     ball_reset_x, 5
    redraw_ball_func 3
    jmp     noInput

input_check_func endp

draw_striker_func proc
    push bx
    push cx
        
    mov bx, striker_x
    mov cx, striker_y   
    mov start_pos_x,bx
    add bx, striker_width
    mov end_pos_x,bx
    mov start_pos_y,cx
    mov end_pos_y,175
    call draw
    
    pop cx
    pop bx
    ret
    draw_striker_func endp

draw_boundary_func proc
    mov color,17    
    ;------TOP------------
    mov start_pos_x,20
    mov end_pos_x,300
    mov start_pos_y,5
    mov end_pos_y,8
    call draw
    ;------RIGHT------------
    mov start_pos_x,297
    mov end_pos_x,300
    mov start_pos_y,7
    mov end_pos_y,180
    call draw
    ;------LEFT------------
    mov start_pos_x,20
    mov end_pos_x,23
    mov start_pos_y,7
    mov end_pos_y,180
    call draw
    ;------BOTTOM------------
    mov start_pos_x,20
    mov end_pos_x,300
    mov start_pos_y,177
    mov end_pos_y,180
    call draw 
   
    ret
draw_boundary_func endp

game_over_func proc
    
    call clear_screen_set
    xor ah, ah
    xor bx, bx
    xor cx, cx
    xor dx, dx

    
    mov _cursor,5
	mov ah,02h  ;set cursor
	mov dh,10
	mov dl,_cursor
	int 10h
	mov cx,22
	mov si,offset str_game_over_func

	Loopgame_over_func:
	    push cx

	    mov al,[si]
	    mov bh,0
	    mov bl,15
	    mov cx,1
	    mov ah,0Ah
	    int 10h
	    add si, TYPE str_game_over_func
	    inc _cursor
	    mov ah,02h
	    mov dh,10
	    mov dl,_cursor
	    int 10h
        
	    pop cx
	LOOP Loopgame_over_func

    ret
    game_over_func endp

draw_lives_scores_func proc
    push dx
    push ax
                 
    mov dh, 23 ;row
    mov dl, 5 ;col
    mov ah, 2 
    int 10h
    
    lea dx, str_score
    mov ah, 9
    int 21h
    
    call print_score
    
    lea dx, str_lives
    mov ah,9
    int 21h  

    pop ax
    pop dx
    ret
draw_lives_scores_func endp

play_sound PROC 

    PUSH AX
    PUSH BX
    PUSH DX
    PUSH CX


	MOV	DX,10000	; Number of times to repeat whole routine.

	MOV	BX,1		; Frequency value.

	MOV	AL, 10110110B	; The Magic Number (use this binary number only)
	OUT     43H, AL          ; Send it to the initializing port 43H Timer 2.

	NEXT_FREQUENCY:          ; This is were we will jump back to 2000 times.

	MOV     AX, BX           ; Move our Frequency value into AX.

	OUT     42H, AL          ; Send LSB to port 42H.
	MOV     AL, AH           ; Move MSB into AL  
	OUT     42H, AL          ; Send MSB to port 42H.

	IN      AL, 61H          ; Get current value of port 61H.
	OR      AL, 00000011B    ; OR AL to this value, forcing first two bits high.
	OUT     61H, AL          ; Copy it to port 61H of the PPI Chip
							; to turn ON the speaker.

	MOV     CX, 100          ; Repeat loop 100 times
	DELAY_LOOP:              ; Here is where we loop back too.
	LOOP    DELAY_LOOP       ; Jump repeatedly to DELAY_LOOP until CX = 0


	INC     BX               ; Incrementing the value of BX lowers 
							; the frequency each time we repeat the
							; whole routine

	DEC     DX               ; Decrement repeat routine count

	CMP     DX, 0            ; Is DX (repeat count) = to 0
	JNZ     NEXT_FREQUENCY   ; If not jump to NEXT_FREQUENCY
							; and do whole routine again.

							; Else DX = 0 time to turn speaker OFF

	IN      AL,61H           ; Get current value of port 61H.
	AND	AL,11111100B	; AND AL to this value, forcing first two bits low.
	OUT     61H,AL           ; Copy it to port 61H of the PPI Chip
							; to turn OFF the speaker.


    POP CX
    POP DX
    POP BX 
    POP AX              

	ret 	
play_sound ENDP

call_next_level proc

mov ax, level

cmp ax, 1
je call_1

cmp ax, 2
je call_2

cmp ax, 3 
je call_3


call_1:
CALL frame_update_set
call level1

call_2:
CALL frame_update_set
call level2
call_3:
CALL frame_update_set
call level3

completed:
    mov ah, 4ch 
    int 21h

call_next_level endp
;-----------------------------------------------
display_level1 proc
    
    
    xor ah, ah
    xor bx, bx
    xor cx, cx
    xor dx, dx

    
    mov _cursor,13
	mov ah,02h  ;set cursor
	mov dh,10
	mov dl,_cursor
	int 10h
	mov cx,13
	mov si,offset str_level1  ; "L E V E L   1"

	level1_display:
	    push cx

	    mov al,[si]
	    mov bh,0
	    mov bl,15
	    mov cx,1
	    mov ah,0Ah
	    int 10h
	    add si, TYPE str_level1
	    inc _cursor
	    mov ah,02h
	    mov dh,10
	    mov dl,_cursor
	    int 10h

	    pop cx
	LOOP level1_display

    ret
display_level1 endp

display_level2 proc
    
    
    xor ah, ah
    xor bx, bx
    xor cx, cx
    xor dx, dx

    
    mov _cursor,13
	mov ah,02h  ;set cursor
	mov dh,10
	mov dl,_cursor
	int 10h
	mov cx,13
	mov si,offset str_level2  ; "L E V E L   1"

	level2_display:
	    push cx

	    mov al,[si]
	    mov bh,0
	    mov bl,15
	    mov cx,1
	    mov ah,0Ah
	    int 10h
	    add si, TYPE str_level2
	    inc _cursor
	    mov ah,02h
	    mov dh,10
	    mov dl,_cursor
	    int 10h

	    pop cx
	LOOP level2_display

    ret
display_level2 endp

display_level3 proc
    
    
    xor ah, ah
    xor bx, bx
    xor cx, cx
    xor dx, dx

    
    mov _cursor,13
	mov ah,02h  ;set cursor
	mov dh,10
	mov dl,_cursor
	int 10h
	mov cx,13
	mov si,offset str_level3  ; "L E V E L   1"

	level3_display:
	    push cx

	    mov al,[si]
	    mov bh,0
	    mov bl,15
	    mov cx,1
	    mov ah,0Ah
	    int 10h
	    add si, TYPE str_level1
	    inc _cursor
	    mov ah,02h
	    mov dh,10
	    mov dl,_cursor
	    int 10h

	    pop cx
	LOOP level3_display

    ret
display_level3 endp

mov ah, 4ch 
int 21H
end Main 