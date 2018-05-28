IF !DEF(__COMMON)
__COMMON EQU 1

; Helpers for internals accessing common parts

; Handles trap for status flag \1, operation number \2 and format \3.
; If trap active, BCDE are passed to the handler unchanged.
; A is set to the operation number and format.
; HL is set to \4 if given and not "ignore". \4 may also be set to "stack" to take HL
; from the top of the stack instead (ie. it will pop HL).
; All registers are passed back from the trap handler unchanged.
; If no trap handler, sets the status flag.
; Clobbers A, HL, others depending on trap handler contract.
; Enable tail-call optimizations by optionally passing \5 == "tail call".
HandleTrap: MACRO
IF _NARGS > 4
// We use STRIN instead of STRCMP to ignore whitespace.
// Its fine as long as valid values aren't substrings of each other
tail_call SET STRIN(\5, "tail call") > 0
ELSE
tail_call SET 0
ENDC
dest_handler SET FloatTraps + 3 * ((\1) - 3)
	ld HL, dest_handler + 1
	ld A, [HL+]
	and [HL] ; A can only still be $ff if HL == $ffff
	inc A ; set z if A was $ff, ie. if HL was $ffff ie. no trap.
	jr nz, .trap\@
	; set status flag
	ld HL, FloatFlags
	set [HL], \1
IF tail_call
	ret
ELSE
	jr .end\@
ENDC
.trap\@
	ld A, (\1) | ((\2) << 3)
IF _NARGS > 3
IF STRIN(\4, "stack") > 0
	pop HL
ELIF STRIN(\4, "ignore") == 0
	ld HL, \4
ENDC
ENDC
IF tail_call
	jp dest_handler
ELSE
	; call [HL] - there's no non-immediate call instr, so we use a trampoline.
	call dest_handler
.end\@
ENDC
ENDM

ENDC
