#include "../param.h"
#include "../src/random.S"
#include "../src/2_secmult_cprr.S"
#include "../src/3_secsbox_fog.S"
	
.text

.syntax unified
#ifdef __thumb2__
.thumb	
#endif

.pool
#ifdef __thumb2__
.thumb_func
#endif
.type   fog_test, %function
.global fog_test	
fog_test:	
	push {R2-R12, LR}
	BL fog_sbox
	pop {R2-R12, LR}
	BX	LR
