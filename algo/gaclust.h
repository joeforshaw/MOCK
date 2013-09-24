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

#ifndef GACLUST_JH_2003
#define GA_CLUST_2003

#include "pesa2.h"
#include "conf.h"
#include "databin.h"
#include "clustering.h"


class gaclust{

 public:

// pointer to configuation object encapsulating all parameter settings

// pointer to data set
  
    int ** nn;
    int ** w;
    USED_DATA_TYPE * dtemp;


    int evaluate(C *c, int knn);
    void init(char * name);
    void globalinit(int s);
    int square(int x);
    void print(clustering * clu, int ** nnlist, int w, double **ind);
    int gensize(); 
    void itoa(int, char * c);
    void sort(int ** nn); 
    void nnlist(int ** nnlist);

};

#endif

int lt2 (const void *a, const void *b);
