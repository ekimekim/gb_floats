include "longcalc.asm"

; Shard components for floating point implementation,
; including definition/manipulation of the status flags and rounding mode.

SECTION "Floating point flags", HRAM

; Bits:
;  0-2: Rounding mode
;  3-7: Status flags
; Users may directly introspect or modify status flags
; using the appropriate bit field operations on this value.
FloatFlags::
	db

SECTION "Floating point trap addresses", WRAM0

; Trampolines for trap handlers. $ffff is used as a sentinel value for a disabled trap.
; Each set of 3 bytes forms a routine "jp NN" which immediately tail-calls the handler.
; Addresses are stored little-endian and in the same order as the status flags
; (ie. INEXACT, UNDERFLOW, OVERFLOW, DIV_BY_ZERO, INVALID)
FloatTraps:
	ds 3 * 5

SECTION "Floating point common methods"

; Note explicit use of ldh as the assembler can't work out these values
; will eventually be resolved by the linker to hram addresses.

; Do basic initialization.
; Clobbers A, HL
InitFloat::
	xor A
	ld [FloatFlags], A
	dec A ; A = ff
	ld HL, FloatTraps
	REPT 5
	ld [HL], $c3 ; c3 is opcode for jp NN
	inc HL
	ld [HL+], A
	ld [HL+], A ; set addr to $ffff
	ENDR
	ret


; Sets rounding mode to that given in B. Clobbers A.
SetRounding::
	ldh A, [FloatFlags]
	and %11111000 ; only keep status flags
	or B ; note: assumes input rounding mode is valid (no high bits set)
	ldh [FloatFlags], A
	ret

; Sets A to current rounding mode
GetRounding::
	ldh A, [FloatFlags]
	and %00000111
	ret

; Sets the status flags given by B. Clobbers A.
SetFlags::
	ldh A, [FloatFlags]
	and %00000111 ; only keep rounding mode
	or B ; note: assumes input rounding mode == 0
	ldh [FloatFlags], A
	ret

; Sets A to the current status flags
GetFlags::
	ldh A, [FloatFlags]
	and %11111000
	ret

; Clears all status flags. Clobbers A.
ClearFlags::
	ldh A, [FloatFlags]
	and %00000111
	ldh [FloatFlags], A
	ret

; Sets HL to the handler slot for trap handler for status flag A.
_GetHandlerAddr: MACRO
	ld H, A
	add A ; A = 2 * A
	add H ; A = 3 * A
	; HL = FloatTraps - 3*3 + 1 + 3*A = FloatTraps + 3*(A-3) + 1 = &FloatTraps[A-3] + 1
	LongAddToA (FloatTraps - 3 * 3 + 1), HL
ENDM

; Set the trap handler for status flag A to DE,
; or disable the trap if DE == $ffff.
; A trap handler is a routine that is called upon the given exception occurring,
; instead of setting the corresponding status flag.
; It will receive A = ooooooff where oooooo is the triggering operation, and ff is its format.
; It may also receive extra values for BCDE depending on the triggering operation.
; In some cases it should return a value, depending on the triggering operation.
; Clobbers A, HL.
SetTrapHandler::
	_GetHandlerAddr
	ld A, D
	ld [HL+], A
	ld [HL], E
	ret

; Returns the current trap handler for status flag A in DE,
; or sets DE to $ffff if the trap is disabled.
; Clobbers HL.
GetTrapHandler::
	_GetHandlerAddr
	ld A, [HL+]
	ld D, A
	ld E, [HL]
	ret
