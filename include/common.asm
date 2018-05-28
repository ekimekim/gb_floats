IF !DEF(__COMMON)
__COMMON EQU 1

; Helpers for internals accessing common parts

; Handles trap for status flag \1 and operation number \2.
; If trap active, BCDE are passed to the handler.
; The status flag and operation number is also passed in A, with operation number
; in the most signifigant 5 bits and status flag in the bottom 3.
; All registers are passed back from the trap handler unmodified.
; If no trap handler, sets the status flag.
; Clobbers A, HL, others depending on trap handler contract.
; Enable tail-call optimizations by optionally passing \3 == "tail call".
HandleTrap: MACRO
IF _NARGS > 2
tail_call SET STRCMP(\3, "tail call") == 0
ELSE
tail_call SET 0
ENDC
	ld HL, FloatTraps + 2 * ((\1) - 3)
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
	ld A, [HL-] ; A = bottom byte of addr
	ld H, [HL] ; H = top byte of addr
	ld L, A ; HL = addr
	ld A, (\1) | ((\2) << 3)
IF tail_call
	jp [HL]
ELSE
	; call [HL] - there's no non-immediate call instr, so we use a trampoline.
	call _Call_HL
.end\@
ENDC
ENDM

ENDC
