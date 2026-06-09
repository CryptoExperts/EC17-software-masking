.text

.syntax unified
#ifdef __thumb2__
.thumb
#endif
    


///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                        FIELD SIZE DEPENDENT MACRO                         //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
    

    ///////////////////////////////////
    //                               //
    //         10-bit Field          //
    //                               //
    ///////////////////////////////////

#if FIELDSIZE==10

    // ------------------------------------------------------------------------
    // Load a value from a table

.macro    load    res, addr, pos, tmp
    LDRB    \res, [\addr, \pos, LSL #1]
    LSL     \tmp, \pos, #1
    ADD     \tmp, \tmp, #1
    LDRB    \tmp, [\addr, \tmp]
    EOR     \res, \res, \tmp, LSL #8
.endm

    // ------------------------------------------------------------------------
    // Load a value and xor it with res
    
.macro    xor_and_load res, addr, pos, tmp
    LDRB    \tmp, [\addr, \pos, LSL #1]
    EOR     \res, \res, \tmp
    LSL     \tmp, \pos, #1
    ADD     \tmp, \tmp, #1
    LDRB    \tmp, [\addr, \tmp]
    EOR     \res, \res, \tmp, LSL #8 
.endm

    ///////////////////////////////////
    //                               //
    //       4,6,8-bit Field         //
    //                               //
    ///////////////////////////////////

#else

    // ------------------------------------------------------------------------
    // Load a value from a table

.macro    load    res, addr, pos, tmp
    LDRB    \res, [\addr, \pos]
.endm

    // ------------------------------------------------------------------------
    // Load a value and xor it with res 

.macro    xor_and_load res, addr, pos, tmp
    LDRB    \tmp, [\addr, \pos]
    EOR     \res, \tmp
.endm

#endif

///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                           CPRR EVALUATION FUNCTION                        //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////

.pool    
cprr_eval:	
    push {R2-R12, LR}

    // ------------------------------------------------------------------------
    // Init phase
    LDR     R2,  =RNGReg
    // cprrTable address is in R10 by default


    ///////////////////////////////////
    //                               //
    //    NORMAL CPRR EVALUATION     //
    //                               //
    ///////////////////////////////////

        
#if CODE_MODE==NORMAL

    // ------------------------------------------------------------------------
    // c_i = h(a_i)

    MOV     R12, #0
loop0cprrnormal:	
    ADD     R4, R0, R12, LSL #2
    LDR     R4, [R4]
    load    R5, R10, R4, R6
    STR R5, [R1, R12, LSL #2]
    // loop 0 processing
    ADD     R12, R12, #1
    CMP     R12, #NBSHARES
    BNE     loop0cprrnormal

    // ------------------------------------------------------------------------
    // t = s + h(a_i + s') + h(a_j + s') + h((a_i+ s') + a_j) + h(s')
    // c_i = c_i + s
    // c_j = c_j + t

    MOV     R12, #0
loop1cprrnormal:	
    ADD     R11, R12, #1
loop2cprrnormal:	
    // c_i = c_i + s
    get_random R3, R2
    LSR     R3, R3, #(32-FIELDSIZE)
    ADD     R4, R1, R12, LSL #2
    LDR     R4, [R4]
    EOR     R4, R3
    STR R4, [R1, R12, LSL #2]
    // t = s + h(a_i+s') 
    get_random R4, R2
    LSR     R4, R4, #(32-FIELDSIZE)
    ADD     R5, R0, R12, LSL #2
    LDR     R5, [R5]
    EOR     R5, R4
    xor_and_load R3,R10,R5,R7
    // t += h(a_j + s')
    ADD     R9, R0, R11, LSL #2
    LDR     R9, [R9]
    EOR     R6, R4, R9
    xor_and_load R3,R10,R6,R7
    // t += h((a_i+s')+a_j) + h(s')
    EOR     R6, R5, R9
    xor_and_load R3,R10,R6,R7
    xor_and_load R3,R10,R4,R7
    ADD     R5, R1, R11, LSL #2
    LDR     R5, [R5]
    EOR     R5, R3
    STR R5, [R1, R11, LSL #2]
    // loop 2 processing
    ADD     R11, R11, #1
    CMP     R11, #NBSHARES
    BNE     loop2cprrnormal
    // loop 1 processing 
    ADD     R12, R12, #1
    CMP     R12, #(NBSHARES-1)
    BNE     loop1cprrnormal


    ///////////////////////////////////
    //                               //
    //    2 //  CPRR EVALUATION      //
    //                               //
    ///////////////////////////////////


#elif CODE_MODE==PARA2

    // ------------------------------------------------------------------------
    // c_i = h(a_i)

    MOV     R12, #0
loop0cprrpara2:	
    // c1_i|c2_i = h(a1_i)|h(a2_i)
    ADD     R4, R0, R12, LSL #2
    LDR     R4, [R4]
    AND     R7, R4, #((1<<FIELDSIZE)-1)
    LDRB    R5, [R10, R7]
    LSR     R8, R4, #FIELDSIZE
    LDRB    R8, [R10, R8]
    EOR     R5, R5, R8, LSL #FIELDSIZE
    STR R5, [R1, R12, LSL #2]
    // loop 0 processing
    ADD     R12, R12, #1
    CMP     R12, #NBSHARES
    BNE     loop0cprrpara2

    // ------------------------------------------------------------------------
    // t = s + h(a_i + s') + h(a_j + s') + h((a_i+ s') + a_j) + h(s')
    // c_i = c_i + s
    // c_j = c_j + t

    MOV     R12, #0
loop1cprrpara2:	
    ADD     R11, R12, #1
loop2cprrpara2:	
    // c_i = c_i + s
    get_random R3, R2
    LSR     R3, R3, #(32-2*FIELDSIZE)
    ADD     R4, R1, R12, LSL #2
    LDR     R4, [R4]
    EOR     R4, R3
    STR R4, [R1, R12, LSL #2]
    //  t = s + h(a_i + s')
    get_random R4, R2
    LSR     R4, R4, #(32-2*FIELDSIZE)
    ADD     R5, R0, R12, LSL #2
    LDR     R5, [R5]
    EOR     R5, R4
    AND     R7, R5, #((1<<FIELDSIZE)-1)
    xor_and_load R3,R10,R7,R14
    LSR     R8, R5, #FIELDSIZE
    LDRB    R8, [R10, R8]
    EOR     R3, R3, R8, LSL #FIELDSIZE
    // t += h(a_j + s')
    ADD     R9, R0, R11, LSL #2
    LDR     R9, [R9]
    EOR     R6, R4, R9
    AND     R7, R6, #((1<<FIELDSIZE)-1)
    xor_and_load R3,R10,R7,R14
    LSR     R8, R6, #FIELDSIZE
    LDRB    R8, [R10, R8]
    EOR     R3, R3, R8, LSL #FIELDSIZE
    // t += h((a_i+s')+a_j) + h(s')
    EOR     R6, R5, R9
    AND     R7, R6, #((1<<FIELDSIZE)-1)
    xor_and_load R3,R10,R7,R14
    LSR     R8, R6, #FIELDSIZE
    LDRB    R8, [R10, R8]
    EOR     R3, R3, R8, LSL #FIELDSIZE
    AND     R7, R4, #((1<<FIELDSIZE)-1)
    xor_and_load R3,R10,R7,R14
    LSR     R8, R4, #FIELDSIZE
    LDRB    R8, [R10, R8]
    EOR     R3, R3, R8, LSL #FIELDSIZE
    ADD     R5, R1, R11, LSL #2
    LDR     R5, [R5]
    EOR     R5, R3
    STR R5, [R1, R11, LSL #2]
    // loop 2 processing
    ADD     R11, R11, #1
    CMP     R11, #NBSHARES
    BNE     loop2cprrpara2
    // loop 1 processing
    ADD     R12, R12, #1
    CMP     R12, #(NBSHARES-1)
    BNE     loop1cprrpara2


    ///////////////////////////////////
    //                               //
    //    4 //  CPRR EVALUATION      //
    //                               //
    ///////////////////////////////////


#elif CODE_MODE==PARA4

    // ------------------------------------------------------------------------
    // c_i = h(a_i)

    MOV     R12, #0
loop0cprrpara4:	
    ADD     R4, R0, R12, LSL #2
    LDR     R4, [R4]
    AND     R7, R4, #((1<<FIELDSIZE)-1)
    LDRB    R5, [R10, R7]
    AND     R7, R4, #(((1<<FIELDSIZE)-1)<<FIELDSIZE)
    LSR     R8, R7, #FIELDSIZE
    LDRB    R8, [R10, R8]
    EOR     R5, R5, R8, LSL #FIELDSIZE 
    AND     R7, R4, #(((1<<FIELDSIZE)-1)<<(2*FIELDSIZE))
    LSR     R8, R7, #(2*FIELDSIZE)
    LDRB    R8, [R10, R8]
    EOR     R5, R5, R8, LSL #(2*FIELDSIZE)
    LSR     R8, R4, #(3*FIELDSIZE)
    LDRB    R8, [R10, R8]
    EOR     R5, R5, R8, LSL #(3*FIELDSIZE)
    STR R5, [R1, R12, LSL #2]
    // loop 0 processing
    ADD     R12, R12, #1
    CMP     R12, #NBSHARES
    BNE     loop0cprrpara4

    // ------------------------------------------------------------------------
    // t = s + h(a_i + s') + h(a_j + s') + h((a_i+ s') + a_j) + h(s')
    // c_i = c_i + s
    // c_j = c_j + t
    
    MOV     R12, #0
loop1cprrpara4:	
    ADD     R11, R12, #1
loop2cprrpara4:	
    // c_i = c_i + s
    get_random R3, R2
    ADD     R4, R1, R12, LSL #2
    LDR     R4, [R4]
    EOR     R4, R3
    STR R4, [R1, R12, LSL #2]
    // t = s + h(a_i+s') 
    get_random R4, R2
    ADD     R5, R0, R12, LSL #2
    LDR     R5, [R5]
    EOR     R5, R4
    AND     R7, R5, #((1<<FIELDSIZE)-1)
    LDRB    R8, [R10, R7]
    EOR     R3, R8
    AND     R7, R5, #(((1<<FIELDSIZE)-1)<<FIELDSIZE)
    LSR     R8, R7, #FIELDSIZE
    LDRB    R8, [R10, R8]
    EOR     R3, R3, R8, LSL #FIELDSIZE
    AND     R7, R5, #(((1<<FIELDSIZE)-1)<<(2*FIELDSIZE))
    LSR     R8, R7, #(2*FIELDSIZE)
    LDRB    R8, [R10, R8]
    EOR     R3, R3, R8, LSL #(2*FIELDSIZE)
    LSR     R8, R5, #(3*FIELDSIZE)
    LDRB    R8, [R10, R8]
    EOR     R3, R3, R8, LSL #(3*FIELDSIZE)
    // t += h(a_j + s') 
    ADD     R9, R0, R11, LSL #2
    LDR     R9, [R9]
    EOR     R6, R4, R9
    AND     R7, R6, #((1<<FIELDSIZE)-1)
    LDRB    R8, [R10, R7]
    EOR     R3, R8
    AND     R7, R6, #(((1<<FIELDSIZE)-1)<<FIELDSIZE)
    LSR     R8, R7, #FIELDSIZE
    LDRB    R8, [R10, R8]
    EOR     R3, R3, R8, LSL #FIELDSIZE
    AND     R7, R6, #(((1<<FIELDSIZE)-1)<<(2*FIELDSIZE))
    LSR     R8, R7, #(2*FIELDSIZE)
    LDRB    R8, [R10, R8]
    EOR     R3, R3, R8, LSL #(2*FIELDSIZE)
    LSR     R8, R6, #(3*FIELDSIZE)
    LDRB    R8, [R10, R8]
    EOR     R3, R3, R8, LSL #(3*FIELDSIZE)
    // t += h((a_i+s')+a_j) + h(s')
    EOR     R6, R5, R9
    AND     R7, R6, #((1<<FIELDSIZE)-1)
    LDRB    R8, [R10, R7]
    EOR     R3, R8
    AND     R7, R6, #(((1<<FIELDSIZE)-1)<<FIELDSIZE)
    LSR     R8, R7, #FIELDSIZE
    LDRB    R8, [R10, R8]
    EOR     R3, R3, R8, LSL #FIELDSIZE
    AND     R7, R6, #(((1<<FIELDSIZE)-1)<<(2*FIELDSIZE))
    LSR     R8, R7, #(2*FIELDSIZE)
    LDRB    R8, [R10, R8]
    EOR     R3, R3, R8, LSL #(2*FIELDSIZE)
    LSR     R8, R6, #(3*FIELDSIZE)
    LDRB    R8, [R10, R8]
    EOR     R3, R3, R8, LSL #(3*FIELDSIZE)
    AND     R7, R4, #((1<<FIELDSIZE)-1)
    LDRB    R8, [R10, R7]
    EOR     R3, R8
    AND     R7, R4, #(((1<<FIELDSIZE)-1)<<FIELDSIZE)
    LSR     R8, R7, #FIELDSIZE
    LDRB    R8, [R10, R8]
    EOR     R3, R3, R8, LSL #FIELDSIZE
    AND     R7, R4, #(((1<<FIELDSIZE)-1)<<(2*FIELDSIZE))
    LSR     R8, R7, #(2*FIELDSIZE)
    LDRB    R8, [R10, R8]
    EOR     R3, R3, R8, LSL #(2*FIELDSIZE)
    LSR     R8, R4, #(3*FIELDSIZE)
    LDRB    R8, [R10, R8]
    EOR     R3, R3, R8, LSL #(3*FIELDSIZE)
    ADD     R5, R1, R11, LSL #2
    LDR     R5, [R5]
    EOR     R5, R3
    STR R5, [R1, R11, LSL #2]
    // loop 2 processing
    ADD     R11, R11, #1
    CMP     R11, #NBSHARES
    BNE     loop2cprrpara4
    // loop 1 processing
    ADD     R12, R12, #1
    CMP     R12, #(NBSHARES-1)
    BNE     loop1cprrpara4


    ///////////////////////////////////
    //                               //
    //    8 //  CPRR EVALUATION      //
    //                               //
    ///////////////////////////////////

#elif CODE_MODE==PARA8

    // ------------------------------------------------------------------------
    // c_i = h(a_i)

    MOV     R12, #0
loop0cprrpara8:	
    // c1_i|c2_i = h(a1_i)|h(a2_i)
    ADD     R4, R0, R12, LSL #2
    LDR     R4, [R4]
    AND     R7, R4, #((1<<FIELDSIZE)-1)
    LDRB    R5, [R10, R7]
    AND     R7, R4, #(((1<<FIELDSIZE)-1)<<FIELDSIZE)
    LSR     R8, R7, #FIELDSIZE
    LDRB    R8, [R10, R8]
    EOR     R5, R5, R8, LSL #FIELDSIZE 
    AND     R7, R4, #(((1<<FIELDSIZE)-1)<<(2*FIELDSIZE))
    LSR     R8, R7, #(2*FIELDSIZE)
    LDRB    R8, [R10, R8]
    EOR     R5, R5, R8, LSL #(2*FIELDSIZE)
    AND     R7, R4, #(((1<<FIELDSIZE)-1)<<(3*FIELDSIZE))
    LSR     R8, R7, #(3*FIELDSIZE)
    LDRB    R8, [R10, R8]
    EOR     R5, R5, R8, LSL #(3*FIELDSIZE)
    AND     R7, R4, #(((1<<FIELDSIZE)-1)<<(4*FIELDSIZE))
    LSR     R8, R7, #(4*FIELDSIZE)
    LDRB    R8, [R10, R8]
    EOR     R5, R5, R8, LSL #(4*FIELDSIZE)
    AND     R7, R4, #(((1<<FIELDSIZE)-1)<<(5*FIELDSIZE))
    LSR     R8, R7, #(5*FIELDSIZE)
    LDRB    R8, [R10, R8]
    EOR     R5, R5, R8, LSL #(5*FIELDSIZE)
    AND     R7, R4, #(((1<<FIELDSIZE)-1)<<(6*FIELDSIZE))
    LSR     R8, R7, #(6*FIELDSIZE)
    LDRB    R8, [R10, R8]
    EOR     R5, R5, R8, LSL #(6*FIELDSIZE)
    LSR     R8, R4, #(7*FIELDSIZE)
    LDRB    R8, [R10, R8]
    EOR     R5, R5, R8, LSL #(7*FIELDSIZE)
    STR R5, [R1, R12, LSL #2]
    // loop 0 processing
    ADD     R12, R12, #1
    CMP     R12, #NBSHARES
    BNE     loop0cprrpara8

    // ------------------------------------------------------------------------
    // t = s + h(a_i + s') + h(a_j + s') + h((a_i+ s') + a_j) + h(s')
    // c_i = c_i + s
    // c_j = c_j + t
    
    MOV     R12, #0
loop1cprrpara8:	
    ADD     R11, R12, #1    
loop2cprrpara8:	
    // c_i = c_i + s
    get_random R3, R2
    ADD     R4, R1, R12, LSL #2
    LDR     R4, [R4]
    EOR     R4, R3
    STR R4, [R1, R12, LSL #2]
    // t = s + h(a_i+s') 
    get_random R4, R2
    ADD     R5, R0, R12, LSL #2
    LDR     R5, [R5]
    EOR     R5, R4
    AND     R7, R5, #((1<<FIELDSIZE)-1)
    LDRB    R8, [R10, R7]
    EOR     R3, R8
    AND     R7, R5, #(((1<<FIELDSIZE)-1)<<FIELDSIZE)
    LSR     R8, R7, #FIELDSIZE
    LDRB    R8, [R10, R8]
    EOR     R3, R3, R8, LSL #FIELDSIZE
    AND     R7, R5, #(((1<<FIELDSIZE)-1)<<(2*FIELDSIZE))
    LSR     R8, R7, #(2*FIELDSIZE)
    LDRB    R8, [R10, R8]
    EOR     R3, R3, R8, LSL #(2*FIELDSIZE)
    AND     R7, R5, #(((1<<FIELDSIZE)-1)<<(3*FIELDSIZE))
    LSR     R8, R7, #(3*FIELDSIZE)
    LDRB    R8, [R10, R8]
    EOR     R3, R3, R8, LSL #(3*FIELDSIZE)
    AND     R7, R5, #(((1<<FIELDSIZE)-1)<<(4*FIELDSIZE))
    LSR     R8, R7, #(4*FIELDSIZE)
    LDRB    R8, [R10, R8]
    EOR     R3, R3, R8, LSL #(4*FIELDSIZE)
    AND     R7, R5, #(((1<<FIELDSIZE)-1)<<(5*FIELDSIZE))
    LSR     R8, R7, #(5*FIELDSIZE)
    LDRB    R8, [R10, R8]
    EOR     R3, R3, R8, LSL #(5*FIELDSIZE)
    AND     R7, R5, #(((1<<FIELDSIZE)-1)<<(6*FIELDSIZE))
    LSR     R8, R7, #(6*FIELDSIZE)
    LDRB    R8, [R10, R8]
    EOR     R3, R3, R8, LSL #(6*FIELDSIZE)
    LSR     R8, R5, #(7*FIELDSIZE)
    LDRB    R8, [R10, R8]
    EOR     R3, R3, R8, LSL #(7*FIELDSIZE)
    // t += h(a_j + s')
    ADD     R9, R0, R11, LSL #2
    LDR     R9, [R9]
    EOR     R6, R4,R9
    AND     R7, R6, #((1<<FIELDSIZE)-1)
    LDRB    R8, [R10, R7]
    EOR     R3, R8
    AND     R7, R6, #(((1<<FIELDSIZE)-1)<<FIELDSIZE)
    LSR     R8, R7, #FIELDSIZE
    LDRB    R8, [R10, R8]
    EOR     R3, R3, R8, LSL #FIELDSIZE
    AND     R7, R6, #(((1<<FIELDSIZE)-1)<<(2*FIELDSIZE))
    LSR     R8, R7, #(2*FIELDSIZE)
    LDRB    R8, [R10, R8]
    EOR     R3, R3, R8, LSL #(2*FIELDSIZE)
    AND     R7, R6, #(((1<<FIELDSIZE)-1)<<(3*FIELDSIZE))
    LSR     R8, R7, #(3*FIELDSIZE)
    LDRB    R8, [R10, R8]
    EOR     R3, R3, R8, LSL #(3*FIELDSIZE)
    AND     R7, R6, #(((1<<FIELDSIZE)-1)<<(4*FIELDSIZE))
    LSR     R8, R7, #(4*FIELDSIZE)
    LDRB    R8, [R10, R8]
    EOR     R3, R3, R8, LSL #(4*FIELDSIZE)
    AND     R7, R6, #(((1<<FIELDSIZE)-1)<<(5*FIELDSIZE))
    LSR     R8, R7, #(5*FIELDSIZE)
    LDRB    R8, [R10, R8]
    EOR     R3, R3, R8, LSL #(5*FIELDSIZE)
    AND     R7, R6, #(((1<<FIELDSIZE)-1)<<(6*FIELDSIZE))
    LSR     R8, R7, #(6*FIELDSIZE)
    LDRB    R8, [R10, R8]
    EOR     R3, R3, R8, LSL #(6*FIELDSIZE)
    LSR     R8, R6, #(7*FIELDSIZE)
    LDRB    R8, [R10, R8]
    EOR     R3, R3, R8, LSL #(7*FIELDSIZE)
    // t += h((a_i+s')+a_j) + h(s')
    EOR     R6, R5, R9
    AND     R7, R6, #((1<<FIELDSIZE)-1)
    LDRB    R8, [R10, R7]
    EOR     R3, R8
    AND     R7, R6, #(((1<<FIELDSIZE)-1)<<FIELDSIZE)
    LSR     R8, R7, #FIELDSIZE
    LDRB    R8, [R10, R8]
    EOR     R3, R3, R8, LSL #FIELDSIZE
    AND     R7, R6, #(((1<<FIELDSIZE)-1)<<(2*FIELDSIZE))
    LSR     R8, R7, #(2*FIELDSIZE)
    LDRB    R8, [R10, R8]
    EOR     R3, R3, R8, LSL #(2*FIELDSIZE)
    AND     R7, R6, #(((1<<FIELDSIZE)-1)<<(3*FIELDSIZE))
    LSR     R8, R7, #(3*FIELDSIZE)
    LDRB    R8, [R10, R8]
    EOR     R3, R3,  R8, LSL #(3*FIELDSIZE)
    AND     R7, R6, #(((1<<FIELDSIZE)-1)<<(4*FIELDSIZE))
    LSR     R8, R7, #(4*FIELDSIZE)
    LDRB    R8, [R10, R8]
    EOR     R3, R3, R8, LSL #(4*FIELDSIZE)
    AND     R7, R6, #(((1<<FIELDSIZE)-1)<<(5*FIELDSIZE))
    LSR     R8, R7, #(5*FIELDSIZE)
    LDRB    R8, [R10, R8]
    EOR     R3, R3, R8, LSL #(5*FIELDSIZE)
    AND     R7, R6, #(((1<<FIELDSIZE)-1)<<(6*FIELDSIZE))
    LSR     R8, R7, #(6*FIELDSIZE)
    LDRB    R8, [R10, R8]
    EOR     R3, R3, R8, LSL #(6*FIELDSIZE)
    LSR     R8, R6, #(7*FIELDSIZE)
    LDRB    R8, [R10, R8]
    EOR     R3, R3, R8, LSL #(7*FIELDSIZE)
    AND     R7, R4, #((1<<FIELDSIZE)-1)
    LDRB    R8, [R10, R7]
    EOR     R3, R8
    AND     R7, R4, #(((1<<FIELDSIZE)-1)<<FIELDSIZE)
    LSR     R8, R7, #FIELDSIZE
    LDRB    R8, [R10, R8]
    EOR     R3, R3, R8, LSL #FIELDSIZE
    AND     R7, R4, #(((1<<FIELDSIZE)-1)<<(2*FIELDSIZE))
    LSR     R8, R7, #(2*FIELDSIZE)
    LDRB    R8, [R10, R8]
    EOR     R3, R3, R8, LSL #(2*FIELDSIZE)
    AND     R7, R4, #(((1<<FIELDSIZE)-1)<<(3*FIELDSIZE))
    LSR     R8, R7, #(3*FIELDSIZE)
    LDRB    R8, [R10, R8]
    EOR     R3, R3, R8, LSL #(3*FIELDSIZE)
    AND     R7, R4, #(((1<<FIELDSIZE)-1)<<(4*FIELDSIZE))
    LSR     R8, R7, #(4*FIELDSIZE)
    LDRB    R8, [R10, R8]
    EOR     R3, R3, R8, LSL #(4*FIELDSIZE)
    AND     R7, R4, #(((1<<FIELDSIZE)-1)<<(5*FIELDSIZE))
    LSR     R8, R7, #(5*FIELDSIZE)
    LDRB    R8, [R10, R8]
    EOR     R3, R3, R8, LSL #(5*FIELDSIZE)
    AND     R7, R4, #(((1<<FIELDSIZE)-1)<<(6*FIELDSIZE))
    LSR     R8, R7, #(6*FIELDSIZE)
    LDRB    R8, [R10, R8]
    EOR     R3, R3, R8, LSL #(6*FIELDSIZE)
    LSR     R8, R4, #(7*FIELDSIZE)
    LDRB    R8, [R10, R8]
    EOR     R3, R3, R8, LSL #(7*FIELDSIZE)
    ADD     R5, R1, R11, LSL #2
    LDR     R5, [R5]
    EOR     R5, R3
    STR R5, [R1, R11, LSL #2]
    // loop 2 processing
    ADD     R11, R11, #1
    CMP     R11, #NBSHARES
    BNE     loop2cprrpara8
    // loop 1 processing
    ADD     R12, R12, #1
    CMP     R12, #(NBSHARES-1)
    BNE     loop1cprrpara8
    
#endif
    
    pop {R2-R12, LR}
    BX LR
