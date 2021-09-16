#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>    
#include <string.h>
#include <time.h>    

#include "param.h"
#include "test/test.h"
#include "test/test_utilities.c"   


/*****************************************************************************/
/*                                                                           */
/* 	              		ASSSEMBLY FUNCTIONS SIGNATURES                       */
/*                                                                           */
/*****************************************************************************/



/********************************/ 
/*								*/
/* 		FIELD MULTIPLICATION   	*/
/*								*/
/********************************/

uint tabmul[1<<(2*FIELDSIZE)];
uint multiplication_func (uint operandeA, uint operandeB);

/********************************/ 
/*								*/
/*	   SECURE MULTIPLICATION	*/
/*								*/
/********************************/

// CPRR
void cprr_test       (uint *operandeA, uint* out);

// ISW
void isw_test     	 (uint* operandeA, uint* operandeB, uint* out);

/********************************/ 
/*								*/
/* 		  SECURE SBOXES   		*/
/*								*/
/********************************/


// RPAES
void rp_test             (uint elm[NBSHARES], uint out[NBSHARES]);

// KHLAES
void khl_test            (uint elm[NBSHARES], uint out[NBSHARES]);

// FOGPRESENT
void fog_test            (uint elm[NBSHARES], uint out[NBSHARES]);

// BSAES
void bsaes_test          (uint in[NBSHARES][8], uint out[NBSHARES][8]);

// BSPRESENT
void bspresent_test      (uint in[NBSHARES][4], uint out[NBSHARES][4]);

/********************************/ 
/*								*/
/* 		  SECURE CIPHER   		*/
/*								*/
/********************************/

// REGAES
void regaes_encrypt      (uint pt[4], uint ct[4], uint ks[NBSHARES][44]);

// REGPRESENT
void regpresent_encrypt  (uint pt[2], uint ct[2], uint ks[NBSHARES][64]);

// BSAES
void bsaes_encrypt       (uint pt[4], uint ct[4], uint ks[NBSHARES][88]);

// BSPRESENT
void bspresent_encrypt   (uint pt[2], uint ct[2], uint ks[NBSHARES][128]);




/*****************************************************************************/
/*                                                                           */
/* 	              					MAIN TEST 			                     */
/*                                                                           */
/*****************************************************************************/


int main () {

	int i;
	
	int opA,opB;
	int nb_test;
	uint res;
	
	uint tab_opA[NBSHARES], tab_opB[NBSHARES];
	uint in[NBSHARES], out[NBSHARES], store_in[NBSHARES];
	uint aes_bs_in[NBSHARES], aes_bs_out[NBSHARES];
	uint aes_elm_tab[NBSHARES][8], aes_res_tab[NBSHARES][8];
	uint present_bs_in[NBSHARES], present_bs_out[NBSHARES];
	uint present_elm_tab[NBSHARES][4], present_res_tab[NBSHARES][4];
	
	uint aes_ciphertext[4];
	uint aes_masked_extendedkey[NBSHARES][4*11];
	uint aes_masked_bs_extendedkey[NBSHARES][8*11];
	uint present_ciphertext[2];
	uint present_masked_extendedkey[NBSHARES][64];
	uint present_masked_bs_extendedkey[NBSHARES][128];
	
	switch (TEST_MODE) {

		case TEST_FIELDMULT            :

		generate_table_mult(tabmul);

		for (opA=0; opA<(1<<FIELDSIZE); opA++) {
			for (opB=0; opB<(1<<FIELDSIZE); opB++) {
				res = multiplication_func(opA, opB);
				if (multiplication(opA,opB) != res) {
					return 1;
				}
			}
		}

		break;

		case TEST_SECMULT_CPRR         :

		generate_table_mult(tabmul);

		for (nb_test = 0; nb_test<NB_TESTS; nb_test++) {
			generate_masked_element(tab_opA);
			reset_element(out);
			cprr_test(tab_opA, out);
			if (test_secure_evaluation(tab_opA, out) != 0) {
				return 1;
			}
		}

		break;

		case TEST_SECMULT_ISW          :

		generate_table_mult(tabmul);

		for (nb_test = 0; nb_test<NB_TESTS; nb_test++) {
			generate_masked_element(tab_opA);
			generate_masked_element(tab_opB);
		    reset_element(out);
			isw_test(tab_opA, tab_opB, out);
			if (test_secure_multiplication(tab_opA, tab_opB, out) != 0) {
			return 1;
			}
		}

		break;

		
		case TEST_SECSBOX_RPAES        :

		for (nb_test = 0; nb_test<NB_TESTS; nb_test++) {
			generate_masked_element(in);
			int i;
			for (i=0; i<NBSHARES; i++) {
			  store_in[i] = in[i];
			}
			rp_test (in, out);
			if (test_aes_sbox(store_in, out) != 0) {
				return 1;
			}
			reset_element(out); 
		}

		break;

		case TEST_SECSBOX_KHLAES       :

		for (nb_test = 0; nb_test<NB_TESTS; nb_test++) {
			generate_masked_element(in);
			int i;
			for (i=0; i<NBSHARES; i++) {
			  store_in[i] = in[i];
			}
			khl_test (in, out);
			if (test_aes_sbox(in, out) != 0) {
				return 1;
			}
			reset_element(out); 
		}

		break;

		case TEST_SECSBOX_FOGPRESENT   :

		for (nb_test = 0; nb_test<NB_TESTS; nb_test++) {
			generate_masked_element(in);
			int i;
			for (i=0; i<NBSHARES; i++) {
			  store_in[i] = in[i];
			}
			reset_element(out); 
			fog_test (in, out);
			if (test_present_sbox(store_in, out) != 0) {
				return 1;
			}
		}

		break;

		case TEST_SECSBOX_BSAES        :

		for (nb_test = 0; nb_test<NB_TESTS; nb_test++) {
			generate_masked_element(aes_bs_in);
			transpose_nm_to_bs_8b(aes_bs_in, aes_elm_tab);
			bsaes_test (aes_elm_tab, aes_res_tab);
			transpose_bs_to_nm_8b(aes_res_tab, aes_bs_out);
			if (test_aes_sbox(aes_bs_in, aes_bs_out) != 0) {
				return 1;
			}
		}
	
		break;

		case TEST_SECSBOX_BSPRESENT    :

		for (nb_test = 0; nb_test<NB_TESTS; nb_test++) {
			generate_masked_element(present_bs_in);
			transpose_nm_to_bs_4b(present_bs_in, present_elm_tab);
			bspresent_test(present_elm_tab, present_res_tab);
			transpose_bs_to_nm_4b(present_res_tab, present_bs_out);
			if (test_present_sbox(present_bs_in, present_bs_out) != 0) {
				return 1;
			}
		}				

		break;

		case TEST_SECCIPHER_REGAES     :

		aes_generate_extendedkey_shares(aes_masked_extendedkey, aes_extended_key);

		for (i=0; i<5; i++) {
			regaes_encrypt(aes_test_plaintext[i], aes_ciphertext, aes_masked_extendedkey);
			if (test_aes_encryption(aes_ciphertext, aes_test_ciphertext[i]) != 0) {
				return 1;
			}
		}

		break;

		case TEST_SECCIPHER_REGPRESENT :
		
		present_generate_extendedkey_shares(present_masked_extendedkey, present_extended_key);
		regpresent_encrypt(present_plaintext,present_ciphertext, present_masked_extendedkey);
		if (test_present_encryption(present_ciphertext, present_test_ciphertext) != 0){
			return 1;
		}
		
		break;

		case TEST_SECCIPHER_BSAES      :
	
		aes_generate_bitsliced_extendedkey_shares(aes_masked_bs_extendedkey, aes_bs_extended_key);
		
		for (i=0; i<5; i++) {
			bsaes_encrypt(aes_test_plaintext[i], aes_ciphertext, aes_masked_bs_extendedkey);
			if (test_aes_encryption(aes_ciphertext, aes_test_ciphertext[i]) != 0) {
				return 1;
			}
		}

		break;

		case TEST_SECCIPHER_BSPRESENT  :

		present_generate_bitsliced_extendedkey_shares(present_masked_bs_extendedkey, present_bs_extended_key);
		bspresent_encrypt(present_plaintext, present_ciphertext, present_masked_bs_extendedkey);
		if (test_present_encryption(present_ciphertext, present_test_ciphertext) != 0){
			return 1;
		}

		break;

	}

	printf("Test successfull\n");
	return 0;
}























