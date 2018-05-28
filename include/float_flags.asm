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
FORMAT_RESERVED rb 1 // unused

// Available operations. Passed into trap handlers.
// Most of these names should be obvious.
// Operands and results all have the same bit size, with the
// exception of _LARGER and _SMALLER ops, where one value is one size 'up' or 'down'
// respectively, eg. OP_MUL_LARGER has a 32-bit result for 16-bit operands.
// These differing sizes apply to results in general, but operands for FROM ops.
rsset 0
OP_ADD rb 1
OP_SUB rb 1
OP_MUL rb 1
OP_MUL_LARGER rb 1 // result is one size larger
OP_DIV rb 1
OP_MOD rb 1
OP_SQRT rb 1 // square root
OP_FROM_INT rb 1
OP_FROM_SMALLER rb 1 // operand is one size smaller
OP_FROM_LARGER rb 1 // operand is one size larger
OP_TO_INT rb 1
OP_TO_INT_LARGER rb 1 // result is one size larger
OP_FROM_STR rb 1
OP_TO_STR rb 1
OP_ROUND rb 1 // rounds to integral value, but result is float
OP_CMP rb 1 // compare, returning -1/0/1/NaN
OP_ABS rb 1 // absolute value
OP_SIGN rb 1 // sign value
OP_SHIFT_LEFT rb 1 // shift left, ie. multiply by integral power of 2
OP_SHIFT_RIGHT rb 1 // shift right, ie. divide by integral power of 2
OP_TYPE rb 1 // one of: normal, subnormal, zero, inf, sNaN, qNaN
OP_FINITE rb 1
OP_IS_INF rb 1
OP_NAN_PAYLOAD rb 1 // returns the payload of a NaN as integer, or 0
OP_NEGATE rb 1
OP_LOG rb 1 // returns the signed integer log base 2, 8-bit for half and single, 16-bit for double.
OP_SIN rb 1
OP_NEXT rb 1 // returns next representable value in positive direction
OP_PREV rb 1 // returns next representable value in negative direction

ENDC
