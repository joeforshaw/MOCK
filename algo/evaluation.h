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


#ifndef EVALUATION_JH_2003
#define EVALUATION_JH_2003

#include "conf.h"
#include "databin.h"
#include "clustering.h"
#include <iostream>
using namespace std;

class evaluation {
    
    conf * par;
    databin<USED_DATA_TYPE> * bin;
    clustering * clust;
    
   
 public:


    evaluation(conf * c);

    ~evaluation();

    void init(databin<USED_DATA_TYPE> * b, clustering * cl);

    double square(double x);

    int mymin(int x, int y);
    
    double myabs(double x);
    
    double fmeasure(int b);

    double randindex(clustering * c1, clustering * c2, int size);

    double adjustedrandindex();

    double randindex();

    double variance();

    double overalldeviation();
    double overalldeviation(int index);

    double completelink(); 

    double singlelink(); 

    double min_of_distances();

    double sum_of_distances();

    double sum_of_squares();

    double connectivity(int ** nnlist, int knn);
    double connectivity(int ** nnlist, int knn, int index);

    double evenness();

    double smallest();

    double fac(int xstart, int xend);

    int cover(int x, int n);

    double silhouette();

    
   
};

double max(double i, double j);
double min(double i, double j);


#endif
