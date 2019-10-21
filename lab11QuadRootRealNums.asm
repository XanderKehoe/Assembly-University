;TITLE callee (callee.asm)

; Xander Kehoe
; CPEN 3710

; This program is called by a C++ program with the
; 3 coefficients A, B, C of the quadratic formula.
; It computes the quadratic formula 
; and returns -1 or 0 in EAX (-1 for negative, 0 if positive)
; and the roots (if any) on the stack.

.386
.model FLAT, C 

public quadform					; quadform can be called by external code

.data

	four	REAL4 4.0
	two		REAL4 2.0
	zero	REAL4 0.0

	trash	REAL4 0.0			; used for unloading stack

	root1val REAL4 ?
	root2val REAL4 ?

	root1PTR DWORD ?
	root2PTR DWORD ?

.code

quadform proc

	push  ebp					; save caller's base pointer
	mov   ebp, esp					; set up a new base pointer

	mov	eax, dword ptr [ebp+20]			; move offset of root1 from HL to root1Ptr variable
	mov	ebx, dword ptr [ebp+24]			; move offset of root2 from HL to root2Ptr variable
	mov	root1PTR, eax
	mov 	root2PTR, ebx

	fld	dword ptr [ebp+8]			; put A into ST(0) which becomes ST(1) after next instruction
	fld	dword ptr [ebp+16]			; put C into ST(0)
	fmul	ST(0), ST(1)				; multiply times C
	fld	four
	fmulp	ST(1), ST(0)				; multiply times 4
	fchs						; make answer negative
	

	fld	dword ptr [ebp+12]			; put B into ST(0)
	fmul	ST(0), ST(0)  				; multiply by self to square it

	fadd	ST(0), ST(1)				; add -4AC to B^2, result in ST(0)

	fld	zero
	fcomi   ST(0), ST(1)
	jz	ZeroOrPositive
	jc	ZeroOrPositive
	mov	eax,-1					; -1 is return code for negative output
	jmp	EndOfProgram				; skip to end of program, no need to calculate roots
	ZeroOrPositive:
	mov	eax,0					; 0 is return code for 0
	jmp	EndOfComp				; skip over positive code

	EndOfComp:

	fld	dword ptr [ebp+12]			; put B into ST(0)
	fchs						; make b negative (-b +- sqrt(...))
	fld	ST(0)					; Make copy for +-
	fld	ST(3)					; load whole sqrt op
	fsqrt						; sqrt the sqrt op
	fadd	ST(1), ST(0)				; first root (stored in ST(1))
	fsubp	ST(2), ST(0)				; second root (stored in ST(2))
	fld	dword ptr [ebp+8]			; Put A into ST(0)
	fld	two					; put 2 into ST(0
	fmulp	ST(1), ST(0)				; obtaining 2a
	fdiv	ST(1), ST(0)				; first root divide by 2a
	fdiv	ST(2), ST(0)				; second root divide by 2a

	fstp	trash					; deleting ST(0)

	fstp	root1val				; Storing roots in variables
	fstp	root2val

	push	eax
	mov	eax,[root1val]				; eax/ebx contain the actual roots
	mov	ebx,[root2val]
	mov	edi,[root1PTR]				; edi/esi contain memory offsets to return
	mov	esi,[root2PTR]

	mov	[edi],eax				; move corresponding values into proper memory address values.
	mov	[esi],ebx
	pop	eax



	EndOfProgram:

	pop	ebp					; restore caller's base pointer
	
	ret						; return (caller to clean up args)

quadform endp

END