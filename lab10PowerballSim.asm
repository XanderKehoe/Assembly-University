title Powerball     (Template.asm)

; Xander Kehoe
; CPEN 3710
; April 3rd, 2019
;
; Simulates Powerball drawings.


include Irvine32.inc                 ; only needed if we call Irvine's routines
                                     ; good idea to always insert at top of pgms.

LotteryDrawing STRUCT
      white_balls	DWORD		5 DUP(?)		; 5 random white balls
      red_ball		DWORD		?				; 1 random red ball
LotteryDrawing ENDS

	       .data                     ; set up variables and constants to use

	white_balls		DWORD		5 DUP(?)
	red_ball		DWORD		?

	start_message	BYTE	"Powerball drawing results: White balls, ",0
	start_message2	BYTE	"... Red ball: ",0
	space		BYTE	" ",0

	white_input1	BYTE	"Please enter your first white number: ",0
	white_input2	BYTE	"Please enter your second white number: ",0
	white_input3	BYTE	"Please enter your third white number: ",0
	white_input4	BYTE	"Please enter your fourth white number: ",0
	white_input5	BYTE	"Please enter your fifth white number: ",0
	red_input	BYTE	"Please enter your red number: ",0

	White0WithRed	Byte	"You have matched just the red number, you win $4!",0
	White0NoRed	Byte	"You have matched no white numbers and not the red number, you did not win.",0
	White1WithRed	Byte	"You have matched 1 white number and the red number, you win $4!",0
	White1NoRed	Byte	"You have matched 1 white number but not the red number, you did not win.",0
	White2WithRed	Byte	"You have matched 2 white numbers and the red number, you win $7!",0
	White2NoRed	Byte	"You have matched 2 white numbers but not the red number, you did not win.",0
	White3NoRed	Byte	"You have matched 3 white numbers but not the red number, you win $7!",0
	White3WithRed	Byte	"You have matched 3 white numbers and the red number, you win $100!",0
	White4NoRed	Byte	"You have matched 4 white numbers but not the red number, you win $100!",0
	White4WithRed	Byte	"You have matched 4 white numbers and the red number, you win $50,000!",0
	White5NoRed	Byte	"You have matched 5 white numbers but not the red number, you win $1,000,000!",0
	White5WithRed	Byte	"You have matched 5 white numbers and the red number, you win the GRAND PRIZE!",0

	invalidMessage	Byte	"Invalid Input! Try Again.",0

	thisDrawing		LotteryDrawing <>

MyRandomRange	MACRO	input, output
	; moves random number from a range of input to the output

	mov		eax, input						
	Call	RandomRange

	mov		output, eax
ENDM

DisplayInput	MACRO	messageOffset
	mov	edx, messageOffset
	call	WriteString
	call	MyReadInt
	call	crlf
ENDM

	       .code
main       proc

											; Initialze balls to random values
	mov	edx, OFFSET start_message
	call	WriteString
	call	Randomize						; get new randomization seed
	mov	esi, OFFSET thisDrawing.white_balls
	mov	ecx,5							; set up loop for all 5 white balls
	WhiteBallLoop:							; saving counter
	MyRandomRange 68, ebx						; generate random number (0-68) for each white ball
	add	ebx, DWORD PTR 1					; add one to get (1-69)

	mov	edx, thisDrawing.white_balls				; check for duplicate for first white ball
	cmp	ebx,edx
	je	WhiteBallLoop
	mov	edx, thisDrawing.white_balls+4				; check for duplicate for second white ball
	cmp	ebx,edx
	je	WhiteBallLoop
	mov	edx, thisDrawing.white_balls+8				; check for duplicate for third white ball
	cmp	ebx,edx
	je	WhiteBallLoop
	mov	edx, thisDrawing.white_balls+12				; check for duplicate for fourth white ball
	cmp	ebx,edx
	je	WhiteBallLoop	

	mov	[esi], ebx

	mov	eax,ebx							; set up for WriteDec
	call	WriteDec
	mov	edx,OFFSET space					; set up for WriteString
	call	WriteString
	add	esi, 4							; move to next index in array
	loop	WhiteBallLoop

	mov	esi,OFFSET thisDrawing.red_ball
	MyRandomRange 25, ebx						; generate random number (0-25) for the red ball
	mov	[esi], ebx
	add	[esi], DWORD PTR 1					; add one to get (1-26)

	mov	edx,OFFSET start_message2
	call	WriteString
	mov	eax, thisDrawing.red_ball
	call	WriteDec
	call	crlf

									; Get User Input
	jmp	valid1
	invalid1:
	mov	edx, OFFSET invalidMessage
	call	WriteString
	call	crlf
	valid1:
	mov	esi, OFFSET white_balls					; Getting input for first white ball
	DisplayInput OFFSET white_input1
	jc 	invalid1
	cmp	eax, 69							; values can't be greater than 69
	jg	invalid1
	cmp	eax, 1							; values can't be less than 1.
	jl	invalid1
	mov	[esi],eax
	add	esi,4
	jmp	valid2


	invalid2:
	mov	edx, OFFSET invalidMessage
	call	WriteString
	call	crlf
	valid2:
									; Getting input for second white ball
	DisplayInput OFFSET white_input2
	jc 	invalid2
	cmp	eax, 69							; values can't be greater than 69
	jg	invalid2
	cmp	eax, 1							; values can't be less than 1.
	jl	invalid2

	cmp	eax,white_balls						; checking for duplicates
	je	invalid2

	mov	[esi],eax
	add	esi,4
	jmp	valid3


	invalid3:
	mov	edx, OFFSET invalidMessage
	call	WriteString
	call	crlf
	valid3:
									; Getting input for third white ball
	DisplayInput OFFSET white_input3
	jc 	invalid3
	cmp	eax, 69							; values can't be greater than 69
	jg	invalid3
	cmp	eax, 1							; values can't be less than 1.
	jl	invalid3

	cmp	eax,white_balls						; Checking for duplicates
	je	invalid3
	mov	ebx,white_balls+4					; EXTRA LINE, DELETE
	cmp	eax,ebx
	je	invalid3

	mov	[esi],eax
	add	esi,4
	jmp	valid4
	

	invalid4:
	mov	edx, OFFSET invalidMessage
	call	WriteString
	call	crlf
	valid4:
									; Getting input for fourth white ball
	DisplayInput OFFSET white_input4
	jc 	invalid4
	cmp	eax, 69							; values can't be greater than 69
	jg	invalid4
	cmp	eax, 1							; values can't be less than 1.
	jl	invalid4

	cmp	eax,white_balls						; Checking for duplicates
	je	invalid4
	cmp	eax,white_balls+4
	je	invalid4
	cmp	eax,white_balls+8
	je	invalid4

	mov		[esi],eax
	add		esi,4
	jmp		valid5


	invalid5:
	mov	edx, OFFSET invalidMessage
	call	WriteString
	call	crlf
	valid5:
									; Getting input for fifth white ball
	DisplayInput OFFSET white_input5
	jc 	invalid5
	cmp	eax, 69							; values can't be greater than 69
	jg	invalid5
	cmp	eax, 1							; values can't be less than 1.
	jl	invalid5

	cmp	eax,white_balls						; Checking for duplicates
	je	invalid5
	cmp	eax,white_balls+4
	je	invalid5
	cmp	eax,white_balls+8
	je	invalid5
	cmp	eax,white_balls+12
	je	invalid5

	mov	[esi],eax

	mov	esi, OFFSET red_ball
	jmp	validRed

	invalidRed:
	mov	edx, OFFSET invalidMessage
	call	WriteString
	call	crlf
	validRed:
									; Getting input for red ball
	DisplayInput OFFSET red_input
	cmp		eax, 26						; values can't be greater than 26
	jg		invalidRed
	cmp		eax, 1						; values can't be less than 1.
	jl		invalidRed

	mov		[esi],eax

									; Check Each White Ball through white_balls array for match

	mov		ebx,0						; Setting to 0 for counting amount of correct whiteballs
	mov		esi,OFFSET white_balls			
	mov		ecx,5						; Set up for outer loop counter
	L_Input_Check:
	mov		eax,[esi]					; move each white ball into eax for checking
	push	ecx							; Save outer loop counter
	mov		ecx,5						; Set up for inner loop
	mov		edi,OFFSET	thisDrawing.white_balls
	L_Correct_Check:
	cmp		eax,[edi]
	jne		NotEqualWhite
	inc		ebx						; if equal, increment ebx
	NotEqualWhite:
	add		edi,4						; move edi to next correct white_ball memory location
	loop	L_Correct_Check
	pop		ecx						; Restore outer loop counter
	add		esi,4
	loop	L_Input_Check
									; Check red ball for match

	mov		ecx,0						; Setting 0 for checking if red balls matches
	mov		eax, thisDrawing.red_ball			; moving pre-calculated drawings redball into eax
	mov		edx, red_ball					; moving user input redball into edx
	cmp		eax, edx						
	jne		NotEqualRed						
	mov		ecx,1
	NotEqualRed:

									; Calculate prize (if any)
									; LEFT OFF HERE (DELETE ME)
	cmp		ecx,1						; Red Ball Checking
	jne		NotRed
	IsRed:
	cmp		ebx,0
	jne		White1IsRed
	mov		edx,OFFSET White0WithRed
	call	WriteString
	jmp		EndOfProgram
	White1IsRed:
	cmp		ebx,1
	jne		White2IsRed
	mov		edx,OFFSET White1WithRed
	call	WriteString
	jmp		EndOfProgram
	White2IsRed:
	cmp		ebx,2
	jne		White3IsRed
	mov		edx,OFFSET White2WithRed
	call	WriteString
	jmp		EndOfProgram
	White3IsRed:
	cmp		ebx,3
	jne		White4IsRed
	mov		edx,OFFSET White3WithRed
	call	WriteString
	jmp		EndOfProgram
	White4IsRed:
	cmp		ebx,4
	jne		White5IsRed
	mov		edx,OFFSET White4WithRed
	call	WriteString
	jmp		EndOfProgram
	White5IsRed:
	mov		edx,OFFSET White5WithRed
	call	WriteString
	jmp		EndOfProgram


	NotRed:								; Not Red Ball Checking
	cmp		ebx,0
	jne		White1NotRed
	mov		edx,OFFSET White0NoRed
	call	WriteString
	jmp		EndOfProgram
	White1NotRed:
	cmp		ebx,1
	jne		White2NotRed
	mov		edx,OFFSET White1NoRed
	call	WriteString
	jmp		EndOfProgram
	White2NotRed:
	cmp		ebx,2
	jne		White3NotRed
	mov		edx,OFFSET White2NoRed
	call	WriteString
	jmp		EndOfProgram
	White3NotRed:
	cmp		ebx,3
	jne		White4NotRed
	mov		edx,OFFSET White3NoRed
	call	WriteString
	jmp		EndOfProgram
	White4NotRed:
	cmp		ebx,4
	jne		White5NotRed
	mov		edx,OFFSET White4NoRed
	call	WriteString
	jmp		EndOfProgram
	White5NotRed:
	mov		edx,OFFSET White5NoRed
	call	WriteString
	jmp		EndOfProgram
	
           

	EndOfProgram::
	call	crlf
        exit								; invoke code to terminate the program

main       endp

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

L8:	
	;call WriteString
	;call Crlf
	stc			; set Carry flag
	mov  eax,0            	; set return value to zero and exit
L9:	ret
MyReadInt ENDP




end        main