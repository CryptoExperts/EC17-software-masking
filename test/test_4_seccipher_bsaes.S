#include "../param.h"
#include "../src/random.S"
#include "../src/4_seccipher_bsaes.S"	
	
.text
.syntax unified

.pool
.global bsaes_test	
bsaes_test:	
	push {R2-R12, LR}
	BL	bsaes_encrypt
	pop {R2-R12, LR}
	BX	LR
