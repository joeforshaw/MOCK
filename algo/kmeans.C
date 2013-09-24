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



#include "kmeans.h"
#include "random.h"

#define MAXIT 1

static long idum = 258954802;

double kmeans::square(double x) {
    return x*x;
}


/* Constructor */
kmeans::kmeans(conf * par, databin<USED_DATA_TYPE> * bin, evaluation * e):
    clalg(par, bin, e) {
    partition = new int[par->binsize];
    center = new data<USED_DATA_TYPE> * [par->kclusters];
}


/* Destructor */
kmeans::~kmeans() {
    delete [] partition;
    for (int i=0; i<par->kclusters; i++) {
	delete center[i];
    }
    delete [] center;
     
    delete clust;
    
}

/* Random intialisation */
void kmeans::init() {
  

    USED_DATA_TYPE * proto = new USED_DATA_TYPE[par->bindim];


    // initialization of cluster centers
    for (int i=0; i<par->kclusters; i++) {
	for (int k=0; k<par->bindim; k++) {
	  proto[k] = 0;
	}

	center[i] = new data<USED_DATA_TYPE>(par, proto);
    }       
    delete [] proto;
}


/* Main routine of k-means algorithm */
void kmeans::run() {
    

    clustering * bestclust = NULL;

    int changes = TRUE;
    int iteration_ctr = 0;

    double minvar = -1.0;

    int * mem_ctr = new int[par->kclusters];

    // iterate kmeans several times to avoid suboptimal solutions
    for (int i=0; i<MAXIT; i++) {


	// randomly initialize partitioning
	for (int i=0; i<par->binsize; i++) {
	    partition[i] = int(ran0(&idum)*par->kclusters);
	}

	clust = new clustering(par);

	iteration_ctr = 0;
	changes = TRUE;

    	while ((changes == TRUE) && (iteration_ctr < 10)) {

	
	    // count number of cluster members in order to detect emtpy clusters
	    for (int i=0; i<par->kclusters; i++) {
		mem_ctr[i] = 0;
	    }
	    
	    iteration_ctr++;
	    changes = FALSE;
	    
	    // computation of new cluster centers
	    int * ctr = new int[par->kclusters];
	    for (int i=0; i<par->kclusters; i++) {
		ctr[i] = 0;
	    }
	    
	    for (int i=0; i<par->kclusters; i++) {
	      for (int j=0; j<par->bindim; j++) {
		(*(center[i]))[j] = 0;
	      }
	    }
	    for (int i=0; i<par->binsize; i++) {
		center[partition[i]]->add((*bin)[i]);
		ctr[partition[i]]++;
	    }
	    for (int i=0; i<par->kclusters; i++) {
		if (ctr[i] != 0) {
		    center[i]->div(ctr[i]);
		
		}
	    }
	    delete [] ctr;


	    // partitioning of data items
	    for (int i=0; i<par->binsize; i++) {
		int temp = partition[i];
		partition[i] = 0;
		USED_DATA_TYPE mind = center[0]->distanceto((*bin)[i]);
		for (int j=0; j<par->kclusters; j++) {
		    USED_DATA_TYPE d = center[j]->distanceto((*bin)[i]);
		    
		    if (d < mind) {
			partition[i] = j;
			mind = d;
		    }
		}
		mem_ctr[partition[i]]++;
		if (temp != partition[i]) {
		    changes = TRUE;
		}
	    }
	    
	    // now check for emtpy clusters
	    for (int i=0; i<par->kclusters; i++) {
		//cout << mem_ctr[i] << endl;
		if (mem_ctr[i] == 0) {
		    //	    cout << "Empty cluster " << endl;
		    changes = TRUE;
		    int index = int(ran0(&idum)*par->binsize);
		    for (int j=0; j<par->bindim; j++) {
			(*(center[i]))[j] = (*bin)[index][j];
		    }
		    partition[index] = i;
		}
	    }
	}
    
	// generate a clustering object
	clust->init(par->kclusters);
	
	// store cluster assignments
	for (int i=0; i<par->binsize; i++) {
	    (*clust)[i] = partition[i];
	}
	
	// store cluster centres
	for (int i=0; i<par->kclusters; i++) {
	    clust->newcentre(i, center[i]);
	}
	

	// keep solution if variance has improved
	e->init(bin,clust);
	double var = e->variance();
	//	cout << var << endl;
	if ((minvar == -1) || (var < minvar)) {
	    minvar = var;

	    if (bestclust != NULL) delete bestclust;
	    bestclust = clust;
	}
	else {
	    delete clust;
	}
		
    }

    //    cout << endl << "Best result found: Variance = " << minvar <<  endl;

    int * kctr = new int[par->kclusters];
    for (int i=0; i<par->kclusters; i++) kctr[i] = 0;
    for (int i=0; i<par->binsize; i++) {
	kctr[(*bestclust)[i]]++;
    }
    clust = bestclust;

    delete [] mem_ctr;
    	

}




    
