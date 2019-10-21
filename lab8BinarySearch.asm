title Binary Search      (Template.asm)

; Xander Kehoe
; CPEN 3710
; March 20, 2019
;
; This program performs a binary search on arrays.

include Irvine32.inc                 ; only needed if we call Irvine's routines
                                     ; good idea to always insert at top of pgms.

.data                	; set up variables and constants to use

    	inputMessage1    	byte "Input 1 or 2 for array choice: ",0
    	inputMessage2     	byte "Insert value to search for: ",0
    	invalidMessage    	byte "Invalid input, try again ",0
   	foundMessage    	byte "Found value at: ",0
    	notFoundMessage    	byte "The value searched for was not found ",0

    	firstArray        	word 0, 1, 4, 12, 20, 21, 35, 65, 123, 127, 128, 211, 1000, 2006, 14111, 60000
    	secondArray       	word 2, 7, 15, 17, 72, 73, 74, 100, 122, 130, 146, 300, 543, 655, 1024, 1066, 1961, 2000, 2001, 2007, 2046, 5023, 10974, 65534, 65535

	startMemory		EQU[ebp-4]
	currentMemory		EQU [ebp-8]
	lastMemory		EQU [ebp-12]

.code
main proc

    	Start:
    	mov     	edx,OFFSET inputMessage1      	; set up for WriteString
    	call    	WriteString
    	call    	ReadDec                       	; eax now contains user input
    	cmp     	eax,1
    	je      	FirstArrayChoice            	; if equal, set up sub-proc for array 1
    	cmp     	eax,2
    	je     	SecondArrayChoice            		; if equal, set up sub-proc for array 2
                                        		; if no jump, input was invalid
    	mov     	edx,OFFSET invalidMessage    	; set up for WriteString
    	call    	WriteString
    	jmp     	Start                        	; try set again if invalid input
    	FirstArrayChoice:
    	mov 	esi,OFFSET firstArray
    	mov 	edi,LENGTHOF firstArray

    	jmp 	callOfSubProc                    	; Skip over 2ndArrayChoice code since we chose 1st array.
    	SecondArrayChoice:
    	mov 	esi,OFFSET secondArray
    	mov 	edi,LENGTHOF secondArray

    	callOfSubProc:					; get input and call subproc
    	mov 	edx,OFFSET inputMessage2
    	Call 	WriteString
    	push 	eax
    	Call 	ReadDec
    	mov 	ecx,eax
    	pop 	eax

    	Call Search

    	cmp        edx,0FFFFFFFFh                	; compare to check if NOT found
    	jne        FoundValue                    	; jump if value was found

    	mov        edx,OFFSET notFoundMessage    	; set up for WriteString
    	call    WriteString

	jmp	EndOfProgram
    	FoundValue:
    	mov        eax,edx                        	; create copy of found value's offset
    	mov        edx,OFFSET foundMessage        	; set up for WriteString
    	call    WriteString
    	call    WriteHex


    	EndOfProgram:
    	call    DumpRegs                    		; use Irvine's procedure to show registers
    	exit                                		; invoke code to terminate the program

main endp

Search proc
	; inputs:
        ;    	esi - OFFSET of array  (was eax)
        ;    	edi - LENGHTOF array   (was ebx)
        ;    	ecx - value to search for
	;	edx - value to return (memory offset or 0FFFFFFFFh for not found)

		enter 12,0

        ; calculate starting memory offset

		mov	startMemory,esi

		; calculate last memory offset

		mov 	eax,edi				; eax = LENGTHOF array
		shl 	eax,1				; Multiplying by 2 (2 for 16-bit array)
		add 	eax,esi				; Starting memory offset + ((LENGTHOF array - 1) * TYPEOF array)
		mov 	lastMemory,eax

		; calulate middle memory offset

		mov 	eax,edi				; eax = LENGTHOF array
		shr 	eax,1				; (LENGTHOF ARRAY/2)
		shl 	eax,1				; ((LENGTHOF ARRAY/2) * 2) 2 for 16-bit array
							; divide by 2 and then multiple by 2? ok...
		add 	eax,startMemory			; startMemory + ((LENGTHOF ARRAY/2) * 2)
		mov 	currentMemory,eax

		; check if first and last offset match

		mov 	eax,startMemory
		mov 	ebx,lastMemory
		cmp 	eax,ebx
		je 	badExit

		; cmp middle mem value with ecx
		mov 	edx,[currentMemory]
		mov 	eax,[edx]
		and 	eax,0000FFFFh			; clearing upper 16 bits, if we dont we get both values
		cmp 	ecx,eax
		call 	DumpRegs
		je 	isEqual
		jl 	isLess
		
		; if greater, next starting memory = current memory offset, edi /= 2
		isGreater:
		mov 	esi,currentMemory
		shr 	edi,1				; dividing by 2

		call 	Search
		jmp 	finalExit

		; if less, edi /= 2.
		isLess:
		shr 	edi,1

		call 	Search
		jmp 	finalExit

		; if equal, jump to ret and return the memory offset
		isEqual:
		mov 	edx,[currentMemory]
		jmp 	finalExit


		badExit:
		mov 	edx,0FFFFFFFFh
		
		finalExit:
		leave
        ret

Search endp

end main