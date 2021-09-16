#include "2_secmult_refresh.S"
#include "2_secmult_iswand.S"
    
.text


///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                        UTILITY MACROS AND FUNCTIONS                       //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////

    // ------------------------------------------------------------------------
    // Xor two values and store it

.macro    xor_and_store dst, inA, inB, addr, shift
    EOR     \dst, \inA, \inB
    STR     \dst, [\addr, #\shift]
.endm

    // ------------------------------------------------------------------------
    // Load a value and xor two others

.macro    load_and_xor src, dst, inA, inB, addr, shift
    LDR     \src, [\addr, #\shift]
    EOR     \dst, \inA, \inB
.endm

    // ------------------------------------------------------------------------
    // Load the adress of an intermediate variable

.macro    load_address dst, src, shift
    ADD     \dst, \src, #\shift&0XFF
    ADD     \dst, #\shift&0XFF00
.endm

    // ------------------------------------------------------------------------
    // Load a value, xor it with an other and store the result

.macro    load_xor_and_store dst, inA, inB, addr, shiftA, shiftD
    LDR     \inA, [\addr, #\shiftA]
    EOR     \dst, \inA, \inB
    STR     \dst, [\addr, #\shiftD]
.endm
    
    
    // ------------------------------------------------------------------------
    // Pack two 16 bit values into one register


.pool   
join_data:	
   push {LR}

.set current_shares, 0
.rept NBSHARES
    LDR     R4, [R7, #current_shares*4]
    LDR     R5, [R8, #current_shares*4]
    EOR     R4, R4, R5, LSL #16
    STR     R4, [R0, #current_shares*4]
    // 
    LDR     R4, [R10, #current_shares*4]
    LDR     R5, [R11, #current_shares*4]
    EOR     R4, R4, R5, LSL #16
    STR     R4, [R1, #current_shares*4]
.set current_shares,current_shares+1
.endr

   pop {LR}
   BX LR

	

	
    // ------------------------------------------------------------------------
    // Split a 32 bit register into two 16 bit values

.pool
fork_data:	
    push {LR}
	
.set current_shares, 0
.rept NBSHARES
    LDR     R4, [R2, #(current_shares)*4]
    LSL     R5, R4, #16
    LSR     R5, #16
    LSR     R6, R4, #16
    STR     R5, [R10, #(current_shares)*4]
    STR     R6, [R11, #(current_shares)*4]
.set current_shares,current_shares+1
.endr
    
    pop {LR}
    BX  LR

    

///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                      Bitslice AES sbox evaluation                         //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////

.pool    
bsaes_sbox:	
    push {R2-R12, LR}
    push {R1}

    // ------------------------------------------------------------------------
    // BEGIN TopLinearForm

    LDR     R12, =intermediatevariableTables
    // Store X7 as an IV
    MOV     R14, #0
loopStoreX7:	
    LDR     R8, [R0]
    load_address R10,R12,addrX7
    STR     R8, [R10, R14, LSL #2]
    ADD     R0, #8*4
    // 
    ADD     R14, #1
    CMP     R14, #NBSHARES
    BNE     loopStoreX7
    SUB     R0, #8*4*NBSHARES
    
    MOV     R14, #0
loopOverShareTLF:	
    LDR     R8, [R0, #28]
    LDR     R1, [R0, #24]
    LDR     R2, [R0, #20]
    LDR     R3, [R0, #16]
    LDR     R4, [R0, #12]
    LDR     R5, [R0, #8]
    LDR     R6, [R0, #4]
    LDR     R7, [R0]
    // NB: X0 = R8
    // y14 = x3 + x5    
    xor_and_store R9,R3,R5,R12,addrY14
    // y13 = x0 + x6
    xor_and_store R10,R8,R6,R12,addrY13
    // y12 = y13+y14
    xor_and_store R10,R9,R10,R12,addrY12
    // y9 = x0 + x3
    xor_and_store R9,R8,R3,R12,addrY9
    // y8 = x0 + x5
    xor_and_store R9,R8,R5,R12,addrY8
    // t0 = x1 + x2 
    EOR     R2, R1, R2
    // y1 = t0 + x7
    xor_and_store R9,R2,R7,R12,addrY1
    // y4 = y1 + x3
    xor_and_store R9,R9,R3,R12,addrY4
    EOR     R3, R9, R3
    // y2 = y1 + x0
    xor_and_store R9,R3,R8,R12,addrY2
    // y5 = y1 + x6
    xor_and_store R6,R3,R6,R12,addrY5
    // t1 = x4 + y12
    EOR     R3, R4, R10
    // y3 = y5 + y8
    LDR     R4, [R12, #addrY8]
    xor_and_store R9,R6,R4,R12,addrY3
    // y15 = t1 + x5
    xor_and_store R5,R3,R5,R12,addrY15
    // y20 = t1 + x1
    xor_and_store R1,R3,R1,R12,addrY20
    // y6 = y15 +x7
    xor_and_store R9,R5,R7,R12,addrY6
    // y10 = y15 + t0
    xor_and_store R6,R5,R2,R12,addrY10
    // y11 = y20 + y9
    LDR     R9, [R12, #addrY9]
    xor_and_store R10,R1,R9,R12,addrY11
    // y7 = x7 + y11
    xor_and_store R9,R7,R10,R12,addrY7
    // y17 = y10 + y11
    xor_and_store R9,R6,R10,R12,addrY17
    // y19 = y10 + y8
    xor_and_store R9,R6,R4,R12,addrY19
    // y16 = t0 + y11
    xor_and_store R6,R2,R10,R12,addrY16
    // y21 = y13 + y16
    LDR     R2, [R12, #addrY13]
    xor_and_store R9,R2,R6,R12,addrY21
    // y18 = x0 + y16
    xor_and_store R9,R8,R6,R12,addrY18
    // Address update
    ADD     R12, #4
    ADD     R0, #8*4
    // loop TopLinearForm processing
    ADD     R14, #1
    CMP     R14, #NBSHARES
    BNE     loopOverShareTLF
    // Address update
    SUB     R12, #4*NBSHARES
    
    // END TopLinearForm

    // ------------------------------------------------------------------------
    // BEGIN MiddleTransformation

    LDR     R0, =tmpOpA
    LDR     R1, =tmpOpB
    LDR     R2, =tmpResAnd
    // t2=y12&y15, t3= y3&y6
    load_address R7,R12,addrY12
    load_address R8,R12,addrY3
    load_address R10,R12,addrY15
    load_address R11,R12,addrY6
    BL      join_data
    BL      refresh_mask
    BL      isw_and
    load_address R10,R12,addrT2
    load_address R11,R12,addrT3
    BL      fork_data
    // t5=y4&x7, t7=y13&y16
    load_address R7,R12,addrY4
    load_address R8,R12,addrY13
    load_address R10,R12,addrX7
    load_address R11,R12,addrY16
    BL      join_data
    BL      refresh_mask
    BL      isw_and
    load_address R10,R12,addrT5
    load_address R11,R12,addrT7
    BL      fork_data   
    // t8=y5&y1, t10=y2&y7
    load_address R7,R12,addrY5
    load_address R8,R12,addrY2
    load_address R10,R12,addrY1
    load_address R11,R12,addrY7
    BL      join_data
    BL      refresh_mask
    BL      isw_and
    load_address R10,R12,addrT8
    load_address R11,R12,addrT10
    BL      fork_data   
    // t12=y9&y11, t13=y14&y17
    load_address R7,R12,addrY9
    load_address R8,R12,addrY14
    load_address R10,R12,addrY11
    load_address R11,R12,addrY17
    BL      join_data
    BL      refresh_mask
    BL      isw_and
    load_address R10,R12,addrT12
    load_address R11,R12,addrT13
    BL      fork_data
    // First series of XOR in between multiplications
    MOV     R14, #0
loopXOR1:	
    // t4 = t3 + t2
    LDR     R4, [R12, #addrT3]
    load_xor_and_store R4,R5,R4,R12,addrT2,addrT4
    // t6 = t5 + t2
    load_xor_and_store R6,R6,R5,R12,addrT5,addrT6
    // t9 = t8 + t7
    LDR     R5, [R12, #addrT8]
    load_xor_and_store R5,R6,R5,R12,addrT7,addrT9
    // t11 = t10 + t7
    load_xor_and_store R8,R8,R6,R12,addrT10,addrT11
    // t14 = t13 + t12
    LDR     R6, [R12, #addrT13]
    load_xor_and_store R6,R8,R6,R12,addrT12,addrT14
    // t17 = t4 + t14
    xor_and_store R3,R4,R6,R12,addrT17
    // t19 = t9 + t14
    xor_and_store R4,R5,R6,R12,addrT19
    // t21 = t17 + y20
    load_xor_and_store R5,R5,R3,R12,addrY20,addrT21
    // t23 = t19 + y21
    load_xor_and_store R6,R6,R4,R12,addrY21,addrT23
    // address update
    ADD     R12, #4
    // loop processing
    ADD     R14, #1
    CMP     R14, #NBSHARES
    BNE     loopXOR1
    // address reset
    SUB     R12, #4*NBSHARES
    // t15=y8&y10, t26=t21&t23
    load_address R7,R12,addrY8
    load_address R8,R12,addrT21
    load_address R10,R12,addrY10
    load_address R11,R12,addrT23
    BL      join_data
    BL      refresh_mask
    BL      isw_and
    load_address R10,R12,addrT15
    load_address R11,R12,addrT26
    BL      fork_data
    // Second series of XOR in between multiplications
    MOV     R14, #0
loopXOR2:	
    // t16 = t15 + t12
    LDR     R3, [R12, #addrT15]
    load_xor_and_store R3,R4,R3,R12,addrT12,addrT16
    // t18 = t6 + t16
    load_xor_and_store R4,R4,R3,R12,addrT6,addrT18
    // t20 = t11 + t16
    load_xor_and_store R5,R5,R3,R12,addrT11,addrT20
    // t24 = t20 + y18
    load_xor_and_store R3,R3,R5,R12,addrY18,addrT24
    // t30 = t23 + t24
    load_xor_and_store R5,R5,R3,R12,addrT23,addrT30
    // t22 = t18 + y19
    load_xor_and_store R5,R5,R4,R12,addrY19,addrT22
    // t25 = t21 + t22
    load_xor_and_store R6,R6,R5,R12,addrT21,addrT25
    // t27 = t24 + t26
    load_xor_and_store R3,R6,R3,R12,addrT26,addrT27
    // t31 = t22 + t26
    xor_and_store R5,R5,R6,R12,addrT31
    // address update
    ADD     R12, #4
    // loop processing
    ADD     R14, #1
    CMP     R14, #NBSHARES
    BNE     loopXOR2
    // address reset
    SUB     R12, #4*NBSHARES
    // t28=t25&t27,t32=t31&t30
    load_address R7,R12,addrT25
    load_address R8,R12,addrT31
    load_address R10,R12,addrT27
    load_address R11,R12,addrT30
    BL      join_data
    BL      refresh_mask
    BL      isw_and
    load_address R10,R12,addrT28
    load_address R11,R12,addrT32
    BL      fork_data
    // Third series of XOR in between multiplications
    MOV     R14, #0
loopXOR3:	
    // t29= t28 + t22
    LDR     R3, [R12, #addrT28]
    load_xor_and_store R3,R4,R3,R12,addrT22,addrT29
    // t33 = t32 + t24
    LDR     R4, [R12, #addrT32]
    load_xor_and_store R4,R5,R4,R12,addrT24,addrT33
    // t34 = t23 + t33
    load_xor_and_store R5,R5,R4,R12,addrT23,addrT34
    // t35 = t27 + t33
    load_xor_and_store R5,R5,R4,R12,addrT27,addrT35
    // t42 = t29 + t33
    xor_and_store R3,R3,R4,R12,addrT42
    // address update
    ADD     R12, #4
    // loop processing
    ADD     R14, #1 
    CMP     R14, #NBSHARES
    BNE     loopXOR3
    // addres reset
    SUB     R12, #4*NBSHARES
    // z14=t29&y2, t36=t24&t35
    load_address R7,R12,addrT29
    load_address R8,R12,addrT24
    load_address R10,R12,addrY2
    load_address R11,R12,addrT35
    BL      join_data
    BL      refresh_mask
    BL      isw_and
    load_address R10,R12,addrZ14
    load_address R11,R12,addrT36
    BL      fork_data
    // Fourth series of XOR in between multiplications
    MOV     R14, #0
loopXOR4:	
    // t37 = t36 + t34
    LDR     R3, [R12, #addrT36]
    load_xor_and_store R4,R4,R3,R12,addrT34,addrT37
    // t38 = t27 + t36
    load_xor_and_store R4,R4,R3,R12,addrT27,addrT38
    ADD     R12, #4
    // loop XOR4 processing
    ADD     R14, #1
    CMP     R14, #NBSHARES
    BNE     loopXOR4
    // address update
    SUB     R12, #4*NBSHARES
    // t39=t29&t38,z5=t29&y7
    load_address R7,R12,addrT29
    load_address R8,R12,addrT29
    load_address R10,R12,addrT38
    load_address R11,R12,addrY7
    BL      join_data
    BL      refresh_mask
    BL      isw_and
    load_address R10,R12,addrT39
    load_address R11,R12,addrZ5
    BL      fork_data
    // Fifth series of XOR in between multiplications
    MOV     R14, #0
loopXOR5:	
    // t44 = t33 + t37
    LDR     R3, [R12, #addrT33]
    load_xor_and_store R3,R4,R3,R12,addrT37,addrT44
    // t40 = t25 + t39
    LDR     R3, [R12, #addrT25]
    load_xor_and_store R3,R5,R3,R12,addrT39,addrT40
    // t41 = t40 + t37
    xor_and_store R4,R3,R4,R12,addrT41
    // t43 = t29 + t40
    load_xor_and_store R5,R5,R3,R12,addrT29,addrT43
    // t45 = t42 + t41
    load_xor_and_store R4,R3,R4,R12,addrT42,addrT45
    // address update
    ADD     R12, #4 
    // loop processing
    ADD     R14, #1
    CMP     R14, #NBSHARES
    BNE     loopXOR5
    // adress reset
    SUB     R12, #4*NBSHARES
    // z0=t44&y15,z1=t37&y6
    load_address R7,R12,addrT44
    load_address R8,R12,addrT37
    load_address R10,R12,addrY15
    load_address R11,R12,addrY6
    BL      join_data
    BL      refresh_mask
    BL      isw_and
    load_address R10,R12,addrZ0
    load_address R11,R12,addrZ1
    BL      fork_data
    // z9=t44&y12,z10=t37&y3
    load_address R7,R12,addrT44
    load_address R8,R12,addrT37
    load_address R10,R12,addrY12
    load_address R11,R12,addrY3
    BL      join_data
    BL      refresh_mask
    BL      isw_and
    load_address R10,R12,addrZ9
    load_address R11,R12,addrZ10
    BL      fork_data
    // z4=t40&y1,z6=t42&y11 
    load_address R7,R12,addrT40
    load_address R8,R12,addrT42
    load_address R10,R12,addrY1
    load_address R11,R12,addrY11
    BL      join_data
    BL      refresh_mask
    BL      isw_and
    load_address R10,R12,addrZ4
    load_address R11,R12,addrZ6
    BL      fork_data
    // z13=t40&y5, z15=t42&y9
    load_address R7,R12,addrT40
    load_address R8,R12,addrT42
    load_address R10,R12,addrY5
    load_address R11,R12,addrY9
    BL      join_data
    BL      refresh_mask
    BL      isw_and
    load_address R10,R12,addrZ13
    load_address R11,R12,addrZ15
    BL      fork_data
    // z7=t45&y17, z8=t41&y10
    load_address R7,R12,addrT45
    load_address R8,R12,addrT41
    load_address R10,R12,addrY17
    load_address R11,R12,addrY10
    BL      join_data
    BL      refresh_mask
    BL      isw_and
    load_address R10,R12,addrZ7
    load_address R11,R12,addrZ8
    BL      fork_data
    // z16=t45&y14, z17=t41&y8
    load_address R7,R12,addrT45
    load_address R8,R12,addrT41
    load_address R10,R12,addrY14
    load_address R11,R12,addrY8
    BL      join_data
    BL      refresh_mask
    BL      isw_and
    load_address R10,R12,addrZ16
    load_address R11,R12,addrZ17
    BL      fork_data
    // z11=t33&y4,z12=t43&y13
    load_address R7,R12,addrT33
    load_address R8,R12,addrT43
    load_address R10,R12,addrY4
    load_address R11,R12,addrY13
    BL      join_data
    BL      refresh_mask
    BL      isw_and
    load_address R10,R12,addrZ11
    load_address R11,R12,addrZ12
    BL      fork_data
    // z2=t33&x7, z3=t43&y16
    load_address R7,R12,addrT33
    load_address R8,R12,addrT43
    load_address R10,R12,addrX7
    load_address R11,R12,addrY16
    BL      join_data
    BL      refresh_mask
    BL      isw_and
    load_address R10,R12,addrZ2
    load_address R11,R12,addrZ3
    BL      fork_data
    
    // END MiddleTransformation

    // ------------------------------------------------------------------------
    // BEGIN BottomLinearForm

    MOV     R14, #0
loopOverShareBLF:	
    // t46 = z15 + z16
    LDR     R4, [R12, #addrZ15]
    load_and_xor R5,R4,R4,R5,R12,addrZ16
    // t55 = z16 + z17
    load_and_xor R3,R5,R5,R3,R12,addrZ17
    // t52 = z7 + z8
    LDR     R3, [R12, #addrZ7]
    load_and_xor R2,R2,R2,R3,R12,addrZ8
    // t54 = z6 + z7
    load_and_xor R1,R3,R3,R1,R12,addrZ6
    // t58 = z4 + t46
    load_and_xor R0,R6,R0,R4,R12,addrZ4
    // t59 = z3 + t54
    load_and_xor R1,R3,R3,R1,R12,addrZ3
    // t64 = z4 + t59
    EOR     R7, R0, R3
    // t47 = z10 + z11
    LDR     R0, [R12, #addrZ10]
    load_and_xor R8,R8,R8,R0,R12,addrZ11
    // t49 = z9 + z10
    load_and_xor R9,R9,R9,R0,R12,addrZ9
    // t63 = t49 + t58
    EOR     R9, R6
    // t66 = z1 + t63
    load_and_xor R10,R10,R10,R9,R12,addrZ1
    // t62 = t52 + t58
    EOR     R6, R2
    // t53 = z0 + z3
    load_and_xor R11,R11,R11,R1,R12,addrZ0
    // t50 = z2 + z12
    LDR     R1, [R12, #addrZ2]
    load_and_xor R0,R2,R0,R1,R12,addrZ12
    // t57 = t50 + t53
    EOR     R2, R11
    // t60 = t46 + t57
    EOR     R4, R2
    // t61 = z14 + t57
    load_and_xor R1,R2,R2,R1,R12,addrZ14
    // t65 = t61 + t62
    EOR     R2, R6
    // s0 = t59 + t63
    EOR     R9, R3
    // t51 = z2 + z5
    LDR     R1, [R12, #addrZ5]
    load_and_xor R3,R3,R3,R1,R12,addrZ2
    // s4 = t51 + t66
    EOR     R3, R10
    // s5 = t47 + t65
    EOR     R8, R2
    // t67 = t64 + t65
    EOR     R2, R7
    // s2 = t55 + t67  
    EOR     R2, R5
    // t48 = z5 ^ z13
    load_and_xor R5,R5,R5,R1,R12,addrZ13
    // t56 = z12 ^ t48
    EOR     R1, R0, R5
    // s3 = t53 ^ t66
    EOR     R10, R11
    // s1 = t64 ^ s3
    EOR     R7, R10
    // s6 = t56 ^ t62
    EOR     R6, R1
    // s7 = t48 ^ t60
    EOR     R4, R5
    // storing the outputs (s0,s1,...,s7)
    pop {R1}
    STR     R9, [R1, #28]
    STR     R7, [R1, #24]
    STR     R2, [R1, #20]
    STR     R10, [R1, #16]
    STR     R3, [R1, #12]
    STR     R8, [R1, #8]
    STR     R6, [R1, #4]
    STR     R4, [R1]
    ADD     R12, #4
    ADD     R1, #8*4
    push {R1}
    // loop BottomLinearPart processing
    ADD     R14, #1
    CMP     R14, #NBSHARES
    BNE     loopOverShareBLF
    // Noting the outputs
    pop {R1}
    // Address update
    SUB     R1, #8*4*NBSHARES
    // Not(s2)
    LDR     R4, [R1, #20]
    EOR     R4, #0xFF
    EOR     R4, #0xFF00
    STR     R4, [R1, #20]
    // Not(s1)
    LDR     R4, [R1, #24]
    EOR     R4, #0xFF
    EOR     R4, #0xFF00
    STR     R4, [R1, #24]
    // Not(s6)
    LDR     R4, [R1, #4]
    EOR     R4, #0xFF
    EOR     R4, #0xFF00
    STR     R4, [R1, #4]
    // Not(s7)
    LDR     R4, [R1]
    EOR     R4, #0xFF
    EOR     R4, #0xFF00
    STR     R4, [R1]

    // END BottomLinearForm

    pop {R2-R12,LR}
    BX      LR


///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//     Temporary tables and addresses for bitslice AES sbox evaluation       //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////


.data
intermediatevariableTables:
	.zero 108*4*NBSHARES
tmpOpA:
	.zero 4*NBSHARES
tmpOpB:
	.zero 4*NBSHARES
tmpResAnd:
	.zero 4*NBSHARES

// Since EQ can not set offset greater than 4096 (when d>=10 this occurs), some addr are reused by other variables (t1 to t8 are used by t62 to t67)
.equ addrY1, 0
.equ addrY2,  4*NBSHARES   
.equ addrY3,  8*NBSHARES  
.equ addrY4,  12*NBSHARES 
.equ addrY5,  16*NBSHARES 
.equ addrY6,  20*NBSHARES 
.equ addrY7,  24*NBSHARES 
.equ addrY8,  28*NBSHARES 
.equ addrY9,  32*NBSHARES 
.equ addrY10, 36*NBSHARES 
.equ addrY11, 40*NBSHARES 
.equ addrY12, 44*NBSHARES 
.equ addrY13, 48*NBSHARES 
.equ addrY14, 52*NBSHARES 
.equ addrY15, 56*NBSHARES 
.equ addrY16, 60*NBSHARES 
.equ addrY17, 64*NBSHARES 
.equ addrY18, 68*NBSHARES 
.equ addrY19, 72*NBSHARES 
.equ addrY20, 76*NBSHARES 
.equ addrY21, 80*NBSHARES 
.equ addrZ0,  404*NBSHARES 
.equ addrZ1,  84*NBSHARES 
.equ addrZ2,  88*NBSHARES 
.equ addrZ3,  92*NBSHARES 
.equ addrZ4,  96*NBSHARES 
.equ addrZ5,  100*NBSHARES
.equ addrZ6,  104*NBSHARES
.equ addrZ7,  108*NBSHARES
.equ addrZ8,  112*NBSHARES
.equ addrZ9,  116*NBSHARES
.equ addrZ10, 120*NBSHARES
.equ addrZ11, 124*NBSHARES
.equ addrZ12, 128*NBSHARES
.equ addrZ13, 132*NBSHARES
.equ addrZ14, 136*NBSHARES
.equ addrZ15, 140*NBSHARES
.equ addrZ16, 144*NBSHARES
.equ addrZ17, 148*NBSHARES
.equ addrZ18, 152*NBSHARES
.equ addrT1,  156*NBSHARES
.equ addrT2,  160*NBSHARES
.equ addrT3,  164*NBSHARES
.equ addrT4,  168*NBSHARES
.equ addrT5,  172*NBSHARES
.equ addrT6,  176*NBSHARES
.equ addrT7,  180*NBSHARES
.equ addrT8,  184*NBSHARES
.equ addrT9,  188*NBSHARES
.equ addrT10, 192*NBSHARES
.equ addrT11, 196*NBSHARES
.equ addrT12, 200*NBSHARES
.equ addrT13, 204*NBSHARES
.equ addrT14, 208*NBSHARES
.equ addrT15, 212*NBSHARES
.equ addrT16, 216*NBSHARES
.equ addrT17, 220*NBSHARES
.equ addrT18, 224*NBSHARES
.equ addrT19, 228*NBSHARES
.equ addrT20, 232*NBSHARES
.equ addrT21, 236*NBSHARES
.equ addrT22, 240*NBSHARES
.equ addrT23, 244*NBSHARES
.equ addrT24, 248*NBSHARES
.equ addrT25, 252*NBSHARES
.equ addrT26, 256*NBSHARES
.equ addrT27, 260*NBSHARES
.equ addrT28, 264*NBSHARES
.equ addrT29, 268*NBSHARES
.equ addrT30, 272*NBSHARES
.equ addrT31, 276*NBSHARES
.equ addrT32, 280*NBSHARES
.equ addrT33, 284*NBSHARES
.equ addrT34, 288*NBSHARES
.equ addrT35, 292*NBSHARES
.equ addrT36, 296*NBSHARES
.equ addrT37, 300*NBSHARES
.equ addrT38, 304*NBSHARES
.equ addrT39, 308*NBSHARES
.equ addrT40, 312*NBSHARES
.equ addrT41, 316*NBSHARES
.equ addrT42, 320*NBSHARES
.equ addrT43, 324*NBSHARES
.equ addrT44, 328*NBSHARES
.equ addrT45, 332*NBSHARES
.equ addrT46, 336*NBSHARES
.equ addrT47, 340*NBSHARES
.equ addrT48, 344*NBSHARES
.equ addrT49, 348*NBSHARES
.equ addrT50, 352*NBSHARES
.equ addrT51, 356*NBSHARES
.equ addrT52, 360*NBSHARES
.equ addrT53, 364*NBSHARES
.equ addrT54, 368*NBSHARES
.equ addrT55, 372*NBSHARES
.equ addrT56, 376*NBSHARES
.equ addrT57, 380*NBSHARES
.equ addrT58, 384*NBSHARES
.equ addrT59, 388*NBSHARES
.equ addrT60, 392*NBSHARES
.equ addrT61, 396*NBSHARES
.equ addrT62, 156*NBSHARES
.equ addrT63, 160*NBSHARES
.equ addrT64, 164*NBSHARES
.equ addrT65, 170*NBSHARES
.equ addrT66, 174*NBSHARES
.equ addrT67, 178*NBSHARES
.equ addrX7,  400*NBSHARES    
