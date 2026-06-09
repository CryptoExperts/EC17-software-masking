.text

.syntax unified
#ifdef __thumb2__
.thumb
#endif

.pool
isw_and:	
    push {R10-R12, LR}
    LDR     R7, =RNGReg
    // c_i = a_i AND b_i
    MOV     R12, #0
loop0and:	
    ADD     R4, R0, R12, LSL #2
    LDR     R4, [R4]
    ADD     R5, R1, R12, LSL #2
    LDR     R5, [R5]
    AND     R6, R4, R5
    STR R6, [R2, R12, LSL #2]
    // loop 0 processing
    ADD     R12, R12, #1
    CMP     R12, #NBSHARES
    BNE     loop0and
    // nested loops
    MOV     R12, #0
loop1iswand:	
    ADD     R11, R12, #1
loop2iswand:	
    // s <-$ F
    get_random R3,R7
    // c_i += s
    ADD     R6, R2, R12, LSL #2
    LDR     R6, [R6]
    EOR     R6, R3
    STR R6, [R2, R12, LSL #2]
    // s' += a_i AND b_j
    ADD     R4, R0, R12, LSL #2
    LDR     R4, [R4]
    ADD     R5, R1, R11, LSL #2
    LDR     R5, [R5]
    AND     R6, R4, R5
    EOR     R3, R6
    // s' += a_j AND b_i
    ADD     R4, R0, R11, LSL #2
    LDR     R4, [R4]
    ADD     R5, R1, R12, LSL #2
    LDR     R5, [R5]
    AND     R6, R4, R5
    EOR     R3, R6
    // c_j += s'
    ADD     R6, R2, R11, LSL #2
    LDR     R6, [R6]
    EOR     R6, R3
    STR R6, [R2, R11, LSL #2]
    // loop 2 processing
    ADD     R11, R11, #1
    CMP     R11, #NBSHARES
    BNE     loop2iswand
    // loop 1 processing
    ADD     R12, R12, #1
    CMP     R12, #(NBSHARES-1)
    BNE     loop1iswand

    pop {R10-R12, LR}
    BX LR
