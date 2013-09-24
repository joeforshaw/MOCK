/*  
    Copyright (C) 2004 Julia Handl
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


#include "agglom.h"


/* Constructor */
agglom::agglom(conf * c, databin<USED_DATA_TYPE> * b, evaluation * e):clalg(c, b, e) {
    par = c;
    bin = b;

    // distance matrix added to speed up
    dmatrix = new tmatrix<USED_DATA_TYPE>(par->binsize);

    // memory allocation
    clusters = new int * [par->binsize];

    centre = new data<USED_DATA_TYPE>[par->binsize](par);

    single = false;

}


/* Destructor */
agglom::~agglom() {
    delete dmatrix;
    for (int i=0; i<par->binsize; i++) {
	if (clusters[i] != NULL)
	    delete []  clusters[i];
    }
    delete [] clusters;
    delete [] centre;
    if (clust != NULL) delete clust;
    
 }


void agglom::init() {
    num = par->binsize;

     
    // initially each cluster contains one data element
    for (int i=0; i<par->binsize; i++) {
	clusters[i] = new int[par->binsize+1];
	if (clusters[i] == NULL) cerr << "Ups..." << endl;
	clusters[i][0] = i;
	for (int j=1; j<par->binsize+1; j++) {
	    clusters[i][j] = FREE;
	}
    }

    // intialize distance matrix
    for (int i=0; i<par->binsize; i++) {
	for (int j=0; j<i; j++) {
	  if (single == false) {	    
	    (*dmatrix)(i,j) = averagelink(clusters[i], clusters[j], bin);
	  }
	  else {
	    (*dmatrix)(i,j) = singlelink(clusters[i], clusters[j], bin);
	  }

	}
    }
}


void agglom::run() {

       
    /* Stopping criteria is the predefined number of clusters */
    while (num > par->kclusters) {


	double minval = FREE;
	int minindex1 = FREE;
	int minindex2 = FREE;
    
	
	// determine closest clusters
	for (int i=0; i<par->binsize; i++) {
	    if (clusters[i] == NULL) continue;
	    for (int j=0; j<i; j++) {
		if (clusters[j] == NULL) continue;
	
		double d = (*dmatrix)(i,j);
	
		if ((minval == FREE) || (d < minval)) {
		    minval = d;
		    minindex1 = i;
		    minindex2 = j;
		}
	    }
	}	


	// merge them    
	int ptr=0;
	//	out << "{";
	while (clusters[minindex1][ptr] != FREE) {
	  ptr++;
	}

	int inbr = ptr;

	int i=0;

	while (clusters[minindex2][i] != FREE) {
	    clusters[minindex1][ptr++] = clusters[minindex2][i];
	    i++;
	}
	int jnbr = i;
	delete [] clusters[minindex2];
	clusters[minindex2] = NULL;


	num--;

	// update row of distance matrix
	for (int i=0; i<par->binsize; i++) {
	    if ( i!= minindex1 && clusters[i] != NULL) {

	      if (single == false) {		
		(*dmatrix)(minindex1, i) = double(inbr) / double(inbr + jnbr) * (*dmatrix)(minindex1, i) + double(jnbr) / double(inbr + jnbr) * (*dmatrix)(minindex2, i);
	      }
	      else {
		(*dmatrix)(minindex1, i) = min( (*dmatrix)(minindex1, i), (*dmatrix)(minindex2, i));
	      }

	    }
	}
    }


    /* Store clustering solution in a clustering object */
    clust = new clustering(par);
    clust->init(par->kclusters);
    int ctr = 0;
    for (int i=0; i<par->binsize; i++) {
	if (clusters[i] == NULL) continue;
	else {
	    int j=0; 
	    data<USED_DATA_TYPE> datacentre(par);
	    while (clusters[i][j] != FREE) {
		int index = clusters[i][j];
		(*clust)[index] = ctr;
		datacentre.add((*bin)[index]);
		j++;
	    }
	    datacentre.div(j);

    	    clust->newcentre(ctr, &datacentre);
	    ctr++;
	}
	
    }
}


/* average link linkage metric */
double agglom::averagelink(int * cluster1, int * cluster2, databin<USED_DATA_TYPE> * docbin) {
    double mean = 0.0;
    int i = 0;
    int ctr = 0;
    while (cluster1[i] != FREE) {
	int j=0;
	int d1 = cluster1[i];
	while (cluster2[j] != FREE) {
	    int d2 = cluster2[j];
	    double d = bin->precomputed_d(d1, d2);
    	    mean += d;
	    j++;
	    ctr++;
	}
	i++;
    }
    mean  /= ctr;
    return mean;
}


/* complete link likage metric */
double agglom::completelink(int * cluster1, int * cluster2, databin<USED_DATA_TYPE> * docbin) {
    double maxd = 0;
    int i=0;
    while (cluster1[i] != FREE) {
	int j=0;
	int d1 = cluster1[i];
	while (cluster2[j] != FREE) {
	    int d2 = cluster2[j];
	    double d = bin->precomputed_d(d1, d2);
	    maxd = max(maxd, d);
	    j++;

	}

	i++;
    }
    return maxd;
}



/* single link likage metric */
double agglom::singlelink(int * cluster1, int * cluster2, databin<USED_DATA_TYPE> * docbin) {
    double mind = 1e10;
    int i=0;
    while (cluster1[i] != FREE) {
	int j=0;
	int d1 = cluster1[i];
	while (cluster2[j] != FREE) {
	    int d2 = cluster2[j];
	    double d = bin->precomputed_d(d1, d2);
	    mind = min(mind, d);
	    j++;

	}

	i++;
    }
    return mind;
}

double agglom::square(double x) {
  return x*x;
}

double agglom::min(double x, double y) {
  if (x < y) return x;
  else return y;
}

double agglom::max(double x, double y) {
  if (x > y) return x;
  else return y;
}
