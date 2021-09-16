#include "../param.h"
#include "../src/random.S"
#include "../src/2_secmult_cprr.S"
#include "../src/2_secmult_isw.S"
#if CIPH_MODE==RP
#include "../src/3_secsbox_rp.S"
#elif CIPH_MODE==KHL
#include "../src/3_secsbox_khl.S"       
#endif 

#include "../src/4_seccipher_regaes.S"	
	
.text
.syntax unified

.pool
.global regaes_test	
regaes_test:	
	push {R2-R12, LR}
	BL	regaes_encrypt
	pop  {R2-R12, LR}
	BX	LR
