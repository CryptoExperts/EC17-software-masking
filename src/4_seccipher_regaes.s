.text
    
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                         Regular AES encryption                            //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////

.pool
.global regaes_encrypt         
regaes_encrypt:	
    push {R1, R3-R12, LR}
    // R0: plaintext address
    // R1: ciphertext address
    // R2: key schedule address
        

    ///////////////////////////////////
    //                               //
    //  Pre-processing of the input  //
    //                               //
    ///////////////////////////////////


    // ------------------------------------------------------------------------
    // Creation of the sharings of each register at order d

    LDM     R0, {R4-R7}
    LDR     R0, =MaskedState
    LDR     R10, =RNGReg
    MOV     R12, #1
loopMasking:	
    get_random R9, R10
    EOR     R4, R9
    STR     R9, [R0, R12, LSL #2]
    ADD     R0, #(4*NBSHARES)
    get_random R9, R10
    EOR     R5, R9
    STR     R9, [R0, R12, LSL #2]
    ADD     R0, #(4*NBSHARES)
    get_random R9, R10
    EOR     R6, R9
    STR     R9, [R0, R12, LSL #2]
    ADD     R0, #(4*NBSHARES)
    get_random R9, R10
    EOR     R7, R9
    STR     R9, [R0, R12, LSL #2]
    SUB     R0, #3*(4*NBSHARES)
    // loop Masking processing
    ADD     R12, #1
    CMP     R12, #NBSHARES
    BNE     loopMasking
    STR     R4, [R0]
    ADD     R0, #(4*NBSHARES)
    STR     R5, [R0]
    ADD     R0, #(4*NBSHARES)
    STR     R6, [R0]
    ADD     R0, #(4*NBSHARES)
    STR     R7, [R0]
    SUB     R0, #3*(4*NBSHARES) 

    // ------------------------------------------------------------------------
    // transposition of the plaintext to work on column

    MOV     R3, #0
loopOverShares:	
    LDR     R9, [R0, R3, LSL #2]
    ADD     R0, #(4*NBSHARES)
    LDR     R10, [R0, R3, LSL #2]
    ADD     R0, #(4*NBSHARES)
    LDR     R11, [R0, R3, LSL #2]
    ADD     R0, #(4*NBSHARES)
    LDR     R12, [R0, R3, LSL #2]
    SUB     R0, #3*(4*NBSHARES)
    EOR     R9, R9, R11, LSR #16
    EOR     R11, R11, R9, LSL #16
    EOR     R9, R9, R11, LSR #16
    EOR     R10, R10, R12, LSR #16
    EOR     R12, R12, R10, LSL #16
    EOR     R10, R10, R12, LSR #16
    EOR     R5, R9, R10, LSR #8
    BIC     R5, #0xFF000000
    BIC     R5, #0x0000FF00
    EOR     R9, R9, R5
    EOR     R10, R10, R5, LSL #8
    EOR     R5, R11, R12, LSR #8
    BIC     R5, #0xFF000000
    BIC     R5, #0x0000FF00
    EOR     R11, R11, R5
    EOR     R12, R12, R5, LSL #8


    ///////////////////////////////////
    //                               //
    //         Initial Round         //
    //                               //
    ///////////////////////////////////


    // ------------------------------------------------------------------------
    // IR:  AddRoundKey 

    LDM     R2, {R5-R8}
    EOR     R9, R5, R9  
    EOR     R10, R6, R10
    EOR     R11, R7, R11
    EOR     R12, R8, R12
    STR     R9, [R0, R3, LSL #2]
    ADD     R0, #(4*NBSHARES)
    STR     R10, [R0, R3, LSL #2]
    ADD     R0, #(4*NBSHARES)
    STR     R11, [R0, R3, LSL #2]
    ADD     R0, #(4*NBSHARES)
    STR     R12, [R0, R3, LSL #2]
    SUB     R0, #3*(4*NBSHARES)
    ADD     R2, #4*44
    // loop processing
    ADD     R3, #1
    CMP     R3, #NBSHARES
    BNE     loopOverShares
    SUB     R2, #16*(11*NBSHARES-1)
    LDR     R11, =sboxOut


    ///////////////////////////////////
    //                               //
    //         Main Rounds           //
    //                               //
    ///////////////////////////////////


    MOV     R3, #9
loopAES:	
    
    // ------------------------------------------------------------------------
    // MR: SubBytes

    MOV     R1, R11
#if CIPH_MODE==RP
    push {R0,R1}
    BL      rp_sbox
    pop {R0,R1}
    ADD     R0, #4*NBSHARES
    ADD     R1, #4*NBSHARES
    push {R0,R1}
    BL      rp_sbox
    pop {R0,R1}
    ADD     R0, #4*NBSHARES
    ADD     R1, #4*NBSHARES
    push {R0,R1}
    BL      rp_sbox
    pop {R0,R1}
    ADD     R0, #4*NBSHARES
    ADD     R1, #4*NBSHARES
    push {R0,R1}
    BL      rp_sbox
    pop {R0,R1}
    
#elif CIPH_MODE==KHL
    push {R0,R1}
    BL      khl_sbox
    pop {R0,R1}
    ADD     R0, #8*NBSHARES
    push {R0,R1}
    BL      khl_sbox
    pop {R0,R1}
#endif

    // ------------------------------------------------------------------------
    // MR: ShiftRows

    MOV     R10, #0
loop2OverShares:	
    ADD     R12, R11, #4*NBSHARES
    LDR     R5, [R12, R10, LSL #2]
    ROR     R5, #24
    STR     R5, [R12, R10, LSL #2]
    ADD     R12, #4*NBSHARES
    LDR     R5, [R12, R10, LSL #2]
    ROR     R5, #16
    STR     R5, [R12, R10, LSL #2]
    ADD     R12, #4*NBSHARES
    LDR     R5, [R12, R10, LSL #2]
    ROR     R5, #8
    STR     R5, [R12, R10, LSL #2]
    // loop processing
    ADD     R10, #1
    CMP     R10, #NBSHARES
    BNE     loop2OverShares
    push {R14}
    push {R3}
    MOV     R12, #0
loop3OverShares:	
    
    // ------------------------------------------------------------------------
    // MR: MixColumns 

    LDR     R7, [R11, R12, LSL #2]
    ADD     R10, R11, #4*NBSHARES
    LDR     R8, [R10, R12, LSL #2]
    ADD     R10, #4*NBSHARES
    LDR     R9, [R10, R12, LSL #2]
    ADD     R10, #4*NBSHARES
    LDR     R10, [R10, R12, LSL #2]
    // tmp = s0+s1+s2+s3
    EOR     R3, R7, R8
    EOR     R3, R3, R9
    EOR     R3, R3, R10
    // 0x01 on all bytes
    MOV     R6, #1
    ADD     R6, R6, R6, LSL #8
    ADD     R6, R6, R6, LSL #16
    // storing 0x1b
    MOV     R5, #27
    // xtimes st0+st1
    EOR     R4, R7, R8
    AND     R14, R6, R4, LSR #7
    MUL     R0, R14, R5
    BIC     R4, R4, R6, LSL #7
    EOR     R4, R0, R4, LSL #1
    // st0 update
    EOR     R7, R7, R3
    EOR     R7, R7, R4
    // xtimes st1+st2
    EOR     R4, R8, R9
    AND     R14, R6, R4, LSR #7
    MUL     R0, R14, R5
    BIC     R4, R4, R6, LSL #7
    EOR     R4, R0, R4, LSL #1
    // st1 update
    EOR     R8, R8, R3
    EOR     R8, R8, R4
    // xtimes st2+st3
    EOR     R4, R9,R10
    AND     R14, R6, R4, LSR #7
    MUL     R0, R14, R5
    BIC     R4, R4, R6, LSL #7
    EOR     R4, R0, R4, LSL #1
    // st2 update
    EOR     R9, R9, R3
    EOR     R9, R9, R4
    // st4
    EOR     R10, R7, R8
    EOR     R10, R9
    EOR     R10, R3
    
    // ------------------------------------------------------------------------
    // MR: AddRoundKeys

    LDM     R2, {R3-R6}
    EOR     R7, R3, R7  
    EOR     R8, R4, R8
    EOR     R9, R5, R9
    EOR     R10, R6, R10
    ADD     R2, #4*44
    LDR     R0, =sboxIn
    STR     R7, [R0, R12, LSL #2]
    ADD     R7, R0, #4*NBSHARES
    STR     R8, [R7, R12, LSL #2]
    ADD     R7, #4*NBSHARES
    STR     R9, [R7, R12, LSL #2]
    ADD     R7, #4*NBSHARES
    STR     R10, [R7, R12, LSL #2]
    ADD     R12, #1
    CMP     R12, #NBSHARES
    BNE     loop3OverShares
    SUB     R2, #16*(11*NBSHARES-1)
    pop {R3}
    pop {R14}
    // loop processing
    SUBS    R3, #1
    BNE     loopAES


    ///////////////////////////////////
    //                               //
    //         Last Round            //
    //                               //
    ///////////////////////////////////


    // ------------------------------------------------------------------------
    // LR: SubBytes

    MOV     R1, R11
#if CIPH_MODE==RP
    push {R0,R1}
    BL      rp_sbox
    pop {R0,R1}
    ADD     R0, #4*NBSHARES
    ADD     R1, #4*NBSHARES
    push {R0,R1}
    BL      rp_sbox
    pop {R0,R1}
    ADD     R0, #4*NBSHARES
    ADD     R1, #4*NBSHARES
    push {R0,R1}
    BL      rp_sbox
    pop {R0,R1}
    ADD     R0, #4*NBSHARES
    ADD     R1, #4*NBSHARES
    push {R0,R1}
    BL      rp_sbox
    pop {R0,R1}
    
#elif CIPH_MODE==KHL
    push {R0,R1}
    BL      khl_sbox
    pop {R0,R1}
    ADD     R0, #8*NBSHARES
    push {R0,R1}
    BL      khl_sbox
    pop {R0,R1}
#endif
    
    
    // ------------------------------------------------------------------------
    // LR: ShitRows + Addroundkey

    MOV     R10, #0
loop4OverShares:	
    LDM     R2, {R3-R6}
    LDR     R7, [R11, R10, LSL #2]
    EOR     R7, R3
    STR     R7, [R11, R10, LSL #2]
    ADD     R12, R11, #4*NBSHARES
    LDR     R7, [R12, R10, LSL #2]
    ROR     R7, #24
    EOR     R7, R4
    STR     R7, [R12, R10, LSL #2]
    ADD     R12, #4*NBSHARES
    LDR     R7, [R12, R10, LSL #2]
    ROR     R7, #16
    EOR     R7, R5
    STR     R7, [R12, R10, LSL #2]
    ADD     R12, #4*NBSHARES
    LDR     R7, [R12, R10, LSL #2]
    ROR     R7, #8
    EOR     R7, R6
    STR     R7, [R12, R10, LSL #2]
    ADD     R2, #4*44
    ADD     R10, #1
    CMP     R10, #NBSHARES
    BNE     loop4OverShares


    ///////////////////////////////////
    //                               //
    // Post-processing of the output //
    //                               //
    ///////////////////////////////////



    // ------------------------------------------------------------------------
    // Unmasking each of the output registers

    MOV     R0, R11
    pop {R1}
    LDR     R4, [R0]
    ADD     R8, R0, #(4*NBSHARES)   
    LDR     R5, [R8]
    ADD     R8, #(4*NBSHARES)   
    LDR     R6, [R8]
    ADD     R8, #(4*NBSHARES)   
    LDR     R7, [R8]
    MOV     R12, #1
loopDemasking:	
    LDR     R9, [R0, R12, LSL #2]
    EOR     R4, R9
    ADD     R8, R0, #4*NBSHARES
    LDR     R9, [R8, R12, LSL #2]
    EOR     R5, R9
    ADD     R8, #4*NBSHARES
    LDR     R9, [R8, R12, LSL #2]
    EOR     R6, R9
    ADD     R8, #4*NBSHARES
    LDR     R9, [R8, R12, LSL #2]
    EOR     R7, R9
    // loop Demasking processing
    ADD     R12, #1
    CMP     R12, #NBSHARES
    BNE     loopDemasking


    // ------------------------------------------------------------------------
    // Changing the representation of the ciphertext into the regular one


    EOR     R4, R4, R6, LSR #16
    EOR     R6, R6, R4, LSL #16
    EOR     R4, R4, R6, LSR #16
    EOR     R5, R5, R7, LSR #16
    EOR     R7, R7, R5, LSL #16
    EOR     R5, R5, R7, LSR #16
    EOR     R10, R4, R5, LSR #8
    BIC     R10, #0xFF000000
    BIC     R10, #0x0000FF00
    EOR     R4, R4, R10
    EOR     R5, R5, R10, LSL #8
    EOR     R10, R6, R7, LSR #8
    BIC     R10, #0xFF000000
    BIC     R10, #0x0000FF00
    EOR     R6, R6, R10
    EOR     R7, R7, R10, LSL #8
    STM     R1, {R4-R7}

    pop {R3-R12, LR}
    BX      LR

    

///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                Temporary tables for regular AES encryption                //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////


.data
MaskedState:
	.zero (4*4*NBSHARES)
sboxIn:
	.zero (4*4*NBSHARES)
sboxOut:
	.zero (4*4*NBSHARES)

