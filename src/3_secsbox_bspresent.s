#include "2_secmult_iswand.S"

.text
.syntax unified        


///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                              UTILITY MACROS                               //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////


#if TEST_MODE == TEST_SECSBOX_BSPRESENT
.macro set_mask mask
    MOV     \mask, #1
.endm

#else
.macro set_mask mask
    MOV     \mask, #0xFF
    ADD     \mask, \mask, \mask, LSL #8
.endm
#endif


///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                    PRESENT bitslice evaluation                            //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////

.pool
bspresent_sbox:	
    push {R0, R2-R12, LR}

    // ------------------------------------------------------------------------
    // init phase

    MOV     R9, R0
    MOV     R8, R1
    LDR     R0, =tmpTable
    MOV     R4, R0
    LDR     R1, =t1Table
    MOV     R6, R1

    // ------------------------------------------------------------------------
    // T1 = X2 ^ X1

    MOV     R12, #0
loopT1:	
    LDR     R11, [R9, #8]
    LDR     R10, [R9, #4]
    EOR     R11, R10
    STR     R11, [R1, R12, LSL #2]
    STR     R10, [R0, R12, LSL #2]
    ADD     R9, #4*4
    // loop T1 processing
    ADD     R12, #1
    CMP     R12, #NBSHARES
    BNE     loopT1
    // Address update
    SUB     R9, #4*4*NBSHARES

    // ------------------------------------------------------------------------
    //  T2 = X1 & T1

    LDR     R2, =t2Table
    push {R3-R9}
    BL      isw_and
    pop {R3-R9}
	
    // ------------------------------------------------------------------------
    // T3 = X0 ^ T2 || Y3 = X3 ^ T3

    LDR     R3, =t3Table
    MOV     R12, #0
loopT3Y3:	
    LDR     R11, [R9]
    LDR     R10, [R2, R12, LSL #2]
    EOR     R11, R10
    STR     R11, [R3, R12, LSL #2]
    LDR     R10, [R9, #12]
    EOR     R11, R10 
    STR     R11, [R8, #12]
    ADD     R9, #4*4
    ADD     R8, #4*4
    // loop T3,Y3 processing
    ADD     R12, #1
    CMP     R12, #NBSHARES
    BNE     loopT3Y3
    // Addresses updates
    SUB     R9, #4*4*NBSHARES
    SUB     R8, #4*4*NBSHARES

    // ------------------------------------------------------------------------
    // T2 = T1 & T3

    MOV     R0, R3
    push {R3-R9}	
    BL      isw_and
    pop {R3-R9}
	
    // ------------------------------------------------------------------------
    // T1 ^= Y3 || T2 ^= X1 || T5 = T2 ^ NOT(X3)

    LDR     R5, =t5Table
    MOV     R0, R4
    LDR     R11, [R8, #12]
    LDR     R10, [R1]
    EOR     R11, R10
    STR     R11, [R1]
    LDR     R11, [R2]
    LDR     R10, [R9, #4]
    EOR     R11, R10
    STR     R11, [R2]
    LDR     R10, [R9, #12]
    MVN     R10, R10
    set_mask R0
    AND     R10, R0   
    EOR     R11, R10
    STR     R11, [R5]
    ADD     R9, #4*4
    ADD     R8, #4*4
    
    MOV     R12, #1
loopT1T2T5:	
    LDR     R11, [R8, #12]
    LDR     R10, [R1, R12, LSL #2]
    EOR     R11, R10
    STR     R11, [R1, R12, LSL #2]
    LDR     R11, [R2, R12, LSL #2]
    LDR     R10, [R9, #4]
    EOR     R11, R10
    STR     R11, [R2, R12, LSL #2]
    LDR     R10, [R9, #12]
    EOR     R11, R10
    STR     R11, [R5, R12, LSL #2]
    ADD     R9, #4*4
    ADD     R8, #4*4
    // loop T1,T2,T5 processing
    ADD     R12, #1
    CMP     R12, #NBSHARES
    BNE     loopT1T2T5
    // Addresses updates
    SUB     R9, #4*4*NBSHARES
    SUB     R8, #4*4*NBSHARES

    // ------------------------------------------------------------------------
    // T6 = T5 | T1 || T4 = X3 | T2

    LDR     R0, = t6Table
    LDR     R1, = t4Table
    MOV     R12, #0
loopT6T4join:	
    LDR     R11, [R5, R12, LSL #2]
    LDR     R10, [R9, #12]
    EOR     R11, R11, R10, LSL #16
    STR     R11, [R0, R12, LSL #2]
    LDR     R11, [R6, R12, LSL #2]
    LDR     R10, [R2, R12, LSL #2]
    EOR     R11, R11, R10, LSL #16
    STR     R11, [R1, R12, LSL #2]
    ADD     R9, #4*4
    // loop join T6,T4 processing
    ADD     R12, #1
    CMP     R12, #NBSHARES
    BNE     loopT6T4join
    // Address update
    SUB     R9, #4*4*NBSHARES
    MOV     R4, R2
    LDR     R2, =tmpTable
    push {R3-R9}
    BL      isw_and
    pop {R3-R9}
    MOV     R12, #0
loopT6T4fork:	
    LDR     R7, [R2, R12, LSL #2]
    LSL     R11, R7, #16
    LSR     R11, #16
    LSR     R10, R7, #16
    STR     R11, [R0, R12, LSL #2]
    STR     R10, [R1, R12, LSL #2]
    // loop fork T6,T4 processing
    ADD     R12, #1
    CMP     R12, #NBSHARES
    BNE     loopT6T4fork
    // Changing AND to OR
#if (NBSHARES&1)==0
    MOV     R12, #0
loopANDtoOR:	
    LDR     R11, [R0, R12, LSL #2]
    LDR     R10, [R5, R12, LSL #2]
    EOR     R11, R10
    LDR     R10, [R6, R12, LSL #2]
    EOR     R11, R10
    STR     R11, [R0, R12, LSL #2]
    LDR     R11, [R1, R12, LSL #2]
    LDR     R10, [R9, #12]
    EOR     R11, R10
    LDR     R10, [R4, R12, LSL #2]
    EOR     R11, R10
    STR     R11, [R1, R12, LSL #2]
    ADD     R9, #4*4
    ADD     R12, #1
    CMP     R12, #NBSHARES
    BNE     loopANDtoOR
    SUB     R9, #4*4*NBSHARES
#endif

    // ------------------------------------------------------------------------
    // Y2 = T1 ^ T4 || Y0 = Y2 ^ T5 || Y1 = T3 ^ T6

    MOV     R12, #0
loopY2Y0Y1:	
    LDR     R11, [R6, R12, LSL #2]
    LDR     R10, [R1, R12, LSL #2]
    EOR     R11, R10
    STR     R11, [R8, #8]
    LDR     R10, [R5, R12, LSL #2]
    EOR     R11, R10
    STR     R11, [R8]
    LDR     R11, [R3, R12, LSL #2]
    LDR     R10, [R0, R12, LSL #2]
    EOR     R11, R10
    STR     R11, [R8, #4]
    ADD     R8, #4*4
    // loop Y2,Y0,Y1 processing
    ADD     R12, #1
    CMP     R12, #NBSHARES
    BNE     loopY2Y0Y1
    // Address update 
    SUB     R8, #4*4*NBSHARES
    
    MOV     R1, R8
    
    pop {R0, R2-R12, LR}
    BX LR




///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//             Temporary tables for bitslice PRESENT evaluation              //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////


.data
tmpTable:
	.zero 4*NBSHARES
t1Table:
	.zero 4*NBSHARES
t2Table:
	.zero 4*NBSHARES
t3Table:
	.zero 4*NBSHARES
t4Table:
	.zero 4*NBSHARES
t5Table:
	.zero 4*NBSHARES
t6Table:
	.zero 4*NBSHARES

