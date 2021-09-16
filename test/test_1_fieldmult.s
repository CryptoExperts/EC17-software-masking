#include "../param.h"
#include "../src/1_fieldmult.S"	
	
.text
.syntax unified	


.pool	
.global multiplication_func
multiplication_func:	
	push {R3-R12, LR}
	
#if MULT_MODE!=BINMULT1
	LDR		R3, =multTable
#endif
		
#if MULT_MODE==BINMULT1
	multiplication	R0,R1,R2,R3,R4,R5,R6,label_binmult1
	
#elif MULT_MODE==BINMULT2
	multiplication	R0,R1,R2,R3,R4,R5,R6,label_binmult2
	
#elif MULT_MODE==EXPLOG1
	multiplication	R0,R1,R2,R3,R4,R5
	
#elif MULT_MODE==EXPLOG2
	multiplication	R0,R1,R2,R3,R4,R5
	
#elif MULT_MODE== KARA
	multiplication	R0,R1,R2,R3,R4,R5,R6
	
#elif MULT_MODE==HALFTAB
	multiplication	R0,R1,R2,R3,R4	
	
#elif MULT_MODE==FULLTAB
	multiplication	R0,R1,R2,R3,R4
	
#endif
	
	MOV		R0, R2
	
	
	pop	{R3-R12, LR}
	BX	LR
