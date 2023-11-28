
#include <iostream>
#include <fstream>
#include <string>
#include <algorithm> 
#include <mmio_cust.h>
#include <common_defs.h>
#include <numeric>
#include <data_struct.h>
#include <parse_mat.h>
#include <csr2tile.h>
#include <tile_spgemm.h>

int main(){


    SMatrix *matrixA = (SMatrix *)malloc(sizeof(SMatrix));
	SMatrix *matrixB = (SMatrix *)malloc(sizeof(SMatrix));

    const char * filename = "pwtk.mtx";
    
    parse_mtx(&matrixA->m, &matrixA->n, &matrixA->nnz, &matrixA->isSymmetric, &matrixA->rowpointer, &matrixA->columnindex, &matrixA->value, filename);
    
    // Parse MTX A
    std::cout << "Parsed  MAT A :m = " << matrixA->m << ", " << "n = " << matrixA->n << "\n";

    // Parse MTX B
    parse_mtx(&matrixB->m, &matrixB->n, &matrixB->nnz, &matrixB->isSymmetric, &matrixB->rowpointer, &matrixB->columnindex, &matrixB->value, filename);
    std::cout << "Parsed  MAT B :m = " << matrixB->m << ", " << "n = " << matrixB->n << "\n";

    // Convert A to Tile row major format?
    csr2tile_row_major(matrixA);

    // Convert B to Tile column major format
    csr2tile_col_major(matrixB);

    int blk_intersec_bitmask_len = ceil((double)matrixA->tilen / 32.0);
    double densityA = (double)matrixA->numtile / ((double)matrixA->tilem*(double)matrixA->tilen);
    double densityB = (double)matrixB->numtile / ((double)matrixB->tilem*(double)matrixB->tilen);


    long long int lengthA = (long long int) (matrixA->tilem) * (long long int)( blk_intersec_bitmask_len) ;

    unsigned int *blk_intersec_bitmask_A = (unsigned int *)malloc(lengthA* sizeof(unsigned int));
    memset(blk_intersec_bitmask_A, 0, lengthA * sizeof(unsigned int));
    for (int i = 0; i < matrixA->tilem; i++)
    {
        for (int j = matrixA->tile_ptr[i]; j < matrixA->tile_ptr[i + 1]; j++)
        {
            int idx = matrixA->tile_columnidx[j];
            unsigned int bitmask = 1;
            bitmask <<=  (31- (idx % 32));
            long long int pos = (long long int)i * (long long int)blk_intersec_bitmask_len + idx / 32;
            blk_intersec_bitmask_A[pos] |= bitmask;
        }
    }

    long long int lengthB = (long long int) (matrixB->tilen) * (long long int)(blk_intersec_bitmask_len) ;

    unsigned int *blk_intersec_bitmask_B = (unsigned int *)malloc(lengthB * sizeof(unsigned int));
    memset(blk_intersec_bitmask_B, 0, lengthB * sizeof(unsigned int));
    for (int i = 0; i < matrixB->tilen; i++)
    {
        for (int j = matrixB->csc_tile_ptr[i]; j < matrixB->csc_tile_ptr[i+1]; j++)
        {
            int idx = matrixB->csc_tile_rowidx[j];
            unsigned int bitmask = 0x1;
            bitmask <<= (31 - (idx % 32));
            long long int pos = (long long int)i * (long long int )blk_intersec_bitmask_len + idx / 32;
            blk_intersec_bitmask_B[pos] |= bitmask;
        }
    }


    // generate rowidx of blockA
    int *tile_rowidx_A = (int *)malloc (matrixA->numtile * sizeof(int ) );
    for (int i = 0; i < matrixA->tilem; i++)
    {
        for (int j = matrixA->tile_ptr[i]; j < matrixA->tile_ptr[i+1]; j++)
        {
            tile_rowidx_A[j] = i;
        }
    }

    // --------------------------------------------------------------------------------------------------------
    SMatrix *matrixC = (SMatrix *)malloc(sizeof(SMatrix));
    
    unsigned long long int nnzC_computed;
    double compression_rate = 0;
    double time_tile = 0;
    double gflops_tile = 0;
    double time_step1 =0,time_step2 =0,time_step3 =0,time_malloc=0; 


}