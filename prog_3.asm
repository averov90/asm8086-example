.model small

.stack 24 ;bytes, 10 - word - stack depth for func_uint16OUT, 2 - for funclion call

.data
;Constants
msg_enterM_err db 0Ah,'"m" must be above "n"! '
msg_enterM db 0Ah,'Enter "m": $'
msg_enterN_err db 0Ah,'"n" must be above or equal 0! '
msg_enterN db 'Enter "n": $'
msg_result db 0Ah,'Result: $'
msg_calc_error db 0Ah,'The result is too big!',0Ah,'Further calculation is not possible.$'
func_uint16IN_errmsg db 0Ah,'Invalid input! Enter 16-bit unsigned number: $'
func_div32x16_divider dw 10
;Multithread non-safe
func_uint16IN_buffer db 6, 0, 6 dup(?)

.code
start proc
	mov ax, @data
	mov ds, ax ;init data segment
	lea dx, msg_enterN
N_reenter:
	mov ah,9
	int 21h ;message print
	call func_uint16IN ;input number
	test ax,ax
	jz N_unc 
	mov di,ax ;di = n
	lea dx, msg_enterM
M_reenter:
	mov ah,9
	int 21h ;message print
	call func_uint16IN ;input number
	cmp ax,di
	jb M_unc
	push ax
	push di
	call func_placments32x16x16
	jc calc_error
	mov bx,ax
	mov cx,dx ;save registers values
	lea dx, msg_result
	mov ah,9
	int 21h ;message print
	mov ax,bx
	mov dx,cx ;restore saved registers values
	call func_uint32OUT
	mov ah, 4Ch
	int 21h ;stop
calc_error:
	lea dx, msg_calc_error
	mov ah,9
	int 21h
	mov ah, 4Ch
	int 21h ;stop
N_unc:
	lea dx, msg_enterN_err
	jmp N_reenter
M_unc:
	lea dx, msg_enterM_err
	jmp M_reenter
start endp 

;require: ax, bx, cx, dx, si, di
func_placments32x16x16 proc
	;ax - low word result
	;dx - high word result
	;CF = error
	pop dx
	pop si
	pop ax
	push dx
	cmp ax,si
	je func_placments_N_decrease
func_placments_next1:
	xor dx,dx ;dx - result high word
	sub si,1
	jbe func_placments_end ;jump to skip loop
	mov cx,si
	mov bx,ax ;bx = m, ax - result low word
func_placments_cloop:
	dec bx
	call func_mul32x16
	jc func_placments_error
	loop func_placments_cloop
func_placments_end:
	clc
func_placments_error:
	ret
func_placments_N_decrease:
	dec si
	jmp func_placments_next1
func_placments32x16x16 endp

;require: ax, bx, cx, dx, si
func_uint16IN proc
	mov bx,10 ;prepare bx register
	xor ch,ch
label_func_uint16IN_reinput:
	lea dx, func_uint16IN_buffer ;set pointer to buffer
	mov ah,0Ah ;init string input mode
	int 21h ;input string
	mov cl, [func_uint16IN_buffer+1]
	lea si, func_uint16IN_buffer+2 ;set pointer to first symbol of string to si
	xor ax,ax ;zero ax
label_func_uint16IN_loop: 	
	cmp byte ptr [si],'0' ;check symbol code
	jb label_func_uint16IN_err
	cmp byte ptr [si],'9' ;check symbol code		
	ja label_func_uint16IN_err 
	mul bx ;multiply to basis
	jc label_func_uint16IN_err
	sub byte ptr [si],'0' ;get number from symbol
	add al,[si] ;add number to result
	adc ah,0
	jc label_func_uint16IN_err
	inc si
	loop label_func_uint16IN_loop ;string to uint16 cycle
	ret
label_func_uint16IN_err: 	
	lea dx,func_uint16IN_errmsg
	mov ah,9
	int 21h
	jmp label_func_uint16IN_reinput
func_uint16IN endp

;require: ax, bx, cx, dx, si, di
func_uint32OUT proc
	;ax - low word
	;dx - high word
	xor cx,cx ;zero counter
label_func_uint32OUT_decodeNext: 
	inc cx ;count digits
	call func_div32x16 ;get digit
	push bx ;save digit
	test ax,ax ;check that digits not finish
	jnz label_func_uint32OUT_decodeNext ;if not - repeat
	test dx,dx
	jnz label_func_uint32OUT_decodeNext ;if not - repeat
	mov ah,2 ;prepare DOS output
label_func_uint32OUT_printNext: 
	pop dx ;get digit
	add dx,'0' ;set digit to output
	int 21h
	loop label_func_uint32OUT_printNext
	ret
func_uint32OUT endp

;require: ax, bx, dx, si, di
func_mul32x16 proc
	;ax - low word
	;dx - high word
	;bx - multiplier
	mov si,ax ;prepare to high word multiply
	mov ax,dx
	mul bx
	jo label_func_mul32x16_overflow
	mov di,ax
	mov ax,si ;prepare to low word multiply
	mul bx
	add dx,di
	jc label_func_mul32x16_overflow
	ret
label_func_mul32x16_overflow:
	stc
	ret
func_mul32x16 endp

;require: ax, bx, dx, si, di
func_div32x16 proc
	;ax - low word input
	;dx - high word input
	;func_div32x16_divider - divider
	;ax - low word quotient
	;dx - high word quotient
	;bx - remainder
	test dx,dx
	jz func_div32x16_simpleDiv
	mov di,dx ;LW block - save high word
	xor dx,dx
	div [func_div32x16_divider] ;divide low word
	mov bx,ax ;save quotient low word
	mov si,dx ;save remainder low word
	mov ax,di ;HW block
	xor dx,dx
	div [func_div32x16_divider] ;divide high word
	mov di,ax ;save quotient high word
	xor ax,ax ;HWR block
	div [func_div32x16_divider] ;divide high word remainder
	add bx,ax
	adc di,0
	mov ax,dx ;R block
	xor dx,dx
	add ax,si ;remainder summ
	adc dx,0
	div [func_div32x16_divider] ;divide remainder summ
	add ax,bx
	adc di,0
	mov bx,dx ;result forming
	mov dx,di ;high word to bx
	ret
func_div32x16_simpleDiv:
	div [func_div32x16_divider]
	mov bx,dx
	xor dx,dx
	ret
func_div32x16 endp

	end start