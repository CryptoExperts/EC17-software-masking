import os

list_of_files = {}
for (dirpath, dirnames, filenames) in os.walk("./"):
    for filename in filenames:
        if filename.endswith('.s'):
            pre, ext = os.path.splitext(os.path.join(dirpath,filename))
            os.rename(os.path.join(dirpath,filename), pre + '.S')

FIELDSIZE = ""	
NUMBEROFSHARES  = "2"	
MULTMODE = ""	
CODEMODE = "NORMAL"
CIPHMODE = "ANY"	
REFMODE  = "RF1"
RANDMODE = "TRNG"	
TESTMODE = ""	
NBTESTS  = "1"	


print("This script will generate the Makefile and the param.h file in order to run the desired test with the adequate inputs")
print("")
print("Please enter the test you wish to run. List of covered tests are the following:")
print("Enter 1: FIELD MULTIPLICATION")
print("Enter 2: SECURE MULTIPLICATION: CPRR")
print("Enter 3: SECURE MULTIPLICATION: ISW")
print("Enter 4: SECURE SBOX: RP AES S-box")
print("Enter 5: SECURE SBOX: KHL AES S-box")
print("Enter 6: SECURE SBOX: FoG PRESENT S-box")
print("Enter 7: SECURE SBOX: BITSLICE AES S-box")
print("Enter 8: SECURE SBOX: BITSLICE PRESENT S-box")
print("Enter 9: SECURE CIPHER: REGULAR AES cipher with RP")
print("Enter 10: SECURE CIPHER: REGULAR PRESENT cipher with FoG")
print("Enter 11: SECURE CIPHER: BITSLICE AES cipher")
print("Enter 12: SECURE CIPHER: BITSLICE PRESENT cipher")
print("Enter the desired number:")
print()

test_mode = int(input())

while test_mode not in range(1,13):
    print("Invalid input: please enter a valid test by picking the correct number (1 to 12)")
    print("Enter the desired number:")
    test_mode = int(input())

print()
print()

if test_mode == 1:
    print("Entering FIELD MULTIPLICATION tests. Please choose the following parameters")

    TESTMODE = "TEST_FIELDMULT"
    test_str = "test_1_fieldmult.S"

    print("MULTIPLICATION MODE:")
    print("1: BINMULT1")
    print("2: BINMULT2")
    print("3: EXPLOG1")
    print("4: EXPLOG2")
    print("5: KARA")
    print("6: HALFTAB")
    print("7: FULLTAB")
    print("Enter the desired number:")
    
    print()
    mult_mode = int(input())
    while mult_mode not in range(1,8):
        print("Invalid input: please enter a valid test by picking the correct number (1 to 7)")
        print("Enter the desired number:")
        mult_mode = int(input())

    if mult_mode == 1:
        print("Choosing BINARY MULTIPLICATION 1 as field multiplication.")

        print("FIELD SIZE:")
        print("1: 4")
        print("2: 6")
        print("3: 8")
        print("4: 10")
        print("Enter the desired number:")
        
        print()
        field_size = int(input())

        while field_size not in range(1,5):
            print("Invalid input: please enter a valid test by picking the correct number (1 to 4)")
            print("Enter the desired number:")
            field_size = int(input())

        if field_size == 1:
            FIELDSIZE = "4"
        elif field_size == 2:
            FIELDSIZE = "6"
        elif field_size == 3:
            FIELDSIZE = "8"
        elif field_size == 4:
            FIELDSIZE = "10"

        MULTMODE = "BINMULT1"

    if mult_mode == 2:
        print("Choosing BINARY MULTIPLICATION 2 as field multiplication.")

        print("FIELD SIZE:")
        print("1: 4")
        print("2: 6")
        print("3: 8")
        print("4: 10")
        print("Enter the desired number:")
        
        print()
        field_size = int(input())

        while field_size not in range(1,5):
            print("Invalid input: please enter a valid test by picking the correct number (1 to 4)")
            print("Enter the desired number:")
            field_size = int(input())

        if field_size == 1:
            FIELDSIZE = "4"
        elif field_size == 2:
            FIELDSIZE = "6"
        elif field_size == 3:
            FIELDSIZE = "8"
        elif field_size == 4:
            FIELDSIZE = "10"

        MULTMODE = "BINMULT2"

    if mult_mode == 3:
        print("Choosing EXP/LOG 1 as field multiplication.")

        print("FIELD SIZE:")
        print("1: 4")
        print("2: 6")
        print("3: 8")
        print("4: 10")
        print("Enter the desired number:")
        
        print()
        field_size = int(input())

        while field_size not in range(1,5):
            print("Invalid input: please enter a valid test by picking the correct number (1 to 4)")
            print("Enter the desired number:")
            field_size = int(input())

        if field_size == 1:
            FIELDSIZE = "4"
        elif field_size == 2:
            FIELDSIZE = "6"
        elif field_size == 3:
            FIELDSIZE = "8"
        elif field_size == 4:
            FIELDSIZE = "10"

        MULTMODE = "EXPLOG1"

    if mult_mode == 4:
        print("Choosing EXP/LOG 2 as field multiplication.")

        print("FIELD SIZE:")
        print("1: 4")
        print("2: 6")
        print("3: 8")
        print("4: 10")
        print("Enter the desired number:")
        
        print()
        field_size = int(input())

        while field_size not in range(1,5):
            print("Invalid input: please enter a valid test by picking the correct number (1 to 4)")
            print("Enter the desired number:")
            field_size = int(input())

        if field_size == 1:
            FIELDSIZE = "4"
        elif field_size == 2:
            FIELDSIZE = "6"
        elif field_size == 3:
            FIELDSIZE = "8"
        elif field_size == 4:
            FIELDSIZE = "10"

        MULTMODE = "EXPLOG2"

    if mult_mode == 5:
        print("Choosing KARATSUBA as field multiplication.")

        print("FIELD SIZE:")
        print("1: 4")
        print("2: 6")
        print("3: 8")
        print("4: 10")
        print("Enter the desired number:")
        
        print()
        field_size = int(input())

        while field_size not in range(1,5):
            print("Invalid input: please enter a valid test by picking the correct number (1 to 4)")
            print("Enter the desired number:")
            field_size = int(input())

        if field_size == 1:
            FIELDSIZE = "4"
        elif field_size == 2:
            FIELDSIZE = "6"
        elif field_size == 3:
            FIELDSIZE = "8"
        elif field_size == 4:
            FIELDSIZE = "10"

        MULTMODE = "KARA"

    if mult_mode == 6:
        print("Choosing HALF TABLE as field multiplication.")

        print("FIELD SIZE:")
        print("1: 4")
        print("2: 6")
        print("3: 8")
        print("4: 10")
        print("Enter the desired number:")
        
        print()
        field_size = int(input())

        while field_size not in range(1,5):
            print("Invalid input: please enter a valid test by picking the correct number (1 to 4)")
            print("Enter the desired number:")
            field_size = int(input())

        if field_size == 1:
            FIELDSIZE = "4"
        elif field_size == 2:
            FIELDSIZE = "6"
        elif field_size == 3:
            FIELDSIZE = "8"
        elif field_size == 4:
            FIELDSIZE = "10"

        MULTMODE = "HALFTAB"

    if mult_mode == 7:
        print("Choosing FULL TABLE as field multiplication.")

        print("FIELD SIZE:")
        print("1: 4")
        print("2: 6")
        print("Enter the desired number:")
        
        print()
        field_size = int(input())

        while field_size not in range(1,3):
            print("Invalid input: please enter a valid test by picking the correct number (1 to 2)")
            print("Enter the desired number:")
            field_size = int(input())

        if field_size == 1:
            FIELDSIZE = "4"
        elif field_size == 2:
            FIELDSIZE = "6"

        MULTMODE = "FULLTAB"

if test_mode == 2:
    print("Entering CPRR EVALUATION tests. Please choose the following parameters")

    TESTMODE = "TEST_SECMULT_CPRR"
    test_str = "test_2_secmult_cprr.S"

    print("NUMBER OF SHARES (x = sum_i^NUMBEROFSHARES x_i")
    print("Enter the desired number:")
    print("1: 2 shares")
    print("2: 3 shares")
    print("3: 4 shares")
    print("4: 5 shares")
    print("5: 6 shares")
    print("6: 7 shares")
    print("7: 8 shares")
    print("8: 9 shares")
    print("9: 10 shares")
    number_of_shares = int(input())

    print()
    print()

    while number_of_shares not in range(1,10):
        print("Invalid input: please enter a valid test by picking the correct number (1 to 9)")
        print("Enter the desired number:")
        number_of_shares = int(input())

    NUMBEROFSHARES = f"{number_of_shares+1}"

    print("CODE MODE (parallelisation level)")
    print("1: NORMAL")
    print("2: PARA 4 (4 elements in //")
    print("3: PARA 8 (8 elements in //")
    print("Enter the desired number:")
    print()
    code_mode = int(input())

    print()
    print()

    while code_mode not in range(1,4):
        print("Invalid input: please enter a valid test by picking the correct number (1 to 3)")
        print("Enter the desired number:")
        code_mode = int(input())
        

    if code_mode == 1:
        print("Choosing NORMAL as code mode.")

        print("FIELD SIZE:")
        print("1: 4")
        print("2: 6")
        print("3: 8")
        print("4: 10")
        print("Enter the desired number:")
        
        print()
        field_size = int(input())

        while field_size not in range(1,5):
            print("Invalid input: please enter a valid test by picking the correct number (1 to 4)")
            print("Enter the desired number:")
            field_size = int(input())

        if field_size == 1:
            FIELDSIZE = "4"
        elif field_size == 2:
            FIELDSIZE = "6"
        elif field_size == 3:
            FIELDSIZE = "8"
        elif field_size == 4:
            FIELDSIZE = "10"

        CODEMODE = "NORMAL"


    if code_mode == 2:
        print("Choosing PARA 4 as code mode.")
        CODEMODE = "PARA4"
        FIELDSIZE = "8"

    if code_mode == 3:
        print("Choosing PARA 8 as code mode.")
        CODEMODE = "PARA8"
        FIELDSIZE = "4"   

if test_mode == 3:
    print("Entering ISW MULTIPLICATION tests. Please choose the following parameters")
    
    TESTMODE = "TEST_SECMULT_ISW"
    test_str = "test_2_secmult_isw.S"
    CIPHMODE = "ANY"

    print("NUMBER OF SHARES (x = sum_i^NUMBEROFSHARES x_i")
    print("Enter the desired number:")
    print("1: 2 shares")
    print("2: 3 shares")
    print("3: 4 shares")
    print("4: 5 shares")
    print("5: 6 shares")
    print("6: 7 shares")
    print("7: 8 shares")
    print("8: 9 shares")
    print("9: 10 shares")
    number_of_shares = int(input())

    print()
    print()

    while number_of_shares not in range(1,10):
        print("Invalid input: please enter a valid test by picking the correct number (1 to 9)")
        print("Enter the desired number:")
        number_of_shares = int(input())

    NUMBEROFSHARES = f"{number_of_shares+1}"

    print("CODE MODE (parallelisation level)")
    print("1: NORMAL")
    print("2: PARA 4 (4 elements in //")
    print("3: PARA 8 (8 elements in //")
    print("Enter the desired number:")
    print()
    code_mode = int(input())

    print()
    print()

    while code_mode not in range(1,4):
        print("Invalid input: please enter a valid test by picking the correct number (1 to 3)")
        print("Enter the desired number:")
        code_mode = int(input())


    if code_mode == 1:
        print("Choosing NORMAL as code mode.")

        CODEMODE = "NORMAL"

        print("MULTIPLICATION MODE:")
        print("1: EXPLOG2")
        print("2: HALFTAB")
        print("3: FULLTAB")
        print("Enter the desired number:")
        
        print()
        mult_mode = int(input())
        while mult_mode not in range(1,4):
            print("Invalid input: please enter a valid test by picking the correct number (1 to 3)")
            print("Enter the desired number:")
            mult_mode = int(input())

        if mult_mode == 1:
            print("FIELD SIZE:")
            print("1: 4")
            print("2: 6")
            print("3: 8")
            print("4: 10")
            print("Enter the desired number:")
            
            print()
            field_size = int(input())

            while field_size not in range(1,5):
                print("Invalid input: please enter a valid test by picking the correct number (1 to 4)")
                print("Enter the desired number:")
                field_size = int(input())

            if field_size == 1:
                FIELDSIZE = "4"
            elif field_size == 2:
                FIELDSIZE = "6"
            elif field_size == 3:
                FIELDSIZE = "8"
            elif field_size == 4:
                FIELDSIZE = "10"

            MULTMODE = "EXPLOG2"

        if mult_mode == 2:

            print("FIELD SIZE:")
            print("1: 4")
            print("2: 6")
            print("3: 8")
            print("4: 10")
            print("Enter the desired number:")
            
            print()
            field_size = int(input())

            while field_size not in range(1,5):
                print("Invalid input: please enter a valid test by picking the correct number (1 to 4)")
                print("Enter the desired number:")
                field_size = int(input())

            if field_size == 1:
                FIELDSIZE = "4"
            elif field_size == 2:
                FIELDSIZE = "6"
            elif field_size == 3:
                FIELDSIZE = "8"
            elif field_size == 4:
                FIELDSIZE = "10"

            MULTMODE = "HALFTAB"

        if mult_mode == 3:

            print("FIELD SIZE:")
            print("1: 4")
            print("2: 6")
            print("Enter the desired number:")
            
            print()
            field_size = int(input())

            while field_size not in range(1,3):
                print("Invalid input: please enter a valid test by picking the correct number (1 to 2)")
                print("Enter the desired number:")
                field_size = int(input())

            if field_size == 1:
                FIELDSIZE = "4"
            elif field_size == 2:
                FIELDSIZE = "6"

            MULTMODE = "FULLTAB"

    if code_mode == 2:
        print("Choosing PARA 4 as code mode.")
        CODEMODE = "PARA4"
        FIELDSIZE = "8"

        print("MULTIPLICATION MODE:")
        print("1: EXPLOG2")
        print("2: HALFTAB")
        print("Enter the desired number:")
        
        print()
        mult_mode = int(input())
        while mult_mode not in range(1,3):
            print("Invalid input: please enter a valid test by picking the correct number (1 to 2)")
            print("Enter the desired number:")
            mult_mode = int(input())

        if mult_mode == 1:
            MULTMODE = "EXPLOG2"

        if mult_mode == 2:
            MULTMODE = "HALFTAB"


    if code_mode == 3:
        print("Choosing PARA 8 as code mode.")
        CODEMODE = "PARA8"
        FIELDSIZE = "4"  
        
        print("MULTIPLICATION MODE:")
        print("1: EXPLOG2")
        print("2: HALFTAB")
        print("3: FULLTAB")
        print("Enter the desired number:")
        
        print()
        mult_mode = int(input())
        while mult_mode not in range(1,4):
            print("Invalid input: please enter a valid test by picking the correct number (1 to 3)")
            print("Enter the desired number:")
            mult_mode = int(input())

        if mult_mode == 1:
            MULTMODE = "EXPLOG2"

        if mult_mode == 2:
            MULTMODE = "HALFTAB"

        if mult_mode == 3:
            MULTMODE = "FULLTAB"

if test_mode == 4:
    print("Entering RP AES SBOX tests. Please choose the following parameters")

    TESTMODE = "TEST_SECSBOX_RPAES"
    test_str = "test_3_secsbox_rp.S"

    print("NUMBER OF SHARES (x = sum_i^NUMBEROFSHARES x_i")
    print("Enter the desired number:")
    print("1: 2 shares")
    print("2: 3 shares")
    print("3: 4 shares")
    print("4: 5 shares")
    print("5: 6 shares")
    print("6: 7 shares")
    print("7: 8 shares")
    print("8: 9 shares")
    print("9: 10 shares")
    number_of_shares = int(input())

    print()
    print()

    while number_of_shares not in range(1,10):
        print("Invalid input: please enter a valid test by picking the correct number (1 to 9)")
        print("Enter the desired number:")
        number_of_shares = int(input())

    NUMBEROFSHARES = f"{number_of_shares+1}"
    FIELDSIZE = 8
    CIPHMODE = "RP"

    print("CODE MODE (parallelisation level)")
    print("1: NORMAL")
    print("2: PARA 4 (4 elements in //")
    print("Enter the desired number:")
    print()
    code_mode = int(input())

    print()
    print()

    while code_mode not in range(1,3):
        print("Invalid input: please enter a valid test by picking the correct number (1 to 2)")
        print("Enter the desired number:")
        code_mode = int(input())

    if code_mode == 1:
        CODEMODE = "NORMAL"
    if code_mode == 2:
        CODEMODE = "PARA4"

    print("MULTIPLICATION MODE")
    print("1: HALFTAB")
    print("2: EXPLOG")
    print("Enter the desired number:")
    print()
    mult_mode = int(input())

    print()
    print()

    while mult_mode not in range(1,3):
        print("Invalid input: please enter a valid test by picking the correct number (1 to 2)")
        print("Enter the desired number:")
        mult_mode = int(input())

    if mult_mode == 1:
        MULTMODE = "HALFTABSHIFT"
    if mult_mode == 2:
        MULTMODE = "EXPLOG2SHIFT"

if test_mode == 5:
    print("Entering KHL AES SBOX tests. Please choose the following parameters")

    TESTMODE = "TEST_SECSBOX_KHLAES"
    test_str = "test_3_secsbox_khl.S"

    print("NUMBER OF SHARES (x = sum_i^NUMBEROFSHARES x_i")
    print("Enter the desired number:")
    print("1: 2 shares")
    print("2: 3 shares")
    print("3: 4 shares")
    print("4: 5 shares")
    print("5: 6 shares")
    print("6: 7 shares")
    print("7: 8 shares")
    print("8: 9 shares")
    print("9: 10 shares")
    number_of_shares = int(input())

    print()
    print()

    while number_of_shares not in range(1,10):
        print("Invalid input: please enter a valid test by picking the correct number (1 to 9)")
        print("Enter the desired number:")
        number_of_shares = int(input())

    NUMBEROFSHARES = f"{number_of_shares+1}"
    FIELDSIZE = 4
    CIPHMODE = "KHL"
    MULTMODE = "FULLTABSHIFT"

if test_mode == 6:
    print("Entering FoG PRESENT SBOX tests. Please choose the following parameters")

    TESTMODE = "TEST_SECSBOX_FOGPRESENT"
    test_str = "test_3_secsbox_fog.S"

    print("NUMBER OF SHARES (x = sum_i^NUMBEROFSHARES x_i")
    print("Enter the desired number:")
    print("1: 2 shares")
    print("2: 3 shares")
    print("3: 4 shares")
    print("4: 5 shares")
    print("5: 6 shares")
    print("6: 7 shares")
    print("7: 8 shares")
    print("8: 9 shares")
    print("9: 10 shares")
    number_of_shares = int(input())

    print()
    print()

    while number_of_shares not in range(1,10):
        print("Invalid input: please enter a valid test by picking the correct number (1 to 9)")
        print("Enter the desired number:")
        number_of_shares = int(input())

    NUMBEROFSHARES = f"{number_of_shares+1}"
    FIELDSIZE = "4"
    MULTMODE = "FULLTAB"
    CODEMODE = "PARA8"

if test_mode == 7:
    print("Entering BITSLICE AES SBOX tests. Please choose the following parameters")

    print("NUMBER OF SHARES (x = sum_i^NUMBEROFSHARES x_i")
    print("Enter the desired number:")
    print("1: 2 shares")
    print("2: 3 shares")
    print("3: 4 shares")
    print("4: 5 shares")
    print("5: 6 shares")
    print("6: 7 shares")
    print("7: 8 shares")
    print("8: 9 shares")
    print("9: 10 shares")
    number_of_shares = int(input())

    print()
    print()

    while number_of_shares not in range(1,10):
        print("Invalid input: please enter a valid test by picking the correct number (1 to 9)")
        print("Enter the desired number:")
        number_of_shares = int(input())

    NUMBEROFSHARES = f"{number_of_shares+1}"

    TESTMODE = "TEST_SECSBOX_BSAES"
    test_str = "test_3_secsbox_bsaes.S"
    FIELDSIZE = "8"
    MULTMODE = "EXPLOG2"

if test_mode == 8:
    print("Entering BITSLICE PRESENT SBOX tests. Please choose the following parameters")

    print("NUMBER OF SHARES (x = sum_i^NUMBEROFSHARES x_i")
    print("Enter the desired number:")
    print("1: 2 shares")
    print("2: 3 shares")
    print("3: 4 shares")
    print("4: 5 shares")
    print("5: 6 shares")
    print("6: 7 shares")
    print("7: 8 shares")
    print("8: 9 shares")
    print("9: 10 shares")
    number_of_shares = int(input())

    print()
    print()

    while number_of_shares not in range(1,10):
        print("Invalid input: please enter a valid test by picking the correct number (1 to 9)")
        print("Enter the desired number:")
        number_of_shares = int(input())

    NUMBEROFSHARES = f"{number_of_shares+1}"

    TESTMODE = "TEST_SECSBOX_BSPRESENT"
    test_str = "test_3_secsbox_bspresent.S"
    FIELDSIZE = "4"
    MULTMODE = "FULLTABSHIFT"

if test_mode == 9:
    print("Entering REGULAR AES CIPHER tests. Please choose the following parameters")

    print("NUMBER OF SHARES (x = sum_i^NUMBEROFSHARES x_i")
    print("Enter the desired number:")
    print("1: 2 shares")
    print("2: 3 shares")
    print("3: 4 shares")
    print("4: 5 shares")
    print("5: 6 shares")
    print("6: 7 shares")
    print("7: 8 shares")
    print("8: 9 shares")
    print("9: 10 shares")
    number_of_shares = int(input())

    print()
    print()

    while number_of_shares not in range(1,10):
        print("Invalid input: please enter a valid test by picking the correct number (1 to 9)")
        print("Enter the desired number:")
        number_of_shares = int(input())

    NUMBEROFSHARES = f"{number_of_shares+1}"

    TESTMODE = "TEST_SECCIPHER_REGAES"
    test_str = "test_4_seccipher_regaes.S"
    FIELDSIZE = "8"
    CODEMODE = "PARA4"
    CIPHMODE = "RP"

    print("MULTIPLICATION MODE")
    print("1: HALFTAB")
    print("2: EXPLOG")
    print("Enter the desired number:")
    print()
    mult_mode = int(input())

    print()
    print()

    while mult_mode not in range(1,3):
        print("Invalid input: please enter a valid test by picking the correct number (1 to 2)")
        print("Enter the desired number:")
        mult_mode = int(input())

    if mult_mode == 1:
        MULTMODE = "HALFTABSHIFT"
    if mult_mode == 2:
        MULTMODE = "EXPLOG2SHIFT"

if test_mode == 10:
    print("Entering REGULAR PRESENT CIPHER tests. Please choose the following parameters")

    print("NUMBER OF SHARES (x = sum_i^NUMBEROFSHARES x_i")
    print("Enter the desired number:")
    print("1: 2 shares")
    print("2: 3 shares")
    print("3: 4 shares")
    print("4: 5 shares")
    print("5: 6 shares")
    print("6: 7 shares")
    print("7: 8 shares")
    print("8: 9 shares")
    print("9: 10 shares")
    number_of_shares = int(input())

    print()
    print()

    while number_of_shares not in range(1,10):
        print("Invalid input: please enter a valid test by picking the correct number (1 to 9)")
        print("Enter the desired number:")
        number_of_shares = int(input())

    NUMBEROFSHARES = f"{number_of_shares+1}"

    TESTMODE = "TEST_SECCIPHER_REGPRESENT"
    test_str = "test_4_seccipher_regpresent.S"
    FIELDSIZE = "4"
    MULTMODE = "FULLTAB"
    CODEMODE = "PARA8"

if test_mode == 11:
    print("Entering BITSLICE AES CIPHER tests. Please choose the following parameters")

    print("NUMBER OF SHARES (x = sum_i^NUMBEROFSHARES x_i")
    print("Enter the desired number:")
    print("1: 2 shares")
    print("2: 3 shares")
    print("3: 4 shares")
    print("4: 5 shares")
    print("5: 6 shares")
    print("6: 7 shares")
    print("7: 8 shares")
    print("8: 9 shares")
    print("9: 10 shares")
    number_of_shares = int(input())

    print()
    print()

    while number_of_shares not in range(1,10):
        print("Invalid input: please enter a valid test by picking the correct number (1 to 9)")
        print("Enter the desired number:")
        number_of_shares = int(input())

    NUMBEROFSHARES = f"{number_of_shares+1}"

    TESTMODE = "TEST_SECCIPHER_BSAES"
    test_str = "test_4_seccipher_bsaes.S"
    FIELDSIZE = "8"
    MULTMODE = "EXPLOG2SHIFT"

if test_mode == 12:
    print("Entering BITSLICE PRESENT tests. Please choose the following parameters")

    print("NUMBER OF SHARES (x = sum_i^NUMBEROFSHARES x_i")
    print("Enter the desired number:")
    print("1: 2 shares")
    print("2: 3 shares")
    print("3: 4 shares")
    print("4: 5 shares")
    print("5: 6 shares")
    print("6: 7 shares")
    print("7: 8 shares")
    print("8: 9 shares")
    print("9: 10 shares")
    number_of_shares = int(input())

    print()
    print()

    while number_of_shares not in range(1,10):
        print("Invalid input: please enter a valid test by picking the correct number (1 to 9)")
        print("Enter the desired number:")
        number_of_shares = int(input())

    NUMBEROFSHARES = f"{number_of_shares+1}"

    TESTMODE = "TEST_SECCIPHER_BSPRESENT"
    test_str = "test_4_seccipher_bspresent.S"
    FIELDSIZE = "4"
    MULTMODE = "FULLTABSHIFT"
    
if test_mode != 1:
    print("RANDOMNESS CHOICE")
    print("1: TRNG")
    print("2: C RANDOM")
    print("Enter the desired number:")
    print()
    rand_mode = int(input())

    print()
    print()

    while rand_mode not in range(1,3):
        print("Invalid input: please enter a valid test by picking the correct number (1 to 2)")
        print("Enter the desired number:")
        rand_mode = int(input())

    if rand_mode == 1:
        RANDMODE = "TRNG"
    if rand_mode == 2:
        RANDMODE = "C_RAND"

print("Generating param.h and Makefile. Test the code by running 'make clean', 'make', and './hom_ec17'")


makefile_str = f'''
# THIS MAKEFILE WAS AUTOMATICALLY GENERATED VIA CONFIGURE SCRIPT. PLEASE DO NOT MODIFY IT.

.PHONY: clean, mrproper

CC = gcc
OCC = gcc
CFLAGS = -Wall -O0
DEPS = $(wildcard test/{test_str})
DEPH = param.h mode.h
OBJ = main.o


hom_ec17: main.c $(DEPH) $(DEPS)
	$(CC) $(CFLAGS) $? -o $@ 

# clean
clean:
	rm -rf *~ rm -rf *.o rm -rf rm src/*~ rm -rf src/*.o rm -rf test/*~
	rm -rf hom_ec17

'''

param_str = f'''
// THIS FILE WAS AUTOMATICALLY GENERATED VIA CONFIGURE SCRIPT. PLEASE DO NOT MODIFY IT.

#ifndef _PARAM_H
#define _PARAM_H

#include "mode.h"

#define uint unsigned int

/*****************************************************************************/
/*                                                                           */
/* 	              				PARAMETERS SELECTION	                     */
/*                                                                           */
/*****************************************************************************/


#define FIELDSIZE				{FIELDSIZE}
#define NBSHARES				{NUMBEROFSHARES}
#define MULT_MODE				{MULTMODE}
#define CODE_MODE				{CODEMODE}
#define CIPH_MODE				{CIPHMODE}
#define REF_MODE                {REFMODE}
#define	RAND_MODE				{RANDMODE}

#define TEST_MODE				{TESTMODE}
#define NB_TESTS				{NBTESTS}

#endif /* _PARAM_H */

'''

f = open("Makefile", "w")
f.write(makefile_str)
f.close()

f = open("param.h", "w")
f.write(param_str)
f.close()