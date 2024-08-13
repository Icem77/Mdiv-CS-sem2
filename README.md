# Mdiv-CS-sem2

➗ Assembly Implementation of a function with the following declaration, called from C: 

➗ int64_t mdiv(int64_t *x, size_t n, int64_t y); 

➗ The function performs integer division with a remainder. The function treats the dividend, divisor, quotient, and remainder as numbers represented in two's complement format. The first and second parameters of the function define the dividend: x is a pointer to a non-empty array of n 64-bit numbers. The dividend has 64 * n bits and is stored in memory in little-endian order. The third parameter y is the divisor. The function returns the remainder of dividing x by y. The function places the quotient in the array x.

➗ If the quotient cannot be stored in the array x, this indicates an overflow. A special case of overflow is division by zero. The function should handle overflow just like the div and idiv instructions, meaning it should raise interrupt number 0.

➗ It is permissible to assume that the pointer x is valid and that n has a positive value.
