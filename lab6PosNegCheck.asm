title Lab#6      (Template.asm)

; Xander Kehoe
; CPEN 3710-0
; February 27th, 2019.
;
; Repeatedly allows user to check if
; a number is negative or positive,
; even or odd, and whether it can be
; represented in 16 bits or not.

include Irvine32.inc                 	; only needed if we call Irvine's routines
                                     	; good idea to always insert at top of pgms.
									 
.data                     		; set up variables and constants to use

buffer BYTE 6 DUP(0)							; input buffer
byteCount DWORD ?							; holds counter

inputMessage byte "Insert a number: ",0					; input message for user
posMessage byte " is a positive number",13,10,0				; positive message to display
negMessage byte " is a negative number",13,10,0				; negative message to display
eveMessage byte " is an even number",13,10,0				; even message to display
oddMessage byte " is an odd number",13,10,0				; odd message to display
i16Message byte " can be represented in 16 bit",13,10,0			; is 16-bit message to display
n16Message byte " can't be represented in 16 bit",13,10,0		; not 16-bit message to display




.code
main proc

	L1:
	mov edx,OFFSET inputMessage					; Setup for WriteString
	call WriteString						; Display message
	mov edx,OFFSET buffer						; Setup for ReadString
	mov ecx,SIZEOF buffer
	call ReadInt							; Get user input (eax = user input)

	cmp eax,0
	je exitProgram							; if input = 0, jump to exit
	jg positive							; if input > 0, jump to positive
	jl negative							; if input < 0, jump to negative
	positive:
	call WriteInt							; Display the input number
	mov edx,OFFSET posMessage					; Setup for WriteString
	call WriteString						; Display posMessage
	jmp evenodd							; skip 'negative' code section
	negative:
	call WriteInt							; Display the input number
	mov edx,OFFSET negMessage					; Setup for WriteString
	call WriteString						; Display negMessage

	evenodd:

	mov ebx,eax							; make copy of input
	and bl,000000001b						; check if last bit is 1, if it is, its uneven (odd).
	cmp bl,0					
	je eve			
	odd:								; label unnecassary but makes formatting better
	call WriteInt							; Display the input number
	mov edx,OFFSET oddMessage					; Setup for WriteString
	call WriteString						; Display oddMessage

	jmp bit16							; skip 'even' code section
	eve:
	call WriteInt							; Display the input number
	mov edx,OFFSET eveMessage					; Setup for WriteString
	call WriteString						; Display evenMessage
	

	bit16:

	cmp eax,32767							; check if 32-bits
	jge not16
	cmp eax,-32768							; check if 32-bits
	jle not16
	is16:
	call WriteInt							; Display the input number
	mov edx,OFFSET i16Message					; Setup for WriteString
	call WriteString						; Display negMessage
	jmp endOfLoop
	not16:
	call WriteInt							; Display the input number
	mov edx,OFFSET n16Message					; Setup for WriteString
	call WriteString						; Display negMessage
	
	endOfLoop: 
	jmp L1								; repeat (will exit from input 0)


	exitProgram:

	
	exit



main endp

end main