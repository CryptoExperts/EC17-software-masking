.text


///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                              UTILITY MACROS                               //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////

    // ------------------------------------------------------------------------
    // Swap a plaintext from a regular representation to a bitslice one

.macro    from_normal_to_bitslice in1, in2, out1, out2, out3, out4, tmp1, tmp2 
    MOV     \tmp1, #1
    AND     \tmp2, \tmp1, \in1, LSR #31
    MOV     \out1, \tmp2, LSL #15
    AND     \tmp2, \tmp1, \in1, LSR #30
    MOV     \out2, \tmp2, LSL #15
    AND     \tmp2, \tmp1, \in1, LSR #29
    MOV     \out3, \tmp2, LSL #15
    AND     \tmp2, \tmp1, \in1, LSR #28
    MOV     \out4, \tmp2, LSL #15
    AND     \tmp2, \tmp1, \in1, LSR #27
    EOR     \out1, \out1, \tmp2, LSL #14
    AND     \tmp2, \tmp1, \in1, LSR #26
    EOR     \out2, \out2, \tmp2, LSL #14
    AND     \tmp2, \tmp1, \in1, LSR #25
    EOR     \out3, \out3, \tmp2, LSL #14
    AND     \tmp2, \tmp1, \in1, LSR #24
    EOR     \out4, \out4, \tmp2, LSL #14
    AND     \tmp2, \tmp1, \in1, LSR #23
    EOR     \out1, \out1, \tmp2, LSL #13
    AND     \tmp2, \tmp1, \in1, LSR #22
    EOR     \out2, \out2, \tmp2, LSL #13
    AND     \tmp2, \tmp1, \in1, LSR #21
    EOR     \out3, \out3, \tmp2, LSL #13
    AND     \tmp2, \tmp1, \in1, LSR #20
    EOR     \out4, \out4, \tmp2, LSL #13
    AND     \tmp2, \tmp1, \in1, LSR #19
    EOR     \out1, \out1, \tmp2, LSL #12
    AND     \tmp2, \tmp1, \in1, LSR #18
    EOR     \out2, \out2, \tmp2, LSL #12
    AND     \tmp2, \tmp1, \in1, LSR #17
    EOR     \out3, \out3, \tmp2, LSL #12
    AND     \tmp2, \tmp1, \in1, LSR #16
    EOR     \out4, \out4, \tmp2, LSL #12
    AND     \tmp2, \tmp1, \in1, LSR #15
    EOR     \out1, \out1, \tmp2, LSL #11
    AND     \tmp2, \tmp1, \in1, LSR #14
    EOR     \out2, \out2, \tmp2, LSL #11
    AND     \tmp2, \tmp1, \in1, LSR #13
    EOR     \out3, \out3, \tmp2, LSL #11
    AND     \tmp2, \tmp1, \in1, LSR #12
    EOR     \out4, \out4, \tmp2, LSL #11
    AND     \tmp2, \tmp1, \in1, LSR #11
    EOR     \out1, \out1, \tmp2, LSL #10
    AND     \tmp2, \tmp1, \in1, LSR #10
    EOR     \out2, \out2, \tmp2, LSL #10
    AND     \tmp2, \tmp1, \in1, LSR #9
    EOR     \out3, \out3, \tmp2, LSL #10
    AND     \tmp2, \tmp1, \in1, LSR #8
    EOR     \out4, \out4, \tmp2, LSL #10
    AND     \tmp2, \tmp1, \in1, LSR #7
    EOR     \out1, \out1, \tmp2, LSL #9
    AND     \tmp2, \tmp1, \in1, LSR #6
    EOR     \out2, \out2, \tmp2, LSL #9
    AND     \tmp2, \tmp1, \in1, LSR #5
    EOR     \out3, \out3, \tmp2, LSL #9
    AND     \tmp2, \tmp1, \in1, LSR #4
    EOR     \out4, \out4, \tmp2, LSL #9
    AND     \tmp2, \tmp1, \in1, LSR #3
    EOR     \out1, \out1, \tmp2, LSL #8
    AND     \tmp2, \tmp1, \in1, LSR #2
    EOR     \out2, \out2, \tmp2, LSL #8
    AND     \tmp2, \tmp1, \in1, LSR #1
    EOR     \out3, \out3, \tmp2, LSL #8
    AND     \tmp2, \tmp1, \in1
    EOR     \out4, \out4, \tmp2, LSL #8
    AND     \tmp2, \tmp1, \in2, LSR #31
    EOR     \out1, \out1, \tmp2, LSL #7
    AND     \tmp2, \tmp1, \in2, LSR #30
    EOR     \out2, \out2, \tmp2, LSL #7
    AND     \tmp2, \tmp1, \in2, LSR #29
    EOR     \out3, \out3, \tmp2, LSL #7
    AND     \tmp2, \tmp1, \in2, LSR #28
    EOR     \out4, \out4, \tmp2, LSL #7
    AND     \tmp2, \tmp1, \in2, LSR #27
    EOR     \out1, \out1, \tmp2, LSL #6
    AND     \tmp2, \tmp1, \in2, LSR #26
    EOR     \out2, \out2, \tmp2, LSL #6
    AND     \tmp2, \tmp1, \in2, LSR #25
    EOR     \out3, \out3, \tmp2, LSL #6
    AND     \tmp2, \tmp1, \in2, LSR #24
    EOR     \out4, \out4, \tmp2, LSL #6
    AND     \tmp2, \tmp1, \in2, LSR #23
    EOR     \out1, \out1, \tmp2, LSL #5
    AND     \tmp2, \tmp1, \in2, LSR #22
    EOR     \out2, \out2, \tmp2, LSL #5
    AND     \tmp2, \tmp1, \in2, LSR #21
    EOR     \out3, \out3, \tmp2, LSL #5
    AND     \tmp2, \tmp1, \in2, LSR #20
    EOR     \out4, \out4, \tmp2, LSL #5
    AND     \tmp2, \tmp1, \in2, LSR #19
    EOR     \out1, \out1, \tmp2, LSL #4
    AND     \tmp2, \tmp1, \in2, LSR #18
    EOR     \out2, \out2, \tmp2, LSL #4
    AND     \tmp2, \tmp1, \in2, LSR #17
    EOR     \out3, \out3, \tmp2, LSL #4
    AND     \tmp2, \tmp1, \in2, LSR #16
    EOR     \out4, \out4, \tmp2, LSL #4
    AND     \tmp2, \tmp1, \in2, LSR #15
    EOR     \out1, \out1, \tmp2, LSL #3
    AND     \tmp2, \tmp1, \in2, LSR #14
    EOR     \out2, \out2, \tmp2, LSL #3
    AND     \tmp2, \tmp1, \in2, LSR #13
    EOR     \out3, \out3, \tmp2, LSL #3
    AND     \tmp2, \tmp1, \in2, LSR #12
    EOR     \out4, \out4, \tmp2, LSL #3
    AND     \tmp2, \tmp1, \in2, LSR #11
    EOR     \out1, \out1, \tmp2, LSL #2
    AND     \tmp2, \tmp1, \in2, LSR #10
    EOR     \out2, \out2, \tmp2, LSL #2
    AND     \tmp2, \tmp1, \in2, LSR #9
    EOR     \out3, \out3, \tmp2, LSL #2
    AND     \tmp2, \tmp1, \in2, LSR #8
    EOR     \out4, \out4, \tmp2, LSL #2
    AND     \tmp2, \tmp1, \in2, LSR #7
    EOR     \out1, \out1, \tmp2, LSL #1
    AND     \tmp2, \tmp1, \in2, LSR #6
    EOR     \out2, \out2, \tmp2, LSL #1
    AND     \tmp2, \tmp1, \in2, LSR #5
    EOR     \out3, \out3, \tmp2, LSL #1
    AND     \tmp2, \tmp1, \in2, LSR #4
    EOR     \out4, \out4, \tmp2, LSL #1
    AND     \tmp2, \tmp1, \in2, LSR #3
    EOR     \out1, \tmp2
    AND     \tmp2, \tmp1, \in2, LSR #2
    EOR     \out2, \tmp2
    AND     \tmp2, \tmp1, \in2, LSR #1
    EOR     \out3, \tmp2
    AND     \tmp2, \tmp1, \in2
    EOR     \out4, \tmp2
.endm

    // ------------------------------------------------------------------------
    // Swap a plaintext from a regular representation to a bitslice one

.macro    from_bitslice_to_normal out1, out2, in1, in2, in3, in4, tmp1, tmp2 
    AND     \tmp2, \tmp1, \in1, LSR #15
    MOV     \out1, \tmp2, LSL #31
    AND     \tmp2, \tmp1, \in1, LSR #14
    EOR     \out1, \out1, \tmp2, LSL #27
    AND     \tmp2, \tmp1, \in1, LSR #13
    EOR     \out1, \out1, \tmp2, LSL #23
    AND     \tmp2, \tmp1, \in1, LSR #12
    EOR     \out1, \out1, \tmp2, LSL #19
    AND     \tmp2, \tmp1, \in1, LSR #11
    EOR     \out1, \out1, \tmp2, LSL #15
    AND     \tmp2, \tmp1, \in1, LSR #10
    EOR     \out1, \out1, \tmp2, LSL #11
    AND     \tmp2, \tmp1, \in1, LSR #9
    EOR     \out1, \out1, \tmp2, LSL #7
    AND     \tmp2, \tmp1, \in1, LSR #8
    EOR     \out1, \out1, \tmp2, LSL #3
    AND     \tmp2, \tmp1, \in1, LSR #7
    MOV     \out2, \tmp2, LSL #31
    AND     \tmp2, \tmp1, \in1, LSR #6
    EOR     \out2, \out2, \tmp2, LSL #27
    AND     \tmp2, \tmp1, \in1, LSR #5
    EOR     \out2, \out2, \tmp2, LSL #23
    AND     \tmp2, \tmp1, \in1, LSR #4
    EOR     \out2, \out2, \tmp2, LSL #19
    AND     \tmp2, \tmp1, \in1, LSR #3
    EOR     \out2, \out2, \tmp2, LSL #15
    AND     \tmp2, \tmp1, \in1, LSR #2
    EOR     \out2, \out2, \tmp2, LSL #11
    AND     \tmp2, \tmp1, \in1, LSR #1
    EOR     \out2, \out2, \tmp2, LSL #7
    AND     \tmp2, \tmp1, \in1
    EOR     \out2, \out2, \tmp2, LSL #3
    AND     \tmp2, \tmp1, \in2, LSR #15
    EOR     \out1, \out1, \tmp2, LSL #30
    AND     \tmp2, \tmp1, \in2, LSR #14
    EOR     \out1, \out1, \tmp2, LSL #26
    AND     \tmp2, \tmp1, \in2, LSR #13
    EOR     \out1, \out1, \tmp2, LSL #22
    AND     \tmp2, \tmp1, \in2, LSR #12
    EOR     \out1, \out1, \tmp2, LSL #18
    AND     \tmp2, \tmp1, \in2, LSR #11
    EOR     \out1, \out1, \tmp2, LSL #14
    AND     \tmp2, \tmp1, \in2, LSR #10
    EOR     \out1, \out1, \tmp2, LSL #10
    AND     \tmp2, \tmp1, \in2, LSR #9
    EOR     \out1, \out1, \tmp2, LSL #6
    AND     \tmp2, \tmp1, \in2, LSR #8
    EOR     \out1, \out1, \tmp2, LSL #2
    AND     \tmp2, \tmp1, \in2, LSR #7
    EOR     \out2, \out2, \tmp2, LSL #30
    AND     \tmp2, \tmp1, \in2, LSR #6
    EOR     \out2, \out2, \tmp2, LSL #26
    AND     \tmp2, \tmp1, \in2, LSR #5
    EOR     \out2, \out2, \tmp2, LSL #22
    AND     \tmp2, \tmp1, \in2, LSR #4
    EOR     \out2, \out2, \tmp2, LSL #18
    AND     \tmp2, \tmp1, \in2, LSR #3
    EOR     \out2, \out2, \tmp2, LSL #14
    AND     \tmp2, \tmp1, \in2, LSR #2
    EOR     \out2, \out2, \tmp2, LSL #10
    AND     \tmp2, \tmp1, \in2, LSR #1
    EOR     \out2, \out2, \tmp2, LSL #6
    AND     \tmp2, \tmp1, \in2
    EOR     \out2, \out2, \tmp2, LSL #2
    AND     \tmp2, \tmp1, \in3, LSR #15
    EOR     \out1, \out1, \tmp2, LSL #29
    AND     \tmp2, \tmp1, \in3, LSR #14
    EOR     \out1, \out1, \tmp2, LSL #25
    AND     \tmp2, \tmp1, \in3, LSR #13
    EOR     \out1, \out1, \tmp2, LSL #21
    AND     \tmp2, \tmp1, \in3, LSR #12
    EOR     \out1, \out1, \tmp2, LSL #17
    AND     \tmp2, \tmp1, \in3, LSR #11
    EOR     \out1, \out1, \tmp2, LSL #13
    AND     \tmp2, \tmp1, \in3, LSR #10
    EOR     \out1, \out1, \tmp2, LSL #9
    AND     \tmp2, \tmp1, \in3, LSR #9
    EOR     \out1, \out1, \tmp2, LSL #5
    AND     \tmp2, \tmp1, \in3, LSR #8
    EOR     \out1, \out1, \tmp2, LSL #1
    AND     \tmp2, \tmp1, \in3, LSR #7
    EOR     \out2, \out2, \tmp2, LSL #29
    AND     \tmp2, \tmp1, \in3, LSR #6
    EOR     \out2, \out2, \tmp2, LSL #25
    AND     \tmp2, \tmp1, \in3, LSR #5
    EOR     \out2, \out2, \tmp2, LSL #21
    AND     \tmp2, \tmp1, \in3, LSR #4
    EOR     \out2, \out2, \tmp2, LSL #17
    AND     \tmp2, \tmp1, \in3, LSR #3
    EOR     \out2, \out2, \tmp2, LSL #13
    AND     \tmp2, \tmp1, \in3, LSR #2
    EOR     \out2, \out2, \tmp2, LSL #9
    AND     \tmp2, \tmp1, \in3, LSR #1
    EOR     \out2, \out2, \tmp2, LSL #5
    AND     \tmp2, \tmp1, \in3
    EOR     \out2, \out2, \tmp2, LSL #1
    AND     \tmp2, \tmp1, \in4, LSR #15
    EOR     \out1, \out1, \tmp2, LSL #28
    AND     \tmp2, \tmp1, \in4, LSR #14
    EOR     \out1, \out1, \tmp2, LSL #24
    AND     \tmp2, \tmp1, \in4, LSR #13
    EOR     \out1, \out1, \tmp2, LSL #20
    AND     \tmp2, \tmp1, \in4, LSR #12
    EOR     \out1, \out1, \tmp2, LSL #16
    AND     \tmp2, \tmp1, \in4, LSR #11
    EOR     \out1, \out1, \tmp2, LSL #12
    AND     \tmp2, \tmp1, \in4, LSR #10
    EOR     \out1, \out1, \tmp2, LSL #8
    AND     \tmp2, \tmp1, \in4, LSR #9
    EOR     \out1, \out1, \tmp2, LSL #4
    AND     \tmp2, \tmp1, \in4, LSR #8
    EOR     \out1, \tmp2
    AND     \tmp2, \tmp1, \in4, LSR #7
    EOR     \out2, \out2, \tmp2, LSL #28
    AND     \tmp2, \tmp1, \in4, LSR #6
    EOR     \out2, \out2, \tmp2, LSL #24
    AND     \tmp2, \tmp1, \in4, LSR #5
    EOR     \out2, \out2, \tmp2, LSL #20
    AND     \tmp2, \tmp1, \in4, LSR #4
    EOR     \out2, \out2, \tmp2, LSL #16
    AND     \tmp2, \tmp1, \in4, LSR #3
    EOR     \out2, \out2, \tmp2, LSL #12
    AND     \tmp2, \tmp1, \in4, LSR #2
    EOR     \out2, \out2, \tmp2, LSL #8
    AND     \tmp2, \tmp1, \in4, LSR #1
    EOR     \out2, \out2, \tmp2, LSL #4
    AND     \tmp2, \tmp1, \in4
    EOR     \out2, \tmp2
.endm

    // ------------------------------------------------------------------------
    // PRESENT permutation layer

.macro    player in1, in2, in3, in4, out1, out2, out3, out4, tmp1, tmp2
    EOR     \in1, \in2, \in1, LSL #16
    EOR     \in2, \in4, \in3, LSL #16
    AND     \tmp2, \tmp1, \in1, LSR #31
    MOV     \out1, \tmp2, LSL #15
    AND     \tmp2, \tmp1, \in1, LSR #30
    MOV     \out2, \tmp2, LSL #15
    AND     \tmp2, \tmp1, \in1, LSR #29
    MOV     \out3, \tmp2, LSL #15
    AND     \tmp2, \tmp1, \in1, LSR #28
    MOV     \out4, \tmp2, LSL #15
    AND     \tmp2, \tmp1, \in1, LSR #27
    EOR     \out1, \out1, \tmp2, LSL #14
    AND     \tmp2, \tmp1, \in1, LSR #26
    EOR     \out2, \out2, \tmp2, LSL #14
    AND     \tmp2, \tmp1, \in1, LSR #25
    EOR     \out3, \out3, \tmp2, LSL #14
    AND     \tmp2, \tmp1, \in1, LSR #24
    EOR     \out4, \out4, \tmp2, LSL #14
    AND     \tmp2, \tmp1, \in1, LSR #23
    EOR     \out1, \out1, \tmp2, LSL #13
    AND     \tmp2, \tmp1, \in1, LSR #22
    EOR     \out2, \out2, \tmp2, LSL #13
    AND     \tmp2, \tmp1, \in1, LSR #21
    EOR     \out3, \out3, \tmp2, LSL #13
    AND     \tmp2, \tmp1, \in1, LSR #20
    EOR     \out4, \out4, \tmp2, LSL #13
    AND     \tmp2, \tmp1, \in1, LSR #19
    EOR     \out1, \out1, \tmp2, LSL #12
    AND     \tmp2, \tmp1, \in1, LSR #18
    EOR     \out2, \out2, \tmp2, LSL #12
    AND     \tmp2, \tmp1, \in1, LSR #17
    EOR     \out3, \out3, \tmp2, LSL #12
    AND     \tmp2, \tmp1, \in1, LSR #16
    EOR     \out4, \out4, \tmp2, LSL #12
    AND     \tmp2, \tmp1, \in1, LSR #15
    EOR     \out1, \out1, \tmp2, LSL #11
    AND     \tmp2, \tmp1, \in1, LSR #14
    EOR     \out2, \out2, \tmp2, LSL #11
    AND     \tmp2, \tmp1, \in1, LSR #13
    EOR     \out3, \out3, \tmp2, LSL #11
    AND     \tmp2, \tmp1, \in1, LSR #12
    EOR     \out4, \out4, \tmp2, LSL #11
    AND     \tmp2, \tmp1, \in1, LSR #11
    EOR     \out1, \out1, \tmp2, LSL #10
    AND     \tmp2, \tmp1, \in1, LSR #10
    EOR     \out2, \out2, \tmp2, LSL #10
    AND     \tmp2, \tmp1, \in1, LSR #9
    EOR     \out3, \out3, \tmp2, LSL #10
    AND     \tmp2, \tmp1, \in1, LSR #8
    EOR     \out4, \out4, \tmp2, LSL #10
    AND     \tmp2, \tmp1, \in1, LSR #7
    EOR     \out1, \out1, \tmp2, LSL #9
    AND     \tmp2, \tmp1, \in1, LSR #6
    EOR     \out2, \out2, \tmp2, LSL #9
    AND     \tmp2, \tmp1, \in1, LSR #5
    EOR     \out3, \out3, \tmp2, LSL #9
    AND     \tmp2, \tmp1, \in1, LSR #4
    EOR     \out4, \out4, \tmp2, LSL #9
    AND     \tmp2, \tmp1, \in1, LSR #3
    EOR     \out1, \out1, \tmp2, LSL #8
    AND     \tmp2, \tmp1, \in1, LSR #2
    EOR     \out2, \out2, \tmp2, LSL #8
    AND     \tmp2, \tmp1, \in1, LSR #1
    EOR     \out3, \out3, \tmp2, LSL #8
    AND     \tmp2, \tmp1, \in1
    EOR     \out4, \out4, \tmp2, LSL #8
    AND     \tmp2, \tmp1, \in2, LSR #31
    EOR     \out1, \out1, \tmp2, LSL #7
    AND     \tmp2, \tmp1, \in2, LSR #30
    EOR     \out2, \out2, \tmp2, LSL #7
    AND     \tmp2, \tmp1, \in2, LSR #29
    EOR     \out3, \out3, \tmp2, LSL #7
    AND     \tmp2, \tmp1, \in2, LSR #28
    EOR     \out4, \out4, \tmp2, LSL #7
    AND     \tmp2, \tmp1, \in2, LSR #27
    EOR     \out1, \out1, \tmp2, LSL #6
    AND     \tmp2, \tmp1, \in2, LSR #26
    EOR     \out2, \out2, \tmp2, LSL #6
    AND     \tmp2, \tmp1, \in2, LSR #25
    EOR     \out3, \out3, \tmp2, LSL #6
    AND     \tmp2, \tmp1, \in2, LSR #24
    EOR     \out4, \out4, \tmp2, LSL #6
    AND     \tmp2, \tmp1, \in2, LSR #23
    EOR     \out1, \out1, \tmp2, LSL #5
    AND     \tmp2, \tmp1, \in2, LSR #22
    EOR     \out2, \out2, \tmp2, LSL #5
    AND     \tmp2, \tmp1, \in2, LSR #21
    EOR     \out3, \out3, \tmp2, LSL #5
    AND     \tmp2, \tmp1, \in2, LSR #20
    EOR     \out4, \out4, \tmp2, LSL #5
    AND     \tmp2, \tmp1, \in2, LSR #19
    EOR     \out1, \out1, \tmp2, LSL #4
    AND     \tmp2, \tmp1, \in2, LSR #18
    EOR     \out2, \out2, \tmp2, LSL #4
    AND     \tmp2, \tmp1, \in2, LSR #17
    EOR     \out3, \out3, \tmp2, LSL #4
    AND     \tmp2, \tmp1, \in2, LSR #16
    EOR     \out4, \out4, \tmp2, LSL #4
    AND     \tmp2, \tmp1, \in2, LSR #15
    EOR     \out1, \out1, \tmp2, LSL #3
    AND     \tmp2, \tmp1, \in2, LSR #14
    EOR     \out2, \out2, \tmp2, LSL #3
    AND     \tmp2, \tmp1, \in2, LSR #13
    EOR     \out3, \out3, \tmp2, LSL #3
    AND     \tmp2, \tmp1, \in2, LSR #12
    EOR     \out4, \out4, \tmp2, LSL #3
    AND     \tmp2, \tmp1, \in2, LSR #11
    EOR     \out1, \out1, \tmp2, LSL #2
    AND     \tmp2, \tmp1, \in2, LSR #10
    EOR     \out2, \out2, \tmp2, LSL #2
    AND     \tmp2, \tmp1, \in2, LSR #9
    EOR     \out3, \out3, \tmp2, LSL #2
    AND     \tmp2, \tmp1, \in2, LSR #8
    EOR     \out4, \out4, \tmp2, LSL #2
    AND     \tmp2, \tmp1, \in2, LSR #7
    EOR     \out1, \out1, \tmp2, LSL #1
    AND     \tmp2, \tmp1, \in2, LSR #6
    EOR     \out2, \out2, \tmp2, LSL #1
    AND     \tmp2, \tmp1, \in2, LSR #5
    EOR     \out3, \out3, \tmp2, LSL #1
    AND     \tmp2, \tmp1, \in2, LSR #4
    EOR     \out4, \out4, \tmp2, LSL #1
    AND     \tmp2, \tmp1, \in2, LSR #3
    EOR     \out1, \tmp2
    AND     \tmp2, \tmp1, \in2, LSR #2
    EOR     \out2, \tmp2
    AND     \tmp2, \tmp1, \in2, LSR #1
    EOR     \out3, \tmp2
    AND     \tmp2, \tmp1, \in2
    EOR     \out4, \tmp2
.endm


///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                       Bitslice PRESENT encryption                         //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////

.pool
.global	bspresent_encrypt
bspresent_encrypt:	
    push {R2-R12, LR}


    ///////////////////////////////////
    //                               //
    //  Pre-processing of the input  //
    //                               //
    ///////////////////////////////////


    // ------------------------------------------------------------------------
    // Changing the representation of the plaintext into the bitslice one

    LDM     R0, {R7,R8}
    from_normal_to_bitslice R7,R8,R3,R4,R5,R6,R11,R12
    
    // ------------------------------------------------------------------------
    // Creation of the sharings of each bitslice register at order d

    LDR     R10, =RNGReg
    LDR     R0,  =MaskedState
    MOV     R12, #0
loopMasking:	
    ADD     R0, #16
    get_random R7, R10
    MOV     R7, R7, LSR #16
    EOR     R3, R7
    STR     R7, [R0]
    get_random R7, R10
    MOV     R7, R7, LSR #16
    EOR     R4, R7
    STR     R7, [R0, #4]
    get_random R7, R10
    MOV     R7, R7, LSR #16
    EOR     R5, R7
    STR     R7, [R0, #8]
    get_random R7, R10
    MOV     R7, R7, LSR #16
    EOR     R6, R7
    STR     R7, [R0, #12]
    // loop Masking processing
    ADD     R12, #1
    CMP     R12, #(NBSHARES-1)
    BNE     loopMasking
    SUB     R0, #16*(NBSHARES-1)
    STR     R3, [R0]
    STR     R4, [R0, #4]
    STR     R5, [R0, #8]
    STR     R6, [R0, #12]


    ///////////////////////////////////
    //                               //
    //         Initial Round         //
    //                               //
    ///////////////////////////////////


    // init phase
    push {R1}
    LDR     R1, =SboxOut


    ///////////////////////////////////
    //                               //
    //         Main Rounds           //
    //                               //
    ///////////////////////////////////


    // Main loop Present
    MOV     R14, #0
loopPresent:	
    push {R14}

    // ------------------------------------------------------------------------
    // AddRoundKey

    MOV     R12, #0
loopARK:	
    LDM     R0, {R3-R6}
    LDM     R2, {R7-R10}
    EOR     R3, R7
    EOR     R4, R8
    EOR     R5, R9
    EOR     R6, R10
    STM     R0!, {R3-R6}
    ADD     R2, #4*128
    // loop AddRoundKey processing
    ADD     R12, #1
    CMP     R12, #NBSHARES
    BNE     loopARK
    SUB     R0, #16*NBSHARES
    SUB     R2, #(4*128*NBSHARES-16)

    // ------------------------------------------------------------------------
    // sBoxLayer

    BL      bspresent_sbox

    // ------------------------------------------------------------------------
    // pLayer

    MOV     R14, #0
loopPL:	
    LDM     R1!, {R3-R6}
    player R3,R4,R5,R6,R7,R8,R9,R10,R11,R12
    STM     R0!, {R7-R10}
    // loop over shares pLayer processing
    ADD     R14, #1
    CMP     R14, #NBSHARES
    BNE     loopPL

    SUB     R0, #16*NBSHARES
    SUB     R1, #16*NBSHARES
    // loop PRESENT processing
    pop {R14}
    ADD     R14, #1
    CMP     R14, #31
    BNE     loopPresent


    ///////////////////////////////////
    //                               //
    //         Last Round            //
    //                               //
    ///////////////////////////////////


    // ------------------------------------------------------------------------
    // LR: AddRoundKey

    MOV     R12, #0
loopLARK:	
    LDM     R0, {R3-R6}
    LDM     R2, {R7-R10}
    EOR     R3, R7
    EOR     R4, R8
    EOR     R5, R9
    EOR     R6, R10
    STM     R0!, {R3-R6}
    ADD     R2, #4*128
    // loop AddRoundKey processing
    ADD     R12, #1
    CMP     R12, #NBSHARES
    BNE     loopLARK
    SUB     R0, #16*NBSHARES



    ///////////////////////////////////
    //                               //
    // Post-processing of the output //
    //                               //
    ///////////////////////////////////


    // ------------------------------------------------------------------------
    // Unmasking each of the output bitslice registers
    LDM     R0!, {R3-R6}
    MOV     R12, #0
loopDemasking:	
    LDM     R0!, {R7-R10}
    EOR     R3, R7
    EOR     R4, R8
    EOR     R5, R9
    EOR     R6, R10
    // loop Demasking processing
    ADD     R12, #1
    CMP     R12, #(NBSHARES-1)
    BNE     loopDemasking

    // ------------------------------------------------------------------------
    // Changing the representation of the ciphertext into the regular one

    from_bitslice_to_normal R7,R8,R3,R4,R5,R6,R11,R12
    
    pop {R1}
    STM     R1, {R7-R8}
    
    pop {R2-R12, LR}
    BX  LR



///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//          Temporary tables for bitslice PRESENT encryption                 //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////

.data
MaskedState:
	.zero (4*4*NBSHARES)
SboxOut:
	.zero (4*4*NBSHARES)

