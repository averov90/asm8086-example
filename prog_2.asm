.model small

.stack 12 ;bytes, 5 - word - stack depth for func_uint16OUT, 1 - for funclion call

.data
;Variables
threshold dw ?
;Constants
msg_enterN db 0Ah,'Enter numbers: $'
msg_enterT db 'Enter threshold number: $'
msg_enterC_err db 0Ah,'Count of numbers must be above 0! '
msg_enterC db 0Ah,'Enter count of numbers: $'
msg_result db 0Ah,'Result: $'
func_int16IN_errmsg db 0Ah,'Invalid input! Enter 16-bit signed number: $'
func_uint16IN_errmsg db 0Ah,'Invalid input! Enter 16-bit unsigned number: $'
;Multithread non-safe
func_int16IN_buffer db 7, 0, 7 dup(?)
func_uint16IN_buffer db 6, 0, 6 dup(?)

.code
start proc
	mov ax, @data
	mov ds, ax ;init data segment
	lea dx, msg_enterT
	mov ah,9
	int 21h ;message print
	call func_int16IN ;input number
	mov [threshold],ax
	lea dx, msg_enterC
C_reenter:
	mov ah,9
	int 21h ;message print
	call func_uint16IN ;input number
	test ax,ax
	jz C_unc 
	mov cx,ax ;di = n
	xor di,di
cloop:
	lea dx, msg_enterN
	mov ah,9
	int 21h ;message print
	mov bp,cx
	call func_int16IN ;input number
	cmp ax,[threshold]
	jle cloop_else
	inc di
cloop_else:
	mov cx,bp
	loop cloop
	lea dx, msg_result
	mov ah,9
	int 21h ;message print
	mov ax,di
	call func_uint16OUT
	mov ah, 4Ch
	int 21h ;stop
C_unc:
	lea dx, msg_enterC_err
	jmp C_reenter
start endp 

;require: ax, bx, cx, dx, si
func_int16IN proc
	mov bx,10 ;prepare bx register
	xor ch,ch
label_func_int16IN_reinput:
	lea dx, func_int16IN_buffer ;set pointer to buffer
	mov ah,0Ah ;init string input mode
	int 21h ;input string
	mov cl, [func_int16IN_buffer+1]
	lea si, func_int16IN_buffer+2 ;set pointer to first symbol of string to si
	xor ax,ax ;zero ax
	cmp byte ptr [si],'-'
	je label_func_int16IN_sign
label_func_int16IN_loop: 
	cmp byte ptr [si],'0' ;check symbol code
	jb label_func_int16IN_err
	cmp byte ptr [si],'9' ;check symbol code		
	ja label_func_int16IN_err 
	mul bx ;multiply to basis
	test ax,ax
	js label_func_int16IN_err
	sub byte ptr [si],'0' ;get number from symbol
	add al,[si] ;add number to result
	adc ah,0
	js label_func_int16IN_err
	inc si
	loop label_func_int16IN_loop ;string to uint16 cycle
	ret
label_func_int16IN_sign:
	inc si
	cmp byte ptr [si],'0' ;check symbol code
	jb label_func_int16IN_err
	cmp byte ptr [si],'9' ;check symbol code		
	ja label_func_int16IN_err 
	sub byte ptr [si],'0' ;get number from symbol
	sub al,[si] ;add number to result
	mov ah,0FFh
	sub cx,2
	jz label_func_int16IN_finite
label_func_int16IN_nloop: 
	inc si
	cmp byte ptr [si],'0' ;check symbol code
	jb label_func_int16IN_err
	cmp byte ptr [si],'9' ;check symbol code		
	ja label_func_int16IN_err 
	imul bx ;multiply to basis
	test ax,ax
	jns label_func_int16IN_err
	sub byte ptr [si],'0' ;get number from symbol
	sub al,[si] ;add number to result
	sbb ah,0
	jns label_func_int16IN_err
	loop label_func_int16IN_nloop ;string to uint16 cycle
label_func_int16IN_finite:	
	ret
label_func_int16IN_err: 	
	lea dx,func_int16IN_errmsg
	mov ah,9
	int 21h
	jmp label_func_int16IN_reinput
func_int16IN endp

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

;require: ax, bx, cx, dx
func_uint16OUT proc
	;ax - low word
	xor cx,cx ;zero counter
	mov bx,10
label_func_uint16OUT_decodeNext: 
	inc cx ;count digits
	xor dx,dx
	div bx
	push dx ;save digit
	test ax,ax ;check that digits not finish
	jnz label_func_uint16OUT_decodeNext ;if not - repeat
	mov ah,2 ;prepare DOS output
label_func_uint16OUT_printNext: 
	pop dx ;get digit
	add dx,'0' ;set digit to output
	int 21h
	loop label_func_uint16OUT_printNext
	ret
func_uint16OUT endp

	end start