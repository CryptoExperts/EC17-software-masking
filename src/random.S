.text

.syntax unified
.thumb

		
#if RAND_MODE==TRNG

.macro	get_random rnd, pttab
	LDR		\rnd, [\pttab]
.endm
	
#elif RAND_MODE==C_RAND

.macro  get_random rnd, unused
    push {R0-R3, R12, LR}
    BL    rand
    MOV   \rnd, R0
    pop {R0-R3, R12, LR}
.endm

#endif
	
.data
RNGReg:
.word 0x4461,0x686D,0x756E,0x2047,0x6f75,0x6461,0x727a,0x6920


