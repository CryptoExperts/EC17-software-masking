#include "../param.h"
#include "../src/random.S"
#include "../src/3_secsbox_bsaes.S"	
	
.text

.syntax unified
#ifdef __thumb2__
.thumb
#endif

.pool
#ifdef __thumb2__
.thumb_func
#endif
.type   bsaes_test, %function
.global bsaes_test	
bsaes_test:	
	push {R2-R12, LR}
	BL	bsaes_sbox
	pop {R2-R12, LR}
	BX	LR
