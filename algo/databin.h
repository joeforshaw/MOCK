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

/***************************************************

date: 7.4.2003

author: Julia Handl (julia.Handl@gmx.de)

description: 
- wrapper class for data collection
- data input
- data normalisation
- precomputation of dissimilarity matrix

***************************************************/

#ifndef DATABIN_JH_2003
#define DATABIN_JH_2003

#include "conf.h"
#include "tmatrix.h"
#include "databin.h"
#include <fstream>
#include <iostream>
#include "math.h"
#include "pesa2.h"
#include "gasdev.h"
#include "pca.h"
#include "string.h"

using namespace std;
template <class BINTYPE> class databin;
template <class DBINTYPE> class docbin;


/***************************************************

       class data

***************************************************/


template <class DATATYPE>
class data {
 
    friend class databin<DATATYPE>;

 private:
    DATATYPE * vector;
   
  
protected:
    conf * par;

 public:
    int color;
    int cluster;

   
 public:
    ~data();

    /* Constructor for a data item that is initialized to the vector <d> */
    data(conf * c, DATATYPE * d);

    data(conf * c, DATATYPE * dat, int col, int cl);

  /* Default constructor */
    data(conf * c);

    /* Lenght of the data vector */
    const int length();

    DATATYPE square(DATATYPE x);

    /* Write-Read access to individual components */
    DATATYPE &operator[](const int i);

    /* Distance computation between two data items */
    const DATATYPE distanceto(data<DATATYPE> & d);

     /* Addition of two data vectors */
    void add(data<DATATYPE> & d);

    /* Division of a data vector by <i> */
    void div(int i);

    /* Data vector is set to <d> */
    void set(data<DATATYPE> & d);

  /* Data vector is set to <d> */
    void set(DATATYPE * d);

};




/***************************************************

       class databin

***************************************************/


template <class BINTYPE>
class databin {

 protected:
    /* pointer to current parameter settings */
    conf * par; 

    /* array of pointer to data objects */ 
    data<BINTYPE> ** bin;   

 public:
    /* precomputed disimilarity matrix */
    tmatrix<BINTYPE> * distancematrix;

    /* array of maxvalue for each attribute */
    BINTYPE * mean;
    BINTYPE * std;
   BINTYPE * minvalue;
    BINTYPE * maxvalue;

    BINTYPE ** memmatrix;

    int * color;

    char ** label;

 
 

    
 public:

  /* Default construcor */  
  databin(conf * c); 

  /* Constructor, file input (for real data) */ 
  databin(conf * c, char * name, int size, int dim);


   /* Destructor */
  ~databin();

  /* Distance computation between two data items in the collection */
  const BINTYPE d(const int index1, const int index2);

  /* Direct access to precomputed dissimilarity matrix */
  const BINTYPE precomputed_d(const int index1, const int index2);

  /* Write-Read access to an individual data item in the collection */
  data<BINTYPE> & operator[](const int i);

    /* Permute order of data items */
  void permutate();

  void uniformprescription();

  int find(char * templabel, char ** classlabel, int & labelctr);

  


};




/***************************************************

       class data - function definitions

***************************************************/


// access to vector length
template <class DATATYPE>const int data <DATATYPE>::length() {
    return par->bindim;
}


 // constructor if data vector is provided
template <class DATATYPE>data <DATATYPE>:: data(conf * c, DATATYPE * dat) {
    par = c;
    vector = new DATATYPE[par->bindim];
    color = 0;
    cluster = 0;
      
    for (int i=0; i<par->bindim; i++) {
	vector[i] = dat[i];
    }
}

// constructor if data vector is provided
template <class DATATYPE>data <DATATYPE>:: data(conf * c, DATATYPE * dat, int col, int cl ) {
    par = c;
    vector = new DATATYPE[par->bindim];
    color = col;
    cluster = cl;
      
    for (int i=0; i<par->bindim; i++) {
	vector[i] = dat[i];
   }
}


// default constructor
template <class DATATYPE>data <DATATYPE>::data(conf * c)  {
    par = c;
    vector = new DATATYPE[par->bindim];
    color = 0;
    cluster = 0;
    
    for (int i=0; i<par->bindim; i++) {
	vector[i] = 0;
    }
}

// destructor
template <class DATATYPE>data <DATATYPE>::~data() {
    delete [] vector;
}


// square function
template <class DATATYPE> DATATYPE data <DATATYPE>::square(DATATYPE x) {
    return x*x;
}

// write-read access to coordinates of dat vector 
template <class DATATYPE> DATATYPE &data <DATATYPE>::operator[](const int i) {
    return vector[i];
}

// distance function defined between data vectors   
template <class DATATYPE>const DATATYPE data <DATATYPE>::distanceto(data<DATATYPE> & dd) {

  if (par->distance == EUCLIDEAN) {
  
    data & d = (data &)dd;
    DATATYPE result = 0.0;

    for (int i=0; i<par->bindim; i++) {
      result += square(d.vector[i] - vector[i]);
    }
    
    return sqrt(result);
  }
  else if (par->distance == COSINE) {  
    
    data & d = (data &)dd;
    DATATYPE result = 0.0;
    DATATYPE r1 = 0.0;
    DATATYPE r2 = 0.0;
    for (int i=0; i<par->bindim; i++) {
	result += d.vector[i] * vector[i];
	r1 += d.vector[i] * d.vector[i];
	r2 += vector[i] * vector[i]; 
    }
    // cerr << result << " " << r1 << " " << r2 << " " << 1.0 - 0.5*(1.0 + result / sqrt(r1*r2)) << endl;
    if (r1 == 0 || r2 == 0) return 0.0;

    else return 1.0 - 0.5*(1.0 + result / sqrt(r1*r2));


  }
  else if (par->distance == CORRELATION) {

    data & d = (data &)dd;
    DATATYPE result = 0.0;
    DATATYPE r1 = 0.0;
    DATATYPE r2 = 0.0;
    DATATYPE av1 = 0.0;
    DATATYPE av2 = 0.0;

    for (int i=0; i<par->bindim; i++) {
      av1 += vector[i] * vector[i];
      av2 += d.vector[i] * d.vector[i];
    }
    av1 /= double(par->bindim);
    av2 /= double(par->bindim);


    for (int i=0; i<par->bindim; i++) {
      	result += (d.vector[i]-av2) * (vector[i]-av1);
	r1 += square(d.vector[i]-av2);
	r2 += square(vector[i]-av1); 
    }

    if (r1 == 0 || r2 == 0) return 0.0;
    // DATATYPE dummy = (result / sqrt(r1*r2));
    //if (dummy >= 0) return 1.0-dummy;
    //else return 1.0+dummy ;
    return 0.5*(1.0 - (result / sqrt(r1*r2)));
  }

  else if (par->distance == GAUSSIAN) {


    data & d = (data &)dd;
    DATATYPE result = 0.0;
    for (int i=0; i<par->bindim; i++) {
	result += square(d.vector[i] - vector[i]);
    }
    return 1-exp(-result);
  }
  else if (par->distance == JACCARD) {
    data & d = (data &)dd;
    DATATYPE result = 0.0;
    DATATYPE r1 = 0.0;
    DATATYPE r2 = 0.0;

    for (int i=0; i<par->bindim; i++) {
        result += d.vector[i] * vector[i];
	r1 += d.vector[i] * d.vector[i];
	r2 += vector[i] * vector[i]; 
    }
    DATATYPE denom = r1+r2-result;
    // cerr << 0.5*(1.0 - result / denom) << endl;
    if (denom == 0) return 0;
    else return 0.5*(1.0 - result / denom);


   
  }
  else {
    cerr << "NO valid distance function selected" << endl;
  }


}



// addition of data vectors   
template <class DATATYPE>void data <DATATYPE>::add(data<DATATYPE> & d) {
    for (int i=0; i<par->bindim; i++) {
	vector[i] += d.vector[i];

    }
 
}

template <class DATATYPE> void data<DATATYPE>::set(data<DATATYPE> & d) {
      for (int i=0; i<par->bindim; i++) {
	  vector[i] = d.vector[i];
      }
}

template <class DATATYPE> void data<DATATYPE>::set(DATATYPE * d) {
      for (int i=0; i<par->bindim; i++) {
	  vector[i] = d[i];
      }
}



// division of a data vector by an integer   
template <class DATATYPE>void data <DATATYPE>::div(int divisor) {
    for (int i=0; i<par->bindim; i++) {
	vector[i] /= double(divisor);

    }
}



/***************************************************

       class databin - function definitions

***************************************************/


// destructor
template <class BINTYPE>databin <BINTYPE>::~databin() {

  delete [] std;
  delete [] mean;
  delete [] minvalue;
  delete [] maxvalue;

    for (int i=0; i<par->binsize; i++) {
	delete bin[i];
	delete memmatrix[i];
    }
    delete [] bin;
    delete [] memmatrix;
    if (distancematrix != NULL) delete distancematrix;
}


template <class BINTYPE> const BINTYPE databin <BINTYPE>::precomputed_d(const int index1, const int index2) {
    return (*distancematrix)(index1,index2);


}

// distance function between the bin's data items
template <class BINTYPE>inline const BINTYPE databin <BINTYPE>::d(const int index1, const int index2) {
    return bin[index1]->distanceto(*bin[index2]);
}


// write-read access to data items
template <class BINTYPE>inline data<BINTYPE> & databin <BINTYPE>::operator[](const int i) {
    return *bin[i];
}

// constructor for class databin if a real data set is used (identified by name) 
template <class BINTYPE>databin <BINTYPE>::databin(conf * c, char * name, int size, int dim) {
  using namespace std;

    int clust = size; 

    ifstream input(name);
    if (! input){
      cerr << "Error while trying to open file " << name << endl;
      exit(0);
    }
  
    par = c;

    par->bindim = dim;
    par->binsize = size;
    par->kclusters = clust;
    par->num_cluster = clust;

    // Start external
    int labelctr = 0;
    char ** classlabels = new char *[size];
    for (int i=0; i<size; i++) {
      classlabels[i] = new char[100];
    }

    par->size_cluster = new int[clust];
    for (int i=0; i<clust;i++) {
      par->size_cluster[i] = 0;
    }
    color = new int[par->binsize];
    // End external

    bin = new data<USED_DATA_TYPE>*[par->binsize];
    mean = new USED_DATA_TYPE[par->bindim];
    std = new USED_DATA_TYPE[par->bindim];
    minvalue = new USED_DATA_TYPE[par->bindim];
    maxvalue = new USED_DATA_TYPE[par->bindim];
    label = new char *[size];
    for (int i=0; i<size;i++) {
      label[i] = new char[1000];
    }



    for (int k=0; k<par->bindim; k++) {
	maxvalue[k] = -100000000.0;
	minvalue[k] = 100000000.0;
    }

    for (int i=0; i<par->bindim; i++) {
	mean[i] = 0;
	std[i] = 0;
    }
    

    USED_DATA_TYPE ** temp = new USED_DATA_TYPE*[par->binsize];
    for (int i=0; i<par->binsize; i++) {
	temp[i] = new USED_DATA_TYPE[par->bindim];
    }

    // Begin external
    char templabel[100];
    par->num_cluster = 0;
    // End external


    for (int i=0; i<par->binsize; i++) {
	for (int j=0; j<par->bindim; j++) {
	  if ( !input.eof() ) {
	    input >> temp[i][j];
	    //	    cerr << temp[i][j] << " ";
	    mean[j] += temp[i][j];
	  }
	  else {
	    cerr << "Error in input line " << i << " " << " at column " << j << endl;
	    cerr << "Size = " << par->binsize << " and dimensionality = " << par->bindim << " given do not correspond to the real size of input file " << name << endl;
	    exit(0);
	  }
	}

	// Begin external
	input >> label[i];
	//	cerr << label[i] << endl;
	strcpy(templabel,label[i]);
	color[i] = find(templabel, classlabels, labelctr);
	par->size_cluster[color[i]]++;
	par->num_cluster = (int)max(par->num_cluster, color[i]+1);
	// End external


    }
    int dummy;
    input >> dummy;
    if ( !input.eof() ) {
      cerr << "Error at the end of input" << endl;
      cerr << "Size = " << par->binsize << " and dimensionality = " << par->bindim << " given do not correspond to the real size of input file " << name << endl;
      exit(0);
    }

    // compute mean in each dimension
    for (int j=0; j<par->bindim; j++) {
      	mean[j] /= double(par->binsize);
    }

    // compute standard deviation in each dimension
    for (int j=0; j<par->bindim; j++) {
	for (int i=0; i<par->binsize; i++) {
	  double diff = temp[i][j]-mean[j];
	  std[j] += diff*diff;
	}
	std[j] /= double(par->binsize);
	std[j] = sqrt(std[j]);
    }

  

    int ctr = 0;

    for (int i=0; i<par->binsize; i++) {
	
	   for (int j=0; j<par->bindim; j++) {
	     if (par->normalize == true) {
	       temp[i][j] -= mean[j];
	       if (std[j] != 0) temp[i][j] /= std[j];
	     }
 
	   }

	   // Begin external
	   bin[i] = new data<USED_DATA_TYPE>(par, temp[i], color[i]+1, color[i]);
      
	   //   bin[ctr] = new data<USED_DATA_TYPE>(par, temp[i]);
	   // End external
	   ctr++;
    }
    
   
   

    for (int i=0; i<par->binsize; i++) {
      for (int k=0; k<par->bindim; k++) {
	maxvalue[k] = max(maxvalue[k], ((*(bin[i]))[k]));
	minvalue[k] = min(minvalue[k], ((*(bin[i]))[k]));
      }
    }

    if (par->normalize == true) {
      for (int j=0; j<par->bindim; j++) {
	mean[j] = 0.0;
	std[j] = 1.0;
      }
    }


   
    distancematrix = new tmatrix<USED_DATA_TYPE>(par->binsize);
    
  
    // compute distances and mean
    par->mu = 0.0;
    par->maxd = 0.0;
    par->mind = 0.0;
    for (int i=0; i<par->binsize; i++) {
	for (int j=0; j<i; j++) {
	    (*distancematrix)(i,j) = bin[i]->distanceto(*(bin[j]));
	    par->mu += (*distancematrix)(i,j);
	    if (i==1 && j==0) {
	      par->mind = (*distancematrix)(i,j);
	      par->maxd = (*distancematrix)(i,j);
	    }
	    else {  
	      if ((*distancematrix)(i,j) < par->mind) {
		par->mind = (*distancematrix)(i,j);
	      }
	      BINTYPE d = (*distancematrix)(i,j);
	      if (d < 0) d =-d;
	      if (d > par->maxd) {
		par->maxd = d;
	      }
	    }
	    
	}
    }
    for (int i=0; i<par->binsize; i++) {
      for (int j=0; j<i; j++) {
	(*distancematrix)(i,j) = ((*distancematrix)(i,j)-par->mind)/(par->maxd-par->mind);
      }
    }

    par->mu /= 0.5*(par->binsize-1)*par->binsize;
   

    /*  for (int i=0; i<par->binsize; i++) {
      delete [] temp[i];
    }
    delete [] temp;*/
    memmatrix = temp;

    par->kclusters = par->num_cluster;

 
}

  

template <class BINTYPE> void databin <BINTYPE>::uniformprescription() {


  long idum = 732832;

  if (distancematrix != NULL) delete distancematrix;

  USED_DATA_TYPE ** datamatrix = new USED_DATA_TYPE * [par->binsize];
    for (int i=0; i<par->binsize; i++) {
      datamatrix[i] = new USED_DATA_TYPE[par->bindim];
    }

    for(int t=0;t<par->binsize;t++)
      {  
	for (int j=0; j<par->bindim; j++) {
	  datamatrix[t][j] = memmatrix[t][j];
	}
      }
    
    pca(datamatrix, par->binsize, par->bindim);

   
    for(int t=0;t<par->binsize;t++)
      {  
	for (int j=0; j<par->bindim; j++) {
	  (*(bin[t]))[j] = datamatrix[t][j];
      }
      }
    
  
    for (int i=0; i<par->binsize; i++) {
      delete [] datamatrix[i];
    }
    delete [] datamatrix;
  
  
    distancematrix = new tmatrix<BINTYPE>(par->binsize);
    if (distancematrix == NULL) {
	cerr << "Databin: Memory allocation failed" << endl;
	exit(0);
    }
    
    // compute distances and mean
    par->mu = 0.0;
    par->max = 0.0;
    for (int i=0; i<par->binsize; i++) {
	for (int j=0; j<i; j++) {
	    (*distancematrix)(i,j) = bin[i]->distanceto(*(bin[j]));
	    par->mu += (*distancematrix)(i,j);
	    par->max = max(par->max, (*distancematrix)(i,j));
	}
    }
    par->mu /= 0.5*(par->binsize-1)*par->binsize;




}


template <class BINTYPE> void databin <BINTYPE>::permutate() {

    
  BINTYPE tempval;

    for (int i=0; i<par->binsize; i++) {
	int j = int(mydrand()*(par->binsize));
	data<BINTYPE> * temp = bin[i];
	bin[i] = bin[j];
	bin[j] = temp;
	for (int k=0; k<par->binsize; k++) {
	    if ((k != i)  && (k != j)) {
		tempval = (*distancematrix)(i,k);
		(*distancematrix)(i,k) = (*distancematrix)(j,k);
		(*distancematrix)(j,k) = tempval;
	    }
	}
    }
}



template <class BINTYPE> int databin <BINTYPE>::find(char * templabel, char ** classlabel, int & labelctr) {
    for (int i=0; i<labelctr; i++) {
	if (strcmp(classlabel[i],templabel) == 0) {
	    return i;
	}
    }
    strcpy(classlabel[labelctr], templabel);
    labelctr++;
    return labelctr-1;
}




#endif

