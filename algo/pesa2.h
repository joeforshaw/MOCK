/*  MOCK - Multiobjective Clustering with Automatoc K-Determination
    Copyright (C) 2004 David Corne, Joshua Knowles and Julia Handl
    Email: Julia.Handl@gmx.de

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

*/

#ifndef PESA2
#define PESA2

#include <stdio.h>
#include <stdlib.h>
#include <math.h>


typedef struct chrom {
    int **cen; // centers - 20 bits per dimension per center
    int *cenlab; // label
    int *g;
  double **ind;
  int *rank;
    double *o;
    double strength;
    int *box;
    int bn;
  int num;
  double rand;
  double even;
  double f;
  double sil;
  double e[7];
  double r;
  double s;
  int smallest;

} C;


void srandom(unsigned);
int myrand(int);
void eps_approx(double *vp, double *newpoint, int ts, int k, double *epsilon, int *num_vecs);
int eps_Pareto(double *vp, double *newpoint, int k, double *epsilon, int *num_vecs);
void remove_items(double *list, int *length, int k, int *kill);
void external_archive();
void box(double *vector, double *epsilon, double *b, int k);
void print_vec(double *vector, int k);
void backtrack(double *vector, int k, int *num_vecs);
void update_epsilon(double *epsilon, int k);
void copy_vector(double *from, double *to, int n, int k);
void insertion_sort(double *vec, int n, int k);

double mydrand();
void aga(double *vp, double *newpoint, int k, int *num_vecs);
void update_grid(double *newpoint, double *vp, int num_vecs, int k);
int get_index_nue(int num_vecs, double *vp);
void sphere(C *c);

int addmp(C *c);
int read_adb_data();  /* reads the data  == datafile at the end */
double getdouble(FILE *, double *, int); /* used by read_adb_data */
double eval_adb(C *c); /*  the eval function */
double mmin(double,double); /* used in eval_adb */
double mmax(double,double); /* ditto */

void print_vec(double *vector, int k);
void box(double *vector, double *epsilon, double *b, int k);
int eps_Pareto(double *vp, double *newpoint, int k, double *epsilon, int *num_vecs);
int equal(double *first, double *second, int n);
int eps_dom(double *first, double *second, int k, double *epsilon);
int dom(double *first, double *second, int n);
int compare_max(double *first, double *second, int n);
int compare_min(double *first, double *second, int n);
void calculate_ranges(double *vp, int k, int num_vecs);
void update_epsilon(double *epsilon, int k);
void external_archive();
void eps_approx(double *vp, double *newpoint, int ts, int k, double *epsilon, int *num_vecs);
void aga(double *vp, double *newpoint, int k, int *num_vecs);
int get_index_nue(int num_vecs, double *vp);
void update_grid(double *newpoint, double *vp, int num_vecs, int k);
int find_loc(double *eval);
void backtrack(double *vector, int k, int *num_vecs);
void copy_vector(double *from, double *to, int n, int k);
void insertion_sort(double *vec, int n, int k);
void remove_items(double *list, int *length, int k, int *kill);
int archivend();
int nd(int c, C *p, int s);
int dominated(int c, C *p, int s);
int covered(int c, C *p, int s);
int dominates(C *a, C *b);
int covers(C *a, C *b);
int addtoarchive(int ch);
int reduceep();
int updateranges(int ch);
int calculateboxes();
int filterdom();
int filter();
int initialize();
int print_ip_details();
int print_ep_details();
int print_results();
int print_chromosome(C *c, int g);
int evaluate(C *c);
int mx(C *c, int rl);
int dec3(C *c, int rl);
int dec4(C *c, int rl);
int co1(C *c);
int co2(C *c);
int f5(C *c);
int t1(C *c);
int t2(C *c);
int t3(C *c);
int t6(C *c);
int t4(C *c);
int t5(C *c);
int circles(C *c);
void sphere(C *c);
int copy_chromosome(C *from, C *to);
int ncoverinip(C *c);
int reproduce();
int update_occboxes();
int worstinip();
int ind_strength(C *c);
int crossover(int n);
int ensemble(int n);
void naive(int n);
void knn_uniform(int n);
int mutate(int n);
C *select1();
C *select2();
int myrand(int n);
double mydrand();
int randgene();
void srandom(unsigned x);
char *
 initstate2(
		unsigned seed,	
		char *arg_state,
		int n		
     );
char *
setstate2(char *arg_state);
int f2(C *c);
int f3(C *c);
int f4(C *c);
int ff5(C *c);
int correl(C *c);
int addmp(C *c);
double getdouble(FILE * file, double *valaddr, int stopateol);
int getint(FILE * f, int *valaddr, int stopateol);
int read_adb_data(void);
double eval_adb(C *c);
double mmin(double a, double b);
double mmax(double a, double b);


#endif
 

