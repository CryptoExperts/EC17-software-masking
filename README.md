# Software Higher-order Masking for Block Ciphers

This repository provides some material related to the article 

<a href="https://eprint.iacr.org/2016/264">How Fast Can Higher-Order Masking Be in Software?</a> 

published at Eurocrypt 2017. The repository includes the source codes of the different masking schemes optimised in ARMv7 assembly as depicted in the paper. 

## Authors

* Dahmun Goudarzi
* Matthieu Rivain

## Copyright and License

Copyright &copy; 2018, CryptoExperts 
License <a href="https://en.wikipedia.org/wiki/GNU_General_Public_License#Version_3">GNU General Public License v3 (GPLv3)</a>


## Disclaimers

* This code does not aim to be strong against side-channel attacks but to benchmark higher-order masking. Strength against side-channel attacks might require a mix of masking and other countermeasures. In particular, no measures were taken to avoid transition leakage (which is hardware dependent). It is likely that a n-share implementation suffers some (n/2)-order flaw because of transition hardware effects. 

* The code has been completely refactored for portability and open sourcing since the publication at Eurocrypt 2017. The target now differs from the one on which the timing were benchmarked in the original paper, which may introduce some differences. In essence the code and its optimisations are unchanged and should still lead to comparable performances.

## Content

### ARMv7 assembly source files:

All the ARMv7 assembly source files can be found in the files called **src**.

 * **1\_fieldmult.s**: different field multiplications.
 * **2\_secmult\_cprr.s**: CPRR evaluation.
 * **2\_secmult\_isw.s**: ISW multiplication.
 * **2\_secmult\_iswand.s**: ISW-AND multiplication. 
 * **2\_secmult\_refresh.s**: ISW-based refresh.
 * **3\_secsbox\_bsaes.s**: bitslice AES s-box.
 * **3\_secsbox\_bspresent.s**: bitslice PRESENT s-box.
 * **3\_secsbox\_fog.s**: FoG PRESENT s-box.
 * **3\_secsbox\_khl.s**: KHL AES s-box.
 * **3\_secsbox\_rp.s**: RP AES s-box.
 * **4\_seccipher\_bsaes.s**: bitslice AES encryption.
 * **4\_seccipher\_bspresent.s**: bitslice PRESENT encryption.
 * **4\_seccipher\_regaes.s**: regular AES encryption.
 * **4\_seccipher\_regpresent.s**: regular PRESENT encryption.
 * **random.s**: random generation.

### Header file:

 * **parameter.h**: Header files containing different sets of parameters.
 * **mode.h**: Header files containing different modes for specific functions.

### Main:

* **main.c**: Main file containing function to set up shares/unmasked shares according to mode chosen and testing the correctness.

## Parameters

### parameters.h
---

* **FIELDSIZE**: sets the bit-size of the elements. Range from 4 to 10. On specific s-boxes such as AES and PRESENT needs to be set to 8 and 4 resp. in order to work.
* **NBSHARES**: sets the number of shares used to protect the implementation. Ranges from 2 to 10.
* **MULT_MODE**: sets the field multiplication algorithm. The possible values are listed in *mode.h*.
* **CODE_MODE**: sets the parallelisation level for the implementation. The possibles values are listed in *mode.h*. The code was developed for a 32-bit architecture. Hence consider that *FIELDSIZE* * *CODE_MODE* should not exceed 32.
* **CIPH_MODE**: sets some implementation tricks for regular AES encryption with KHL and RP schemes. The possible values are listed in *mode.h*. If not set to *ANY*, it should be used with specific sets of parameters (see below).
* **RAND_MODE**: sets the random number generator. Can either be C rand function for functionality testing (*C_RAND*) or a table look-up to emulate a fast TRNG for performance testing (*TRNG*). 
* **TEST_MODE**: sets the function that will be tested. The possible values are listed in *mode.h*.
* **NB_TESTS**: sets the number of test that are going to be performed.


### mode.h
---

#### ***Field Multiplication***

* **BINMULT1**: binary multiplication (l2r).
* **BINMULT2**: binary multiplication (l2r) with look-up table used for the modular reduction.
* **EXPLOG1**: exp-log multiplication.
* **EXPLOG2**: exp-log multiplication with look-up table used for the modular reduction.
* **KARA**: Karatsuba multiplication.
* **HALFTAB**: half table multiplication.
* **FULLTAB**: full table multiplication.
* **FULLTABSHIFT**: tweaked full table multiplication for 8 elements in parallel (for KHL cipher mode only).
* **EXPLOG2SHIFT**: tweaked exp-log multiplication for 4 elements in parallel (for RP cipher mode only).
* **HALFTABSHIFT**: tweaked half table multiplication for 4 elements in parallel (for in RP cipher mode only).

#### ***Parallelisation level***

* **NORMAL**: no parallelisation.
* **PARA2**: parallelisation level 2: 2 elements/register.
* **PARA4**: parallelisation level 4: 4 elements/register (usually used for FIELDSIZE=8).
* **PARA8**: parallelisation level 8: 4 elements/register (only use for FIELDSIZE=4).
* **BITSLICE**: parallelisation level full: 32 elements/register.

#### ***Cipher choice***

* **ANY**: default choice for testing.
* **KHL**: used when testing KHL encryption.
* **RP**: used when testing RP encryption.

#### ***Refresh choice***

* **RF1**: regular refresh.
* **RF4**: optimised refresh (partial unrolling of loops).

#### ***Random choice***

* **TRNG**: "randomness" from table look-up to emulate a fast TRNG. **For performance testing only!**
* **C_RAND**: randomness from C rand function. For functionality testing.

#### ***Test choice***

* **TEST\_FIELDMULT**: to test field multiplications.
* **TEST\_SECMULT\_CPRR**: to test CPRR evaluations.
* **TEST\_SECMULT\_ISW**: to test ISW multiplications.
* **TEST\_SECSBOX\_RPAES**: to test RP AES s-box.
* **TEST\_SECSBOX\_KHLAES**: to test KHL AES s-box.
* **TEST\_SECSBOX\_FOGPRESENT**: to test FoG PRESENT s-box.
* **TEST\_SECSBOX\_BSAES**: to test bitsliced AES s-box.
* **TEST\_SECSBOX\_BSPRESENT**: to test bitsliced PRESENT s-box.
* **TEST\_SECCIPHER\_REGAES**: to test regular AES encryption.
* **TEST\_SECCIPHER\_REGPRESENT**: to test regular PRESENT encryption.
* **TEST\_SECCIPHER\_BSAES**: to test bitslice AES encryption.
* **TEST\_SECCIPHER\_BSPRESENT**: to test bitslice PRESENT encryption.


## How to use

To test the code: 

* run the `python3 configure.py` script and follow the instructions to set up the desired tests and its parameters. 
* use the `make clean; make` command to compile the code.
* run `./hom_ec17`.


## Bugs and test coverage

Due to the numerous amount of parameters, test coverage is work in progress (although the entire source code is already there). If you find any bug while testing this code, please contact the authors.

## Contact

If you have any questions, please feel free to contact us at 

* dahmun.goudarzi@gmail.com
* matthieu.rivain@cryptoexperts.com
