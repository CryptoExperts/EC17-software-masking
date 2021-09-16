#include "../param.h"
#include "../src/random.S"
#include "../src/2_secmult_cprr.S"
#include "../src/2_secmult_isw.S"
#include "../src/3_secsbox_rp.S"


.text
.syntax unified

.pool
.global rp_test	
rp_test:	
	push {R2-R12, LR}
	BL	rp_sbox
	pop {R2-R12, LR}
	BX	LR
