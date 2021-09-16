#include "../param.h"
#include "../src/random.S"
#include "../src/2_secmult_cprr.S"
#include "../src/2_secmult_isw.S"
#include "../src/3_secsbox_khl.S"

.text
.syntax unified

.pool
.global khl_test	
khl_test:	
	push {R2-R12, LR}
	BL	khl_sbox
	pop {R2-R12, LR}
	BX	LR
