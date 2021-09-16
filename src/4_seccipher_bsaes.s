#include "3_secsbox_bsaes.S"

.text


///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                              UTILITY MACROS                               //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////


    // ------------------------------------------------------------------------
    // Swap the 16 LSB of a register A with the 16 MSB of a register B

.macro    swap_LSB_w_MSB opA, opB
    EOR     \opA, \opA, \opB, LSR #16
    EOR     \opB, \opB, \opA, LSL #16
    EOR     \opA, \opA, \opB, LSR #16
.endm
	
    // ------------------------------------------------------------------------
    // Swap the 1st byte of a register A with the 2nd byte of a register B 

.macro    swap_firstbyte_w_secondbyte opA, opB, tmp
    EOR     \tmp, \opA, \opB, LSR #8
    BIC     \tmp, #0xFF000000
    BIC     \tmp, #0x0000FF00
    EOR     \opA, \opA, \tmp
    EOR     \opB, \opB, \tmp, LSL #8
.endm
	
    // ------------------------------------------------------------------------
    // Get the ith bit of each of the 16 bytes of the input plaintext

.macro    extract_bits in1, in2, in3, in4, out, mask, acc1, extractor1, acc2, extractor2, bit_number, pos
    AND     \acc1, \mask, \in1, LSR #\bit_number
    AND     \acc2, \mask, \in1, LSR #\pos
    AND     \extractor1, \acc1, #0x01
    EOR     \extractor1, \extractor1, \acc1, LSR #7
    AND     \extractor2, \acc2, #0x01
    EOR     \extractor2, \extractor2, \acc2, LSR #7     
    EOR     \out, \extractor1, \extractor2, LSL #2
    AND     \acc1, \mask, \in2, LSR #\bit_number
    AND     \acc2, \mask, \in2, LSR #\pos
    AND     \extractor1, \acc1, #0x01
    EOR     \extractor1, \extractor1, \acc1, LSR #7
    AND     \extractor2, \acc2, #0x01
    EOR     \extractor2, \extractor2, \acc2, LSR #7     
    EOR     \acc1, \extractor1, \extractor2, LSL #2
    EOR     \out, \out, \acc1, LSL #4
    AND     \acc1, \mask, \in3, LSR #\bit_number
    AND     \acc2, \mask, \in3, LSR #\pos
    AND     \extractor1, \acc1, #0x01
    EOR     \extractor1, \extractor1, \acc1, LSR #7
    AND     \extractor2, \acc2, #0x01
    EOR     \extractor2, \extractor2, \acc2, LSR #7     
    EOR     \acc1, \extractor1, \extractor2, LSL #2
    EOR     \out, \out, \acc1, LSL #8
    AND     \acc1, \mask, \in4, LSR #\bit_number
    AND     \acc2, \mask, \in4, LSR #\pos
    AND     \extractor1, \acc1, #0x01
    EOR     \extractor1, \extractor1, \acc1, LSR #7
    AND     \extractor2, \acc2, #0x01
    EOR     \extractor2, \extractor2, \acc2, LSR #7     
    EOR     \acc1, \extractor1, \extractor2, LSL #2
    EOR     \out, \out, \acc1, LSL #12
.endm

    // ------------------------------------------------------------------------
    // Same macro but without the LSR 0, because ARM does not compile on LSR #0 !
	
.macro    extract_bit_0 in1, in2, in3, in4, out, mask, acc1, extractor1, acc2, extractor2, pos
    AND     \acc1, \mask, \in1
    AND     \acc2, \mask, \in1, LSR #\pos
    AND     \extractor1, \acc1, #0x01
    EOR     \extractor1, \extractor1, \acc1, LSR #7
    AND     \extractor2, \acc2, #0x01
    EOR     \extractor2, \extractor2, \acc2, LSR #7     
    EOR     \out, \extractor1, \extractor2, LSL #2
    AND     \acc1, \mask, \in2
    AND     \acc2, \mask, \in2, LSR #\pos
    AND     \extractor1, \acc1, #0x01
    EOR     \extractor1, \extractor1, \acc1, LSR #7
    AND     \extractor2, \acc2, #0x01
    EOR     \extractor2, \extractor2, \acc2, LSR #7     
    EOR     \acc1, \extractor1, \extractor2, LSL #2
    EOR     \out, \out, \acc1, LSL #4
    AND     \acc1, \mask, \in3
    AND     \acc2, \mask, \in3, LSR #\pos
    AND     \extractor1, \acc1, #0x01
    EOR     \extractor1, \extractor1, \acc1, LSR #7
    AND     \extractor2, \acc2, #0x01
    EOR     \extractor2, \extractor2, \acc2, LSR #7     
    EOR     \acc1, \extractor1, \extractor2, LSL #2
    EOR     \out, \out, \acc1, LSL #8
    AND     \acc1, \mask, \in4
    AND     \acc2, \mask, \in4, LSR #\pos
    AND     \extractor1, \acc1, #0x01
    EOR     \extractor1, \extractor1, \acc1, LSR #7
    AND     \extractor2, \acc2, #0x01
    EOR     \extractor2, \extractor2, \acc2, LSR #7     
    EOR     \acc1, \extractor1, \extractor2, LSL #2
    EOR     \out, \out, \acc1, LSL #12
.endm
	
    // ------------------------------------------------------------------------
    // Creating the sharings for two bitslice register

.macro    add_mask_to_2_registers reg1, reg2, rnd, addr, dst1, dst2, pos1, pos2, tmp
    // mask first register
    get_random \rnd, \addr
    LSR     \tmp, #16
    EOR     \reg1, \tmp
    STR     \reg1, [\dst1, #\pos1]
    STR     \tmp, [\dst2, #\pos1]
    // mask second register
    ROR     \tmp, \rnd, #16
    LSR     \tmp, #16
    EOR     \reg2, \tmp
    STR     \reg2, [\dst1, #\pos2]
    STR     \tmp, [\dst2, #\pos2]
.endm

    // ------------------------------------------------------------------------
    // First addroundkey macro in bitslice

.macro    initial_addroundkey state1, state2, state3, state4, key1, key2, key3, key4, loopcounter, addr_state, addr_key
    MOV     \loopcounter, #0
loopIRARK:	
    LDM     \addr_state, {\state1-\state4}
    LDM     \addr_key!, {\key1-\key4}
    EOR     \state1, \key1
    EOR     \state2, \key2
    EOR     \state3, \key3
    EOR     \state4, \key4
    STM     \addr_state!, {\state1-\state4}
    LDM     \addr_state, {\state1-\state4}
    LDM     \addr_key!, {\key1-\key4}
    EOR     \state1, \key1
    EOR     \state2, \key2
    EOR     \state3, \key3
    EOR     \state4, \key4
    STM     \addr_state!, {\state1-\state4}
    ADD     \addr_key, #4*80
    // loop processing
    ADD     \loopcounter, #1
    CMP     \loopcounter, #NBSHARES
    BNE     loopIRARK
.endm

    // ------------------------------------------------------------------------
    // Rotation of a bitslice register for shiftrows

.macro    shiftrows_rotatation_on_register in, tmp1, tmp2
    AND     \tmp1, \in, #0xF0
    AND     \tmp2, \tmp1, #0x80
    BIC     \tmp1, \tmp1, #0x80
    EOR     \tmp1, \tmp1, \tmp2, LSR #4
    BIC     \in, #0xF0
    EOR     \in, \in, \tmp1, LSL #1
    AND     \tmp1, \in, #0xF00
    AND     \tmp2, \tmp1, #0xC00
    BIC     \tmp1, \tmp1, #0xC00
    EOR     \tmp1, \tmp1, \tmp2, LSR #4
    BIC     \in, #0xF00
    EOR     \in, \in, \tmp1, LSL #2
    AND     \tmp1, \in, #0xF000
    AND     \tmp2, \tmp1, #0x1000
    BIC     \tmp1, \tmp1, #0x1000
    EOR     \tmp1, \tmp2, \tmp1, LSR #4
    BIC     \in, #0xF000
    EOR     \in, \in, \tmp1, LSL #3
.endm    

    // ------------------------------------------------------------------------
    // AES Shiftrows in bitslice

.macro    shiftrows in1, in2, in3, in4, in5, in6, in7, in8, tmp1, tmp2
    shiftrows_rotatation_on_register \in1,\tmp1,\tmp2
    shiftrows_rotatation_on_register \in2,\tmp1,\tmp2
    shiftrows_rotatation_on_register \in3,\tmp1,\tmp2
    shiftrows_rotatation_on_register \in4,\tmp1,\tmp2
    shiftrows_rotatation_on_register \in5,\tmp1,\tmp2
    shiftrows_rotatation_on_register \in6,\tmp1,\tmp2
    shiftrows_rotatation_on_register \in7,\tmp1,\tmp2
    shiftrows_rotatation_on_register \in8,\tmp1,\tmp2
.endm

    // ------------------------------------------------------------------------
    // Mixing of one bitslice register for mixcolumns

.macro    mix_submacro out, in1, in2
    EOR     \out, \in1, \in1, LSL #12
    EOR     \out, \out, \in2, LSL #12
    EOR     \out, \out, \in2, LSL #8
    EOR     \out, \out, \in2, LSL #4
    EOR     \out, \out, \out, LSL #16
    LSR     \out, #16   
.endm
    
    // ------------------------------------------------------------------------
    // AES Mixcolumns in bitslice

.macro    mixcolumns in1, in2, in3, in4, in5, in6, in7, in8, tmp1, tmp2
    mix_submacro \tmp1,\in8,\in1
    EOR     \tmp2, \in1, \in8
    mix_submacro \tmp2,\tmp2,\in2
    mix_submacro \in1,\in2,\in3
    EOR     \in2, \in3, \in8
    mix_submacro \in2,\in2,\in4
    EOR     \in3, \in4, \in8
    mix_submacro \in3,\in3,\in5
    mix_submacro \in4,\in5,\in6
    mix_submacro \in5,\in6,\in7
    mix_submacro \in6,\in7,\in8
.endm

    // ------------------------------------------------------------------------
    // AES Addroundkey in bitslice

.macro    addroundkey in1, in2, in3, in4, in5, in6, in7, in8, key1, key2, addr
    LDM     \addr!, {\key1-\key2}
    EOR     \in1, \key1
    EOR     \in2, \key2
    LDM     \addr!, {\key1-\key2}
    EOR     \in3, \key1
    EOR     \in4, \key2
    LDM     \addr!, {\key1-\key2}
    EOR     \in5, \key1
    EOR     \in6, \key2
    LDM     \addr!, {\key1-\key2}
    EOR     \in7, \key1
    EOR     \in8, \key2
    ADD     \addr, #4*80
.endm

    // ------------------------------------------------------------------------
    // Demasking the sharings for each bitslice register

.macro    demasking in1, in2, in3, in4, in5, in6, in7, in8, loopcounter, addr, tmp
    MOV     \loopcounter, #0
loopDemasking:	
    LDR     \tmp, [\addr]
    ADD     \addr, #4
    EOR     \in1, \tmp
    LDR     \tmp, [\addr]
    ADD     \addr, #4
    EOR     \in2, \tmp
    LDR     \tmp, [\addr]
    ADD     \addr, #4
    EOR     \in3, \tmp
    LDR     \tmp, [\addr]
    ADD     \addr, #4
    EOR     \in4, \tmp
    LDR     \tmp, [\addr]
    ADD     \addr, #4
    EOR     \in5, \tmp
    LDR     \tmp, [\addr]
    ADD     \addr, #4
    EOR     \in6, \tmp
    LDR     \tmp, [\addr]
    ADD     \addr, #4
    EOR     \in7, \tmp
    LDR     \tmp, [\addr]
    ADD     \addr, #4
    EOR     \in8, \tmp
    // loop Demasking processing
    ADD     \loopcounter, #1
    CMP     \loopcounter, #(NBSHARES-1)
    BNE     loopDemasking
.endm

    // ------------------------------------------------------------------------
    // Extract each octet of the ciphertext in the bitslice registers

.macro    swap_representation in1, in2, in3, in4, in5, in6, in7, in8, addr, acc, tmp1, tmp2
    // Extract first octet
    AND     \tmp1, \in1, #0x01
    AND     \tmp2, \in2, #0x01
    EOR     \tmp1, \tmp1, \tmp2, LSL #1
    AND     \tmp2, \in3, #0x01
    EOR     \tmp1, \tmp1, \tmp2, LSL #2
    AND     \tmp2, \in4, #0x01
    EOR     \tmp1, \tmp1, \tmp2, LSL #3
    AND     \tmp2, \in5, #0x01
    EOR     \tmp1, \tmp1, \tmp2, LSL #4
    AND     \tmp2, \in6, #0x01
    EOR     \tmp1, \tmp1, \tmp2, LSL #5
    AND     \tmp2, \in7, #0x01
    EOR     \tmp1, \tmp1, \tmp2, LSL #6
    AND     \tmp2, \in8, #0x01
    EOR     \acc, \tmp1, \tmp2, LSL #7
    // Extract second octet
    AND     \tmp1, \in1, #0x02
    LSR     \tmp1, #1
    AND     \tmp2, \in2, #0x02
    EOR     \tmp1, \tmp2
    AND     \tmp2, \in3, #0x02
    EOR     \tmp1, \tmp1, \tmp2, LSL #1
    AND     \tmp2, \in4, #0x02
    EOR     \tmp1, \tmp1, \tmp2, LSL #2
    AND     \tmp2, \in5, #0x02
    EOR     \tmp1, \tmp1, \tmp2, LSL #3
    AND     \tmp2, \in6, #0x02
    EOR     \tmp1, \tmp1, \tmp2, LSL #4
    AND     \tmp2, \in7, #0x02
    EOR     \tmp1, \tmp1, \tmp2, LSL #5
    AND     \tmp2, \in8, #0x02
    EOR     \tmp1, \tmp1, \tmp2, LSL #6
    EOR     \acc, \acc, \tmp1, LSL #8
    // Extract third octet
    AND     \tmp1, \in1, #0x04
    LSR     \tmp1, #2
    AND     \tmp2, \in2, #0x04
    EOR     \tmp1, \tmp1, \tmp2, LSR #1
    AND     \tmp2, \in3, #0x04
    EOR     \tmp1, \tmp2
    AND     \tmp2, \in4, #0x04
    EOR     \tmp1, \tmp1, \tmp2, LSL #1
    AND     \tmp2, \in5, #0x04
    EOR     \tmp1, \tmp1, \tmp2, LSL #2
    AND     \tmp2, \in6, #0x04
    EOR     \tmp1, \tmp1, \tmp2, LSL #3
    AND     \tmp2, \in7, #0x04
    EOR     \tmp1, \tmp1, \tmp2, LSL #4
    AND     \tmp2, \in8, #0x04
    EOR     \tmp1, \tmp1, \tmp2, LSL #5
    EOR     \acc, \acc, \tmp1, LSL #16
    // Extract fourth octet
    AND     \tmp1, \in1, #0x08
    LSR     \tmp1, #3
    AND     \tmp2, \in2, #0x08
    EOR     \tmp1, \tmp1, \tmp2, LSR #2
    AND     \tmp2, \in3, #0x08
    EOR     \tmp1, \tmp1, \tmp2, LSR #1
    AND     \tmp2, \in4, #0x08
    EOR     \tmp1, \tmp2
    AND     \tmp2, \in5, #0x08
    EOR     \tmp1, \tmp1, \tmp2, LSL #1
    AND     \tmp2, \in6, #0x08
    EOR     \tmp1, \tmp1, \tmp2, LSL #2
    AND     \tmp2, \in7, #0x08
    EOR     \tmp1, \tmp1, \tmp2, LSL #3
    AND     \tmp2, \in8, #0x08
    EOR     \tmp1, \tmp1, \tmp2, LSL #4
    EOR     \acc, \acc, \tmp1, LSL #24
    // 
    STR     \acc, [\addr]
    ADD     \addr, #4
.endm
    
    // ------------------------------------------------------------------------
    // Swap a ciphertext from a bitslice representation to a regular one

.macro    from_bitslice_to_normal in1, in2, in3, in4, in5, in6, in7, in8, addr_in, addr_out, acc, tmp1, tmp2
    AND     \in1, #0xF
    AND     \in2, #0xF
    AND     \in3, #0xF
    AND     \in4, #0xF
    AND     \in5, #0xF
    AND     \in6, #0xF
    AND     \in7, #0xF
    AND     \in8, #0xF
    swap_representation \in1,\in2,\in3,\in4,\in5,\in6,\in7,\in8,\addr_out,\acc,\tmp1,\tmp2
    LDM         \addr_in, {\in1-\in8}
    AND     \in1, #0xF0
    AND     \in2, #0xF0
    AND     \in3, #0xF0
    AND     \in4, #0xF0
    AND     \in5, #0xF0
    AND     \in6, #0xF0
    AND     \in7, #0xF0
    AND     \in8, #0xF0
    LSR     R5, #4
    LSR     R6, #4
    LSR     R7, #4
    LSR     R8, #4
    LSR     R9, #4
    LSR     R10, #4
    LSR     R11, #4
    LSR     R12, #4
    swap_representation \in1,\in2,\in3,\in4,\in5,\in6,\in7,\in8,\addr_out,\acc,\tmp1,\tmp2
    LDM         \addr_in, {\in1-\in8}
    AND     \in1, #0xF00
    AND     \in2, #0xF00
    AND     \in3, #0xF00
    AND     \in4, #0xF00
    AND     \in5, #0xF00
    AND     \in6, #0xF00
    AND     \in7, #0xF00
    AND     \in8, #0xF00
    LSR     R5, #8
    LSR     R6, #8
    LSR     R7, #8
    LSR     R8, #8
    LSR     R9, #8
    LSR     R10, #8
    LSR     R11, #8
    LSR     R12, #8
    swap_representation \in1,\in2,\in3,\in4,\in5,\in6,\in7,\in8,\addr_out,\acc,\tmp1,\tmp2
    LDM         \addr_in, {\in1-\in8}
    AND     \in1, #0xF000
    AND     \in2, #0xF000
    AND     \in3, #0xF000
    AND     \in4, #0xF000
    AND     \in5, #0xF000
    AND     \in6, #0xF000
    AND     \in7, #0xF000
    AND     \in8, #0xF000
    LSR     R5, #12
    LSR     R6, #12
    LSR     R7, #12
    LSR     R8, #12
    LSR     R9, #12
    LSR     R10, #12
    LSR     R11, #12
    LSR     R12, #12
    swap_representation \in1,\in2,\in3,\in4,\in5,\in6,\in7,\in8,\addr_out,\acc,\tmp1,\tmp2
    SUB     \addr_out, #16
.endm

    
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                        Bitslice AES encryption                            //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////

.pool
.global bsaes_encrypt
bsaes_encrypt:	
    // R0: plaintext address
    // R1: ciphertext address
    // R2: key schedule address
    
    push {R3-R12, LR}
    push {R1}


    ///////////////////////////////////
    //                               //
    //  Pre-processing of the input  //
    //                               //
    ///////////////////////////////////

    // ------------------------------------------------------------------------
    // Changing the representation of the plaintext into the bitslice one

    LDM     R0, {R9-R12}
    LDR     R0, =BitSliceTable
    B       ignored1
.pool
ignored1:	
    // Swap LSB of R9 with MSB of R11
    swap_LSB_w_MSB R9, R11
    // Swap LSB of R10 with MSB of R12
    swap_LSB_w_MSB R10, R12
    // Swap second byte of R9 with first byte of R10
    swap_firstbyte_w_secondbyte R9, R10, R5
    // Swap second byte of R11 with first byte of R12
    swap_firstbyte_w_secondbyte R11, R12, R5
    // Setting masks for extraction
    MOV     R8, #0x01
    EOR     R8, R8, R8, LSL #8
    // Get the first bit of each state elements
    extract_bit_0 R9,R10,R11,R12,R4,R8,R7,R5,R1,R3,16
    // Store extracted register
    STR     R4, [R0]
    ADD     R6, R0, #4
    // Get the second bit of each state elements
    extract_bits R9,R10,R11,R12,R4,R8,R7,R5,R1,R3,1,17
    // Store extracted register
    STR     R4, [R6]
    ADD     R6, #4
    // Get the third bit of each state elements
    extract_bits R9,R10,R11,R12,R4,R8,R7,R5,R1,R3,2,18
    // Store extracted register
    STR     R4, [R6]
    ADD     R6, #4
    // Get the fourth bit of each state elements
    extract_bits R9,R10,R11,R12,R4,R8,R7,R5,R1,R3,3,19
    // Store extracted register
    STR     R4, [R6]
    ADD     R6, #4
    // Get the fifth bit of each state elements
    extract_bits R9,R10,R11,R12,R4,R8,R7,R5,R1,R3,4,20
    // Store extracted register
    STR     R4, [R6]
    ADD     R6, #4
    // Get the sixth bit of each state elements
    extract_bits R9,R10,R11,R12,R4,R8,R7,R5,R1,R3,5,21
    // Store extracted register
    STR     R4, [R6]
    ADD     R6, #4
    // Get the seventh bit of each state elements
    extract_bits R9,R10,R11,R12,R4,R8,R7,R5,R1,R3,6,22
    // Store extracted register
    STR     R4, [R6]
    ADD     R6, #4
    // Get the eighth bit of each state elements
    extract_bits R9,R10,R11,R12,R4,R8,R7,R5,R1,R3,7,23
    // Store extracted register
    STR     R4, [R6]
    
    // ------------------------------------------------------------------------
    // Creation of the sharings of each bitslice register at order d

    LDR     R1, =SboxIn
    push {R2}
    LDR     R2, =RNGReg
    LDM     R0, {R5-R12}
    B       ignored2
.pool
ignored2:	
    MOV     R0, R1
    MOV     R3, #0
loopMasking:	
    ADD     R0, #4*8
    add_mask_to_2_registers R5,R6,R4,R2,R1,R0,0,4,R14
    add_mask_to_2_registers R7,R8,R4,R2,R1,R0,8,12,R14
    add_mask_to_2_registers R9,R10,R4,R2,R1,R0,16,20,R14
    add_mask_to_2_registers R11,R12,R4,R2,R1,R0,24,28,R14
    // loop Masking processing
    ADD     R3, #1
    CMP     R3, #(NBSHARES-1)
    BNE     loopMasking
    

    ///////////////////////////////////
    //                               //
    //         Initial Round         //
    //                               //
    ///////////////////////////////////


    // ------------------------------------------------------------------------
    // Initial Round: AddRoundKey

    MOV     R0, R1
    pop {R2}
    initial_addroundkey R4,R5,R6,R7,R8,R9,R10,R11,R3,R0,R2
    // Address update
    SUB     R2, #((4*88*NBSHARES)-32)
    SUB     R0, #4*8*NBSHARES
    

    ///////////////////////////////////
    //                               //
    //         Main Rounds           //
    //                               //
    ///////////////////////////////////


    MOV     R12, #9
loopAES:	
    push {R12}
    
    // ------------------------------------------------------------------------
    // MR: SubBytes

    LDR     R1, =SboxOut
    BL      bsaes_sbox
    LDR     R0, =SboxIn
    // loop over masks for shiftrows mixcolumns and addroundkey
    MOV     R11, #0
loopMRSRMRARK:	
    push {R0}
    LDM     R1!, {R3-R10}
    push {R1}
    push {R2}

    // ------------------------------------------------------------------------
    // MR: ShiftRows

    shiftrows R3,R4,R5,R6,R7,R8,R9,R10,R0,R2
    
    // ------------------------------------------------------------------------
    // MR: MixColumns 

    mixcolumns R3,R4,R5,R6,R7,R8,R9,R10,R0,R2
    MOV     R9, R0
    MOV     R10, R2
    
    // ------------------------------------------------------------------------
    // MR: AddRoundKeys

    pop {R2}
    addroundkey R9,R10,R3,R4,R5,R6,R7,R8,R0,R1,R2
    pop {R1}
    pop {R0}
    STM     R0!, {R9,R10}
    STM     R0!, {R3-R8}
    // loop SR,MR,ARK processing
    ADD     R11, #1
    CMP     R11, #NBSHARES
    BNE     loopMRSRMRARK
    // Address update
    SUB     R2, #((4*88*NBSHARES)-32)
    SUB     R0, #4*8*NBSHARES
    // loop Main Round processing
    pop {R12}
    SUBS    R12, #1
    BNE     loopAES
    

    ///////////////////////////////////
    //                               //
    //         Last Round            //
    //                               //
    ///////////////////////////////////


    // ------------------------------------------------------------------------
    // LR: SubBytes

    LDR     R1, =SboxOut
    BL      bsaes_sbox
    LDR     R0, =SboxIn
    
    // ------------------------------------------------------------------------
    // LR: ShitRows

    MOV     R11, #0
loopLastRound:	
    push {R0}
    LDM     R1!, {R3-R10}
    push {R1}
    push {R2}
    
    // ------------------------------------------------------------------------
    // LR: ShitRows

    shiftrows R3,R4,R5,R6,R7,R8,R9,R10,R0,R2
    
    // ------------------------------------------------------------------------
    // LR: AddRoundKey

    pop {R2}
    addroundkey R3,R4,R5,R6,R7,R8,R9,R10,R0,R1,R2
    pop {R1}
    pop {R0}
    STM     R0!, {R3-R10}
    // loop Last Round processing 
    ADD     R11, #1
    CMP     R11, #NBSHARES
    BNE     loopLastRound
    // Address update
    SUB     R2, #4*80*NBSHARES
    SUB     R0, #8*4*NBSHARES


    ///////////////////////////////////
    //                               //
    // Post-processing of the output //
    //                               //
    ///////////////////////////////////


    // ------------------------------------------------------------------------
    // Unmasking each of the output bitslice registers

    LDM     R0!, {R5-R12}
    demasking R5,R6,R7,R8,R9,R10,R11,R12,R3,R0,R4

    // ------------------------------------------------------------------------
    // Changing the representation of the ciphertext into the regular one

    pop {R3}
    LDR     R1, =SboxIn
    STM     R1, {R5-R12}
    from_bitslice_to_normal R5,R6,R7,R8,R9,R10,R11,R12,R1,R3,R4,R0,R2
    // Transposition of the state 
    LDM     R3, {R9-R12}
    // Swap LSB of R9 with MSB of R11
    swap_LSB_w_MSB R9, R11
    // Swap LSB of R10 with MSB of R12
    swap_LSB_w_MSB R10, R12
    // Swap second byte of R9 with first byte of R10
    swap_firstbyte_w_secondbyte R9, R10, R5
    // Swap second byte of R11 with first byte of R12
    swap_firstbyte_w_secondbyte R11, R12, R5
    STM     R3, {R9-R12}

    pop {R3-R12, LR}
    BX  LR



///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                Temporary tables for bitslice AES encryption               //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////


.data
BitSliceTable:
	.zero 4*8
SboxIn:
	.zero 4*8*NBSHARES
SboxOut:
	.zero 4*8*NBSHARES
