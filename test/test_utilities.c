#include "test.h"



/*****************************************************************************/
/*                                                                           */
/*                              GENERIC UTILITIES                            */
/*                                                                           */
/*****************************************************************************/

void generate_masked_element (uint operande[NBSHARES]) {
	int i;
	if (CODE_MODE == NORMAL) {
		operande[NBSHARES-1] = rand() & ((1<<FIELDSIZE)-1);
		for (i=0; i<NBSHARES-1; i++) {
			operande[i] = rand() & ((1<<FIELDSIZE)-1);
			operande[NBSHARES-1] ^= operande[i];
		}
	}
	else {
		operande[NBSHARES-1] = rand();
		for (i=0; i<NBSHARES-1; i++) {
			operande[i] = rand();
			operande[NBSHARES-1] ^= operande[i];
		} 
	}
}

void reset_element (uint operande[NBSHARES]) {
  if (CODE_MODE == NORMAL) {
    memset(operande, 0, ((FIELDSIZE-1)/8 +1)*NBSHARES);
  }
  else {
    memset(operande, 0, 4*NBSHARES);
  }  
}


void transpose_nm_to_bs_8b(uint in[NBSHARES], uint elm[NBSHARES][8]){
	int i;
    for (i=0; i<NBSHARES; i++) {
      elm[i][0] = in[i] & 1;
      elm[i][1] = (in[i] & 2)>> 1;
      elm[i][2] = (in[i] & 4)>> 2;
      elm[i][3] = (in[i] & 8)>> 3;
      elm[i][4] = (in[i] & 16)>> 4;
      elm[i][5] = (in[i] & 32)>> 5;
      elm[i][6] = (in[i] & 64)>> 6;
      elm[i][7] = in[i] >> 7;
    }
}

void transpose_nm_to_bs_4b(uint in[NBSHARES], uint elm[NBSHARES][4]){
	int i;
    for (i=0; i<NBSHARES; i++) {
      elm[i][3] = in[i] & 1;
      elm[i][2] = (in[i] & 2)>> 1;
      elm[i][1] = (in[i] & 4)>> 2;
      elm[i][0] = in[i] >> 3;
    }
}


void transpose_bs_to_nm_8b(uint res[NBSHARES][8], uint out[NBSHARES]){
	int i;
    for (i=0; i<NBSHARES; i++) {
      out[i] = res[i][0] & 0x1;
      out[i] += (res[i][1]<<1) & 0x2;
      out[i] += (res[i][2]<<2) & 0x4; 
      out[i] += (res[i][3]<<3) & 0x8;
      out[i] += (res[i][4]<<4) & 0x10;
      out[i] += (res[i][5]<<5) & 0x20;
      out[i] += (res[i][6]<<6) & 0x40;
      out[i] += (res[i][7]<<7) & 0x80;
    }
}

void transpose_bs_to_nm_4b(uint res[NBSHARES][4], uint out[NBSHARES]){
	int i;
    for (i=0; i<NBSHARES; i++) {
      out[i] = res[i][3] + (res[i][2]<<1) + (res[i][1]<<2) + (res[i][0]<<3);
    }
}


/*****************************************************************************/
/*                                                                           */
/*                   FIELD MULTIPLICATION UTILITIES                          */
/*                                                                           */
/*****************************************************************************/

uint tabmul[1<<(2*FIELDSIZE)];

void generate_table_mult(uint *tab) {
	uint i,j;
  uint tmp = 0;
  for (i=0; i<(1<<FIELDSIZE); i++){
    for (j=0; j<(1<<FIELDSIZE); j++){
      if (i!=0 && j!=0){
				tmp = j + (i<<FIELDSIZE);
				tab[tmp] = logtab[i] + logtab[j];
				tab[tmp] %= (1<<FIELDSIZE)-1;
				tab[tmp] = alogtab[tab[tmp]];
      }
      else{
				tmp = j + (i<<FIELDSIZE);
				tab[tmp] = 0;
      }
    }
  }
}

uint multiplication(uint a, uint b){
    return tabmul[b+(a<<FIELDSIZE)];
}



/*****************************************************************************/
/*                                                                           */
/*                          CPRR EVALUATION UTILITIES                        */
/*                                                                           */
/*****************************************************************************/


int test_secure_evaluation (uint opA[NBSHARES], uint out[NBSHARES]) {
	int i,nb_chunk;
  uint A, res;

  if (CODE_MODE == NORMAL) {
    A = opA[0];
    res = out[0];
    for (i=1; i<NBSHARES; i++) {
      A ^= opA[i];
      res ^= out[i];
    }
    if (multiplication(A, multiplication(A,A)) != res) {
      return 1;
    }
  }
  else {
    for (nb_chunk=0; nb_chunk<FIELDSIZE; nb_chunk++) {
      A = opA[0] & (((1<<FIELDSIZE)-1) << (FIELDSIZE*nb_chunk)) >> (FIELDSIZE*nb_chunk);
      res = out[0] & (((1<<FIELDSIZE)-1) << (FIELDSIZE*nb_chunk)) >> (FIELDSIZE*nb_chunk);
      for (i=1; i<NBSHARES; i++) {
        A ^= opA[i] & (((1<<FIELDSIZE)-1) << (FIELDSIZE*nb_chunk)) >> (FIELDSIZE*nb_chunk);
        res ^= out[i] & (((1<<FIELDSIZE)-1) << (FIELDSIZE*nb_chunk)) >> (FIELDSIZE*nb_chunk);
      }
      if (multiplication(A, multiplication(A,A)) != res ) {
        return 1;
      }   
    }
  }

  return 0;
}


/*****************************************************************************/
/*                                                                           */
/*                        ISW MULTIPLICATION UTILITIES                       */
/*                                                                           */
/*****************************************************************************/



int test_secure_multiplication (uint opA[NBSHARES], uint opB[NBSHARES], uint out[NBSHARES]) {
	int i,nb_chunk;
  uint A, B, res;

  if (CODE_MODE == NORMAL) {
    A = opA[0];
    B = opB[0];
    res = out[0];
    for (i=1; i<NBSHARES; i++) {
      A ^= opA[i];
      B ^= opB[i];
      res ^= out[i];
    }
    if (multiplication(A,B) != res) {
      return 1;
    }
  }
  else {
    for (nb_chunk=0; nb_chunk<FIELDSIZE; nb_chunk++) {
      A = opA[0] & (((1<<FIELDSIZE)-1) << (FIELDSIZE*nb_chunk)) >> (FIELDSIZE*nb_chunk);
      B = opB[0] & (((1<<FIELDSIZE)-1) << (FIELDSIZE*nb_chunk)) >> (FIELDSIZE*nb_chunk);
      res = out[0] & (((1<<FIELDSIZE)-1) << (FIELDSIZE*nb_chunk)) >> (FIELDSIZE*nb_chunk);
      for (i=1; i<NBSHARES; i++) {
        A ^= opA[i] & (((1<<FIELDSIZE)-1) << (FIELDSIZE*nb_chunk)) >> (FIELDSIZE*nb_chunk);
        B ^= opB[i] & (((1<<FIELDSIZE)-1) << (FIELDSIZE*nb_chunk)) >> (FIELDSIZE*nb_chunk);
        res ^= out[i] & (((1<<FIELDSIZE)-1) << (FIELDSIZE*nb_chunk)) >> (FIELDSIZE*nb_chunk);
      }
      if (multiplication(A,B) != res) {
        return 1;
      }   
    }
  }

  return 0;
}


/*****************************************************************************/
/*                                                                           */
/*                       AES POLYNOMIAL SBOX UTILITIES                       */
/*                                                                           */
/*****************************************************************************/


int test_aes_sbox(uint in[NBSHARES], uint out[NBSHARES]) {
  int i, nb_chunk;
  uint elm, res;

  
  if (CODE_MODE == NORMAL) {
    elm = in[0] & 0xFF;
    res = out[0] & 0xFF;
    for (i=1; i<NBSHARES; i++) {
      elm ^= in[i] & 0xFF;
      res ^= out[i] & 0xFF;
    }
    if (aes_sbox_table[elm] != res) {
      return 1;
    }
  }
  else {
    for (nb_chunk=0; nb_chunk<4; nb_chunk++) {
      elm = (in[0] & (((1<<8)-1) << (8*nb_chunk))) >> (8*nb_chunk);
      res = (out[0] & (((1<<8)-1) << (8*nb_chunk))) >> (8*nb_chunk);
      for (i=1; i<NBSHARES; i++) {
        elm ^= (in[i] & (((1<<8)-1) << (8*nb_chunk))) >> (8*nb_chunk);
        res ^= (out[i] & (((1<<8)-1) << (8*nb_chunk))) >> (8*nb_chunk);
      }
      if (aes_sbox_table[elm] != res) {
        return 1;
      } 
    }
  }
  return 0;
}




/*****************************************************************************/
/*                                                                           */
/*                      PRESENT POLYNOMIAL SBOX UTILITIES                    */
/*                                                                           */
/*****************************************************************************/


int test_present_sbox(uint in[NBSHARES], uint out[NBSHARES]) {
	int i,nb_chunk;
  uint elm, res;

  if (CODE_MODE == NORMAL) {
    elm = in[0] & 0xF;
    res = out[0] & 0xF;
    for (i=1; i<NBSHARES; i++) {
      elm ^= in[i] & 0xF;
      res ^= out[i] & 0xF;
    }
    if (present_sbox_table[elm] != res) {
      return 1;
    }
  }
  else {
    for (nb_chunk=0; nb_chunk<8; nb_chunk++) {
      elm = (in[0] & (((1<<4)-1) << (4*nb_chunk))) >> (4*nb_chunk);
      res = (out[0] & (((1<<4)-1) << (4*nb_chunk))) >> (4*nb_chunk);
      for (i=1; i<NBSHARES; i++) {
        elm ^= (in[i] & (((1<<4)-1) << (4*nb_chunk))) >> (4*nb_chunk);
        res ^= (out[i] & (((1<<4)-1) << (4*nb_chunk))) >> (4*nb_chunk);
      }
      if (present_sbox_table[elm] != res) {
        return 1;
      } 
    }
  }

  return 0;
}



/*****************************************************************************/
/*                                                                           */
/*                          AES ENCRYPTION UTILITIES                         */
/*                                                                           */
/*****************************************************************************/

void aes_generate_extendedkey_shares (uint masked_extendedkey[NBSHARES][44], uint extended_key[44]) {
	int i,j;
	
  for(i=0; i<44; i++) {
    masked_extendedkey[NBSHARES-1][i] = 0;
    for (j=0; j<NBSHARES-1; j++) {
      masked_extendedkey[j][i] = rand();
      masked_extendedkey[NBSHARES-1][i] ^= masked_extendedkey[j][i];
    }
    masked_extendedkey[NBSHARES-1][i] ^= extended_key[i]; 
  }

}

void aes_generate_bitsliced_extendedkey_shares (uint masked_bs_extendedkey[NBSHARES][8*11], uint bs_extended_key[88]) {
	int i,j;
	
  for(i=0; i<88; i++) {
    masked_bs_extendedkey[NBSHARES-1][i] = 0;
    for (j=0; j<NBSHARES-1; j++) {
      masked_bs_extendedkey[j][i] = rand() & 0xFFFF;
      masked_bs_extendedkey[NBSHARES-1][i] ^= masked_bs_extendedkey[j][i];
    }
    masked_bs_extendedkey[NBSHARES-1][i] ^= bs_extended_key[i]; 
  }

}

int test_aes_encryption(uint ciphertext[4], uint test_ciphertext[4]) {
  if (memcmp(ciphertext, test_ciphertext, 4*sizeof(uint)) == 0){
    return 0;
  }
  return 1;
}



/*****************************************************************************/
/*                                                                           */
/*                      PRESENT ENCRYPTION UTILITIES                         */
/*                                                                           */
/*****************************************************************************/

void present_generate_extendedkey_shares (uint masked_extendedkey[NBSHARES][64], uint extended_key[64]) {
	int i,j;
	
  for(i=0; i<64; i++) {
    masked_extendedkey[NBSHARES-1][i] = 0;
    for (j=0; j<NBSHARES-1; j++) {
      masked_extendedkey[j][i] = rand();
      masked_extendedkey[NBSHARES-1][i] ^= masked_extendedkey[j][i];
    }
    masked_extendedkey[NBSHARES-1][i] ^= extended_key[i]; 
  }

}

void present_generate_bitsliced_extendedkey_shares (uint masked_bs_extendedkey[NBSHARES][128], uint bs_extended_key[128]) {
	int i,j;
	
  for(i=0; i<128; i++) {
    masked_bs_extendedkey[NBSHARES-1][i] = 0;
    for (j=0; j<NBSHARES-1; j++) {
      masked_bs_extendedkey[j][i] = rand() & 0xFFFF;
      masked_bs_extendedkey[NBSHARES-1][i] ^= masked_bs_extendedkey[j][i];
    }
    masked_bs_extendedkey[NBSHARES-1][i] ^= bs_extended_key[i]; 
  }

}

int test_present_encryption(uint ciphertext[2], uint test_ciphertext[2]) {
  if (memcmp(ciphertext, test_ciphertext, 2*sizeof(uint)) == 0){
    return 0;
  }
  return 1;
}
