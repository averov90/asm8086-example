# asm8086 IO and Arithmetic example
[![License](https://img.shields.io/badge/LICENSE-The%20Unlicense-green?style=flat-square)](/LICENSE)  [![Version](https://img.shields.io/badge/VERSION-STABLE-green?style=flat-square)](https://github.com/averov90/asm8086-io-ariphmetic/releases)
### :small_orange_diamond: [Russian version](/README.md)

This repository contains 3 small running programs that contain some I/O and arithmetic functions. To get an example (to be able to demonstrate), each program has a head function. Below, the list of examples will be discussed in more detail.

To run the examples, you need: a *DOS* environment, a *TASM (Turbo Assembler)* compiler for *Intel 8086*. As a *DOS* environment, you can take *DOSBox* (or *DOSBox Staging*, but in the *DOSBox*, compiled programs seem to work better).

Before starting each function, it is specified which registers are required for this function to work (i.e., those registers whose value must be stored before calling the function in case the values stored in them are needed later). These registers also include function arguments. The description of these arguments is given inside the function (at the beginning). Many aspects of program execution are explained in the comments in the code.

## prog_1.asm
**func_uint16IN** - function for entering an unsigned 16-bit number. The number itself is returned after entering via the *AX* register.

**func_uint32OUT** - function for outputting an unsigned 32-bit number. The number for output is supplied via 2 registers (*AX* - lower word, *DX* - upper word). In operation, this function uses a stack (requires 10 words, i.e. 20 bytes).

**func_mul32x16** - function for multiplying a 32-bit number by a 16-bit number. The numbers for are fed through 3 registers (*AX* - the lower word of 1 number, *DX* - the upper word of 1 number, *BX* - the multiplier). The result is via *AX* and *DX*.

**func_div32x16** - function for dividing a 32-bit number by a 16-bit number. Numbers for output are fed through 2 registers (*AX* - the lower word of dividend number, *DX* - the upper word of dividend number) and the variable *func_div32x16_divider*. The result is in terms of *AX* and *DX* (integer part), *BX* - remainder.

The main function of this example uses the above functions to calculate the number of permutations when *m* and *n* are passed to the program.

## prog_2.asm
**func_int16IN** - function for entering a signed 16-bit number. The number itself is returned after entering via the *AX* register.

**func_uint16IN** - function for entering an unsigned 16-bit number. The number itself is returned after entering via the *AX* register.

**func_uint16OUT** - function for outputting an unsigned 16-bit number. The number for output is supplied through 2 registers (*AX* - the lower word). In operation, this function uses a stack (requires 10 words, i.e. 20 bytes).

The main function of this example uses the above functions to count the number of numbers greater than the specified threshold. Allows you to enter both the threshold and the number of numbers to enter.

## prog_3.asm
**func_placments32x16x16** - function for calculating the number of permutations for *m* and *n* passed to the program. Arguments to the function are passed through the stack.

**func_uint16IN** - function for entering an unsigned 16-bit number. The number itself is returned after entering via the *AX* register.

**func_uint32OUT** - function for outputting an unsigned 32-bit number. The number for output is supplied via 2 registers (*AX* - lower word, *DX* - upper word). In operation, this function uses a stack (requires 10 words, i.e. 20 bytes).

**func_mul32x16** - function for multiplying a 32-bit number by a 16-bit number. The numbers for are fed through 3 registers (*AX* - the lower word of 1 number, *DX* - the upper word of 1 number, *BX* - the multiplier). The result is via *AX* and *DX*.

**func_div32x16** - function for dividing a 32-bit number by a 16-bit number. Numbers for output are fed through 2 registers (*AX* - the lower word of 1 number, *DX* - the upper word of 1 number, *BX* - the multiplier) and the variable *func_div32x16_divider*. The result is in terms of *AX* and *DX* (integer part), *BX* - remainder.

The main function of this example uses the above functions to calculate the number of permutations when *m* and *n* are passed to the program.
