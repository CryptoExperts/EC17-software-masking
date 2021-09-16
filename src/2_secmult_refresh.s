.text


///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                             ISW REFRESH FUNCTION                          //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////

.pool	
refresh_mask:	
    push {R2-R12, LR}
    // ------------------------------------------------------------------------
    // init phase
    LDR     R7, =RNGReg
    

    ///////////////////////////////////
    //                               //
    //      NORMAL ISW REFRESH       //
    //                               //
    ///////////////////////////////////


#if REF_MODE==RF1
    
    // ------------------------------------------------------------------------
    // a_0 = a_0 + \sum r_i
    // a_i = a_i + r_i

    MOV     R12, #0
loop1rf:	
    // load a_i
    LDR     R4, [R0, R12, LSL #2]
    ADD     R11, R12, #1
loop2rf:	
    // s <-$ F
    get_random R3,R7
    // a_i <- a_i + s
    EOR     R4, R3
    // a_j <- a_j + s
    LDR     R5, [R0, R11, LSL #2]
    EOR     R5, R3
    STR     R5, [R0, R11, LSL #2]
    // loop 2 processing
    ADD     R11, #1
    CMP     R11, #NBSHARES
    BNE     loop2rf
    // store a_i
    STR     R4, [R0, R12, LSL #2]
    // loop 1 processing
    ADD     R12, #1
    CMP     R12, #(NBSHARES-1)
    BNE     loop1rf


    ///////////////////////////////////
    //                               //
    //   PARTIAL UNROLLED REFRESH    //
    //                               //
    ///////////////////////////////////


#elif REF_MODE==RF4

    // ------------------------------------------------------------------------
    // a_0 = a_0 + \sum r_i
    // a_i = a_i + r_i

    MOV     R12, #0
loop1rf:	
    // load a_i, a_i+1, a_i+2, a_i+3
    get_random  R3, R7
    LDR     R4, [R0, R12, LSL #2]
    ADD     R2, R12, #1
    LDR     R6, [R0, R2, LSL #2]
    ADD     R2, #1
    EOR     R4, R3
    EOR     R6,R3
    get_random R3, R7
    LDR     R9, [R0, R2, LSL #2]
    ADD     R2, #1
    EOR     R4, R3
    EOR     R9, R3
    LDR     R10, [R0, R2, LSL #2]
    get_random R3, R7
    EOR     R4, R3
    EOR     R10, R3
    ADD     R11, R2, #1
    CMP     R11, #NBSHARES
    BEQ     endofloop
loop2rf:	
    // s <-$ F
    get_random R3, R7
    LDR     R5, [R0, R11, LSL #2]
    EOR     R4, R3
    EOR     R5, R3
    get_random R3, R7
    EOR     R6, R3
    EOR     R5, R3
    get_random R3, R7
    EOR     R9, R3
    EOR     R5, R3
    get_random R3, R7
    EOR     R10, R3
    EOR     R5, R3
    STR     R5, [R0, R11, LSL #2]
    // loop 2 processing
    ADD     R11, #1
    CMP     R11, #NBSHARES
    BNE     loop2rf
    // store a_i
    STR     R4, [R0, R12, LSL #2]
    ADD     R12, #1
    STR     R6, [R0, R12, LSL #2]
    ADD     R12, #1
    STR     R9, [R0, R12, LSL #2]
    ADD     R12, #1
    STR     R10, [R0, R12, LSL #2]
    // loop 1 processing
    ADD     R12, #1
    CMP     R12, #(NBSHARES-1)
    BNE     loop1rf
endofloop:	
#endif
    
    pop {R2-R12, LR}
    BX LR
