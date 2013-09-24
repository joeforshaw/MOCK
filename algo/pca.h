
void pca(float ** mydata, int mysize, int mydim);
void corcol(float ** data, int n, int m, float ** symmat);
void covcol(float ** data, int n, int m, float ** symmat);
void scpcol(float ** data, int n, int m, float **symmat);
void erhand(char * err_msg);
float *vector(int n);
float **mymatrix(int n,int m);
void free_vector(float * v,int n);
void free_matrix(float ** mat,int n,int m);
void tred2(float ** a, int n, float *d, float * e);
void tqli(float * d, float * e, int n, float ** z);

