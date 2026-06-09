# Software Higher-order Masking for Block Ciphers

This repository provides some material related to the article 

<a href="https://eprint.iacr.org/2016/264">How Fast Can Higher-Order Masking Be in Software?</a> 

published at Eurocrypt 2017. The repository includes the source codes of the different masking schemes optimised in ARMv7 assembly as depicted in the paper. 

## Authors

* Dahmun Goudarzi
* Matthieu Rivain

Contributors:

* Ryad Benadjila

## Copyright and License

Copyright &copy; 2018-2026, CryptoExperts 
License <a href="https://en.wikipedia.org/wiki/GNU_General_Public_License#Version_3">GNU General Public License v3 (GPLv3)</a>

Updated in 2026 for ARMv7M compatibility various fixes.

## Disclaimer

* This code does not aim to be strong against side-channel attacks but to benchmark higher-order masking. Strength against side-channel attacks might require a mix of masking and other countermeasures. In particular, no measures were taken to avoid transition leakage (which is hardware dependent). It is likely that a n-share implementation suffers some (n/2)-order flaw because of transition hardware effects. 

## History

* The code has been completely refactored for portability and open sourcing since the publication at Eurocrypt 2017. The target now differs from the one on which the timing were benchmarked in the original paper, which may introduce some differences. In essence the code and its optimisations are unchanged and should still lead to comparable performances.

* In 2026, the code has been adapted to be compatible with ARMv7M (Thumb-2), compilation targets have been added, as well as emulation with `qemu` for tests. An exhaustive testing script has also been added for regression tests.

## Content

### ARMv7 assembly source files:

All the ARMv7 assembly source files can be found in the files called **src**.

 * **1\_fieldmult.S**: different field multiplications.
 * **2\_secmult\_cprr.S**: CPRR evaluation.
 * **2\_secmult\_isw.S**: ISW multiplication.
 * **2\_secmult\_iswand.S**: ISW-AND multiplication. 
 * **2\_secmult\_refresh.S**: ISW-based refresh.
 * **3\_secsbox\_bsaes.S**: bitslice AES s-box.
 * **3\_secsbox\_bspresent.S**: bitslice PRESENT s-box.
 * **3\_secsbox\_fog.S**: FoG PRESENT s-box.
 * **3\_secsbox\_khl.S**: KHL AES s-box.
 * **3\_secsbox\_rp.S**: RP AES s-box.
 * **4\_seccipher\_bsaes.S**: bitslice AES encryption.
 * **4\_seccipher\_bspresent.S**: bitslice PRESENT encryption.
 * **4\_seccipher\_regaes.S**: regular AES encryption.
 * **4\_seccipher\_regpresent.S**: regular PRESENT encryption.
 * **random.S**: random generation.

### Header files:

 * **param.h**: Header files containing different sets of parameters.
 * **mode.h**: Header files containing different modes for specific functions.

### Main:

* **main.c**: Main file containing function to set up shares/unmasked shares according to mode chosen and testing the correctness.

## Parameters

**NOTE:** Beware that all the possible set of parameters might not be compatible with each other, sometimes because of inherent incompatibility, and sometimes
because the selection is not implemented (yet). When this is the case, usually a `#error` will be triggered at compilation time.

### param.h
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
* **PARA8**: parallelisation level 8: 8 elements/register (only use for FIELDSIZE=4).
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

### Targets

The assembly code targets regular 32-bit ARMv7A platforms as well as ARMV v7M embedded platforms. In the generated `Makefile`, we use the two
specific **cross-compilation** targets Cortex-A for ARMv7A, and Cortex-M4 for ARMv7M Thumb-2 (you can however easily adapt this `Makefile` to change the target with compatible
CPUs through `gcc` `-march` and `-mcpu` options). A last target is the "local" one, i.e. compilation on the current platform.
For cross-compilation, `arm-linux-gnueabi-gcc` is used for Cortex-A (all development and tests have been performed with version 15.2.0)
and `arm-none-eabi-gcc` for Cortex-M (all development and tests have been performed with version 14.2.1).

- **The local target:**

The "local" target compiles the code for the current platform, i.e. where the current `gcc` is installed. This can be for instance a Raspberry Pi or any
ARM based compatible platform where a GNU compatible `gcc` compilation toolchain is installed. The produced file is an ELF executable file that can be executed
on the same platform, or using `qemu` user mode emulation (see below the Cortex-A target).

Simply compile the project with `make clean && make`. This will produce the `hom_ec17` ELF executable, that you should be able to execute with `./hom_ec17`.

-  **The Cortex-A target:**

This is a cross-compilation platform for the `arm-linux-gnueabi-gcc` toolchain. The produced file is an ELF executable that can be executed with the
`qemu` user mode emulation: on recent Linux kernels, the `bin-fmt` translation layer allows to transparently handle cross-platforms executions.

Simply compile the project with `make clean && PLATFORM=cortexa make`, this will produce a `hom_ec17` ELF executable for ARMv7A Cortex-A. Then,
you can launch the emulation with `PLATFORM=cortexa make platform_test` (this will simply execute `./hom_ec17` and trigger the `bin-fmt` machinery
in the kernel).

- **The Cortex-M4 target:**

This is a cross-compilation platform for the `arm-none-eabi-gcc` toolchain targeting MCUs for embedded devices. The produced file is an ELF executable that in fact
represents an embedded **firmware**. In order to perform tests, we use the so-called **semi-hosting feature** of the toolchain and `qemu` so that printing on the console
is made easy. Emulation makes use of `qemu system` that emulates a whole system with this semi-hosting activated, the emulated board being the classical
`mps2-an386`. A minimal linker script `linker.ld` as well as a minimal startup file `startup.c` are provided to setup the platform in a minimal working state: **beware**
that some work will be necessary to adapt this to other real-world boards for fully-working firmware (this work goes beyond the current repository purpose).

Simply compile with `make clean && PLATFORM=cortexm4 make`, this will produce a `hom_ec17` ELF that represents a firmware that uses semi-hosting for
the `mps2-an386` board. Then, emulate with `PLATFORM=cortexm4 make platform_test` (this actually invokes `qemu system` with the proper arguments).

### Quick compilation commands

To test the code: 

* Run the `python3 configure.py` script and follow the instructions to set up the desired tests and its parameters. 
* Depending on your target ("local", cross-compile Cortex-A, cross-compile Cortex-M4), compile with:
  * For local: `make clean && make`
  * For Cortex-A: `make clean && PLATFORM=cortexa make`
  * For Cortex-M4: `make clean && PLATFORM=cortexm4 make`
* Depending on your target, run:
  * For local: `./hom_ec17`
  * For Cortex-A: `PLATFORM=cortexa make platform_test`
  * For Cortex-M4: `PLATFORM=cortexm4 make platform_test`

### Docker

You can find a `Makefile.CI` that will build a Docker machine that includes all the dependencies (cross-compilers and emulators).
The CI (Continuous Integration) will be run with:

```sh
make -f Makefile.CI
```

This builds the Docker with the name `ec17_tester`.

If you want to manually use this Docker, execute the following:

```sh
docker run -it ec17_tester /bin/bash
```

This will drop a shell in the Docker with all the necessary tools installed, so that you can compile and test everything.


## Bugs and test coverage

Due to the numerous amount of parameters, test coverage is implemented in the [test_all_configs.py](test_all_configs.py) script.
This scripts uses a DFS (Depth-First Search) tree traversal to first enumerate all the possible configurations with dynamic detection, and then
for all these configurations it compiles and executes the tests for the Cortex-A and Cortex-M4 cross-compilation target. This script is called
by the CI (Continuous Integration) `Makefile.CI`.

Although this should test exhaustively the configurations, bugs might still be present.
If you find any bug while testing this code, please contact the authors or contributors (see below).

## Contact

If you have any questions, please feel free to contact us at 

* dahmun.goudarzi@gmail.com
* matthieu.rivain@cryptoexperts.com
* ryad.benadjila@cryptoexperts.com
