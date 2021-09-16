#ifndef _MODE_H
#define _MODE_H


/*****************************************************************************/
/*                                                                           */
/* 	              			   PARAMETERS DEFINITION	                     */
/*                                                                           */
/*****************************************************************************/


/********************************/ 
/*								*/
/* 		FIELD MULTIPLICATION   	*/
/*								*/
/********************************/


#define BINMULT1				10
#define BINMULT2				11
#define EXPLOG1					12
#define EXPLOG2					13
#define KARA					14
#define HALFTAB					15
#define	FULLTAB					16
#define FULLTABSHIFT			17
#define EXPLOG2SHIFT			18
#define HALFTABSHIFT			19


/********************************/ 
/*								*/
/*	   PARALLELISATION LEVEL	*/
/*								*/
/********************************/


#define NORMAL					20
#define PARA2					21
#define PARA4					22 
#define PARA8					23
#define BITSLICE				24		


/********************************/ 
/*								*/
/* 		 CIPHER CHOICE  		*/
/*								*/
/********************************/	


#define ANY						30
#define KHL						31
#define RP						32


/********************************/ 
/*								*/
/* 		 REF CHOICE  		    */
/*								*/
/********************************/


#define RF1						40
#define RF4						41


/********************************/ 
/*								*/
/* 		  RANDOM CHOICE   		*/
/*								*/
/********************************/


#define TRNG					50
#define C_RAND					51

/********************************/ 
/*								*/
/* 		   TEST CHOICE   		*/
/*								*/
/********************************/

#define TEST_FIELDMULT					10 
#define TEST_SECMULT_CPRR				20
#define TEST_SECMULT_ISW				21
#define TEST_SECSBOX_RPAES				32
#define TEST_SECSBOX_KHLAES				33
#define TEST_SECSBOX_FOGPRESENT			34
#define TEST_SECSBOX_BSAES				35
#define TEST_SECSBOX_BSPRESENT			36
#define TEST_SECCIPHER_REGAES			40
#define TEST_SECCIPHER_REGPRESENT		41
#define TEST_SECCIPHER_BSAES			42
#define TEST_SECCIPHER_BSPRESENT		43


#endif /* _MODE_H */
