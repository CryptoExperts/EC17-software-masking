#include "../param.h"
#include "../src/random.S"
#include "../src/2_secmult_cprr.S"
#include "../src/3_secsbox_fog.S"
#include "../src/4_seccipher_regpresent.S"

.text
.syntax unified

.pool
.global regpresent_test	
regpresent_test:	
	push {R2-R12, LR}
	BL	regpresent_encrypt
	pop  {R2-R12, LR}
	BX	LR
