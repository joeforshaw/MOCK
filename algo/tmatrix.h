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

author: Julia Handl (julia.handl@gmx.de)

description:
implementation of a triangular matrix
(to save storage space as the precomputed
dissimilarity matrix is symmetric)

***************************************************/


#ifndef TMATRIX_JH_2003
#define TMATRIX_JH_2003
#include <iostream>


template <class T>
class tmatrix {
 public:
  int size;
  T ** data;
  

 public:
  /* Konstruktor */
  tmatrix(const int s);

  /* Copy-Konstruktor */
  tmatrix(const tmatrix <T> & t);

  /* Destruktor */
  ~tmatrix();

  /* Assignment */
  void operator=(const tmatrix <T> & t);
  
  /* Access to data within matrix via indices (order doesn't matter) */
  T &operator()(const int i, const int j);

  const int getsize();
};




 /* Konstruktor - Allocation of memory */
template<class T> tmatrix <T>::tmatrix(const int s) {
    
      data = new T * [s];
      size = s;
      for (int i=0; i<s; i++) {
	data[i] = new T [i+1];
      }
    
      for (int i=0; i<s; i++) {
	  for (int j=0; j<=i; j++) {
	      data[i][j] = 0;
	  }
      }
}
  

/* Copy-Konstruktor */
template<class T> tmatrix <T>::tmatrix(const tmatrix <T>& t) {
   
	data = new T * [t.size];
	size = t.size;
	for (int i=0; i<size; i++) {
	    data[i] = new T [i+1];
	}

    for (int i=0; i<size; i++) {
	for (int j=0; j<=i; j++) {
	    data[i][j] = t.data[i][j];
	}
    }
}


           
/* Destruktor */
template<class T>tmatrix <T>::~tmatrix() {
    for (int i=0; i<size; i++) {
      delete [] data[i];
    }
    delete [] data;

  }

/* Assignment */
template<class T>void tmatrix <T>::operator=(const tmatrix & t) {
    if (this == &t) return;
    for (int i=0; i<size; i++) {
      delete [] data[i];
    }
    delete [] data;
    
   
	data = new T * [t.size];
	size = t.size;
	for (int i=0; i<size; i++) {
	    data[i] = new T [i+1];
	}

    for (int i=0; i<size; i++) {
	for (int j=0; j<=i; j++) {
	    data[i][j] = t.data[i][j];
	}
    }
}
    
   
/* Access to data within matrix via indices (order doesn't matter) */
template<class T>T &tmatrix <T>::operator()(const int i, const int j) {
    
    return (i < j)? data[j][i] : data[i][j];
}

  
/* read matrix size */
template<class T> const int tmatrix <T>::getsize() {
    return size;
}

inline template class tmatrix<float>;

#endif
