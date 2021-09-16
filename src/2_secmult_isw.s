#include "1_fieldmult.S"

	
.text
        


///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                   SPECIAL CASE MULTIPLICATION MACRO                       //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
    

    ///////////////////////////////////
    //                               //
    //         Wrapper macro         //
    //                               //
    ///////////////////////////////////


    // ------------------------------------------------------------------------
    // Wrapper for normal ISW multiplication 

.macro    multiplication_wrapper opA, opB, res, pttab, tmp, tmp2, label
#if (MULT_MODE==FULLTAB) || (MULT_MODE==HALFTAB)
    multiplication \opA,\opB,\res,\pttab,\tmp
#else
    multiplication \opA,\opB,\res,\pttab,\tmp,\tmp2
#endif
.endm

    // ------------------------------------------------------------------------
    // Wrapper for 4 parallel ISW multiplication

.macro    multiplication_wrapper_para4 opA, opB, res, pttab, tmp, shift
#if MULT_MODE==HALFTAB
    multiplicationHT \opA,\opB,\res,\pttab,\tmp,\shift
#elif MULT_MODE==EXPLOG2
    multiplicationEL \opA,\opB,\res,\pttab,\tmp,\shift
#endif
.endm


    ///////////////////////////////////
    //                               //
    //    4 // ISW MULTIPLICATION    //
    //                               //
    ///////////////////////////////////


    // ------------------------------------------------------------------------
    // Half tab multiplication for 4 parallel ISW multiplication

.macro    multiplicationHT opA, opB, res, pttab, tmp, shift
.if \shift==1
    LSR     \opA, #(\shift*FIELDSIZE)
    LSR     \opB, #(\shift*FIELDSIZE)
.elseif \shift==2
    LSR     \opA, #(\shift*FIELDSIZE)
    LSR     \opB, #(\shift*FIELDSIZE)
.endif
    // res <- T1[a_h|a_l|b_h]	
    EOR     \tmp, \opB, \opA, LSL #FIELDSIZE
    LDRB    \res, [\pttab, \tmp, LSR #(FIELDSIZE>>1)]
    ADD     \pttab, #(1<<(3*FIELDSIZE/2))
    // tmp <- T2[a_h|a_l|b_l]
    EOR     \tmp, \opA, \opB, LSL #(32-(FIELDSIZE>>1))
    LDRB    \tmp, [\pttab, \tmp, ROR #(32-(FIELDSIZE>>1))]
    // res <- res ^ tmp
    EOR     \res, \tmp
    // when called multiple times
    SUB     \pttab, #(1<<(3*FIELDSIZE/2))
.endm

    // ------------------------------------------------------------------------
    // Exp-log multiplication for parallel 4 ISW multiplication

.macro    multiplicationEL opA, opB, res, pttab, tmp, shift
    // log(opA) + log(opB)
.if \shift==0
    MUL     \tmp, \opA, \opB
    LDRB    \opA, [\pttab, \opA]
    LDRB    \opB, [\pttab, \opB]    
.elseif \shift==1
    MUL     \tmp, \opA, \opB
    LSR     \tmp, #(\shift*FIELDSIZE)
    LDRB    \opA, [\pttab, \opA, LSR #(\shift*FIELDSIZE)]
    LDRB    \opB, [\pttab, \opB, LSR #(\shift*FIELDSIZE)]   
.elseif \shift==2
    UMULL   \res, \tmp, \opA, \opB
    LDRB    \opA, [\pttab, \opA, LSR #(\shift*FIELDSIZE)]
    LDRB    \opB, [\pttab, \opB, LSR #(\shift*FIELDSIZE)]   
.elseif \shift==3
    MUL     \tmp, \opA, \opB    
    LDRB    \opA, [\pttab, \opA]
    LDRB    \opB, [\pttab, \opB]                    
.endif
    ADD     \opA, \opB                                  
    // res <- alog (tmp0)
    ADD     \pttab, #(1<<FIELDSIZE)
    LDRB    \res, [\pttab, \opA]
    // check if opA or opB is 0
    RSB     \tmp, #0                                
    AND     \res, \tmp, ASR #32 
    // when called multiple times
    SUB     \pttab, #(1<<FIELDSIZE)
.endm


    ///////////////////////////////////
    //                               //
    //    8 //  ISW MULTIPLICATION   //
    //                               //
    ///////////////////////////////////
    

    // ------------------------------------------------------------------------
    // Full tab multiplication for parallel 8 ISW multiplication


.macro    multiplicationFT opA, opB, res, pttab, shift
    EOR     \opA, \opB, \opA, LSL #FIELDSIZE
.if \shift==0
    LDRB    \res, [\pttab,\opA]
.elseif \shift==7
    LDRB    \res, [\pttab,\opA]
.else
    LDRB    \res, [\pttab,\opA, LSR #(\shift*FIELDSIZE)]
.endif
.endm


///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                        ISW MULTIPLICATION FUNCTION                        //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////

.pool
isw_mult:	
    push {R3-R12, LR}
    // ------------------------------------------------------------------------
    // init phase
    LDR     R7, =multTable
    LDR     R14, =RNGReg


    ///////////////////////////////////
    //                               //
    //   NORMAL ISW MULTIPLICATION   //
    //                               //
    ///////////////////////////////////


#if CIPH_MODE==ANY

#if CODE_MODE==NORMAL

    // ------------------------------------------------------------------------
    // c_i = a_i * b_i

    MOV     R12, #0
loop0iswnormal:	
    LDR     R4, [R0, R12, LSL #2]
    LDR     R5, [R1, R12, LSL #2]
    multiplication_wrapper R4,R5,R6,R7,R8,R9,mul0    
    STR     R6, [R2, R12, LSL #2]
    // loop 0 processing
    ADD     R12, #1
    CMP     R12, #NBSHARES
    BNE     loop0iswnormal

    // ------------------------------------------------------------------------
    // s' = (s + (a_i*b_j)) + (a_j*b_i)s
    // c_i = c_i + s
    // c_j = c_j + s'

    MOV     R12, #0
loop1iswnormal:	
    ADD     R11, R12, #1
loop2iswnormal:	
    // s <-$ F
    get_random R3, R14
    LSR     R3, #(32-FIELDSIZE)
    // c_i += s
    LDR     R6, [R2, R12, LSL #2]
    EOR     R6, R3
    STR     R6, [R2, R12, LSL #2]
    // s' += a_i*b_j
    LDR     R4, [R0, R12, LSL #2] 
    LDR     R5, [R1, R11, LSL #2] 
    multiplication_wrapper R4,R5,R6,R7,R8,R9,mul1
    EOR     R3, R6
    // s' += a_j*b_i 
    LDR     R4, [R0, R11, LSL #2] 
    LDR     R5, [R1, R12, LSL #2] 
    multiplication_wrapper R4,R5,R6,R7,R8,R9,mul2
    EOR     R3, R6
    // c_j += s' 
    LDR     R6, [R2, R11, LSL #2]
    EOR     R6, R3
    STR     R6, [R2, R11, LSL #2]
    // loop 2 processing
    ADD     R11, #1
    CMP     R11, #NBSHARES
    BNE     loop2iswnormal
    // loop 1 processing 
    ADD     R12, #1
    CMP     R12, #(NBSHARES-1)
    BNE     loop1iswnormal
        
    ///////////////////////////////////
    //                               //
    //    4 // ISW MULTIPLICATION    //
    //                               //
    ///////////////////////////////////
    
#elif CODE_MODE==PARA4
    // stores RNGReg address in the stack
    STR     R14, [R13]

    // ------------------------------------------------------------------------
    // c_i = a_i * b_i

    MOV     R12, #0
loop0iswpara4:	
    LDR     R4, [R0, R12, LSL #2]
    LDR     R5, [R1, R12, LSL #2]   
    AND     R8, R4, #((1<<FIELDSIZE)-1)
    AND     R9, R5, #((1<<FIELDSIZE)-1)
    multiplication_wrapper_para4 R8,R9,R10,R7,R3,0,mul00
    AND     R8, R4, #(((1<<FIELDSIZE)-1)<<FIELDSIZE)
    AND     R9, R5, #(((1<<FIELDSIZE)-1)<<FIELDSIZE)
    multiplication_wrapper_para4 R8,R9,R6,R7,R3,1,mul01
    EOR     R10, R10, R6, LSL #FIELDSIZE
    AND     R8, R4, #(((1<<FIELDSIZE)-1)<<(2*FIELDSIZE))
    AND     R9, R5, #(((1<<FIELDSIZE)-1)<<(2*FIELDSIZE))
    multiplication_wrapper_para4 R8,R9,R6,R7,R3,2,mul02
    EOR     R10, R10, R6, LSL #(2*FIELDSIZE)
    LSR     R8, R4, #(3*FIELDSIZE)
    LSR     R9, R5, #(3*FIELDSIZE)
    multiplication_wrapper_para4 R8,R9,R6,R7,R3,3,mul03
    EOR     R10, R10, R6, LSL #(3*FIELDSIZE)
    STR     R10, [R2, R12, LSL #2]
    // loop 0 processing
    ADD     R12, #1
    CMP     R12, #NBSHARES
    BNE     loop0iswpara4

    // ------------------------------------------------------------------------
    // s' = (s + (a_i*b_j)) + (a_j*b_i)
    // c_i = c_i + s
    // c_j = c_j + s'

    MOV     R12, #0
loop1iswpara4:	
    ADD     R11, R12, #1
loop2iswpara4:	
    // get RNGReg adress from stack and s <-$ F
    LDR     R14, [R13]
    get_random R3, R14
    // c_i += s 
    LDR     R6, [R2, R12, LSL #2]
    EOR     R6, R3
    STR     R6, [R2, R12, LSL #2]
    // s' += a_i*b_j
    LDR     R4, [R0, R12, LSL #2]
    LDR     R5, [R1, R11, LSL #2]
    AND     R8, R4, #((1<<FIELDSIZE)-1)
    AND     R9, R5, #((1<<FIELDSIZE)-1)
    multiplication_wrapper_para4 R8,R9,R10,R7,R14,0,mul10
    AND     R8, R4, #(((1<<FIELDSIZE)-1)<<FIELDSIZE)
    AND     R9, R5, #(((1<<FIELDSIZE)-1)<<FIELDSIZE)
    multiplication_wrapper_para4 R8,R9,R6,R7,R14,1,mul11
    EOR     R10, R10, R6, LSL #FIELDSIZE
    AND     R8, R4, #(((1<<FIELDSIZE)-1)<<(2*FIELDSIZE))
    AND     R9, R5, #(((1<<FIELDSIZE)-1)<<(2*FIELDSIZE))
    multiplication_wrapper_para4 R8,R9,R6,R7,R14,2,mul12
    EOR     R10, R10, R6, LSL #(2*FIELDSIZE)
    LSR     R8, R4, #(3*FIELDSIZE)
    LSR     R9, R5, #(3*FIELDSIZE)
    multiplication_wrapper_para4 R8,R9,R6,R7,R14,3,mul13
    EOR     R10, R10, R6, LSL #(3*FIELDSIZE)
    EOR     R3, R10
    // s' += a_j*b_i
    LDR     R4, [R0, R11, LSL #2]
    LDR     R5, [R1, R12, LSL #2]
    AND     R8, R4, #((1<<FIELDSIZE)-1)
    AND     R9, R5, #((1<<FIELDSIZE)-1)
    multiplication_wrapper_para4 R8,R9,R10,R7,R14,0,mul20
    AND     R8, R4, #(((1<<FIELDSIZE)-1)<<FIELDSIZE)
    AND     R9, R5, #(((1<<FIELDSIZE)-1)<<FIELDSIZE)
    multiplication_wrapper_para4 R8,R9,R6,R7,R14,1,mul21
    EOR     R10, R10, R6, LSL #FIELDSIZE
    AND     R8, R4, #(((1<<FIELDSIZE)-1)<<(2*FIELDSIZE))
    AND     R9, R5, #(((1<<FIELDSIZE)-1)<<(2*FIELDSIZE))
    multiplication_wrapper_para4 R8,R9,R6,R7,R14,2,mul22
    EOR     R10, R10, R6, LSL #(2*FIELDSIZE)
    LSR     R8, R4, #(3*FIELDSIZE)
    LSR     R9, R5, #(3*FIELDSIZE)
    multiplication_wrapper_para4 R8,R9,R6,R7,R14,3,mul23
    EOR     R10, R10, R6, LSL #(3*FIELDSIZE)
    EOR     R3, R10
    // c_j += s' 
    LDR     R6, [R2, R11, LSL #2]
    EOR     R6, R3
    STR     R6, [R2, R11, LSL #2]
    // loop 2 processing
    ADD     R11, #1
    CMP     R11, #NBSHARES
    BNE     loop2iswpara4
    // loop 1 processing
    ADD     R12, #1
    CMP     R12, #(NBSHARES-1)
    BNE     loop1iswpara4

    ///////////////////////////////////
    //                               //
    //    8 // ISW MULTIPLICATION    //
    //                               //
    ///////////////////////////////////
    
#elif CODE_MODE==PARA8

    // ------------------------------------------------------------------------
    // c_i = a_i * b_i

    MOV     R12, #0
loop0iswpara8:	
    LDR     R4, [R0, R12, LSL #2]
    LDR     R5, [R1, R12, LSL #2]   
    AND     R8, R4, #((1<<FIELDSIZE)-1)
    AND     R9, R5, #((1<<FIELDSIZE)-1)
    multiplicationFT R8,R9,R10,R7,0
    AND     R8, R4, #(((1<<FIELDSIZE)-1)<<FIELDSIZE)
    AND     R9, R5, #(((1<<FIELDSIZE)-1)<<FIELDSIZE)
    multiplicationFT R8,R9,R6,R7,1
    EOR     R10, R10, R6, LSL #FIELDSIZE
    AND     R8, R4, #(((1<<FIELDSIZE)-1)<<(2*FIELDSIZE))
    AND     R9, R5, #(((1<<FIELDSIZE)-1)<<(2*FIELDSIZE))
    multiplicationFT R8,R9,R6,R7,2
    EOR     R10, R10, R6, LSL #(2*FIELDSIZE)
    AND     R8, R4, #(((1<<FIELDSIZE)-1)<<(3*FIELDSIZE))
    AND     R9, R5, #(((1<<FIELDSIZE)-1)<<(3*FIELDSIZE))
    multiplicationFT R8,R9,R6,R7,3
    EOR     R10, R10, R6, LSL #(3*FIELDSIZE)
    AND     R8, R4, #(((1<<FIELDSIZE)-1)<<(4*FIELDSIZE))
    AND     R9, R5, #(((1<<FIELDSIZE)-1)<<(4*FIELDSIZE))
    multiplicationFT R8,R9,R6,R7,4
    EOR     R10, R10, R6, LSL #(4*FIELDSIZE)
    AND     R8, R4, #(((1<<FIELDSIZE)-1)<<(5*FIELDSIZE))
    AND     R9, R5, #(((1<<FIELDSIZE)-1)<<(5*FIELDSIZE))
    multiplicationFT R8,R9,R6,R7,5
    EOR     R10, R10, R6, LSL #(5*FIELDSIZE)
    AND     R8, R4, #(((1<<FIELDSIZE)-1)<<(6*FIELDSIZE))
    AND     R9, R5, #(((1<<FIELDSIZE)-1)<<(6*FIELDSIZE))
    multiplicationFT R8,R9,R6,R7,6
    EOR     R10, R10, R6, LSL #(6*FIELDSIZE)
    LSR     R8, R4, #(7*FIELDSIZE)
    LSR     R9, R5, #(7*FIELDSIZE)
    multiplicationFT R8,R9,R6,R7,7
    EOR     R10, R10, R6, LSL #(7*FIELDSIZE)
    STR     R10, [R2, R12, LSL #2]
    // loop 0 processing
    ADD     R12, #1
    CMP     R12, #NBSHARES
    BNE     loop0iswpara8

    // ------------------------------------------------------------------------
    // s' = (s + (a_i*b_j)) + (a_j*b_i)s
    // c_i = c_i + s
    // c_j = c_j + s'

    MOV     R12, #0
loop1iswpara8:	
    ADD     R11, R12, #1
loop2iswpara8:	
    // s <-$ F
    get_random R3, R14
    // c_i += s
    LDR     R6, [R2, R12, LSL #2]
    EOR     R6, R3
    STR     R6, [R2, R12, LSL #2]
    // s' += a_i * b_j
    LDR     R4, [R0, R12, LSL #2]
    LDR     R5, [R1, R11, LSL #2]
    AND     R8, R4, #((1<<FIELDSIZE)-1)
    AND     R9, R5, #((1<<FIELDSIZE)-1)
    multiplicationFT R8,R9,R10,R7,0
    AND     R8, R4, #(((1<<FIELDSIZE)-1)<<FIELDSIZE)
    AND     R9, R5, #(((1<<FIELDSIZE)-1)<<FIELDSIZE)
    multiplicationFT R8,R9,R6,R7,1
    EOR     R10, R10, R6, LSL #FIELDSIZE
    AND     R8, R4, #(((1<<FIELDSIZE)-1)<<(2*FIELDSIZE))
    AND     R9, R5, #(((1<<FIELDSIZE)-1)<<(2*FIELDSIZE))
    multiplicationFT R8,R9,R6,R7,2
    EOR     R10, R10, R6, LSL #(2*FIELDSIZE)
    AND     R8, R4, #(((1<<FIELDSIZE)-1)<<(3*FIELDSIZE))
    AND     R9, R5, #(((1<<FIELDSIZE)-1)<<(3*FIELDSIZE))
    multiplicationFT R8,R9,R6,R7,3
    EOR     R10, R10, R6, LSL #(3*FIELDSIZE)
    AND     R8, R4, #(((1<<FIELDSIZE)-1)<<(4*FIELDSIZE))
    AND     R9, R5, #(((1<<FIELDSIZE)-1)<<(4*FIELDSIZE))
    multiplicationFT R8,R9,R6,R7,4
    EOR     R10, R10, R6, LSL #(4*FIELDSIZE)
    AND     R8, R4, #(((1<<FIELDSIZE)-1)<<(5*FIELDSIZE))
    AND     R9, R5, #(((1<<FIELDSIZE)-1)<<(5*FIELDSIZE))
    multiplicationFT R8,R9,R6,R7,5
    EOR     R10, R10, R6, LSL #(5*FIELDSIZE)
    AND     R8, R4, #(((1<<FIELDSIZE)-1)<<(6*FIELDSIZE))
    AND     R9, R5, #(((1<<FIELDSIZE)-1)<<(6*FIELDSIZE))
    multiplicationFT R8,R9,R6,R7,6
    EOR     R10, R10, R6, LSL #(6*FIELDSIZE)
    LSR     R8, R4, #(7*FIELDSIZE)
    LSR     R9, R5, #(7*FIELDSIZE)
    multiplicationFT R8,R9,R6,R7,7
    EOR     R10, R10, R6, LSL #(7*FIELDSIZE)
    EOR     R3, R10
    // s' += a_j*b_i
    LDR     R4, [R0, R11, LSL #2]
    LDR     R5, [R1, R12, LSL #2]
    AND     R8, R4, #((1<<FIELDSIZE)-1)
    AND     R9, R5, #((1<<FIELDSIZE)-1)
    multiplicationFT R8,R9,R10,R7,0
    AND     R8, R4, #(((1<<FIELDSIZE)-1)<<FIELDSIZE)
    AND     R9, R5, #(((1<<FIELDSIZE)-1)<<FIELDSIZE)
    multiplicationFT R8,R9,R6,R7,1
    EOR     R10, R10, R6, LSL #FIELDSIZE
    AND     R8, R4, #(((1<<FIELDSIZE)-1)<<(2*FIELDSIZE))
    AND     R9, R5, #(((1<<FIELDSIZE)-1)<<(2*FIELDSIZE))
    multiplicationFT R8,R9,R6,R7,2
    EOR     R10, R10, R6, LSL #(2*FIELDSIZE)
    AND     R8, R4, #(((1<<FIELDSIZE)-1)<<(3*FIELDSIZE))
    AND     R9, R5, #(((1<<FIELDSIZE)-1)<<(3*FIELDSIZE))
    multiplicationFT R8,R9,R6,R7,3
    EOR     R10, R10, R6, LSL #(3*FIELDSIZE)
    AND     R8, R4, #(((1<<FIELDSIZE)-1)<<(4*FIELDSIZE))
    AND     R9, R5, #(((1<<FIELDSIZE)-1)<<(4*FIELDSIZE))
    multiplicationFT R8,R9,R6,R7,4
    EOR     R10, R10, R6, LSL #(4*FIELDSIZE)
    AND     R8, R4, #(((1<<FIELDSIZE)-1)<<(5*FIELDSIZE))
    AND     R9, R5, #(((1<<FIELDSIZE)-1)<<(5*FIELDSIZE))
    multiplicationFT R8,R9,R6,R7,5
    EOR     R10, R10, R6, LSL #(5*FIELDSIZE)
    AND     R8, R4, #(((1<<FIELDSIZE)-1)<<(6*FIELDSIZE))
    AND     R9, R5, #(((1<<FIELDSIZE)-1)<<(6*FIELDSIZE))
    multiplicationFT R8,R9,R6,R7,6
    EOR     R10, R10, R6, LSL #(6*FIELDSIZE)
    LSR     R8, R4, #(7*FIELDSIZE)
    LSR     R9, R5, #(7*FIELDSIZE)
    multiplicationFT R8,R9,R6,R7,7
    EOR     R10, R10, R6, LSL #(7*FIELDSIZE)
    EOR     R3, R10
    // c_j += s'
    LDR     R6, [R2, R11, LSL #2]
    EOR     R6, R3
    STR     R6, [R2, R11, LSL #2]
    // loop 2 processing
    ADD     R11, #1
    CMP     R11, #NBSHARES
    BNE     loop2iswpara8
    // loop 1 processing
    ADD     R12, #1
    CMP     R12, #(NBSHARES-1)
    BNE     loop1iswpara8
#endif
        
    ///////////////////////////////////
    //                               //
    //  ISW MULTIPLICATION FOR KHL   //
    //                               //
    ///////////////////////////////////
    
#elif CIPH_MODE==KHL

#if CODE_MODE==NORMAL

    // ------------------------------------------------------------------------
    // c_i = a_i * b_i

    MOV     R12, #0
loop0iswkhlnormal:	
    LDR     R4, [R0,R12, LSL #2]
    LDR     R5, [R1,R12, LSL #2]
    multiplication R4,R5,R6,R7,0
    STR     R6, [R2,R12, LSL #2]
    // loop 0 processing
    ADD     R12, #1
    CMP     R12, #NBSHARES
    BNE     loop0iswkhlnormal

    // ------------------------------------------------------------------------
    // s' = (s + (a_i*b_j)) + (a_j*b_i)s
    // c_i = c_i + s
    // c_j = c_j + s'

    MOV     R12, #0
loop1iswkhlnormal:	
    ADD     R11, R12, #1
loop2iswkhlnormal:	
    // s <-$ F
    get_random R3,R14
    LSR     R3, #(32-4)
    // c_i += s
    LDR     R6, [R2,R12, LSL #2]
    EOR     R6, R3
    STR     R6, [R2,R12, LSL #2]
    // s' += a_i*b_j
    LDR     R4, [R0,R12, LSL #2] 
    LDR     R5, [R1,R11, LSL #2] 
    multiplication R4,R5,R6,R7,0
    EOR     R3, R6
    // s' += a_j*b_i 
    LDR     R4, [R0,R11, LSL #2] 
    LDR     R5, [R1,R12, LSL #2] 
    multiplication R4,R5,R6,R7,0
    EOR     R3, R6
    // c_j += s' 
    LDR     R6, [R2,R11, LSL #2]
    EOR     R6, R3
    STR     R6, [R2,R11, LSL #2]
    // loop 2 processing
    ADD     R11, #1
    CMP     R11, #NBSHARES
    BNE     loop2iswkhlnormal
    // loop 1 processing 
    ADD     R12, #1
    CMP     R12, #(NBSHARES-1)
    BNE     loop1iswkhlnormal
    
#elif CODE_MODE==PARA8
    MOV     R12, #0
loop0iswkhlpara8:	
    LDR     R4, [R0, R12, LSL #2]
    LDR     R5, [R1, R12, LSL #2]   
    AND     R8, R4, #((1<<4)-1)
    AND     R9, R5, #((1<<4)-1)
    multiplication R8,R9,R10,R7,0
    AND     R8, R4, #(((1<<4)-1)<<4)
    AND     R9, R5, #(((1<<4)-1)<<4)
    multiplication R8,R9,R6,R7,1
    EOR     R10, R10, R6, LSL #4
    AND     R8, R4, #(((1<<4)-1)<<(2*4))
    AND     R9, R5, #(((1<<4)-1)<<(2*4))
    multiplication R8,R9,R6,R7,2
    EOR     R10, R10, R6, LSL #(2*4)
    AND     R8, R4, #(((1<<4)-1)<<(3*4))
    AND     R9, R5, #(((1<<4)-1)<<(3*4))
    multiplication R8,R9,R6,R7,3
    EOR     R10, R10, R6, LSL #(3*4)
    AND     R8, R4, #(((1<<4)-1)<<(4*4))
    AND     R9, R5, #(((1<<4)-1)<<(4*4))
    multiplication R8,R9,R6,R7,4
    EOR     R10, R10, R6, LSL #(4*4)
    AND     R8, R4, #(((1<<4)-1)<<(5*4))
    AND     R9, R5, #(((1<<4)-1)<<(5*4))
    multiplication R8,R9,R6,R7,5
    EOR     R10, R10, R6, LSL #(5*4)
    AND     R8, R4, #(((1<<4)-1)<<(6*4))
    AND     R9, R5, #(((1<<4)-1)<<(6*4))
    multiplication R8,R9,R6,R7,6
    EOR     R10, R10, R6, LSL #(6*4)
    LSR     R8, R4, #(7*4)
    LSR     R9, R5, #(7*4)
    multiplication R8,R9,R6,R7,7
    EOR     R10, R10, R6, LSL #(7*4)
    STR     R10, [R2, R12, LSL #2]
    // loop 0 processing
    ADD     R12, #1
    CMP     R12, #NBSHARES
    BNE     loop0iswkhlpara8

    // ------------------------------------------------------------------------
    // s' = (s + (a_i*b_j)) + (a_j*b_i)s
    // c_i = c_i + s
    // c_j = c_j + s'

    MOV     R12, #0
loop1iswkhlpara8:	
    ADD     R11, R12, #1
loop2iswkhlpara8:	
    // s <-$ F
    get_random R3,R14
    // c_i += s
    LDR     R6, [R2, R12, LSL #2]
    EOR     R6, R3
    STR     R6, [R2, R12, LSL #2]
    // s' += a_i * b_j
    LDR     R4, [R0, R12, LSL #2]
    LDR     R5, [R1, R11, LSL #2]
    AND     R8, R4, #((1<<4)-1)
    AND     R9, R5, #((1<<4)-1)
    multiplication R8,R9,R10,R7,0
    AND     R8, R4, #(((1<<4)-1)<<4)
    AND     R9, R5, #(((1<<4)-1)<<4)
    multiplication R8,R9,R6,R7,1
    EOR     R10, R10, R6, LSL #4
    AND     R8, R4, #(((1<<4)-1)<<(2*4))
    AND     R9, R5, #(((1<<4)-1)<<(2*4))
    multiplication R8,R9,R6,R7,2
    EOR     R10, R10, R6, LSL #(2*4)
    AND     R8, R4, #(((1<<4)-1)<<(3*4))
    AND     R9, R5, #(((1<<4)-1)<<(3*4))
    multiplication R8,R9,R6,R7,3
    EOR     R10, R10, R6, LSL #(3*4)
    AND     R8, R4, #(((1<<4)-1)<<(4*4))
    AND     R9, R5, #(((1<<4)-1)<<(4*4))
    multiplication R8,R9,R6,R7,4
    EOR     R10, R10, R6, LSL #(4*4)
    AND     R8, R4, #(((1<<4)-1)<<(5*4))
    AND     R9, R5, #(((1<<4)-1)<<(5*4))
    multiplication R8,R9,R6,R7,5
    EOR     R10, R10, R6, LSL #(5*4)
    AND     R8, R4, #(((1<<4)-1)<<(6*4))
    AND     R9, R5, #(((1<<4)-1)<<(6*4))
    multiplication R8,R9,R6,R7,6
    EOR     R10, R10, R6, LSL #(6*4)
    LSR     R8, R4, #(7*4)
    LSR     R9, R5, #(7*4)
    multiplication R8,R9,R6,R7,7
    EOR     R10, R10, R6, LSL #(7*4)
    EOR     R3, R10
    // s' += a_j*b_i
    LDR     R4, [R0, R11, LSL #2]
    LDR     R5, [R1, R12, LSL #2]
    AND     R8, R4, #((1<<4)-1)
    AND     R9, R5, #((1<<4)-1)
    multiplication R8,R9,R10,R7,0
    AND     R8, R4, #(((1<<4)-1)<<4)
    AND     R9, R5, #(((1<<4)-1)<<4)
    multiplication R8,R9,R6,R7,1
    EOR     R10, R10, R6, LSL #4
    AND     R8, R4, #(((1<<4)-1)<<(2*4))
    AND     R9, R5, #(((1<<4)-1)<<(2*4))
    multiplication R8,R9,R6,R7,2
    EOR     R10, R10, R6, LSL #(2*4)
    AND     R8, R4, #(((1<<4)-1)<<(3*4))
    AND     R9, R5, #(((1<<4)-1)<<(3*4))
    multiplication R8,R9,R6,R7,3
    EOR     R10, R10, R6, LSL #(3*4)
    AND     R8, R4, #(((1<<4)-1)<<(4*4))
    AND     R9, R5, #(((1<<4)-1)<<(4*4))
    multiplication R8,R9,R6,R7,4
    EOR     R10, R10, R6, LSL #(4*4)
    AND     R8, R4, #(((1<<4)-1)<<(5*4))
    AND     R9, R5, #(((1<<4)-1)<<(5*4))
    multiplication R8,R9,R6,R7,5
    EOR     R10, R10, R6, LSL #(5*4)
    AND     R8, R4, #(((1<<4)-1)<<(6*4))
    AND     R9, R5, #(((1<<4)-1)<<(6*4))
    multiplication R8,R9,R6,R7,6
    EOR     R10, R10, R6, LSL #(6*4)
    LSR     R8, R4, #(7*4)
    LSR     R9, R5, #(7*4)
    multiplication R8,R9,R6,R7,7
    EOR     R10, R10, R6, LSL #(7*4)
    EOR     R3, R10
    // c_j += s'
    LDR     R6, [R2, R11, LSL #2]
    EOR     R6, R3
    STR     R6, [R2, R11, LSL #2]
    // loop 2 processing
    ADD     R11, #1
    CMP     R11, #NBSHARES
    BNE     loop2iswkhlpara8
    // loop 1 processing
    ADD     R12, #1
    CMP     R12, #(NBSHARES-1)
    BNE     loop1iswkhlpara8
    
#endif


    ///////////////////////////////////
    //                               //
    //   ISW MULTIPLICATION FOR RP   //
    //                               //
    ///////////////////////////////////


#elif CIPH_MODE==RP

#if CODE_MODE==NORMAL

    // ------------------------------------------------------------------------
    // c_i = a_i * b_i

    MOV     R12, #0
loop0iswrpnormal:	
    LDR     R4, [R0,R12, LSL #2]
    LDR     R5, [R1,R12, LSL #2]
    multiplication R4,R5,R6,R7,R8,0
    STR     R6, [R2,R12, LSL #2]
    // loop 0 processing
    ADD     R12, #1
    CMP     R12, #NBSHARES
    BNE     loop0iswrpnormal

    // ------------------------------------------------------------------------
    // s' = (s + (a_i*b_j)) + (a_j*b_i)s
    // c_i = c_i + s
    // c_j = c_j + s'

    MOV     R12, #0
loop1iswrpnormal:	
    ADD     R11, R12, #1
loop2iswrpnormal:	
    // s <-$ F
    get_random R3,R14
    LSR     R3, #(32-8)
    // c_i += s
    LDR     R6, [R2,R12, LSL #2]
    EOR     R6, R3
    STR     R6, [R2,R12, LSL #2]
    // s' += a_i*b_j
    LDR     R4, [R0,R12, LSL #2] 
    LDR     R5, [R1,R11, LSL #2] 
    multiplication R4,R5,R6,R7,R8,0
    EOR     R3, R6
    // s' += a_j*b_i 
    LDR     R4, [R0,R11, LSL #2] 
    LDR     R5, [R1,R12, LSL #2] 
    multiplication R4,R5,R6,R7,R8,0
    EOR     R3, R6
    // c_j += s' 
    LDR     R6, [R2,R11, LSL #2]
    EOR     R6, R3
    STR     R6, [R2,R11, LSL #2]
    // loop 2 processing
    ADD     R11, #1
    CMP     R11, #NBSHARES
    BNE     loop2iswrpnormal
    // loop 1 processing 
    ADD     R12, #1
    CMP     R12, #(NBSHARES-1)
    BNE     loop1iswrpnormal
    
#elif CODE_MODE==PARA4

    // stores RNGReg address in the stack
    STR     R14, [R13]

    // ------------------------------------------------------------------------
    // c_i = a_i * b_i

    MOV     R12, #0
loop0iswrppara4:	
    LDR     R4, [R0, R12, LSL #2]
    LDR     R5, [R1, R12, LSL #2]   
    AND     R8, R4, #((1<<8)-1)
    AND     R9, R5, #((1<<8)-1)
    multiplication R8,R9,R10,R7,R3,0
    AND     R8, R4, #(((1<<8)-1)<<8)
    AND     R9, R5, #(((1<<8)-1)<<8)
    multiplication R8,R9,R6,R7,R3,1
    EOR     R10, R10, R6, LSL #8
    AND     R8, R4, #(((1<<8)-1)<<(2*8))
    AND     R9, R5, #(((1<<8)-1)<<(2*8))
    multiplication R8,R9,R6,R7,R3,2
    EOR     R10, R10, R6, LSL #(2*8)
    LSR     R8, R4, #(3*8)
    LSR     R9, R5, #(3*8)
    multiplication R8,R9,R6,R7,R3,3
    EOR     R10, R10, R6, LSL #(3*8)
    STR     R10, [R2, R12, LSL #2]
    // loop 0 processing
    ADD     R12, #1
    CMP     R12, #NBSHARES
    BNE     loop0iswrppara4

    // ------------------------------------------------------------------------
    // s' = (s + (a_i*b_j)) + (a_j*b_i)
    // c_i = c_i + s
    // c_j = c_j + s'

    MOV     R12, #0
loop1iswrppara4:	
    ADD     R11, R12, #1
loop2iswrppara4:	
    // get RandTable from stack and s <-$ F
    LDR     R14, [R13]
    get_random R3,R14
    // c_i += s 
    LDR     R6, [R2, R12, LSL #2]
    EOR     R6, R3
    STR     R6, [R2, R12, LSL #2]
    // s' += a_i*b_j
    LDR     R4, [R0, R12, LSL #2]
    LDR     R5, [R1, R11, LSL #2]
    AND     R8, R4, #((1<<8)-1)
    AND     R9, R5, #((1<<8)-1)
    multiplication R8,R9,R10,R7,R14,0
    AND     R8, R4, #(((1<<8)-1)<<8)
    AND     R9, R5, #(((1<<8)-1)<<8)
    multiplication R8,R9,R6,R7,R14,1
    EOR     R10, R10, R6, LSL #8
    AND     R8, R4, #(((1<<8)-1)<<(2*8))
    AND     R9, R5, #(((1<<8)-1)<<(2*8))
    multiplication R8,R9,R6,R7,R14,2
    EOR     R10, R10, R6, LSL #(2*8)
    LSR     R8, R4, #(3*8)
    LSR     R9, R5, #(3*8)
    multiplication R8,R9,R6,R7,R14,3
    EOR     R10, R10, R6, LSL #(3*8)
    EOR     R3, R10
    // s' += a_j*b_i
    LDR     R4, [R0, R11, LSL #2]
    LDR     R5, [R1, R12, LSL #2]
    AND     R8, R4, #((1<<8)-1)
    AND     R9, R5, #((1<<8)-1)
    multiplication R8,R9,R10,R7,R14,0
    AND     R8, R4, #(((1<<8)-1)<<8)
    AND     R9, R5, #(((1<<8)-1)<<8)
    multiplication R8,R9,R6,R7,R14,1
    EOR     R10, R10, R6, LSL #8
    AND     R8, R4, #(((1<<8)-1)<<(2*8))
    AND     R9, R5, #(((1<<8)-1)<<(2*8))
    multiplication R8,R9,R6,R7,R14,2
    EOR     R10, R10, R6, LSL #(2*8)
    LSR     R8, R4, #(3*8)
    LSR     R9, R5, #(3*8)
    multiplication R8,R9,R6,R7,R14,3
    EOR     R10, R10, R6, LSL #(3*8)
    EOR     R3, R10
    // c_j += s' 
    LDR     R6, [R2, R11, LSL #2]
    EOR     R6, R3
    STR     R6, [R2, R11, LSL #2]
    // loop 2 processing
    ADD     R11, #1
    CMP     R11, #NBSHARES
    BNE     loop2iswrppara4
    // loop 1 processing
    ADD     R12, #1
    CMP     R12, #(NBSHARES-1)
    BNE     loop1iswrppara4
#endif
#endif	
    
    pop {R3-R12, LR}
    BX  LR

