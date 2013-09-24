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


#include "evaluation.h"


evaluation::evaluation(conf * c) {
    par = c;
}

evaluation::~evaluation() {
  
}

void evaluation::init(databin<USED_DATA_TYPE> * b, clustering * cl) {
    bin = b;
    clust = cl;
}

double evaluation::square(double x) {
    return x*x;
}

double evaluation::myabs(double x) {
  if (x < 0) return -x;
  else return x;
}

int evaluation::mymin(int x, int y) {
  if (x < y) return x;
  else return y;
}

/****************************************************************************************

 Evaluation measures for unsupervised clustering, i.e. when the real partitions are NOT known 

 - Variance
 - Overall Deviation
 - Connectivity
 
****************************************************************************************/




double evaluation::smallest() {
 
    int * count = new int [clust->num];
    for (int i=0; i<clust->num; i++) {
	count[i] = 0;
    }

    for (int i=0; i<par->binsize; i++) {
	count[(*clust)[i]]++;
    }

    int minsize = count[0];
    for (int i=1; i<clust->num; i++) {
      minsize = mymin(minsize, count[i]);

    }

    delete [] count;
    return minsize;
}





double evaluation::evenness() {

    int * count = new int [clust->num];
    for (int i=0; i<clust->num; i++) {
	count[i] = 0;
    }

    for (int i=0; i<par->binsize; i++) {
	count[(*clust)[i]]++;
    }

    double av = 0.0;
    for (int i=0; i<par->num_cluster; i++) {
	av += count[i];
    }
    av /= double(clust->num);


    double ms = 0;
    for (int i=0; i<par->num_cluster; i++) {
	ms += myabs(count[i]-av);
    }

    ms /= double(par->num_cluster);
    delete [] count;
    return ms;
        
}
    
	


double evaluation::connectivity(int ** nnlist, int knn) {
  
    double sum = 0;
    int ctr[clust->num];

    double penalty[knn];
    for (int j=0; j<knn; j++) {
      penalty[j] = 1.0/(double(j)+1.0);
    }
  
    for (int i=0; i<par->binsize; i++) {
      
	double nctr = 0.0;
	int label = (*clust)[i];

	for (int j=0; j<knn; j++) {
	  
	  int nn_label = (*clust)[nnlist[i][j]];
	 	  
	  if (label != nn_label) {
	    nctr += penalty[j];
	  }
	
	}
	sum += nctr;
    }

    return (sum);
}


double evaluation::connectivity(int ** nnlist, int knn, int index) {

    double sum = 0;
    int ctr[clust->num];

    double penalty[knn];
    for (int j=0; j<knn; j++) {
      penalty[j] = 1.0/(double(j)+1.0);
    }
  
    int i = index;
    double nctr = 0.0;
    int label = (*clust)[i];

    for (int j=0; j<knn; j++) {
	  
      int nn_label = (*clust)[nnlist[i][j]];
	 	  
      if (label != nn_label) {
	nctr += penalty[j];
      }
	
    }
    sum += nctr;
    
    return (sum);
}


double evaluation::completelink() {
  
  double * diameter = new double[clust->num];
  
  // initialisation
  for (int i=0; i<clust->num; i++) {
    diameter[i] = 0.0;
 
  }

  for (int i=0; i<par->binsize; i++) {
    for (int j=0; j<i; j++) {
	double diff = 0.0;
	int p1 = clust->partition[i];
	int p2 = clust->partition[j];
	if (p1 == p2) {
	  diff = (*bin)[i].distanceto((*bin)[j]);
	  diameter[p1]=max(diameter[p1],diff);
	}
    }
  }
  double maxdiameter=0;
  for (int i=0; i<clust->num; i++) {
    if (diameter[i] > maxdiameter) {
      maxdiameter=diameter[i];
    }
  }
  return maxdiameter;
}





double evaluation::singlelink() {
  
  if (clust->num==1) {
    return 1e10;
  }

  double * split = new double[clust->num];
  
  // initialisation
  for (int i=0; i<clust->num; i++) {
    split[i] = 1e10;
 
  }

  for (int i=0; i<par->binsize; i++) {
    for (int j=0; j<i; j++) {
	double diff = 0.0;
	int p1 = clust->partition[i];
	int p2 = clust->partition[j];
	if (p1 != p2) {
	  diff = (*bin)[i].distanceto((*bin)[j]);
	  split[p1]=min(split[p1],diff);
	  split[p2]=min(split[p2],diff);
	}
    }
  }
  double minsplit=1e10;
  for (int i=0; i<clust->num; i++) {
    if (split[i] < minsplit) {
      minsplit=split[i];
    }
  }
  //  std::cerr<< minsplit<<std::endl;
  return minsplit;
}

double evaluation::overalldeviation() {

    double * var = new double[clust->num];
    int * ctr = new int[clust->num];

    // initialisation

    for (int i=0; i<clust->num; i++) {
	var[i] = 0.0;
	ctr[i] = 0;
    }

    data<USED_DATA_TYPE> ** di = new data<USED_DATA_TYPE> * [clust->num];
    for (int i=0; i<clust->num; i++) {
      di[i] = new data<USED_DATA_TYPE>(par, clust->centres[i]);
    }

    for (int i=0; i<par->binsize; i++) {

	double diff = 0.0;
	int p = clust->partition[i];
	diff = (*bin)[i].distanceto(*(di[p]));
	var[p] += diff;
    }

   

    double totalvariance = 0.0;
    for (int i=0; i<clust->num; i++) {
	totalvariance += var[i];

    }

    for (int i=0; i<clust->num; i++) {
      delete di[i];
    }
    delete [] di;

    delete [] var;
    delete [] ctr;

    return (totalvariance);
}


double evaluation::overalldeviation(int index) {

    double * var = new double[clust->num];
    int * ctr = new int[clust->num];

    // initialisation

    for (int i=0; i<clust->num; i++) {
	var[i] = 0.0;
	ctr[i] = 0;
    }

    data<USED_DATA_TYPE> ** di = new data<USED_DATA_TYPE> * [clust->num];
    for (int i=0; i<clust->num; i++) {
      di[i] = new data<USED_DATA_TYPE>(par, clust->centres[i]);
    }

    // for (int i=0; i<par->binsize; i++) {
    int i = index;
    double diff = 0.0;
    int p = clust->partition[i];
    diff = (*bin)[i].distanceto(*(di[p]));
    var[p] += diff;
    

   
    double totalvariance = 0.0;
    for (int i=0; i<clust->num; i++) {
      totalvariance += var[i];
    }

    for (int i=0; i<clust->num; i++) {
      delete di[i];
    }
    delete [] di;

    delete [] var;
    delete [] ctr;

    return (totalvariance);
}


double evaluation::min_of_distances() {


    // initialisation
    double mind=1e10;
    

    data<USED_DATA_TYPE> ** di = new data<USED_DATA_TYPE> * [clust->num];
    for (int i=0; i<clust->num; i++) {
      di[i] = new data<USED_DATA_TYPE>(par, clust->centres[i]);
    }
    
    for (int i=0; i<clust->num; i++) {
      for (int j=0; j<i; j++) {
	  double diff = (*(di[j])).distanceto(*(di[i]));
	  mind=min(mind,diff);
	}
    }
    return mind;
}


double evaluation::sum_of_distances() {


    // initialisation
    double sum=0.0;
    int ctr=0;

    data<USED_DATA_TYPE> ** di = new data<USED_DATA_TYPE> * [clust->num];
    for (int i=0; i<clust->num; i++) {
      di[i] = new data<USED_DATA_TYPE>(par, clust->centres[i]);
    }
    for (int i=0; i<clust->num; i++) {
      for (int j=0; j<i; j++) {
	  double diff = (*(di[j])).distanceto(*(di[i]));
	  sum+= diff;
	  ctr++;
	}
    }
    return sum/ctr;
}


double evaluation::sum_of_squares() {

    double * var = new double[clust->num];
    int * ctr = new int[clust->num];

    // initialisation

    for (int i=0; i<clust->num; i++) {
	var[i] = 0.0;
	ctr[i] = 0;
    }

    data<USED_DATA_TYPE> ** di = new data<USED_DATA_TYPE> * [clust->num];
    for (int i=0; i<clust->num; i++) {
      di[i] = new data<USED_DATA_TYPE>(par, clust->centres[i]);
    }

    for (int i=0; i<par->binsize; i++) {
	double diff = 0.0;
	int p = clust->partition[i];
	diff = (*bin)[i].distanceto(*(di[p]));
	var[p] += diff*diff;
    }

   

    double totalvariance = 0.0;
    for (int i=0; i<clust->num; i++) {
	totalvariance += var[i];

    }

    for (int i=0; i<clust->num; i++) {
      delete di[i];
    }
    delete [] di;

    delete [] var;
    delete [] ctr;

    return (totalvariance);
}

/*double evaluation::connectivity(int ** nnlist, int knn) {

    double sum = 0;
    int ctr[clust->num];
  
    for (int i=0; i<par->binsize; i++) {
      
	double nctr = 0.0;
	int label = (*clust)[i];

	for (int j=0; j<knn; j++) {
	  
	  int nn_label = (*clust)[nnlist[i][j]];
	 	  

	  if (label != nn_label) {
	    
	    nctr += 1.0/(double(j)+1.0);
	  }
	
	}
	
	sum += nctr;

    }

    return (sum);
}



double evaluation::overalldeviation() {

    double * var = new double[clust->num];
    int * ctr = new int[clust->num];

    // initialisation

    for (int i=0; i<clust->num; i++) {
	var[i] = 0.0;
	ctr[i] = 0;
    }

    for (int i=0; i<par->binsize; i++) {

	double diff = 0.0;
	int p = clust->partition[i];
	data<USED_DATA_TYPE> di(par, clust->centres[p]);

	diff = (*bin)[i].distanceto(di);
	var[p] += diff;
    }

   

    double totalvariance = 0.0;
    for (int i=0; i<clust->num; i++) {
	totalvariance += var[i];

    }
    delete [] var;
    delete [] ctr;

    return (totalvariance);
}
*/


double evaluation::variance() {

    double * var = new double[clust->num];
    int * ctr = new int[clust->num];

    // initialisation

    for (int i=0; i<clust->num; i++) {
	var[i] = 0.0;
	ctr[i] = 0;
    }

    for (int i=0; i<par->binsize; i++) {

	double diff = 0.0;
	int p = clust->partition[i];
	data<USED_DATA_TYPE> di(par, clust->centres[p]);

	diff = (*bin)[i].distanceto(di);
	var[p] += diff*diff;
    }

  
    double totalvariance = 0.0;
    for (int i=0; i<clust->num; i++) {
	totalvariance += var[i];

    }
    totalvariance /= double(par->binsize);
    
    delete [] var;
    delete [] ctr;

    return sqrt(totalvariance);
}







/****************************************************************************************

 Evaluation measures for supervised clustering, i.e. when the real partitions are known 

  - F-Measure
 - Rand-Index


****************************************************************************************/


double evaluation::fmeasure(int b) {

    int ** assignments = new int* [clust->num];
    for (int i=0; i<clust->num; i++) {
	assignments[i] = new int [par->kclusters];
	for (int j=0; j<par->kclusters; j++) {
	    assignments[i][j] = 0;
	}
    }

    for (int i=0; i<par->binsize; i++) {
	int p = clust->partition[i];
	int real_p = (*bin)[i].cluster;
	assignments[p][real_p]++;
    }

    double totalf = 0.0;
    int num = clust->num;
    double ** f = new double *[clust->num];
    for (int i=0; i<clust->num; i++) {
	f[i] = new double[par->kclusters];
    }
    for (int i=0; i<clust->num; i++) {
	int max = 0;
	int maxnum = 0;
	int size = 0;
	for (int j=0; j<par->kclusters; j++) {

	    // determine n_j
	    size += assignments[i][j];
	}

		
	for (int j=0; j<par->kclusters; j++) {
	    if ((size != 0) && (assignments[i][j] != 0)){

		// n_ij / n_i
		double r = double(assignments[i][j]) / double(par->size_cluster[j]);

		// n_ij / n_j
		double p = double(assignments[i][j]) / double(size);

		// F-value for class j and cluster i
		f[i][j] = (double(b*b)+1.0)*p*r / (double(b*b)*p + r);
	    }
	    else f[i][j] = 0;
	}
    }
    for (int j=0; j<par->kclusters; j++) {

	// find max{F(i,j)}
	double maxf = 0.0;
	for (int i=0; i<clust->num; i++) {
	    maxf = max(maxf, f[i][j]);
	}
	totalf += double(par->size_cluster[j]) / double(par->binsize) * maxf;
    } 

    for (int i=0; i<clust->num; i++) {
	delete [] assignments[i];
	delete [] f[i];
    }
    delete [] assignments;
    delete [] f;
    return totalf;
}
 



double evaluation::randindex() {
    int a = 0;
    int b = 0;
    int c = 0;
    int d = 0;

    double r = 0.0;
    for (int i=0; i<par->binsize; i++) {
	int p1 = clust->partition[i];
	int q1 = (*bin)[i].cluster;
	for (int j=0; j<par->binsize; j++) {
	    int p2 = clust->partition[j];
	    int q2 = (*bin)[j].cluster;
	    if ((p1 == p2) && (q1 == q2)) a++;
	    if ((p1 == p2) && !(q1 == q2)) b++;
	    if (!(p1 == p2) && (q1 == q2)) c++;
	    if (!(p1 == p2) && !(q1 == q2)) d++;
	}
    }


    r = double(a+d)/double(a+b+c+d);
    return r;
}


double evaluation::randindex(clustering * c1, clustering * c2, int size) {
    int a = 0;
    int b = 0;
    int c = 0;
    int d = 0;

    double r = 0.0;
    for (int i=0; i<size; i++) {
	int p1 = c1->partition[i];
	int q1 = c2->partition[i];
	for (int j=0; j<size; j++) {
	    int p2 = c1->partition[j];
	    int q2 = c2->partition[j];
	    if ((p1 == p2) && (q1 == q2)) a++;
	    if ((p1 == p2) && !(q1 == q2)) b++;
	    if (!(p1 == p2) && (q1 == q2)) c++;
	    if (!(p1 == p2) && !(q1 == q2)) d++;
	}
    }


    r = double(a+d)/double(a+b+c+d);
    return r;
}

// Adjusted Rand Index (as unary measure)
double evaluation::adjustedrandindex() {
  

  double sum = 0.0;
  int ctr[clust->num];
  
  int ** assignments = new int* [clust->num];

  // intitialize matrix
  for (int i=0; i<clust->num; i++) {
    assignments[i] = new int [par->kclusters];
    ctr[i] = 0;
    for (int j=0; j<par->kclusters; j++) {
      assignments[i][j] = 0;
    }
  }

  // count assignments of known class labels
  // to identified clusters
  for (int i=0; i<par->binsize; i++) {
    int p = clust->partition[i];
    int real_p = (*bin)[i].cluster;
    assignments[p][real_p]++;
    ctr[p]++;
  }

  double sumij = 0.0;
  double sumi = 0.0;
  double sumj = 0.0;


  for (int i=0; i<par->kclusters; i++) {
    for (int j=0; j<clust->num; j++) {
     sumij += cover(2,assignments[j][i]);
    }
  }
  for (int i=0; i<par->kclusters; i++) {
    sumi += cover(2,par->size_cluster[i]);    
  }  
  for (int j=0; j<clust->num; j++) {
    sumj += cover(2,ctr[j]); 
  }

  double top = sumij-(sumi*sumj)/cover(2,par->binsize);
  double low = 0.5*(sumi+sumj)-(sumi*sumj)/cover(2,par->binsize);

  double r = top/low;

 for (int i=0; i<clust->num; i++) {
    delete [] assignments[i];
  }
  delete [] assignments;
  
  return r;
}



// Faculty function: multiplies all integers from xend+1 to xstart
double evaluation::fac(int xstart, int xend) {
  long double sum = 1.0;
  while (xstart > xend) {
    sum *= double(xstart);
    xstart--;
  }
  return sum;
}
    

// Compute binomial coefficient n over x
int evaluation::cover(int x, int n) {
 
  if (x > n) return 0;
  if (x == n) return 1;
  return (int)(fac(n,n-x)/fac(x,1));
}

double max(double i, double j) {
    if (i > j) return i;
    else return j;
}

double min(double i, double j) {
    if (i < j) return i;
    else return j;
}



// Silhouette Width
double evaluation::silhouette() {
  if (clust->num <= 1) {
    //cerr << "Silhouette Index cannot be computed for one single cluster" << endl;
    return 0;
  }

  int ** assignment = new int * [clust->num];
  int * ctr = new int[clust->num];


  for (int i=0; i<clust->num; i++) {
    ctr[i] = 0;
    assignment[i] = new int[par->binsize+1];
    for (int j=0; j<=par->binsize; j++) {
      assignment[i][j] = -1;
    }
  }

  for (int i=0; i<par->binsize; i++) {
    int index = (*clust)[i];
    assignment[index][ctr[index]] = i;
    ctr[index]++;
  }

  double s = 0;

  // compute silhouette for each data item
  for (int i=0; i<par->binsize; i++) {
    double a = 0;
    double b = 1e10;
    int index = (*clust)[i];

    // compute average distance to items in the same cluster
    for (int j=0; j<ctr[index]; j++) {
      if (assignment[index][j] != i) {
	a += bin->precomputed_d(assignment[index][j],i);
      }
    }
    if (ctr[index] != 1) {
      a /= double(ctr[index]-1);
    }

    // compute average distance to items in the closest cluster
    for (int k=0; k<clust->num; k++) {
      double btemp = 0;
      if (k != index && ctr[k] != 0) {
	for (int j=0; j<ctr[k]; j++) {
	  btemp += bin->precomputed_d(assignment[k][j],i);
	}
	btemp /= double(ctr[k]);
    
	b = min(btemp, b);
      }
    }

    double c = max(a,b);
    
    if (c != 0) {
      s += (b-a)/c;
    }
    else {
      s += 1.0;
    }
  }

  for (int i=0; i<clust->num; i++) {
    delete [] assignment[i];
  }
  delete [] assignment;
  delete [] ctr;

  return s/double(par->binsize);
}
  
