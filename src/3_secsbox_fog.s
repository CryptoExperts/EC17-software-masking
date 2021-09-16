.text
    

///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                  PRESENT polynomial (FoG) evaluation                      //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////

.pool
fog_sbox:	
    push {R2-R12, LR}

    // ------------------------------------------------------------------------
    // init phase

    MOV     R8, R1
    LDR     R10, =gTable
    LDR     R1, =tmpTable


    ///////////////////////////////////
    //                               //
    //    Normal sbox evaluation     //
    //                               //
    ///////////////////////////////////


 #if CODE_MODE==NORMAL

    // ------------------------------------------------------------------------
    // G(x)

    BL      cprr_eval
    LDRB    R3, [R10]
    MOV     R5, #1
    BIC     R5, R5, #NBSHARES
    LDRB    R2, [R1]
    MUL     R4, R5, R3
    EOR     R2, R4
    STRB    R2, [R1]

    // ------------------------------------------------------------------------
    // F(G(x))

    ADD     R10, #16
    MOV     R0, R1
    MOV     R1, R8
    BL      cprr_eval
    LDRB    R3, [R10]
    MOV     R5, #1
    BIC     R5, R5, #NBSHARES
    LDRB    R2, [R1]
    MUL     R4, R5, R3
    EOR     R2, R4
    STRB    R2, [R1]


    ///////////////////////////////////
    //                               //
    //      8 // sbox evaluation     //
    //                               //
    ///////////////////////////////////

    
#elif CODE_MODE==PARA8

    // ------------------------------------------------------------------------
    // G(x)

    BL      cprr_eval
    LDRB    R3, [R10]
    MOV     R5, #1
    BIC     R5, R5, #NBSHARES
    LDR     R2, [R1]
    MUL     R4, R5, R3
    EOR     R4, R4, R4, LSL #4
    EOR     R4, R4, R4, LSL #8
    EOR     R4, R4, R4, LSL #16
    EOR     R2, R4
    STR     R2, [R1]

    // ------------------------------------------------------------------------
    // F(G(x))

    ADD     R10, #16
    MOV     R0, R1
    MOV     R1, R8
    BL      cprr_eval
    LDRB    R3, [R10]
    MOV     R5, #1
    BIC     R5, R5, #NBSHARES
    LDR     R2, [R1]
    MUL     R4, R5, R3
    EOR     R4, R4, R4, LSL #4
    EOR     R4, R4, R4, LSL #8
    EOR     R4, R4, R4, LSL #16
    EOR     R2, R4
    STR     R2, [R1]

#endif
    
    pop {R2-R12, LR}
    BX      LR

    
    
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                 Temporary tables for FoG evaluation                       //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////


.data
tmpTable:
	.zero 4*NBSHARES


    
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                            FoG look-up tables                             //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////

    
.data
gTable:	
    .byte 0x7,0xE,0x9,0x2,0xB,0x0,0x4,0xD,0x5,0xC,0xA,0x1,0x8,0x3,0x6,0xF
fTable:	
    .byte 0x0,0x8,0xB,0x7,0xA,0x3,0x1,0xC,0x4,0x6,0xF,0x9,0xE,0xD,0x5,0x2

