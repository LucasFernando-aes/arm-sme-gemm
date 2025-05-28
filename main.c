#include <stdlib.h>
#include <stdio.h>
#include <arm_sme.h>

//extern void matmul_opt(void);
//extern void preprocess_l(void);
int packing_lhs_16xk(int n, int m, float *a, int lda, float *b);
int packing_rhs_kx16(int m, int n, float *a, int lda, float *b);
extern void outer_product_4tile(float *A, float *B, float *C, int M, int N, int K, int LDC);

void print_matrix(int m, int n, float *mat){
	for (int i=0; i < m; i++){
		for (int j=0; j < n; j++){
			printf("%2.0f ", mat[i*n+j]);
		}
		printf("\n");
	}
}

int main(){

	//bool has_sme = __arm_has_sme();
	//printf("%d\n", has_sme);

	//if (!has_sme){
	//	printf("Arch has no SME extension.");       
	//	return 1;
	//}

	//f32 example A 16x16, B 16x16 and C 16x16
	int m = 32, n = 32, k = 8;
	float *A = (float *) malloc(m * k * sizeof(float));
	float *sa = (float *) malloc(m * k * sizeof(float));
	float *B = (float *) malloc(k * n * sizeof(float));
	float *sb = (float *) malloc(k * n * sizeof(float));
	float *C = (float *) calloc(m * n, sizeof(float));

	float count = 0;;
	for (int i = 0; i < m; i++){
		for(int j = 0; j < k; j++){
			A[i*k+j] = count;
			count += 1.;
		}
		count =0;
	}

	count = 0;
	for (int i = 0; i < k; i++){
		for(int j = 0; j < n; j++){
			B[i*n+j] = count;
			count += 1.;
		}
		count = 0;
	}
	

	//print_matrix(m, k, A); printf("\n");
	//print_matrix(2*k, 16,  sa); printf("\n");
	//print_matrix(k, n, B); printf("\n");
	//print_matrix(2*k, 16,  sb); printf("\n");
	//print_matrix(m, n, C);

	packing_lhs_16xk(k, m, A, k, sa);
	packing_rhs_kx16(k, n, B, n, sb);
	outer_product_4tile(sa, sb, C, m, n, k, n);

	print_matrix(32, 32, C);
	return 0;
}
