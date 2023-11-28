#include <common_defs.h>

#ifndef SMATRIX
#define SMATRIX
typedef struct 
{
    int m;
    int n;
    int nnz;
    int isSymmetric;
	MAT_VAL_TYPE *value;
	int *columnindex;
	MAT_PTR_TYPE *rowpointer;
    int tilem;
    int tilen;
    MAT_PTR_TYPE *tile_ptr;
    int *tile_columnidx;
    int *tile_rowidx;
    int *tile_nnz;
    int numtile;
    MAT_VAL_TYPE *tile_csr_Value;
    unsigned char *tile_csr_Col;
    unsigned char *tile_csr_Ptr;
    unsigned short *mask;
    int *csc_tile_ptr;
    int *csc_tile_rowidx;
}SMatrix;
#endif