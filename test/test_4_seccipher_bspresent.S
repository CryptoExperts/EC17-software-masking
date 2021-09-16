#include "../param.h"
#include "../src/random.S"
#include "../src/3_secsbox_bspresent.S"
#include "../src/4_seccipher_bspresent.S"	
	
.text
.syntax unified

.pool
.global bspresent_test	
bspresent_test:	
	push {R2-R12, LR}
	BL	bspresent_encrypt
	pop {R2-R12, LR}
	BX	LR
