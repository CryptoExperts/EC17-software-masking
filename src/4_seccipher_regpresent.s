.text
.syntax unified

	
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                              UTILITY MACROS                               //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////

    // ------------------------------------------------------------------------
    // PRESENT permutation layer

.macro    player in1, in2, out1, out2, tmp, msk
    AND     \tmp, \msk, \in1, LSR #31
    EOR     \out1, \out1, \tmp, LSL #31
    AND     \tmp, \msk, \in1, LSR #30
    EOR     \out1, \out1, \tmp, LSL #15
    AND     \tmp, \msk, \in1, LSR #29
    EOR     \out2, \out2, \tmp, LSL #31
    AND     \tmp, \msk, \in1, LSR #28
    EOR     \out2, \out2, \tmp, LSL #15
    AND     \tmp, \msk, \in1, LSR #27
    EOR     \out1, \out1, \tmp, LSL #30
    AND     \tmp, \msk, \in1, LSR #26
    EOR     \out1, \out1, \tmp, LSL #14
    AND     \tmp, \msk, \in1, LSR #25
    EOR     \out2, \out2, \tmp, LSL #30
    AND     \tmp, \msk, \in1, LSR #24
    EOR     \out2, \out2, \tmp, LSL #14
    AND     \tmp, \msk, \in1, LSR #23
    EOR     \out1, \out1, \tmp, LSL #29
    AND     \tmp, \msk, \in1, LSR #22
    EOR     \out1, \out1, \tmp, LSL #13
    AND     \tmp, \msk, \in1, LSR #21
    EOR     \out2, \out2, \tmp, LSL #29
    AND     \tmp, \msk, \in1, LSR #20
    EOR     \out2, \out2, \tmp, LSL #13
    AND     \tmp, \msk, \in1, LSR #19
    EOR     \out1, \out1, \tmp, LSL #28
    AND     \tmp, \msk, \in1, LSR #18
    EOR     \out1, \out1, \tmp, LSL #12
    AND     \tmp, \msk, \in1, LSR #17
    EOR     \out2, \out2, \tmp, LSL #28
    AND     \tmp, \msk, \in1, LSR #16
    EOR     \out2, \out2, \tmp, LSL #12
    AND     \tmp, \msk, \in1, LSR #15
    EOR     \out1, \out1, \tmp, LSL #27
    AND     \tmp, \msk, \in1, LSR #14
    EOR     \out1, \out1, \tmp, LSL #11
    AND     \tmp, \msk, \in1, LSR #13
    EOR     \out2, \out2, \tmp, LSL #27
    AND     \tmp, \msk, \in1, LSR #12
    EOR     \out2, \out2, \tmp, LSL #11
    AND     \tmp, \msk, \in1, LSR #11
    EOR     \out1, \out1, \tmp, LSL #26
    AND     \tmp, \msk, \in1, LSR #10
    EOR     \out1, \out1, \tmp, LSL #10
    AND     \tmp, \msk, \in1, LSR #9
    EOR     \out2, \out2, \tmp, LSL #26
    AND     \tmp, \msk, \in1, LSR #8
    EOR     \out2, \out2, \tmp, LSL #10
    AND     \tmp, \msk, \in1, LSR #7
    EOR     \out1, \out1, \tmp, LSL #25
    AND     \tmp, \msk, \in1, LSR #6
    EOR     \out1, \out1, \tmp, LSL #9
    AND     \tmp, \msk, \in1, LSR #5
    EOR     \out2, \out2, \tmp, LSL #25
    AND     \tmp, \msk, \in1, LSR #4
    EOR     \out2, \out2, \tmp, LSL #9
    AND     \tmp, \msk, \in1, LSR #3
    EOR     \out1, \out1, \tmp, LSL #24
    AND     \tmp, \msk, \in1, LSR #2
    EOR     \out1, \out1, \tmp, LSL #8
    AND     \tmp, \msk, \in1, LSR #1
    EOR     \out2, \out2, \tmp, LSL #24
    AND     \tmp, \msk, \in1
    EOR     \out2, \out2, \tmp, LSL #8
    AND     \tmp, \msk, \in2, LSR #31
    EOR     \out1, \out1, \tmp, LSL #23
    AND     \tmp, \msk, \in2, LSR #30
    EOR     \out1, \out1, \tmp, LSL #7
    AND     \tmp, \msk, \in2, LSR #29
    EOR     \out2, \out2, \tmp, LSL #23
    AND     \tmp, \msk, \in2, LSR #28
    EOR     \out2, \out2, \tmp, LSL #7
    AND     \tmp, \msk, \in2, LSR #27
    EOR     \out1, \out1, \tmp, LSL #22
    AND     \tmp, \msk, \in2, LSR #26
    EOR     \out1, \out1, \tmp, LSL #6
    AND     \tmp, \msk, \in2, LSR #25
    EOR     \out2, \out2, \tmp, LSL #22
    AND     \tmp, \msk, \in2, LSR #24
    EOR     \out2, \out2, \tmp, LSL #6
    AND     \tmp, \msk, \in2, LSR #23
    EOR     \out1, \out1, \tmp, LSL #21
    AND     \tmp, \msk, \in2, LSR #22
    EOR     \out1, \out1, \tmp, LSL #5
    AND     \tmp, \msk, \in2, LSR #21
    EOR     \out2, \out2, \tmp, LSL #21
    AND     \tmp, \msk, \in2, LSR #20
    EOR     \out2, \out2,\tmp, LSL #5
    AND     \tmp, \msk, \in2, LSR #19
    EOR     \out1, \out1, \tmp, LSL #20
    AND     \tmp, \msk, \in2, LSR #18
    EOR     \out1, \out1, \tmp, LSL #4
    AND     \tmp, \msk, \in2, LSR #17
    EOR     \out2, \out2, \tmp, LSL #20
    AND     \tmp, \msk, \in2, LSR #16
    EOR     \out2, \out2, \tmp, LSL #4
    AND     \tmp, \msk, \in2, LSR #15
    EOR     \out1, \out1, \tmp, LSL #19
    AND     \tmp, \msk, \in2, LSR #14
    EOR     \out1, \out1, \tmp, LSL #3
    AND     \tmp, \msk, \in2, LSR #13
    EOR     \out2, \out2, \tmp, LSL #19
    AND     \tmp, \msk, \in2, LSR #12
    EOR     \out2, \out2, \tmp, LSL #3
    AND     \tmp, \msk, \in2, LSR #11
    EOR     \out1, \out1, \tmp, LSL #18
    AND     \tmp, \msk, \in2, LSR #10
    EOR     \out1, \out1, \tmp, LSL #2
    AND     \tmp, \msk, \in2, LSR #9
    EOR     \out2, \out2, \tmp, LSL #18
    AND     \tmp, \msk, \in2, LSR #8
    EOR     \out2, \out2, \tmp, LSL #2
    AND     \tmp, \msk, \in2, LSR #7
    EOR     \out1, \out1, \tmp, LSL #17
    AND     \tmp, \msk, \in2, LSR #6
    EOR     \out1, \out1, \tmp, LSL #1
    AND     \tmp, \msk, \in2, LSR #5
    EOR     \out2, \out2, \tmp, LSL #17
    AND     \tmp, \msk, \in2, LSR #4
    EOR     \out2, \out2, \tmp, LSL #1
    AND     \tmp, \msk, \in2, LSR #3
    EOR     \out1, \out1, \tmp, LSL #16
    AND     \tmp, \msk, \in2, LSR #2
    EOR     \out1, \tmp
    AND     \tmp, \msk, \in2, LSR #1
    EOR     \out2, \out2, \tmp, LSL #16
    AND     \tmp, \msk, \in2
    EOR     \out2, \tmp
.endm
	
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                       Regular PRESENT encryption                          //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////


.pool
.global regpresent_encrypt         
regpresent_encrypt:	
    push {R3-R12, LR}


    ///////////////////////////////////
    //                               //
    //  Pre-processing of the input  //
    //                               //
    ///////////////////////////////////


    // ------------------------------------------------------------------------
    // Creation of the sharings of each register at order d


    LDR     R10, =RNGReg
    LDR     R4, [R0]
    LDR     R5, [R0, #4]
    LDR     R0, =MaskedState
    MOV     R12, #1
loopMasking:	
    get_random R6, R10
    EOR     R4, R6
    STR     R6, [R0, R12, LSL #2]
    ADD     R0, #(4*NBSHARES)
    get_random R6, R10
    EOR     R5, R6
    STR     R6, [R0, R12, LSL #2]
    SUB     R0, #(4*NBSHARES)   
    // loop Masking processing
    ADD     R12, #1
    CMP     R12, #NBSHARES
    BNE     loopMasking
    STR     R4, [R0]
    ADD     R0, #(4*NBSHARES)
    STR     R5, [R0]
    SUB     R0, #(4*NBSHARES)

    ///////////////////////////////////
    //                               //
    //         Initial Round         //
    //                               //
    ///////////////////////////////////


    MOV     R8, R1
    LDR     R1, =SboxOut
    MOV     R11, #1
    
    MOV     R12, #0
loopPRESENT:	

    // ------------------------------------------------------------------------
    // IR:  AddRoundKey 

    MOV     R14, #0
loopARK:	
    LDR     R4, [R2]
    LDR     R5, [R2, #4]
    LDR     R6, [R0, R14, LSL #2]
    ADD     R0, #4*NBSHARES
    LDR     R7, [R0, R14, LSL #2]
    SUB     R0, #4*NBSHARES
    EOR     R6, R4
    EOR     R7, R5
    STR     R6, [R0, R14, LSL #2]
    ADD     R0, #4*NBSHARES
    STR     R7, [R0, R14, LSL #2]
    SUB     R0, #4*NBSHARES
    ADD     R2, #8*32
    // loop AddRoundKey processing
    ADD     R14, #1
    CMP     R14, #NBSHARES
    BNE     loopARK
    // Address update
    SUB     R2, #8*((32*NBSHARES))
    ADD     R2, #8

    // ------------------------------------------------------------------------
    // MR: sBoxLayer

    push {R0,R1}
    BL      fog_sbox
    pop {R0,R1}
    ADD     R0, #4*NBSHARES
    ADD     R1, #4*NBSHARES
    push {R0,R1}
    BL      fog_sbox
    pop {R0,R1}
    SUB     R0, #4*NBSHARES
    SUB     R1, #4*NBSHARES

    // ------------------------------------------------------------------------
    // MR: pLayer

    MOV     R14, #0
loopPL:	
    LDR     R6, [R1, R14, LSL #2]
    ADD     R1, #4*NBSHARES
    LDR     R7, [R1, R14, LSL #2]
    SUB     R1, #4*NBSHARES
    MOV     R4, #0
    MOV     R5, #0
    player R6,R7,R4,R5,R9,R11
    STR     R4, [R0, R14, LSL #2]
    ADD     R0, #4*NBSHARES
    STR     R5, [R0, R14, LSL #2]   
    SUB     R0, #4*NBSHARES
    // loop PL processing
    ADD     R14, #1
    CMP     R14, #NBSHARES
    BNE     loopPL
    // loop PRESENT processing
    ADD     R12, #1
    CMP     R12, #31
    BNE     loopPRESENT


    ///////////////////////////////////
    //                               //
    //         Last Round            //
    //                               //
    ///////////////////////////////////


    // ------------------------------------------------------------------------
    // LR: AddRoundKey

    MOV     R14, #0
loopLARK:	
    LDR     R4, [R2]
    LDR     R5, [R2, #4]
    LDR     R6, [R0, R14, LSL #2]
    ADD     R0, #4*NBSHARES
    LDR     R7, [R0, R14, LSL #2]
    SUB     R0, #4*NBSHARES
    EOR     R6, R4
    EOR     R7, R5
    STR     R6, [R0, R14, LSL #2]
    ADD     R0, #4*NBSHARES
    STR     R7, [R0, R14, LSL #2]
    SUB     R0, #4*NBSHARES
    ADD     R2, #8*32
    // loop LastAddRoundKey processing
    ADD     R14, #1
    CMP     R14, #NBSHARES
    BNE     loopLARK


    ///////////////////////////////////
    //                               //
    // Post-processing of the output //
    //                               //
    ///////////////////////////////////


    // ------------------------------------------------------------------------
    // Unmasking each of the output registers

    MOV     R1, R8
    LDR     R4, [R0]
    ADD     R0, #(4*NBSHARES)
    LDR     R5, [R0]
    SUB     R0, #(4*NBSHARES)
    MOV     R12, #1
loopDemasking:	
    LDR     R6, [R0, R12, LSL #2]
    EOR     R4, R6
    ADD     R0, #(4*NBSHARES)
    LDR     R6, [R0, R12, LSL #2]
    EOR     R5, R6
    SUB     R0, #(4*NBSHARES)
    // loop Demasking processing
    ADD     R12, #1
    CMP     R12, #NBSHARES
    BNE     loopDemasking
    STR     R4, [R1]
    STR     R5, [R1, #4]

    pop {R3-R12, LR}
    BX LR



///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                            PRESENT temporary tables                       //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
	
.data
SboxOut:
	.zero (2*4*NBSHARES)
MaskedState:
	.zero (2*4*NBSHARES)



