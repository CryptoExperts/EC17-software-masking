.text
        

///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                         KHL SECURE FIELD INVERSION                        //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
    
sec_inv:	
    push {R2-R12, LR}
    // init phase
    MOV     R2, R1
    LDR     R10, =T1Table
    LDR     R9,  =T2Table
    
    //////////////////////////////////
    //                              //
    //    NORMAL FIELD INVERSION    //
    //                              //
    //////////////////////////////////
    
#if CODE_MODE==NORMAL
    
    // w = x^2
    MOV     R12, #0
loopSQRnormal:	
    LDRB    R5, [R0, R12, LSL #2]
    LDRB    R5, [R10, R5]
    STRB    R5, [R8, R12, LSL #2]
    // loop SQR processing
    ADD     R12, #1
    CMP     R12, #NBSHARES
    BNE     loopSQRnormal
    // z = x^3
    LDR     R1, =zTable
    LDR     R10, =cprrTable
    BL      cprr_eval
    // z = z^4 = x^12
    MOV     R12, #0
loopPower4normal:	
    LDRB    R5, [R1, R12, LSL #2]
    LDRB    R5, [R9, R5]
    STRB    R5, [R1, R12, LSL #2]
    // loop P4 processing
    ADD     R12, #1
    CMP     R12, #NBSHARES
    BNE     loopPower4normal
    // y = z*w
    MOV     R0, R8
    BL      isw_mult
    
    //////////////////////////////////
    //                              //
    //  8 PARALLEL FIELD INVERSION  //
    //                              //
    //////////////////////////////////

#elif CODE_MODE==PARA8
    // w = x^2
    MOV     R12, #0
loopSQRpara8:	
    LDR     R5, [R0, R12, LSL #2]
    AND     R7, R5, #((1<<4)-1)
    LDRB    R4, [R10, R7]
    AND     R7, R5, #(((1<<4)-1)<<4)
    LDRB    R7, [R10, R7, LSR #4]
    EOR     R4, R4, R7, LSL #4
    AND     R7, R5, #(((1<<4)-1)<<8)
    LDRB    R7, [R10, R7, LSR #8]
    EOR     R4, R4, R7, LSL #8
    AND     R7, R5, #(((1<<4)-1)<<12)
    LDRB    R7, [R10, R7, LSR #12]
    EOR     R4, R4, R7, LSL #12
    AND     R7, R5, #(((1<<4)-1)<<16)
    LDRB    R7, [R10, R7, LSR #16]
    EOR     R4, R4, R7, LSL #16
    AND     R7, R5, #(((1<<4)-1)<<20)
    LDRB    R7, [R10, R7, LSR #20]
    EOR     R4, R4, R7, LSL #20
    AND     R7, R5, #(((1<<4)-1)<<24)
    LDRB    R7, [R10, R7, LSR #24]
    EOR     R4, R4, R7, LSL #24
    AND     R7, R5, #(((1<<4)-1)<<28)
    LDRB    R7, [R10, R7, LSR #28]
    EOR     R4, R4, R7, LSL #28
    STR     R4, [R8, R12, LSL #2]
    // loop SQR processing
    ADD     R12, #1
    CMP     R12, #NBSHARES
    BNE     loopSQRpara8
    //      z = x^3
    LDR     R1, =zTable
    LDR     R10, =cprrTable
    BL      cprr_eval
    // z = z^4 = x^12
    MOV     R12, #0
loopPower4para8:	
    LDR     R5, [R1, R12, LSL #2]
    AND     R7, R5, #((1<<4)-1)
    LDRB    R4, [R9, R7]
    AND     R7, R5, #(((1<<4)-1)<<4)
    LDRB    R7, [R9, R7, LSR #4]
    EOR     R4, R4, R7, LSL #4
    AND     R7, R5, #(((1<<4)-1)<<8)
    LDRB    R7, [R9, R7, LSR #8]
    EOR     R4, R4, R7, LSL #8
    AND     R7, R5, #(((1<<4)-1)<<12)
    LDRB    R7, [R9, R7, LSR #12]
    EOR     R4, R4, R7, LSL #12
    AND     R7, R5, #(((1<<4)-1)<<16)
    LDRB    R7, [R9, R7, LSR #16]
    EOR     R4, R4, R7, LSL #16
    AND     R7, R5, #(((1<<4)-1)<<20)
    LDRB    R7, [R9, R7, LSR #20]
    EOR     R4, R4, R7, LSL #20
    AND     R7, R5, #(((1<<4)-1)<<24)
    LDRB    R7, [R9, R7, LSR #24]
    EOR     R4, R4, R7, LSL #24
    AND     R7, R5, #(((1<<4)-1)<<28)
    LDRB    R7, [R9, R7, LSR #28]
    EOR     R4, R4, R7, LSL #28
    STR     R4, [R1, R12, LSL #2]
    // loop P4 processing
    ADD     R12, #1
    CMP     R12, #NBSHARES
    BNE     loopPower4para8
    // y = w*z
    MOV     R0, R8
    BL      isw_mult

#endif
    
    MOV     R1, R2
    
    pop {R2-R12, LR}
    BX  LR


///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                     KHL polynomial AES evaluation                         //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////

.pool
khl_sbox:	
    push {R2-R12, LR}
    // init phase
    MOV     R7, R1
    LDR     R11, =T5Table
    LDR     R10, =T3Table
    LDR     R9,  =HTable
    LDR     R8,  =tmpTable
    LDR     R1,  =tTable
    LDR     R6,  =tmpwTable
    

    ///////////////////////////////////
    //                               //
    //    Normal sbox evaluation     //
    //                               //
    ///////////////////////////////////


#if CODE_MODE==NORMAL

    // ------------------------------------------------------------------------
    // 1. Tower field representation

    MOV     R12, #0
loopSplitDatanormal:	
    // (a) (H||L) = T5[x]
    LDRB    R5, [R0, R12, LSL #2]
    LDRB    R5, [R11, R5]
    MOV     R4, R5, LSR #4
    AND     R3, R5, #15
    STRB    R4, [R9, R12, LSL #2]
    STRB    R3, [R8, R12, LSL #2]
    // (c)  t = H^L
    EOR     R5, R4, R3
    STRB    R5, [R1, R12, LSL #2]
    // (b)  w = T3[H]
    LDRB    R4, [R10, R4]
    STRB    R4, [R6, R12, LSL #2]
    // loop SD processing
    ADD     R12, #1
    CMP     R12, #NBSHARES
    BNE     loopSplitDatanormal

    // ------------------------------------------------------------------------
    // 2. L = t*L

    LDR     R2, =LTable
    MOV     R0 ,R8
    BL      isw_mult

    // ------------------------------------------------------------------------
    // 3. w = w^L

    MOV     R12, #0
loopXorWLnormal:	
    LDRB    R5, [R2, R12, LSL #2]
    LDRB    R4, [R6, R12, LSL #2]
    EOR     R4, R5
    STRB    R4, [R6, R12, LSL #2]
    // loop XWL processing
    ADD     R12, #1
    CMP     R12, #NBSHARES
    BNE     loopXorWLnormal

    // ------------------------------------------------------------------------
    // 4. w = w^14

    MOV     R0, R6
    LDR     R1, =wTable
    BL      sec_inv

    // ------------------------------------------------------------------------
    // 5. H = w*H

    MOV     R0, R1
    MOV     R2, R8
    MOV     R1, R9
    BL      isw_mult

    // ------------------------------------------------------------------------
    // 6. L = w*t

    LDR     R2, =LTable
    LDR     R1, =tTable
    BL      isw_mult

    // ------------------------------------------------------------------------
    // 7. y = T6[H||L]

    LDR     R10, =T6Table
    MOV     R12, #0
loopJoinDatanormal:	
    LDRB    R5, [R8, R12, LSL #2]
    LDRB    R4, [R2, R12, LSL #2]
    EOR     R4, R4, R5, LSL #4
    LDRB    R4, [R10, R4]
    STRB    R4, [R7, R12, LSL #2]
    // loop JD processing
    ADD     R12, #1
    CMP     R12, #NBSHARES
    BNE     loopJoinDatanormal

    // ------------------------------------------------------------------------
    // 8. y_0= y_0^((1&NBSHARES)*0x63)

    LDRB    R3, [R7]
    MOV     R5, #1
    BIC     R5, R5, #NBSHARES
    MOV     R6, #0x63
    MUL     R4, R5, R6
    EOR     R3, R4
    STRB    R3, [R7]


    ///////////////////////////////////
    //                               //
    //      8 // sbox evaluation     //
    //                               //
    ///////////////////////////////////

    
#elif CODE_MODE==PARA8

    push {R7}
    push {R14}

    // ------------------------------------------------------------------------
    // 1. Tower field representation

    MOV     R12, #0
loopSplitDatapara8:	
    // (a)  (H||L) = T5[x] |  w = T3[H]
    LDR     R5, [R0, R12, LSL #3]
    AND     R2, R5, #((1<<8)-1)
    LDRB    R2, [R11, R2]
    MOV     R4, R2, LSR #4
    LDRB    R14, [R10, R4]
    AND     R3, R2, #15
    AND     R2, R5, #(((1<<8)-1)<<8)
    LDRB    R2, [R11, R2, LSR #8]
    MOV     R7, R2, LSR #4
    EOR     R4, R4, R7, LSL #4
    LDRB    R7, [R10, R7]
    EOR     R14, R14, R7, LSL #4
    AND     R7, R2, #15
    EOR     R3, R3, R7, LSL #4
    AND     R2, R5, #(((1<<8)-1)<<16)
    LDRB    R2, [R11, R2, LSR #16]
    MOV     R7, R2, LSR #4
    EOR     R4, R4, R7, LSL #8
    LDRB    R7, [R10, R7]
    EOR     R14, R14, R7, LSL #8
    AND     R7, R2, #15
    EOR     R3, R3, R7, LSL #8
    AND     R2, R5, #(((1<<8)-1)<<24)
    LDRB    R2, [R11, R2, LSR #24]
    MOV     R7, R2, LSR #4
    EOR     R4, R4, R7, LSL #12
    LDRB    R7, [R10, R7]
    EOR     R14, R14, R7, LSL #12
    AND     R7, R2, #15
    EOR     R3, R3, R7, LSL #12
    ADD     R2, R0, #4
    LDR     R5, [R2, R12, LSL #3]
    AND     R2, R5, #((1<<8)-1)
    LDRB    R2, [R11, R2]
    MOV     R7, R2, LSR #4
    EOR     R4, R4, R7, LSL #16
    LDRB    R7, [R10, R7]
    EOR     R14, R14, R7, LSL #16
    AND     R7, R2, #15
    EOR     R3, R3, R7, LSL #16
    AND     R2, R5, #(((1<<8)-1)<<8)
    LDRB    R2, [R11, R2, LSR #8]
    MOV     R7, R2, LSR #4
    EOR     R4, R4, R7, LSL #20
    LDRB    R7, [R10, R7]
    EOR     R14, R14, R7, LSL #20
    AND     R7, R2, #15
    EOR     R3, R3, R7, LSL #20
    AND     R2, R5, #(((1<<8)-1)<<16)
    LDRB    R2, [R11, R2, LSR #16]
    MOV     R7, R2, LSR #4
    EOR     R4, R4, R7, LSL #24
    LDRB    R7, [R10, R7]
    EOR     R14, R14, R7, LSL #24
    AND     R7, R2, #15
    EOR     R3, R3, R7, LSL #24
    AND     R2, R5, #(((1<<8)-1)<<24)
    LDRB    R2, [R11, R2, LSR #24]
    MOV     R7, R2, LSR #4
    EOR     R4, R4, R7, LSL #28
    LDRB    R7, [R10, R7]
    EOR     R14, R14, R7, LSL #28
    AND     R7, R2, #15
    EOR     R3, R3, R7, LSL #28
    STR     R4, [R9, R12, LSL #2]
    STR     R3, [R8, R12, LSL #2]
    STR     R14, [R6, R12, LSL #2]
    // (c)  t = H^L
    EOR     R5, R4, R3
    STR     R5, [R1, R12, LSL #2]
    // (b) done in (a) :)
    // loop SD processing
    ADD     R12, #1
    CMP     R12, #NBSHARES
    BNE     loopSplitDatapara8

    // ------------------------------------------------------------------------
    // 2.   L = t*L

    pop {R14}
    LDR     R2, =LTable
    MOV     R0, R8
    BL      isw_mult

    // ------------------------------------------------------------------------
    // 3.   w = w^L

    MOV     R12, #0
loopXorWLpara8:	
    LDR     R5, [R2, R12, LSL #2]
    LDR     R4, [R6, R12, LSL #2]
    EOR     R4, R5
    STR     R4, [R6, R12, LSL #2]
    // loop XWL processing
    ADD     R12, #1
    CMP     R12, #NBSHARES
    BNE     loopXorWLpara8

    // ------------------------------------------------------------------------
    // 4.   w = w^14

    MOV     R0, R6
    LDR     R1, =wTable
    BL      sec_inv

    // ------------------------------------------------------------------------
    // 5.   H = w*H

    MOV     R0, R1
    MOV     R2, R8
    MOV     R1, R9
    BL      isw_mult

    // ------------------------------------------------------------------------
    // 6.   L = w*t

    LDR     R2, =LTable
    LDR     R1, =tTable
    BL      isw_mult

    // ------------------------------------------------------------------------
    // 7.   y = T6[H||L]

    pop {R7}
    MOV     R1, R7
    LDR     R10, =T6Table
    MOV     R12, #0
loopJoinDatapara8:	
    LDR     R5, [R8, R12, LSL #2]
    LDR     R4, [R2, R12, LSL #2]
    AND     R6, R4, #((1<<4)-1)
    AND     R7, R5, #((1<<4)-1)
    EOR     R3, R6, R7, LSL #4
    LDRB    R3, [R10, R3]
    AND     R6, R4, #(((1<<4)-1)<<4)
    AND     R7, R5, #(((1<<4)-1)<<4)
    EOR     R9, R6, R7, LSL #4
    LDRB    R9, [R10, R9, LSR #4]
    EOR     R3, R3, R9, LSL #8
    AND     R6, R4, #(((1<<4)-1)<<8)
    AND     R7, R5, #(((1<<4)-1)<<8)
    EOR     R9, R6, R7, LSL #4
    LDRB    R9, [R10, R9, LSR #8]
    EOR     R3, R3, R9, LSL #16
    AND     R6, R4, #(((1<<4)-1)<<12)
    AND     R7, R5, #(((1<<4)-1)<<12)
    EOR     R9, R6, R7, LSL #4
    LDRB    R9, [R10, R9, LSR #12]
    EOR     R3, R3, R9, LSL #24
    STR     R3, [R1, R12, LSL #3]
    ADD     R11, R1, #4
    AND     R6, R4, #(((1<<4)-1)<<16)
    AND     R7, R5, #(((1<<4)-1)<<16)
    EOR     R3, R6, R7, LSL #4
    LDRB    R3, [R10, R3, LSR #16]
    AND     R6, R4, #(((1<<4)-1)<<20)
    AND     R7, R5, #(((1<<4)-1)<<20)
    EOR     R9, R6, R7, LSL #4
    LDRB    R9, [R10, R9, LSR #20]
    EOR     R3, R3, R9, LSL #8
    AND     R6, R4, #(((1<<4)-1)<<24)
    AND     R7, R5, #(((1<<4)-1)<<24)
    EOR     R9, R6, R7, LSL #4
    LDRB    R9, [R10, R9, LSR #24]
    EOR     R3, R3, R9, LSL #16
    LSR     R6, R4, #28
    LSR     R7, R5, #28
    EOR     R9, R6, R7, LSL #4
    LDRB    R9, [R10, R9]
    EOR     R3, R3, R9, LSL #24
    STR     R3, [R11, R12, LSL #3]
    // loop JD processing
    ADD     R12, #1
    CMP     R12, #NBSHARES
    BNE     loopJoinDatapara8

    // ------------------------------------------------------------------------
    // 8.   y_0 = y_0^((1&NBSHARES)*0x63)

    LDR     R3, [R1]
    MOV     R5, #1
    BIC     R5, R5, #NBSHARES
    MOV     R6, #0x63
    EOR     R6, R6, R6, LSL #8
    EOR     R6, R6, R6, LSL #16
    MUL     R4, R5, R6
    EOR     R3, R4
    STR     R3, [R1]
    LDR     R3, [R11]
    EOR     R3, R4
    STR     R3, [R11]

#endif

    pop {R2-R12, LR}
    BX      LR



///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                 Temporary tables for KHL evaluation                       //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////


.data
HTable:
	.zero (NBSHARES*4)
LTable:
	.zero (NBSHARES*4)
tmpTable:
	.zero (NBSHARES*4)
tTable:
	.zero (NBSHARES*4)
tmpwTable:
	.zero (NBSHARES*4)
wTable:
	.zero (NBSHARES*4)
zTable:
	.zero (NBSHARES*4)

    
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                            KHL look-up tables                             //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////

    
.data
T1Table:	
    .byte 0x00,0x01,0x03,0x02,0x06,0x07,0x05,0x04,0x0D,0x0C,0x0E,0x0F,0x0B,0x0A,0x08,0x09
T2Table:	
    .byte 0x00,0x01,0x02,0x03,0x05,0x04,0x07,0x06,0x0A,0x0B,0x08,0x09,0x0F,0x0E,0x0D,0x0C
cprrTable:	
    .byte 0x00,0x01,0x01,0x01,0x0E,0x0D,0x08,0x0A,0x0E,0x0A,0x0D,0x08,0x0E,0x08,0x0A,0x0D
T3Table:	
    .byte 0x00,0x0C,0x08,0x04,0x09,0x05,0x01,0x0D,0x07,0x0B,0x0F,0x03,0x0E,0x02,0x06,0x0A
T4Table:	
    .byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
    .byte 0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,0x0E,0x0F
    .byte 0x00,0x02,0x03,0x01,0x08,0x0A,0x0B,0x09,0x0C,0x0E,0x0F,0x0D,0x04,0x06,0x07,0x05
    .byte 0x00,0x03,0x01,0x02,0x0C,0x0F,0x0D,0x0E,0x04,0x07,0x05,0x06,0x08,0x0B,0x09,0x0A
    .byte 0x00,0x04,0x08,0x0C,0x06,0x02,0x0E,0x0A,0x0B,0x0F,0x03,0x07,0x0D,0x09,0x05,0x01
    .byte 0x00,0x05,0x0A,0x0F,0x02,0x07,0x08,0x0D,0x03,0x06,0x09,0x0C,0x01,0x04,0x0B,0x0E
    .byte 0x00,0x06,0x0B,0x0D,0x0E,0x08,0x05,0x03,0x07,0x01,0x0C,0x0A,0x09,0x0F,0x02,0x04
    .byte 0x00,0x07,0x09,0x0E,0x0A,0x0D,0x03,0x04,0x0F,0x08,0x06,0x01,0x05,0x02,0x0C,0x0B
    .byte 0x00,0x08,0x0C,0x04,0x0B,0x03,0x07,0x0F,0x0D,0x05,0x01,0x09,0x06,0x0E,0x0A,0x02
    .byte 0x00,0x09,0x0E,0x07,0x0F,0x06,0x01,0x08,0x05,0x0C,0x0B,0x02,0x0A,0x03,0x04,0x0D
    .byte 0x00,0x0A,0x0F,0x05,0x03,0x09,0x0C,0x06,0x01,0x0B,0x0E,0x04,0x02,0x08,0x0D,0x07
    .byte 0x00,0x0B,0x0D,0x06,0x07,0x0C,0x0A,0x01,0x09,0x02,0x04,0x0F,0x0E,0x05,0x03,0x08
    .byte 0x00,0x0C,0x04,0x08,0x0D,0x01,0x09,0x05,0x06,0x0A,0x02,0x0E,0x0B,0x07,0x0F,0x03
    .byte 0x00,0x0D,0x06,0x0B,0x09,0x04,0x0F,0x02,0x0E,0x03,0x08,0x05,0x07,0x0A,0x01,0x0C
    .byte 0x00,0x0E,0x07,0x09,0x05,0x0B,0x02,0x0C,0x0A,0x04,0x0D,0x03,0x0F,0x01,0x08,0x06
    .byte 0x00,0x0F,0x05,0x0A,0x01,0x0E,0x04,0x0B,0x02,0x0D,0x07,0x08,0x03,0x0C,0x06,0x09
T5Table:	
    .byte 0x00,0x01,0x5F,0x5E,0x7C,0x7D,0x23,0x22,0x74,0x75,0x2B,0x2A,0x08,0x09,0x57,0x56
    .byte 0x46,0x47,0x19,0x18,0x3A,0x3B,0x65,0x64,0x32,0x33,0x6D,0x6C,0x4E,0x4F,0x11,0x10
    .byte 0xB0,0xB1,0xEF,0xEE,0xCC,0xCD,0x93,0x92,0xC4,0xC5,0x9B,0x9A,0xB8,0xB9,0xE7,0xE6
    .byte 0xF6,0xF7,0xA9,0xA8,0x8A,0x8B,0xD5,0xD4,0x82,0x83,0xDD,0xDC,0xFE,0xFF,0xA1,0xA0
    .byte 0x4B,0x4A,0x14,0x15,0x37,0x36,0x68,0x69,0x3F,0x3E,0x60,0x61,0x43,0x42,0x1C,0x1D
    .byte 0x0D,0x0C,0x52,0x53,0x71,0x70,0x2E,0x2F,0x79,0x78,0x26,0x27,0x05,0x04,0x5A,0x5B
    .byte 0xFB,0xFA,0xA4,0xA5,0x87,0x86,0xD8,0xD9,0x8F,0x8E,0xD0,0xD1,0xF3,0xF2,0xAC,0xAD
    .byte 0xBD,0xBC,0xE2,0xE3,0xC1,0xC0,0x9E,0x9F,0xC9,0xC8,0x96,0x97,0xB5,0xB4,0xEA,0xEB
    .byte 0xFC,0xFD,0xA3,0xA2,0x80,0x81,0xDF,0xDE,0x88,0x89,0xD7,0xD6,0xF4,0xF5,0xAB,0xAA
    .byte 0xBA,0xBB,0xE5,0xE4,0xC6,0xC7,0x99,0x98,0xCE,0xCF,0x91,0x90,0xB2,0xB3,0xED,0xEC
    .byte 0x4C,0x4D,0x13,0x12,0x30,0x31,0x6F,0x6E,0x38,0x39,0x67,0x66,0x44,0x45,0x1B,0x1A
    .byte 0x0A,0x0B,0x55,0x54,0x76,0x77,0x29,0x28,0x7E,0x7F,0x21,0x20,0x02,0x03,0x5D,0x5C
    .byte 0xB7,0xB6,0xE8,0xE9,0xCB,0xCA,0x94,0x95,0xC3,0xC2,0x9C,0x9D,0xBF,0xBE,0xE0,0xE1
    .byte 0xF1,0xF0,0xAE,0xAF,0x8D,0x8C,0xD2,0xD3,0x85,0x84,0xDA,0xDB,0xF9,0xF8,0xA6,0xA7
    .byte 0x07,0x06,0x58,0x59,0x7B,0x7A,0x24,0x25,0x73,0x72,0x2C,0x2D,0x0F,0x0E,0x50,0x51
    .byte 0x41,0x40,0x1E,0x1F,0x3D,0x3C,0x62,0x63,0x35,0x34,0x6A,0x6B,0x49,0x48,0x16,0x17
T6Table:	
    .byte 0x63,0x7C,0x7A,0x65,0xCE,0xD1,0xD7,0xC8,0xE7,0xF8,0xFE,0xE1,0x4A,0x55,0x53,0x4C
    .byte 0x37,0x28,0x2E,0x31,0x9A,0x85,0x83,0x9C,0xB3,0xAC,0xAA,0xB5,0x1E,0x01,0x07,0x18
    .byte 0x27,0x38,0x3E,0x21,0x8A,0x95,0x93,0x8C,0xA3,0xBC,0xBA,0xA5,0x0E,0x11,0x17,0x08
    .byte 0x73,0x6C,0x6A,0x75,0xDE,0xC1,0xC7,0xD8,0xF7,0xE8,0xEE,0xF1,0x5A,0x45,0x43,0x5C
    .byte 0x26,0x39,0x3F,0x20,0x8B,0x94,0x92,0x8D,0xA2,0xBD,0xBB,0xA4,0x0F,0x10,0x16,0x09
    .byte 0x72,0x6D,0x6B,0x74,0xDF,0xC0,0xC6,0xD9,0xF6,0xE9,0xEF,0xF0,0x5B,0x44,0x42,0x5D
    .byte 0x62,0x7D,0x7B,0x64,0xCF,0xD0,0xD6,0xC9,0xE6,0xF9,0xFF,0xE0,0x4B,0x54,0x52,0x4D
    .byte 0x36,0x29,0x2F,0x30,0x9B,0x84,0x82,0x9D,0xB2,0xAD,0xAB,0xB4,0x1F,0x00,0x06,0x19
    .byte 0x90,0x8F,0x89,0x96,0x3D,0x22,0x24,0x3B,0x14,0x0B,0x0D,0x12,0xB9,0xA6,0xA0,0xBF
    .byte 0xC4,0xDB,0xDD,0xC2,0x69,0x76,0x70,0x6F,0x40,0x5F,0x59,0x46,0xED,0xF2,0xF4,0xEB
    .byte 0xD4,0xCB,0xCD,0xD2,0x79,0x66,0x60,0x7F,0x50,0x4F,0x49,0x56,0xFD,0xE2,0xE4,0xFB
    .byte 0x80,0x9F,0x99,0x86,0x2D,0x32,0x34,0x2B,0x04,0x1B,0x1D,0x02,0xA9,0xB6,0xB0,0xAF
    .byte 0xD5,0xCA,0xCC,0xD3,0x78,0x67,0x61,0x7E,0x51,0x4E,0x48,0x57,0xFC,0xE3,0xE5,0xFA
    .byte 0x81,0x9E,0x98,0x87,0x2C,0x33,0x35,0x2A,0x05,0x1A,0x1C,0x03,0xA8,0xB7,0xB1,0xAE
    .byte 0x91,0x8E,0x88,0x97,0x3C,0x23,0x25,0x3A,0x15,0x0A,0x0C,0x13,0xB8,0xA7,0xA1,0xBE
    .byte 0xC5,0xDA,0xDC,0xC3,0x68,0x77,0x71,0x6E,0x41,0x5E,0x58,0x47,0xEC,0xF3,0xF5,0xEA
        

