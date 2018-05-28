IF !DEF(__FLOAT_FLAGS)
__FLOAT_FLAGS EQU 1

// Defines constants for working with float library.
// This include file is intended for external use.

// Rounding modes:
rsset 0
ROUND_TO_NEAREST_TIE_EVEN rb 1
ROUND_TO_NEAREST_TIE_AWAY_FROM_ZERO rb 1
ROUND_TOWARD_ZERO rb 1
ROUND_UP rb 1
ROUND_DOWN rb 1

// Status flags. Note these are generally used in a bitfield,
// so you would check the status of eg. overflow by doing BIT R, FLAG_OVERFLOW
rsset 3 // the bottom two bits of the bitfield are used for rounding mode
FLAG_INEXACT rb 1
FLAG_UNDERFLOW rb 1
FLAG_OVERFLOW rb 1
FLAG_DIV_BY_ZERO rb 1
FLAG_INVALID rb 1

// Available formats. Passed into trap handlers.
rsset 0
FORMAT_HALF rb 1
FORMAT_SINGLE rb 1
FORMAT_DOUBLE rb 1
FORMAT_RESERVED rb 1

// Available operations. Passed into trap handlers.
rsset 0
// TODO

ENDC
