#include "../param.h"
#include "../src/random.S"
#include "../src/2_secmult_isw.S"
		
.text
.syntax unified	

.pool
.global isw_test	
isw_test:	
	push {R3-R12, LR}
	BL	isw_mult	
	pop {R3-R12, LR}
	BX	LR
