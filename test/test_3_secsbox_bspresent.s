#include "../param.h"
#include "../src/random.S"
#include "../src/3_secsbox_bspresent.S"

.text
.syntax unified

.pool	
.global bspresent_test	
bspresent_test:	
	push {R2-R12, LR}
	BL	bspresent_sbox	
	pop {R2-R12, LR}
	BX  LR
