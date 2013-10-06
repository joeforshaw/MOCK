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
- wrapper class for all parameter settings

***************************************************/

#ifndef CONF_JH_2003
#define CONF_JH_2003

#include <iostream>
#include <fstream>
 
#define USED_DATA_TYPE float
#define FALSE 0
#define TRUE 1

/* define the distance measure to be used */
#define EUCLIDEAN 1
#define COSINE 2
#define CORRELATION 3
#define JACCARD 4
#define GAUSSIAN 5

#define TEST 0

class conf {
    
 public:

     // databin parameters
  char filename[100];
     int bintype;
     int binsize;
     int bindim;
     USED_DATA_TYPE mu;
     USED_DATA_TYPE max;
     int distance;
     bool normalize;

     int s;
     int type;
     int num_cluster;
     USED_DATA_TYPE ** mu_cluster;
     USED_DATA_TYPE ** sigma_cluster;
     int * size_cluster;
     int kclusters;

     int imax;
     int jmax;

     int userid;
     int runid;

     double mind;
     double maxd;

     conf(int x) {
     }

};


#endif
