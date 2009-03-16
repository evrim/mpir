/* Generated by tuneup.c, 2009-02-28, gcc 4.2 */

#define MUL_KARATSUBA_THRESHOLD          28
#define MUL_TOOM3_THRESHOLD              86

#define SQR_BASECASE_THRESHOLD            0  /* always (native) */
#define SQR_KARATSUBA_THRESHOLD          33
#define SQR_TOOM3_THRESHOLD             117

#define MULLOW_BASECASE_THRESHOLD         5
#define MULLOW_DC_THRESHOLD              28
#define MULLOW_MUL_N_THRESHOLD          327

#define DIV_SB_PREINV_THRESHOLD           0  /* always */
#define DIV_DC_THRESHOLD                 60
#define POWM_THRESHOLD                  154

#define GCD_ACCEL_THRESHOLD             114
#define GCDEXT_THRESHOLD                  0  /* always */
#define JACOBI_BASE_METHOD                1

#define DIVREM_1_NORM_THRESHOLD           0  /* always */
#define DIVREM_1_UNNORM_THRESHOLD         0  /* always */
#define MOD_1_NORM_THRESHOLD              0  /* always */
#define MOD_1_UNNORM_THRESHOLD            0  /* always */
#define USE_PREINV_DIVREM_1               1
#define USE_PREINV_MOD_1                  1
#define DIVREM_2_THRESHOLD                0  /* always */
#define DIVEXACT_1_THRESHOLD              0  /* always */
#define MODEXACT_1_ODD_THRESHOLD          0  /* always */

#define GET_STR_DC_THRESHOLD             14
#define GET_STR_PRECOMPUTE_THRESHOLD     19
#define SET_STR_THRESHOLD              7059

#define MUL_FFT_TABLE  { 816, 1696, 3904, 7936, 19456, 61440, 147456, 458752, 0 }
#define MUL_FFT_MODF_THRESHOLD          832
#define MUL_FFT_THRESHOLD             17920

#define SQR_FFT_TABLE  { 848, 1824, 3648, 7424, 19456, 45056, 147456, 458752, 0 }
#define SQR_FFT_MODF_THRESHOLD          976
#define SQR_FFT_THRESHOLD             14848

/* Tuneup completed successfully, took 74 seconds */