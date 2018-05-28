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

; Addresses for trap handlers. $ffff is used as a sentinel value for a disabled trap.
; Addresses are stored big-endian and in the same order as the status flags
; (ie. INEXACT, UNDERFLOW, OVERFLOW, DIV_BY_ZERO, INVALID)
FloatTraps:
	ds 2 * 5

SECTION "Floating point common methods"

; Note explicit use of ldh as the assembler can't work out these values
; will eventually be resolved by the linker to hram addresses.

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
	add A ; A = 2 * A
	; HL = FloatTraps - 2*3 + 2*A = FloatTraps + 2*(A-3) = &FloatTraps[A-3]
	LongAddToA (FloatTraps - 2 * 3), HL
ENDM

; Set the trap handler for status flag A to DE,
; or disable the trap if DE == $ffff.
; A trap handler is a routine that is called upon the given exception occurring,
; instead of setting the corresponding status flag.
; It will receive A = the status flag that triggered it, as well as optionally
; extra values for BCDE depending on the triggering operation.
; In some cases it should return a value in BCDE, depending on the triggering operation.
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

; A trampoline that is needed to simulate 'call [HL]' when calling traps.
; Use it by calling it after setting HL. When the routine pointed to by HL returns,
; it will return to the caller.
_Call_HL::
	jp [HL]
