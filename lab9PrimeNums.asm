title Prime Numbers	

; Xander Kehoe
; CPEN 3710
; March 27, 2019
;
; This program determines if a number is prime

include Irvine32.inc
                                     	
.data                 	; set up variables and constants to use

	main_input_message	byte "Enter a non-negative integer (0 to exit): ",0

	neg_input_message	byte "Input was invalid, try again: ",0

	isP_output_message	byte " is a prime number.",0
	NP1_output_message	byte " is NOT a prime number.",0
	NP2_output_message	byte " is divisible by ",0
	time1_output_message	byte "This computation took ",0
	time2_output_message	byte " millseconds",0

.code
main	proc
	StartOfProgram:
	mov	edx, OFFSET main_input_message	; display input message
	call	WriteString
	StartOfProgramNoMessage:
	call 	MyReadInt			; receive input
	call 	Crlf

	jnc		GoodInput

						; if no jump, input is invalid
	mov	edx, OFFSET neg_input_message	
	Call	WriteString
	jmp 	StartOfProgramNoMessage

	GoodInput:

	cmp	eax,0
	je	EndOfProgram			; user entered 0, exit program

	cmp 	eax,1
	jne	NotOne

	mov [ebp-8],eax

	;mov		eax,1
	mov		ebx,0
	mov		ecx,0
	
	jmp		NotPrimeOutput	

	NotOne:
	cmp		eax,2
	je		IsTwo

	push	eax
	Call	GetMseconds
	mov	ebx,eax				; ebx contains time before CheckPrime
	pop	eax

	mov	[ebp-4],eax			; passing in input for CheckPrime
	Call	CheckPrime
	mov	edx,[ebp-4]			; getting output from CheckPrime

	push	eax
	Call	GetMseconds
	mov	ecx,eax				; ecx contains time after CheckPrime
	pop	eax

	cmp	edx,0
	je	NotPrimeOutput

	IsTwo:
	mov		ecx,0
	mov		ebx,0

	IsPrimeOutput:
	call	WriteDec
	mov	edx, OFFSET isP_output_message
	call	WriteString
	call	Crlf
	jmp		TimeOutput

	NotPrimeOutput:
	call WriteDec
	mov	edx, OFFSET NP1_output_message
	mov eax, [ebp-8]
	call	WriteString
	call	Crlf
	mov	edx, OFFSET NP2_output_message
	call	WriteString
	call	WriteDec
	call	Crlf


	TimeOutput:
	mov	edx, OFFSET time1_output_message
	call	WriteString
	mov	eax,ecx
	sub	eax,ebx				; calculating time CheckPrime took
	call	WriteDec
	mov	edx, OFFSET time2_output_message
	call	WriteString
	call	Crlf
	call	Crlf

		
	jmp	StartOfProgram
	EndOfProgram:

	exit                      		; invoke code to terminate the program

main	endp



CheckPrime	proc USES eax ebx ecx edx
	; Inputs ebp-4
	; Outputs ebp-4, 1 if prime, 0 if not prime
	;		  ebp-8, if not prime, the number it is divisible by
	
	; take input and start by dividing by n (which ='s 2 to start)
	; if edx = 0, number is not prime and retun
	; else, try dividing by n+1, and then repeat until n >= result of last division

	mov		ebx, 2					; ebx = n
	DoStuff:						; need better name here?
	mov		edx, 0					; clear edx
	push		eax					; save eax
	div		ebx					; divide eax by ebx(n).
	cmp		edx,0					; if remainder is 0, then prime, if not keep checking
	mov		ecx,ebx
	je		NotPrime

	inc		eax					; round eax up
	inc		ebx					; n=n+1
	cmp		ebx,eax					; check if n >= result of last division
	pop		eax					; restoring eax
	jge		IsPrime
	jl		DoStuff					; repeat
	IsPrime:
	mov 	[ebp-4], DWORD PTR 1				; return 1 / Is Prime
	jmp EndOfProc						; skip over 'NotPrime' code

	NotPrime:
	pop	eax						; pop so EIP gets popped into stack by ret
	mov	[ebp-4], DWORD PTR 0				; return 0 / Not Prime
	mov	[ebp-8], ecx

	EndOfProc:
	ret
CheckPrime	endp

MyReadInt PROC uses ebx ecx edx esi
; Modified from Irvine32.asm by Dr. Joe Dumas
; Reads a 32-bit unsigned decimal integer from standard
; input, stopping when the Enter key is pressed.
; All valid digits occurring before a non-numeric character
; are converted to the integer value. Leading spaces are
; ignored, and an optional leading + sign is permitted.

; Receives: nothing
; Returns:  If CF=0, the integer is valid, and EAX = binary value.
;   If CF=1, the integer is invalid and EAX = 0.
.data
LMAX_DIGITS = 80
Linputarea    BYTE  LMAX_DIGITS dup(0),0
overflow_msgL BYTE  " <32-bit integer overflow>",0
invalid_msgL  BYTE  " <invalid integer>",0
neg_msg       BYTE  " <negative numbers not allowed>",0
.code

; Input a string of digits using ReadString.

	mov   edx,offset Linputarea
	mov   esi,edx           	; save offset in ESI
	mov   ecx,LMAX_DIGITS
	call  ReadString
	mov   ecx,eax           	; save length in ECX
	cmp   ecx,0            		; greater than zero?
	jne   L1              		; yes: continue
	mov   eax,0            		; no: set return value
	jmp   L9              		; and exit

; Skip over any leading spaces.

L1:	mov   al,[esi]         		; get a character from buffer
	cmp   al,' '          		; space character found?
	jne   L2              		; no: check for a sign
	inc   esi              		; yes: point to next char
	loop  L1
	jcxz  L8              		; quit if all spaces

; Check for a leading sign.

L2:	cmp   al,'-'          		; minus sign found?
	jne   L3              		; no: look for plus sign
	mov   edx, offset neg_msg       ; tell user negative numbers not allowed
        jmp   L8
L3:	cmp   al,'+'          		; plus sign found?
	jne   L4              		; no: must be a digit
	inc   esi              		; yes: skip over the sign
	dec   ecx              		; subtract from counter

; Test the first digit, and exit if it is nonnumeric.

L3A:mov  al,[esi]		; get first character
	call IsDigit		; is it a digit?
	jnz  L7A		; no: show error message

; Start to convert the number.

L4:	mov   eax,0           		; clear accumulator
	mov   ebx,10          		; EBX is the divisor

; Repeat loop for each digit.

L5:	mov  dl,[esi]		; get character from buffer
	cmp  dl,'0'		; character < '0'?
	jb   L9
	cmp  dl,'9'		; character > '9'?
	ja   L9
	and  edx,0Fh		; no: convert to binary
	push edx
	mul  ebx		; EDX:EAX = EAX * EBX
	pop  edx

	jo   L6			; quit if result too big for 32 bits
	add  eax,edx         	; add new digit to AX
	jo   L6			; quit if result too big for 32 bits
	inc  esi              	; point to next digit
	jmp  L5			; get next digit

; Carry out of 32 bits has occured, choose "integer overflow" messsage.

L6:	mov  edx,OFFSET overflow_msgL
	jmp  L8

; Choose "invalid integer" message.

L7A:
	mov  edx,OFFSET invalid_msgL

; Display the error message pointed to by EDX.

L8:	call WriteString
	call Crlf
	stc			; set Carry flag
	mov  eax,0            	; set return value to zero and exit
L9:	ret
MyReadInt ENDP



end	main