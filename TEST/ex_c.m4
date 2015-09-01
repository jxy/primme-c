/*******************************************************************************
 *   PRIMME PReconditioned Iterative MultiMethod Eigensolver
 *   Copyright (C) 2015 College of William & Mary,
 *   James R. McCombs, Eloy Romero Alcalde, Andreas Stathopoulos, Lingfei Wu
 *
 *   This file is part of PRIMME.
 *
 *   PRIMME is free software; you can redistribute it and/or
 *   modify it under the terms of the GNU Lesser General Public
 *   License as published by the Free Software Foundation; either
 *   version 2.1 of the License, or (at your option) any later version.
 *
 *   PRIMME is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *   Lesser General Public License for more details.
 *
 *   You should have received a copy of the GNU Lesser General Public
 *   License along with this library; if not, write to the Free Software
 *   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 *
 *******************************************************************************
 *
 *  Example to compute the k largest eigenvalues in a 1-D Laplacian matrix.
 *
 ******************************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <math.h>
ifdef(`USE_COMPLEX', ``#include <complex.h>
'')dnl
ifdef(`USE_PETSC', ``#include <petscpc.h>
#include <petscmat.h>
'')dnl
#include "primme.h"   /* header file is required to run primme */ 
define(`PRIMME_NUM', ifdef(`USE_PETSC', `PetscScalar', ifdef(`USE_COMPLEX', `complex double', `double')))dnl
ifdef(`USE_PETSC', `
PetscErrorCode generateLaplacian1D(int n, Mat *A);
void PETScMatvec(void *x, void *y, int *blockSize, primme_params *primme);
void ApplyPCPrecPETSC(void *x, void *y, int *blockSize, primme_params *primme);
static void par_GlobalSumDouble(void *sendBuf, void *recvBuf, int *count,
                         primme_params *primme);
', `
void LaplacianMatrixMatvec(void *x, void *y, int *blockSize, primme_params *primme);
void LaplacianApplyPreconditioner(void *x, void *y, int *blockSize, primme_params *primme);
')dnl

int main (int argc, char *argv[]) {

   /* Solver arrays and parameters */
   double *evals;    /* Array with the computed eigenvalues */
   double *rnorms;   /* Array with the computed eigenpairs residual norms */
   PRIMME_NUM *evecs;    /* Array with the computed eigenvectors;
                        first vector starts in evecs[0],
                        second vector starts in evecs[primme.n],
                        third vector starts in evecs[primme.n*2]...  */
   primme_params primme;
                     /* PRIMME configuration struct */
ifdef(`ADVANCED', `   double targetShifts[1];
')dnl

   /* Other miscellaneous items */
   int ret;
   int i;
ifdef(`USE_PETSC', `   Mat A; /* problem matrix */
   PC pc;            /* preconditioner */
   PetscErrorCode ierr;
   MPI_Comm comm;

   PetscInitialize(&argc, &argv, NULL, NULL);

')dnl

   /* Set default values in PRIMME configuration struct */
   primme_initialize(&primme);

   /* Set problem matrix */
ifdef(`USE_PETSC', `   ierr = generateLaplacian1D(100, &A); CHKERRQ(ierr);
   primme.matrix = &A;
   primme.matrixMatvec = PETScMatvec;
', `   primme.matrixMatvec = LaplacianMatrixMatvec;
')dnl
                           /* Function that implements the matrix-vector product
                              A*x for solving the problem A*x = l*x */
  
   /* Set problem parameters */
ifdef(`USE_PETSC', `   ierr = MatGetSize(A, &primme.n, NULL); CHKERRQ(ierr);',
                   `   primme.n = 100;') /* set problem dimension */
   primme.numEvals = 10;   /* Number of wanted eigenpairs */
   primme.eps = 1e-9;      /* ||r|| <= eps * ||matrix|| */
   primme.target = primme_smallest;
                           /* Wanted the smallest eigenvalues */

   /* Set preconditioner (optional) */
ifdef(`USE_PETSC', `   ierr = PCCreate(PETSC_COMM_WORLD, &pc); CHKERRQ(ierr);
   ierr = PCSetType(pc, PCJACOBI); CHKERRQ(ierr);
   ierr = PCSetOperators(pc, A, A); CHKERRQ(ierr);
   ierr = PCSetFromOptions(pc); CHKERRQ(ierr);
   ierr = PCSetUp(pc); CHKERRQ(ierr);
   primme.preconditioner = &pc;
   primme.applyPreconditioner = ApplyPCPrecPETSC;
', `   primme.applyPreconditioner = LaplacianApplyPreconditioner;
')dnl
   primme.correctionParams.precondition = 1;

   /* Set advanced parameters if you know what are you doing (optional) */
   /*
   primme.maxBasisSize = 14;
   primme.minRestartSize = 4;
   primme.maxBlockSize = 1;
   primme.maxMatvecs = 1000;
   */

   /* Set method to solve the problem */
   primme_set_method(DYNAMIC, &primme);
   /* DYNAMIC uses a runtime heuristic to choose the fastest method between
       DEFAULT_MIN_TIME and DEFAULT_MIN_MATVECS. But you can set another
       method, such as LOBPCG_OrthoBasis_Window, directly */

ifdef(`USE_PETSC', `   /* Set parallel parameters */
   ierr = MatGetLocalSize(A, &primme.nLocal, NULL); CHKERRQ(ierr);
   comm = PETSC_COMM_WORLD;
   primme.commInfo = &comm;
   MPI_Comm_size(comm, &primme.numProcs);
   MPI_Comm_rank(comm, &primme.procID);
   primme.globalSumDouble = par_GlobalSumDouble;

')dnl
   /* Display PRIMME configuration struct (optional) */
ifdef(`USE_PETSC', `   if (primme.procID == 0) /* Reports process with ID 0 */
   ')   primme_display_params(primme);

   /* Allocate space for converged Ritz values and residual norms */
   evals = (double *)primme_calloc(primme.numEvals, sizeof(double), "evals");
   evecs = (PRIMME_NUM *)primme_calloc(primme.n*primme.numEvals, 
                                sizeof(PRIMME_NUM), "evecs");
   rnorms = (double *)primme_calloc(primme.numEvals, sizeof(double), "rnorms");

define(`CALL_PRIMME', `   /* Call primme  */
ifdef(`USE_PETSC', ``#if defined(PETSC_USE_COMPLEX)
   ret = zprimme(evals, (Complex_Z*)evecs, rnorms, &primme);
#else
   ret = dprimme(evals, evecs, rnorms, &primme);
#endif
'',
`   ret = ifdef(`USE_COMPLEX',`z', `d')primme(evals, ifdef(`USE_COMPLEX', `(Complex_Z*)')evecs, rnorms, &primme);
')dnl

   if (ret != 0) {
      fprintf(primme.outputFile, 
         "Error: primme returned with nonzero exit status: %d \n",ret);
      return -1;
   }

ifdef(`USE_PETSC', ``   if (primme.procID == 0) { /* Reports process with ID 0 */
' define(sp, `   ')', `define(sp, `')')dnl
   sp()/* Reporting (optional) */
   sp()primme_PrintStackTrace(primme);

   sp()for (i=0; i < primme.initSize; i++) {
   sp()   fprintf(primme.outputFile, "Eval[%d]: %-22.15E rnorm: %-22.15E\n", i+1,
   sp()      evals[i], rnorms[i]); 
   sp()}
   sp()fprintf(primme.outputFile, " %d eigenpairs converged\n", primme.initSize);
   sp()fprintf(primme.outputFile, "Tolerance : %-22.15E\n", 
   sp()                                                      primme.aNorm*primme.eps);
   sp()fprintf(primme.outputFile, "Iterations: %-d\n", 
   sp()                                              primme.stats.numOuterIterations); 
   sp()fprintf(primme.outputFile, "Restarts  : %-d\n", primme.stats.numRestarts);
   sp()fprintf(primme.outputFile, "Matvecs   : %-d\n", primme.stats.numMatvecs);
   sp()fprintf(primme.outputFile, "Preconds  : %-d\n", primme.stats.numPreconds);
   sp()if (primme.locking && primme.intWork && primme.intWork[0] == 1) {
   sp()   fprintf(primme.outputFile, "\nA locking problem has occurred.\n");
   sp()   fprintf(primme.outputFile,
   sp()      "Some eigenpairs do not have a residual norm less than the tolerance.\n");
   sp()   fprintf(primme.outputFile,
   sp()      "However, the subspace of evecs is accurate to the required tolerance.\n");
   sp()}

   sp()switch (primme.dynamicMethodSwitch) {
   sp()   case -1: fprintf(primme.outputFile,
   sp()         "Recommended method for next run: DEFAULT_MIN_MATVECS\n"); break;
   sp()   case -2: fprintf(primme.outputFile,
   sp()         "Recommended method for next run: DEFAULT_MIN_TIME\n"); break;
   sp()   case -3: fprintf(primme.outputFile,
   sp()         "Recommended method for next run: DYNAMIC (close call)\n"); break;
   sp()}
ifdef(`USE_PETSC', `   }
')dnl
')dnl end of CALL_PRIMME
CALL_PRIMME
ifdef(`ADVANCED', `
   /* Note that d/zprimme can be called more than once before call primme_Free. */
   /* Find the 5 eigenpairs closest to .5 */
   primme.numTargetShifts = 1;
   targetShifts[0] = .5;
   primme.targetShifts = targetShifts;
   primme.target = primme_closest_abs;
   primme.numEvals = 5;
   primme.initSize = 0; /* primme.initSize may be not zero after a d/zprimme;
                           so set it to zero to avoid the already converged eigenvectors
                           being used as initial vectors. */

CALL_PRIMME

   /* Perturb the 5 approximate eigenvectors in evecs and used them as initial solution.
      This time the solver should converge faster than the last one. */
   for (i=0; i<primme.n*5; i++)
      evecs[i] += rand()/(double)RAND_MAX*1e-4;
   primme.initSize = 5;
   primme.numEvals = 5;

CALL_PRIMME

   /* Find the next 5 eigenpairs closest to .5 */
   primme.initSize = 0;
   primme.numEvals = 5;
   primme.numOrthoConst = 5; /* solver will find solutions orthogonal to the already
                                5 approximate eigenvectors in evecs */

CALL_PRIMME
')dnl
   primme_Free(&primme);
   free(evals);
   free(evecs);
   free(rnorms);

ifdef(`USE_PETSC', `   ierr = PetscFinalize(); CHKERRQ(ierr);

')dnl
  return(0);
}

/* 1-D Laplacian block matrix-vector product, Y = A * X, where

   - X, input dense matrix of size primme.n x blockSize;
   - Y, output dense matrix of size primme.n x blockSize;
   - A, tridiagonal square matrix of dimension primme.n with this form:

        [ 2 -1  0  0  0 ... ]
        [-1  2 -1  0  0 ... ]
        [ 0 -1  2 -1  0 ... ]
         ...
*/
ifdef(`USE_PETSC', `
PetscErrorCode generateLaplacian1D(int n, Mat *A) {
   PetscScalar    value[3] = {-1.0, 2.0, -1.0};
   PetscInt       i,Istart,Iend,col[3];
   PetscBool      FirstBlock=PETSC_FALSE,LastBlock=PETSC_FALSE;
   PetscErrorCode ierr;

   PetscFunctionBegin;

   ierr = MatCreate(PETSC_COMM_WORLD, A); CHKERRQ(ierr);
   ierr = MatSetSizes(*A, PETSC_DECIDE, PETSC_DECIDE, n, n); CHKERRQ(ierr);
   ierr = MatSetFromOptions(*A); CHKERRQ(ierr);
   ierr = MatSetUp(*A); CHKERRQ(ierr);

   ierr = MatGetOwnershipRange(*A, &Istart, &Iend); CHKERRQ(ierr);
   if (Istart == 0) FirstBlock = PETSC_TRUE;
   if (Iend == n) LastBlock = PETSC_TRUE;
   for (i=(FirstBlock? Istart+1: Istart); i<(LastBlock? Iend-1: Iend); i++) {
      col[0]=i-1; col[1]=i; col[2]=i+1;
      ierr = MatSetValues(*A, 1, &i, 3, col, value, INSERT_VALUES); CHKERRQ(ierr);
   }
   if (LastBlock) {
      i=n-1; col[0]=n-2; col[1]=n-1;
      ierr = MatSetValues(*A, 1, &i, 2, col, value, INSERT_VALUES); CHKERRQ(ierr);
   }
   if (FirstBlock) {
      i=0; col[0]=0; col[1]=1; value[0]=2.0; value[1]=-1.0;
      ierr = MatSetValues(*A, 1, &i, 2, col, value, INSERT_VALUES); CHKERRQ(ierr);
   }

   ierr = MatAssemblyBegin(*A, MAT_FINAL_ASSEMBLY);CHKERRQ(ierr);
   ierr = MatAssemblyEnd(*A, MAT_FINAL_ASSEMBLY);CHKERRQ(ierr);

   PetscFunctionReturn(0);
}

void PETScMatvec(void *x, void *y, int *blockSize, primme_params *primme) {
   int i;
   Mat *matrix;
   Vec xvec, yvec;
   PetscErrorCode ierr;

   matrix = (Mat *)primme->matrix;

   ierr = MatCreateVecs(*matrix, &xvec, &yvec); CHKERRABORT(*(MPI_Comm*)primme->commInfo, ierr);
   for (i=0; i<*blockSize; i++) {
      ierr = VecPlaceArray(xvec, ((PetscScalar*)x) + primme->nLocal*i); CHKERRABORT(*(MPI_Comm*)primme->commInfo, ierr);
      ierr = VecPlaceArray(yvec, ((PetscScalar*)y) + primme->nLocal*i); CHKERRABORT(*(MPI_Comm*)primme->commInfo, ierr);
      ierr = MatMult(*matrix, xvec, yvec); CHKERRABORT(*(MPI_Comm*)primme->commInfo, ierr);
      ierr = VecResetArray(xvec); CHKERRABORT(*(MPI_Comm*)primme->commInfo, ierr);
      ierr = VecResetArray(yvec); CHKERRABORT(*(MPI_Comm*)primme->commInfo, ierr);
   }
   ierr = VecDestroy(&xvec); CHKERRABORT(*(MPI_Comm*)primme->commInfo, ierr);
   ierr = VecDestroy(&yvec); CHKERRABORT(*(MPI_Comm*)primme->commInfo, ierr);
}
', `
void LaplacianMatrixMatvec(void *x, void *y, int *blockSize, primme_params *primme) {
   
   int i;            /* vector index, from 0 to *blockSize-1*/
   int row;          /* Laplacian matrix row index, from 0 to matrix dimension */
   PRIMME_NUM *xvec;     /* pointer to i-th input vector x */
   PRIMME_NUM *yvec;     /* pointer to i-th output vector y */
   
   for (i=0; i<*blockSize; i++) {
      xvec = (PRIMME_NUM *)x + primme->n*i;
      yvec = (PRIMME_NUM *)y + primme->n*i;
      for (row=0; row<primme->n; row++) {
         yvec[row] = 0.0;
         if (row-1 >= 0) yvec[row] += -1.0*xvec[row-1];
         yvec[row] += 2.0*xvec[row];
         if (row+1 < primme->n) yvec[row] += -1.0*xvec[row+1];
      }      
   }
}
')dnl

/* This performs Y = M^{-1} * X, where

   - X, input dense matrix of size primme.n x blockSize;
   - Y, output dense matrix of size primme.n x blockSize;
   - M, diagonal square matrix of dimension primme.n with 2 in the diagonal.
*/
ifdef(`USE_PETSC', `
void ApplyPCPrecPETSC(void *x, void *y, int *blockSize, primme_params *primme) {
   int i;
   Mat *matrix;
   PC *pc;
   Vec xvec, yvec;
   PetscErrorCode ierr;
   
   matrix = (Mat *)primme->matrix;
   pc = (PC *)primme->preconditioner;

   ierr = MatCreateVecs(*matrix, &xvec, &yvec); CHKERRABORT(*(MPI_Comm*)primme->commInfo, ierr);
   for (i=0; i<*blockSize; i++) {
      ierr = VecPlaceArray(xvec, ((PetscScalar*)x) + primme->nLocal*i); CHKERRABORT(*(MPI_Comm*)primme->commInfo, ierr);
      ierr = VecPlaceArray(yvec, ((PetscScalar*)y) + primme->nLocal*i); CHKERRABORT(*(MPI_Comm*)primme->commInfo, ierr);
      ierr = PCApply(*pc, xvec, yvec); CHKERRABORT(*(MPI_Comm*)primme->commInfo, ierr);
      ierr = VecResetArray(xvec); CHKERRABORT(*(MPI_Comm*)primme->commInfo, ierr);
      ierr = VecResetArray(yvec); CHKERRABORT(*(MPI_Comm*)primme->commInfo, ierr);
   }
   ierr = VecDestroy(&xvec); CHKERRABORT(*(MPI_Comm*)primme->commInfo, ierr);
   ierr = VecDestroy(&yvec); CHKERRABORT(*(MPI_Comm*)primme->commInfo, ierr);
}

static void par_GlobalSumDouble(void *sendBuf, void *recvBuf, int *count, 
                         primme_params *primme) {
   MPI_Comm communicator = *(MPI_Comm *) primme->commInfo;

   MPI_Allreduce(sendBuf, recvBuf, *count, MPI_DOUBLE, MPI_SUM, communicator);
}
', `
void LaplacianApplyPreconditioner(void *x, void *y, int *blockSize, primme_params *primme) {
   
   int i;            /* vector index, from 0 to *blockSize-1*/
   int row;          /* Laplacian matrix row index, from 0 to matrix dimension */
   PRIMME_NUM *xvec;     /* pointer to i-th input vector x */
   PRIMME_NUM *yvec;     /* pointer to i-th output vector y */
    
   for (i=0; i<*blockSize; i++) {
      xvec = (PRIMME_NUM *)x + primme->n*i;
      yvec = (PRIMME_NUM *)y + primme->n*i;
      for (row=0; row<primme->n; row++) {
         yvec[row] = xvec[row]/2.;
      }      
   }
}
')dnl
