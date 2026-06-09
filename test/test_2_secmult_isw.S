#include "../param.h"
#include "../src/random.S"
#include "../src/2_secmult_isw.S"
		
.text

.syntax unified
#ifdef __thumb2__
.thumb	
#endif

.pool
#ifdef __thumb2__
.thumb_func
#endif
.type   isw_test, %function
.global isw_test	
isw_test:	
	push {R3-R12, LR}
	BL	isw_mult	
	pop {R3-R12, LR}
	BX	LR
