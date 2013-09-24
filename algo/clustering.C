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

author: Julia Handl (Julia.Handl@gmx.de)

Description: object for the storage of a 
partitioning of a data set; encapsulates
cluster centres and cluster assignments
for each data item



***************************************************/


#include "clustering.h"


// Constructor
 clustering::clustering(conf * c) {
     par = c;
 }


// Destructor
 clustering::~clustering() {
     if (centres != NULL) {
	 for (int i=0; i<num; i++) {
	     delete[] centres[i];
	 }
	 delete [] centres;
     }
     if (partition != NULL) {
	 delete [] partition;
     }
 }


// Initialisation: allocation of memory
// for a partitioning of a given size <n>
 void clustering::init(int n) {

     num = n;
     centres = new USED_DATA_TYPE*[num];
     for (int i=0; i<num; i++) {
	 centres[i] = new USED_DATA_TYPE[par->bindim];
     }
     partition = new int[par->binsize];
 }

/* Read-Write access for the cluster assignment
   of data item <i> */
 int & clustering::operator[](int i) {
     return partition[i];
 }



/* Add cluster centre number <index> as described by <coords>*/
 void clustering::newcentre(int index, data<USED_DATA_TYPE> * coords) {
      for (int i=0; i<par->bindim; i++) {
	 centres[index][i] = (*coords)[i];

     }
 }
