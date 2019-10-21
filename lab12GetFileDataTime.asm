title File Time Date  (Template.asm)

; Xander Kehoe
; CPEN 3710
;
; This program retrieves a files last modification date/time
;

include Irvine16.inc                 ; only needed if we call Irvine's routines
                                     ; good idea to always insert at top of pgms.

.data											; set up variables and constants to use
	MaxSize	EQU 50
	input_message	BYTE "Enter the name of the file: ",0
	input		BYTE MaxSize DUP(0)
	input_length	BYTE ?

	error_message	BYTE "Error: File Not Found or Cannot Be Opened.",0
	noerr_message	BYTE "No Error!",0
	slash		BYTE "/",0
	semicolon	BYTE ":",0
	comma		BYTE ", ",0
	peroid		BYTE ".",0
	am_message	BYTE " a.m.",0
	pm_message	BYTE " p.m.",0
	month_error	BYTE " Error in obtaining month ",0

	output_message1	BYTE " was last modified at ",0
	output_message2 BYTE " on ",0

	day		WORD ?
	month		WORD ?
	year		WORD ?
	hour		WORD ?
	minute		WORD ?
	second		WORD ?
	am		WORD ?

	jan		BYTE "January ",0
	feb		BYTE "February  ",0
	mar		BYTE "March ",0
	apr		BYTE "April ",0
	may		BYTE "May ",0
	jun		BYTE "June ",0
	jul		BYTE "July ",0
	aug		BYTE "August ",0
	sep		BYTE "September ",0
	oct		BYTE "October ",0
	nov		BYTE "November ",0
	dem		BYTE "December ",0
	

.code
main	proc
		mov     	ax,@data
		mov     	ds,ax
		lea		dx, input_message			; Setup for Output of input_message
		Call		WriteString
		mov		cx, MaxSize
		lea		dx, input
		Call		ReadString				; get input (max size = MaxSize) and store result in input var
		mov		input_length, al			; store length of input

		mov		ax,3D00h				; open/create
		lea		dx,input				; get offset of file
		int		21h
		jc		failed


		lea		dx, noerr_message
		call		WriteString
		call		CRLF

									; Obtaining date/time
		mov		bx, ax					; move file handle into bx
		mov		ax, 5700h				; setup for code 57 with 00 in AL.
		int		21h					
									; cx should now contain file time
 									; dx should now contain file date

		push		ax
		mov		ax, dx					; create copy of dx (file date)
		and		ax, 000000111100000b			; bit-mask month
		shr		ax, 5
		mov		[month], ax

		mov		ax, dx					; create copy of dx (file date)
		and		ax, 000000000011111b			; bit-mask day
		mov		[day], ax

		mov		ax, dx					; create copy of dx (file date)
		and		ax, 111111000000000b			; bit-mask year
		shr		ax, 9
		mov		[year], ax
		
		mov		ax, cx					; create copy of cx (file time)
		and		ax, 1111100000000000b			; bit-mask hour
		shr		ax, 11
		mov		[hour], ax

		mov		ax, cx					; create copy of cx (file time)
		and		ax, 0000011111110000b			; bit-mask minutes
		shr		ax, 5
		mov		[minute], ax

		mov		ax, cx					; create copy of cx (file time)
		and		ax, 0000000000001111b			; bit-mask seconds
		cmp		ax, 9
		mov		[second], ax
									; Displaying output
		lea		dx, input
		call		WriteString				; display file name
		lea		dx, output_message1
		call		WriteString				; " was last modifed at "
		mov		ax, hour
		cmp		ax, 12					; Decision for AM/PM display here
		jge		PM1
		lea		cx, am_message
		jmp		DisplayHour
		PM1:
		lea		cx, pm_message
		je		DisplayHour
		sub		ax, 12					; convert from military time to normie time

		DisplayHour:
		cmp		ax, 0
		jne		Not12am
		mov		ax, 12
		Not12am:
		call		WriteDec				; display hour
		lea		dx, semicolon
		call		WriteString				; semicolon

		mov		ax, minute
		cmp		ax, 9
		jg		GreaterThanNineMinute
		push		ax					
		mov		ax, 0
		call		WriteDec				; add 0 here for proper display (ex: 12:05)
		pop		ax
		GreaterThanNineMinute:
		call		WriteDec
		mov		dx, cx					; mov edx the memory offset of either AM/PM
		call		WriteString
		lea		dx, output_message2
		call		WriteString

									; Obtaining Month
		mov		ax, month
		cmp		ax,1
		jne		FebCheck
		lea		dx, jan					; set month to display jan
		jmp		EndOfMonthCheck
		FebCheck:
		cmp		ax,2
		jne		MarCheck
		lea		dx, feb					; set month to display feb
		jmp		EndOfMonthCheck
		MarCheck:
		cmp		ax,3
		jne		AprCheck
		lea		dx, mar					; set month to display mar
		jmp		EndOfMonthCheck
		AprCheck:
		cmp		ax,4
		jne		MayCheck
		lea		dx, apr					; set month to display apr
		jmp		EndOfMonthCheck
		MayCheck:
		cmp		ax,5
		jne		JunCheck
		lea		dx, may					; set month to display may
		jmp		EndOfMonthCheck
		JunCheck:
		cmp		ax,6
		jne		JulCheck
		lea		dx, jun					; set month to display jun
		jmp		EndOfMonthCheck
		JulCheck:
		cmp		ax,7
		jne		AugCheck
		lea		dx, jul					; set month to display jul
		jmp		EndOfMonthCheck
		AugCheck:
		cmp		ax,8
		jne		SepCheck
		lea		dx, aug					; set month to display aug
		jmp		EndOfMonthCheck
		SepCheck:
		cmp		ax,9
		jne		OctCheck
		lea		dx, sep					; set month to display sep
		jmp		EndOfMonthCheck
		OctCheck:
		cmp		ax,10
		jne		NovCheck
		lea		dx, oct					; set month to display oct
		jmp		EndOfMonthCheck
		NovCheck:
		cmp		ax,11
		jne		DecCheck
		lea		dx, nov					; set month to display nov
		jmp		EndOfMonthCheck
		DecCheck:
		cmp		ax,12
		jne		MonthError	
		lea		dx, dem					; set month to display dec
		jmp		EndOfMonthCheck
		MonthError:
		lea		dx, month_error
		call		WriteString
		
		EndOfMonthCheck:

		call		WriteString				; display month (in words)

		mov		ax, day
		call		WriteDec				; display day
		lea		dx, comma				; insert comma (with space)
		call		WriteString
		mov		ax, year
		add		ax, 1980
		call		WriteDec				; display year
		lea		dx, peroid
		call		WriteString				; display peroid

		pop		ax
			

									; closing file
									; moving file handle for closing
		;mov		bx,ax					; bx already contains file handle		
		mov  		ah,3Eh
		int  		21h
		jc   		failed

		

		jmp		EndOfProgram				; jump over 'failed' code
		failed:
		lea		dx, error_message	
		call		WriteString

		EndOfProgram:
			

		exit

main	endp

end		main