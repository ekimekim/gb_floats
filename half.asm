
SECTION "Half-precision float methods", ROM0

// A half-precision float (aka. IEEE-754 binary16 format) has the following
// format in bits, from MSB to LSB:
//  SEEEEEMM MMMMMMMM
// where:
//	S is the sign bit (0 is positive, 1 is negative)
//  E is a 5-bit unsigned exponent (the actual exponent value = EEEEE - 15)
//    When EEEEE == 0, the number is subnormal
//    When EEEEE == 31, the number is +-Inf or NaN
//  M is a 10-bit unsigned mantissa, with an implicit leading bit unless the number
//    is subnormal. When E == 31 and M == 0, the number is Infinity.
//    When E == 31 and M != 0, the number is NaN.
//
// NaNs are encoded as follows:
//  S11111QP PPPPPPPP
// where:
//  S is the sign bit, and is ignored but propogated where possible.
//  Q indicates this is a quiet NaN, not a signalling NaN.

// Where applicable, trap handlers are given values in this form:
//  For overflow, underflow, inexact:
//   BC: Rounded result
//  For invalid, div_by_zero:
//   BC: First operand
//   DE: Second operand, if any
// And should return values in BC.

// All operations clobber all regs unless indicated otherwise.


