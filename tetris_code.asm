include irvine32.inc
title this is my 3rd Semester COAL project

.data


;---------------------------------------------------------------------------------------------------------
;-----------------------------------------BLOCKS----------------------------------------------------------
;---------------------------------------------------------------------------------------------------------

op0 dword  30303030h, 30303030h, 0DCDC3030h , 30DBDC30h   ;     
    dword 30303030h, 30DC3030h, 30DBDC30h , 3030DB30h     ;    
    dword  30303030h,  30303030h, 30DCDC30h, 0DCDB3030h   ;  
    dword 30303030h, 30DC3030h, 0DCDB3030h, 0DB303030h

op1 dword  30303030h, 30303030h, 0DCDC3030h , 30DBDC30h   ;             []               []
    dword 30303030h, 30DC3030h, 30DBDC30h , 3030DB30h     ;     [][]    [][]  [][]     [][]
    dword  30303030h,  30303030h, 30DCDC30h, 0DBDC3030h   ;   [][]        []    [][]   []
    dword 30303030h, 30DC3030h, 0DCDB3030h, 0DB303030h

                                                          ;    [][]
op2   DWORD 30303030h, 30303030h, 3030DCDCh, 30DBDB30h    ;    [][]

                                                          ;                []
op3 dword 30303030h,30303030h,30303030h, 0DCDCDCDCh       ;  [][][][][]    []
    dword 0DC303030h, 0DB303030h, 0DB303030h, 0DB303030h  ;                []
                                                          ;                []

op4 dword 30303030h,30303030h, 0DCDCDC30h, 30DB3030h      ; [][][]  []      []      []
    dword 30303030h, 0DC303030h, 0DBDC3030h, 0DB303030h   ;   []    [][]  [][][]  [][]
    dword 30303030h,30303030h, 30DC3030h, 0DCDBDC30h      ;         []              []
    dword 30303030h,30DC3030h, 0DCDB3030h, 30DB3030h      ;                          

op5 dword 30303030h, 30303030h, 30303030h, 0DC303030h     ;   []

                                                          
op6 dword 0DC303030h,0DB303030h,0DB303030h,0DBDC3030h   ; []      [][]                 
    dword 0DCDC3030h,30DB3030h,30DB3030h,30DB3030h      ; []      []                    
    dword 30303030h,30303030h,  0DCDCDCDCh,0DB303030h   ; []      []    [][][][]    []                
    dword 30303030h,30303030h,303030DCh,0DCDCDCDBh      ; [][]    []          []    [][][][]  


op7 dword 30DC3030h, 30DB3030h, 30DB3030h, 0DCDB3030h    ; []    [][]                 
    dword 0DCDC3030h,0DB303030h, 0DB303030h, 0DB303030h  ; []      []                    
    dword 30303030h,30303030h,  0DCDCDCDCh,303030DBh     ; []      []    [][][][]          []          
    dword 30303030h,030303030h ,0DC303030h, 0DBDCDCDCh   ; [][]    []    []          [][][][]  












;-------------------------------------------------------------------------------------------------------------------------------------------------------
;-----------------------------------------------GAME START-UP SETTING-----------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------------------------------------------------------------------


Table byte 30 DUP(  31 DUP ('0') )
Table_height byte 30
Table_length byte 31
TilePlaced BYTE 0
key_pressed BYTE ?
Player_ypos BYTE 0
Player_xpos BYTE 14
Player_pos_BYTE DWORD 14
tittle Byte "Tetris 2.0", 0
msg1 Byte "A - left ", 0
msg2 Byte"D - right ", 0
msg3 Byte "T - down ", 0
msg4 Byte "Q - quit ", 0
msg5 Byte "Written By Zeeshan Ahmed", 0
msg6 Byte "Score 0", 0

.code


main PROC
    call NewTile_in_backendTable  ; Okay
    call printtable           ; Okay
    call Build_screen

Gameplay:
    call GetInput             ;Okay
    cmp al, 'q'
    JZ Game_end
    call gravity
    call Character_Movements   ; Okay
    call updateScreen
    call is_tile_Alive
     call updateScreen

jmp Gameplay

Game_end:
call Clrscr
exit
main ENDP



RandomizeOP PROC
call Randomize
mov eax, 20
call Randomrange
mov dl, 16
mul dl

mov edx, Offset op1
add edx, eax  ; result of random

mov ecx, 4
mov ebx, 0
mov esi, OFFSET op0
l1:
mov eax, [edx + ebx]
mov [esi+ebx], eax
add ebx, 4
Loop l1
ret
RandomizeOP ENDP

is_tile_Alive PROC
mov al, tilePlaced
cmp al, 0
JZ tile_alive
call Checklinefill
call NewTile_in_backendTable
mov player_pos_byte, 14
mov tilePlaced, 0
tile_alive:
is_tile_Alive ENDP

GetInput PROC
;mov dh, 18
;mov dl, 37
;call gotoxy
    call ReadChar
    cmp al, 's'
    JNZ conversion
    mov al, 'g'

conversion:
    mov key_pressed, al
    ret
GetInput ENDP

calculatepos PROC
movzx bx, player_ypos
movzx ax, Table_length
mul bx                              ; result in EDX
shl eax, 16
shld edx, eax, 16           ; edx represent rows
movzx eax, player_xpos   
add edx, eax
mov Player_pos_BYTE, eax
ret
calculatepos ENDP










;--------------------------------------------------------------------------------------------------------------------------------------------------------
;---------------------------------------------------------Player Controls----------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------------------------------------------------------------


Character_Movements PROC
call cheackingneighbours
cmp EAX, -1
JZ false_Movement

Movement_True:

mov edi, OFFSET op0
mov esi, OFFSET Table
add esi, Player_pos_BYTE

mov al, key_pressed
cmp al, 's'
JZ Down
cmp al, 'a'
JZ left
cmp al, 'd'
JZ right


Down:
call go_Down
jmp false_movement

left:
call go_left
jmp false_movement

right:
call go_Right


false_movement:

ret
Character_movements ENDP



go_Down PROC
call performNAND        ; Delete the position
movzx eax, table_length
add player_pos_byte, Eax
;call calculatepos
call performOR
ret
go_Down ENDP


go_Right PROC
call performNAND        ; Delete the position
add player_pos_byte, 1 
call performOR
ret
go_Right ENDP


go_left PROC
call performNAND        ; Delete the position
sub player_pos_byte, 1
call performOR
ret
go_left ENDP




cheackingneighbours PROC
mov edi, OFFSET op0
mov esi, OFFSET Table
add esi, Player_pos_BYTE
mov al, key_pressed
cmp al, 's'
JZ Downwardchecking
cmp al, 'a'
JZ leftwardchecking
cmp al, 'd'
JZ rightwardchecking
jmp MoveNotPossible

leftwardchecking:
mov ecx, 4                   ; every Op length
left_l1:
push ecx
mov ecx, 4
mov ebx, 0
left_l2:
movzx edx, byte PTR [edi + ebx]  ; operator tile
cmp edx, '0'                     ; comparision 1
JZ left_noCompare
mov edx, esi                     ; Table OFFSET
add edx, ebx
mov Eax, 1
sub Edx, Eax                     ; left position of tile =  edx
movzx Eax, Byte PTR[edx]
cmp Eax, '0'                    ; comparision 2
JZ left_NoCompare
mov edx, edi
add edx, ebx                    ; check wheter below filled position is of operator itself
sub edx, 1                      ; rowsizeof op1
movzx eax, Byte PTR [edx]
cmp eax, '0'                    ; comparision 3
JZ MoveNotPossible
left_noCompare:
add ebx, 1
Loop left_l2
add edi, ebx
movzx edx, Table_length
add esi, Edx
pop Ecx
Loop left_L1
mov eax, 0
call BoundryCheck
jmp loop_end


rightwardchecking:

mov EcX, 4                   ; every Op length
right_l1:
push Ecx
mov Ecx, 4
mov Ebx, 0
right_l2:
movzx edx, byte PTR [edi + ebx]     ; operator tile
cmp edx, '0'              ; comaperision 1
JZ right_noCompare
mov Edx, esi
add Edx, ebx
add Edx, 1                
movzx Eax, Byte PTR[edx]
cmp Eax, '0'             ; comparison 2
JZ right_NoCompare
mov edx, edi
add edx, ebx                ; 
add edx, 1                  ; rowsizeof op1
movzx eax, Byte PTR [edx]
cmp eax, '0'            ; comparision 3
JZ MoveNotPossible
right_noCompare:
inc ebx
Loop right_l2
add edi, ebx
movzx edx, Table_length
add esi, Edx
pop Ecx
Loop right_L1
mov eax, 0
call BoundryCheck
jmp loop_end


Downwardchecking:
mov ecx, 4                   ; every Op length
l1:
push ecx
mov ecx, 4
mov ebx, 0
l2:
movzx edx, byte PTR [edi + ebx]     ; operator tile
cmp edx, '0'
JZ noCompare
mov edx, esi
add edx, ebx
movzx Eax, table_Length
add Edx, Eax                ; below position of tile =  edx
movzx Eax, Byte PTR[edx]
cmp Eax, '0'
JZ NoCompare
mov edx, edi
add edx, ebx               ; check wheter below filled position is of operator itself
add edx, 4                 ; rowsizeof op1
movzx eax, Byte PTR [edx]
cmp eax, '0'
JZ MoveNotPossible
noCompare:
inc ebx
Loop l2
add edi, ebx
movzx edx, Table_length
add esi, Edx
pop Ecx
Loop L1
mov eax, 0
call boundrycheck
jmp loop_end

Movenotpossible:
pop ecx
mov eax, -1
loop_end:
ret
cheackingneighbours ENDP





   ;let tile from start displacement = 14

NewTile_in_backendTable PROC
call RandomizeOP
mov esi, OFFSET op0 
mov edi, OFFSET Table+14
call Put_Tile
ret
NewTile_in_backendtable ENDP

Put_Tile PROC
mov ecx, 4
l2:
push ecx
cld
mov ecx,4
rep movsb
pop ecx
add edi, 27
Loop l2
ret
Put_Tile ENDP


BoundryCheck PROC
mov al, key_pressed
cmp al, 's'
JZ down
cmp al, 'a'
JZ left
cmp al, 'd'
JZ right

left:
mov esi, Offset table   ;
add esi, 0                                   
mov ecx, 4
l1:
movzx eax, BYTE ptr[esi]
cmp al, 150
JA  Boundry_Not_Safe
movzx edx, Table_length
add esi, edx
Loop l1
jmp Boundry_Safe

right:
movzx ebx, Table_length
sub ebx, 4
mov eax, Player_pos_Byte     ; even the max var will be within 2bytes
cmp eax, ebx                   ; 27 ; <------------------Need To make a better logic than that
JL Boundry_Safe
mov esi, Offset table   ;
add esi, 28
mov ecx, 4
l3:
mov eax, [esi]
cmp eax, 150
JA  Boundry_Not_Safe
movzx edx, Table_length
add eax, edx
Loop l3
jmp Boundry_Safe

Down:
cmp player_pos_Byte, 806
JG Boundry_Not_Safe

Boundry_Safe:
mov Eax, 0
jmp _toEnd

Boundry_Not_Safe:
mov Eax, -1

_toEnd:
ret
BoundryCheck ENDP


updateScreen PROC
mov eax, Player_pos_byte   ; Ax has the position byte
cmp eax, 0
JLE default
cmp eax, 0FFFFFFFDh
JAE default
mov dl, table_length
DIV dl                  ; Quotient in AL
Mov dl, 0
mov dh, AL            ; AL is the row to print
mov bh, Ah
call Gotoxy
mov ebx, 0
mov bl, 4
cmp Ah, 30
JE extra
jmp No_Default

extra:
mov bl, 5
jmp No_default

default:
mov dl, 114
mov dh, 10
call GOTOxy
call dumpregs
mov dl, 0    ; row/col position
mov dh, 0
mov Al, 0     
mov bl, 6
call Gotoxy

No_Default:
mov dl, Table_length
Mul dl
movzx Edx, ax
mov edi, OFFSET Table
add edi, Edx

mov edx, 0
movzx ecx, bl
l1:
push ecx
movzx ecx, table_length
l2:
mov al, [edi + edx]
call writechar
inc edx
Loop l2
call CRLF
pop ecx
Loop l1

ret
UpdateScreen ENDP


Gravity PROC

cmp al, 't'                          ; space character
JNZ _toend
set_position:
mov al, 's'
mov key_pressed, al
call Character_Movements
cmp Eax, -1
JZ _tilesett
mov eax, 100
call Delay
call updateScreen
jmp set_position
_tilesett:
call updateScreen
mov tilePlaced, 1
mov key_pressed, 't'
_toend:
Gravity ENDP


;---------------------------------------------------------------------------------------------------------------------------------------------------
;-------------------------------------------------------Logical Bit-wise Operation------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------------------------------------------------------


performOR proc
mov edi, OFFSET OP0
mov esi, OFFSET Table
add esi, player_pos_byte

mov edx, 0
mov ecx, 4                   ; every Op length
L1:
push ecx
mov ecx, 4
mov ebx, 0
L2:
mov dl, byte PTR [edi + ebx]     ; operator tile
movzx dx, dl
cmp dx, 200
JB Nochange
mov al, [esi+ebx]
movzx ax, al
add dx, ax
cmp dx, 200 
Jb Nochange
mov al, [edi + ebx]
mov [esi + ebx], al
Nochange:
inc ebx
Loop L2
add edi, ebx
movzx edx, Table_length
add esi, Edx
pop Ecx
Loop L1
ret
performOR ENDP



performNand proc        ; Useful for deleting previous position
mov edi, OFFSET OP0
mov esi, OFFSET Table
add esi, player_pos_byte

mov edx, 0
mov ecx, 4                   ; every Op length
L1:
push ecx
mov ecx, 4
mov ebx, 0
L2:
mov dl, byte PTR [edi + ebx]     ; operator tile
movzx dx, dl
mov al, [esi+ebx]
movzx ax, al
add dx, ax
cmp dx, 400 
Jb Nochange
cmp dx, 200
JB Nochange
mov al, '0'
mov [esi + ebx], al
Nochange:
inc ebx
Loop L2
add edi, ebx
movzx edx, Table_length
add esi, Edx
pop Ecx
Loop L1
ret
performNAND ENDP

performAND proc
mov edi, OFFSET OP0
mov esi, OFFSET Table
add esi, player_pos_byte

mov edx, 0
mov ecx, 4                   ; every Op length
L1:
push ecx
mov ecx, 4
mov ebx, 0
L2:
mov dl, byte PTR [edi + ebx]     ; operator tile
movzx dx, dl
mov al, [esi+ebx]
movzx ax, al
add dx, ax
cmp dx, 400 
JA Nochange
cmp dx, 200
JB Nochange
mov al, '0'
mov [esi + ebx], al
Nochange:
inc ebx
Loop L2
add edi, ebx
movzx edx, Table_length
add esi, Edx
pop Ecx
Loop L1
ret
performAND ENDP

performNOT proc
mov esi, OFFSET Table
add esi, player_pos_byte

mov ecx, 4                   ; every Op length
L1:
push ecx
mov ecx, 4
mov ebx, 0
L2:
mov al, [esi + ebx]
cmp al, 200
Jb second
mov al, '0'
mov [esi + ebx], al
jmp after_second
second:
mov al, 220
mov [esi + ebx], al
after_second:
inc ebx
Loop L2
movzx edx, Table_length
add esi, Edx
pop Ecx
Loop L1
ret
performNot ENDP

Checklinefill PROC
cmp TilePlaced, 1
JNZ _toend
mov eax, Player_pos_byte   ; Ax has the position byte
mov dl, table_length
DIV dl                  ; Quotient in AL

mov dl, Table_length
Mul dl
movzx Edx, ax
mov edi, OFFSET Table
add edi, Edx
          ; Allset up done now just need to check things;;;;;;  Edx has the row number

mov ecx, 4
l1:
push ecx
movzx ecx, Table_length
mov ebx, 0
l2:
mov dl, [edi+ebx]
cmp dl, 200
JB _NoCompare
inc Ebx
Loop L2

; Upper all rows need to come down   [For which row ? edi has the row address]
call BringrowsDownward

_NoCompare:
movzx eax, Table_length
add edi, eax
pop ecx
Loop l1
_toend:
ret
Checklinefill ENDP

BringrowsDownward Proc
; edi has the offset to the row
mov esi, Edi
mov edx, edi
movzx eax, table_length
sub edx, eax

mov ecx, 10
l1:
;push ecx
movzx ecx, Table_length
mov ebx, 0
l2:
mov eax, [edx + ebx]
mov [edi+ebx], eax
Loop l1
movzx eax, table_length
sub edi, eax
sub edx, eax
;pop ecx
Loop l1

mov Edi, esi
ret
BringrowsDownward ENDP







;---------------------------------------------------------------------------------------------------------------------------------------------------
;------------------------------------------------------------------Screen Builder------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------------------------------------------------------



PrintTable PROC
mov edi, OFFSET Table
movzx ecx, Table_height
l1:
push ecx
movzx ecx, Table_length
l2:
mov al, [edi]
cmp al, 0
jz tate
call writechar
jmp tates
tate:
mov al, " "
call writechar
tates:
add edi, type table
Loop L2
call CRLF
pop ecx
Loop l1
ret 
Printtable ENDP



updatePosition PROC
mov ecx, 4                 ; esi has table offset\ edi has tile offset
L1:
mov ebx, 0
push ecx
mov ecx, 4
L2:

mov edx, [esi + ebx]
cmp edi, '0'
JZ ignore
mov eax, [edi]
mov [esi+ebx], eax
ignore:
inc ebx
inc edi
Loop L2
movzx eax, table_length
add esi, eax
pop ecx
Loop L1
ret
updatePosition ENDP



Build_Screen PROC
mov dl, 31
mov dh, 0

movzx ecx, Table_height
inc ecx
l1:
call GOTOxy
mov eax,gray +(black)
call SetTextColor
mov al, 178
call Writechar
inc dh
Loop l1

mov dh, 30
mov dl, 0

movzx ecx, Table_length
l2:
call GOTOxy
mov al, 178
call Writechar
inc dl
Loop l2

mov eax,white+(black)
call SetTextColor

call intro
ret
Build_Screen ENDP

intro PROC
mov dl, 41
mov dh, 6
call GOTOxy
mov edx, OFFSET tittle
call WriteString
mov dl, 41
mov dh, 9
call GOTOxy
mov edx, OFFSET msg1
call WriteString

mov dl, 41
mov dh,11
call GOTOxy
mov edx, OFFSET msg2
call WriteString

mov dl, 41
mov dh, 13
call GOTOxy
mov edx, OFFSET msg3
call WriteString

mov dl, 41
mov dh, 15
call GOTOxy
mov edx, OFFSET msg4
call WriteString

mov dl, 40
mov dh, 28
call GOTOxy
mov edx, OFFSET msg5
call WriteString

mov dl, 34
mov dh, 1
call GOTOxy
mov edx, OFFSET msg6
call WriteString

ret
intro ENDP





;---------------------------------------------------------------------------------------------------------------------------------------------------
;------------------------------------------------------------------CODE THAT MIGHT BE USEFUL--------------------------------------------------------
;---------------------------------------------------------------------------------------------------------------------------------------------------





DeletethisPosition PROC
mov edi, offset op7
mov esi, OFFSET Table
ADD esi, Player_pos_BYTE
mov ecx, 4
L1:
mov ebx, 0
push ecx
mov ecx, 4
L2:

mov edx, [esi + ebx]
cmp edx, [edi + ebx]
JNZ ignore
mov eax, '0'
mov [esi], al
ignore:
inc ebx
Loop L2
movzx eax, table_length
add esi, eax
pop ecx
Loop L1
ret
DeletethisPosition ENDP


printtile PROC      ; takes OFFSET OF TILE in edi
mov edx, 0
mov ecx, 4
l1:
push ecx
mov ecx, 4
l2:
mov al, [edi + edx]
cmp al, 0
jz tate
call writechar
jmp tates
tate:
mov al, " "
call writechar
tates:
inc edx
Loop L2
call CRLF
pop ecx
Loop l1
ret
printtile ENDP

Move_Down PROC
mov esi, OFFSET Table
add esi, Player_pos_BYTE
mov edi, OFFSET op7         ; edi represent operator                  ;  1st check if move is valid
movzx eax, table_length                                               ; 2nd if yes, delete previous position (xor it with itself)
add esi, eax                ; esi represent table position to compare with      ; 3rd put in new position (increament y-axis, and perform OR) operation with op) 
                            ; eax represent coloumns

mov ecx, 4  
L2:
push ecx
mov ecx, 4
mov edx, 0
mov ebx, [edi + edx]      ; tiles current position
mov eax, [esi + edx]
l1:

sub ebx, eax
cmp ebx, 10
Jg going
cmp ebx, -10
JL going
stop:
mov ebx, -1
jmp invalid
going:
add edx, TYPE table
Loop L1
movzx eax, table_length
add esi, eax
pop ecx
Loop L2

valid:
call DeletethisPosition
mov edi, offset op7
mov esi, OFFSET Table
ADD esi, Player_pos_BYTE
movzx eax, table_length
add esi, eax      ; beacuse we are moving one row down

call updatePosition        ; esi has table offset\ edi has tile offset
invalid:
ret
Move_Down ENDP

END main




