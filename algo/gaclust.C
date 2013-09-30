/*  MOCK - Multiobjective Clustering with Automatoc K-Determination
    Copyright (C) 2004 Joshua Knowles and Julia Handl
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


#include "gaclust.h"
#include "databin.h"
#include "conf.h"
#include "evaluation.h"
#include <stdlib.h>
#include <stdio.h>

using namespace std;

conf * par;
databin<USED_DATA_TYPE> * bin;

extern int prflag, prflag2, epindex, nobjs, nbits, rflag, prindex;
extern int ncents;
double meand[100];
extern char * dataname;
extern int run;
ofstream * pareto; 
static double minvar = 1.0;
static double minconn = 1.0;
extern int MAXNO;
extern int MINNO;
extern int SMALLEST;
extern int globalclust;
extern int globaldim;
extern int globalsize;
extern int L;
extern int jobnbr;



// size of the data set
int gaclust::gensize() {

   return par->binsize;
}


void gaclust::globalinit(int s) {

  std::cerr << "Using objective setting " << s << std::endl;
  par = new conf(TEST);    
  par->s = s;
 
}

void gaclust::init(char * name) {

  char * pathname;
  int dim;
  int size;
  int clust;
 
  size = globalsize;
  dim = globaldim;
  pathname = name;
  
  bin = new databin<USED_DATA_TYPE>(par, pathname, size, dim); 

}


int gaclust::evaluate(C *c, int knn)
{

  static int eval=0;
  int ass[par->binsize]; 
  
  // decode the adjacency-based encoding

  for (int i=0; i<par->binsize; i++) {
    ass[i] = -1;
  }

  int clctr = 0;
  int prev[par->binsize];
  for (int i=0; i<par->binsize; i++) {
    int ctr = 0;
    if (ass[i] == -1) {
      ass[i] = clctr;
      int neigh = c->g[i];
      prev[ctr++] = i;
      while (ass[neigh] == -1) {
	prev[ctr++] = neigh;
	ass[neigh] = clctr;
	neigh = c->g[neigh];
      }
      if (ass[neigh] != clctr) {
	ctr--;
	while (ctr >= 0) {
	  ass[prev[ctr]] = ass[neigh];
	  ctr--;
	}
      }
      else {
	clctr++;
      }
    }
  }

  int * ctr = new int[clctr];
  for (int i=0; i<clctr; i++) {
    ctr[i] = 0;
  }
  for (int i=0; i<par->binsize; i++) {
    ctr[ass[i]]++;
  }

  par->num_cluster = clctr;
  
  clustering clu(par);
  clu.init(par->num_cluster);

  data<USED_DATA_TYPE> ** centres = new data<USED_DATA_TYPE>*[par->num_cluster];

  for (int i=0; i<par->num_cluster;i++) {
    centres[i] = new data<USED_DATA_TYPE>(par);
  }

  for (int i=0; i<par->num_cluster; i++) {
    ctr[i] = 0;
  }

 
  for (int i=0; i<par->binsize; i++) {
    clu[i] = ass[i];
    centres[clu[i]]->add((*bin)[i]);
    ctr[clu[i]]++;
  }

  for (int i=0; i<par->num_cluster; i++) {
    centres[i]->div(ctr[i]);
    clu.newcentre(i, (centres[i]));
  }


  evaluation e(par);
  e.init(bin, &clu);


// OPTIMISATION CRITERIA
    
  // evaluate objective functions


  if (par->s==1) {
    // Handl and Knowles
    c->o[0] = e.connectivity(nn,L);
    c->o[1] = e.overalldeviation();
  }
  else if (par->s==2) {
    
    // Delattre and Hansen
    c->o[0] = e.completelink();//e.connectivity(nn,L);
    c->o[1] = 1.0/(1.0+e.singlelink());//e.overalldeviation();
  }
 else if (par->s==3) {
    c->o[0] = e.sum_of_squares();
    c->o[1] = 1.0/(1.0+e.min_of_distances());
  }
 else if (par->s==4) {
    c->o[0] = e.sum_of_squares();
    c->o[1] = par->num_cluster*1.0/(1.0+e.sum_of_distances());
  }

  c->num = par->num_cluster;
     
   

  if(prflag)
    {
      

      if(prflag2) {
	c->f = e.adjustedrandindex();//e.fmeasure(1);
	c->sil = e.silhouette();//e.fmeasure(1);
	c->e[0] = e.connectivity(nn,L);
	c->e[1] = e.overalldeviation();
	c->e[2] = e.completelink();
	c->e[3] = 1.0/(1.0+e.singlelink());
	c->e[4] = e.sum_of_squares();
	c->e[5] = 1.0/(1.0+e.sum_of_distances());
	c->e[6] = 1.0/(1.0+e.min_of_distances());

	for (int i=0;i<par->binsize;i++) {
	  
	  if (par->s==1) {

	    c->ind[i][0] = e.connectivity(nn,L,i);
	    //	    fprintf(stderr,"%f ",c->ind[i][0]);
	    c->ind[i][1] = e.overalldeviation(i);
	    //fprintf(stderr,"%f ",c->ind[i][1]);
	  }
	}



	print(&clu, nn, L, c->ind);
      }
      
    }
       

  eval++;
    
  delete [] ctr;
  for (int i=0;i<par->num_cluster;i++) {
    delete centres[i];
  }
  delete []centres;
    
}

void gaclust::itoa(int integer, char * c) {

    int ctr = 0;
    for (int i=0; i<10; i++) {
	c[i] = '\0';
    }
    while (ctr < 10) {

	int i = integer % 10;
	integer = integer-i;
	integer = integer / 10;

	switch(i) {
	    case 0: c[ctr] = '0'; break;
	    case 1: c[ctr] = '1'; break;
	    case 2: c[ctr] = '2'; break;
	    case 3: c[ctr] = '3'; break;
	    case 4: c[ctr] = '4'; break;
	    case 5: c[ctr] = '5'; break;
	    case 6: c[ctr] = '6'; break;
	    case 7: c[ctr] = '7'; break;
	    case 8: c[ctr] = '8'; break;
	    case 9: c[ctr] = '9'; break;
	}
	ctr++;

	if (integer == 0) break;

    }
    int end = 9;
    while (c[end] == '\0') {
	end--;
    }
    int start = 0;
    while (start < end) {
	char temp = c[start];
	c[start] = c[end];
	c[end] = temp;
	start++;
	end--;
    }
    return;
}


void gaclust::print(clustering * clust, int ** nnlist, int knn, double ** ind) {
    
 
  /*char name[20];
    sprintf(name, "%d-%d.all", jobnbr, epindex);
    ofstream out_all(name);

    char name2[20];
    sprintf(name2, "%d-%d.solution", jobnbr, epindex);
    ofstream out_all2(name2);
  */  

  int maxj = 0;
  for (int j=0; j<clust->num; j++) {
    for (int i=0; i<par->binsize; i++) {
      if (clust->partition[i] == j) {
	      maxj=j;
      }
    }
  }

  if (maxj < 25) {

    char name[130];
    sprintf(name, "data/%s.method%d.run%d.solution%d.part", par->filename,par->s, jobnbr, prindex);
    prindex++;
    // cerr << prindex << endl;
    ofstream out_k(name);
    
    // for (int j=0; j<clust->num; j++) {
      for (int i=0; i<par->binsize; i++) {
        // if (clust->partition[i] == j) {
          for (int k=0;k<par->bindim; k++) {
            out_k << (*bin)[i][k] << " ";
          }
          out_k << clust->partition[i] << std::endl; 
      }
    // }

    // for (int j=0; j<clust->num; j++) {
    //   for (int i=0; i<par->binsize; i++) {
  	 //    // if (clust->partition[i] == j) {
    //   	  for (int k=0;k<par->bindim; k++) {
    //   	    out_k << (*bin)[i][k] << " ";
    //   	  }
    //       out_k << clust->partition[i] << " " << ind[i][0] << " " << ind[i][1] << std::endl;
	   //    // }
    //   }
    //   // out_k << std::endl;
    //   // out_k << std::endl;
    // }  
  }


  /*     for (int i=0; i<par->binsize; i++) {
      int p = (*clust)[i];
      data<USED_DATA_TYPE> di(par, clust->centres[p]);
      double diff = (*bin)[i].distanceto(di);

 
      out_all << bin->label[i] << " " << p << " " << (diff)/(par->maxd)  << endl;

      for (int j=0; j<par->bindim; j++) {
	out_all2 << (*bin)[i][j] << " ";
      }
      out_all2 << bin->label[i] << " " << p << endl;
      }*/   
      


    /*    sprintf(name, "%d-%d.clust", jobnbr, epindex);
    ofstream out_k(name);
    out_k << par->num_cluster << endl;
    for (int i=0; i<par->num_cluster; i++) {
      for (int j=0; j<i; j++) {
	data<USED_DATA_TYPE> di(par, clust->centres[i]);
	data<USED_DATA_TYPE> dj(par, clust->centres[j]);
	double diff = di.distanceto(dj);
	out_k << diff << endl;
      }
      }*/

  


}


void gaclust::nnlist(int ** nnlist) {
    sort(nnlist);
} 
    


void gaclust::sort(int ** nn_arg) {

  int size = par->binsize-1;
  dtemp = new USED_DATA_TYPE[2*size];


    for (int i=0; i<par->binsize; i++) {
     

      if (dtemp == NULL) {
	cerr << "Error during memory allocation (gaclust:sort)" << endl;
	exit(0);
      }
  
      int ctr = 0;
 
      for (int j=0; j < par->binsize; j++) {
	if (i==j) continue;
	dtemp[ctr] = USED_DATA_TYPE(j);
	ctr++;
	dtemp[ctr] = bin->precomputed_d(i,j);
	ctr++;
      }
        
      qsort((void*)dtemp, size, (2*sizeof(USED_DATA_TYPE)), lt2);
    

      for (int j=0; j<size;j++) {
	nn_arg[i][j] = int(dtemp[j*2]);
      }
    
    }
    nn = nn_arg;
   
    delete [] dtemp;

}


int lt2(const void *a, const void *b) {
  USED_DATA_TYPE * pta = (USED_DATA_TYPE *)a;
  USED_DATA_TYPE * ptb = (USED_DATA_TYPE *)b;
 
    if (pta[1] < ptb[1])
	return -1;
    if (pta[1] > ptb[1])
	return 1;
 
   
    
    else return 0;
}


