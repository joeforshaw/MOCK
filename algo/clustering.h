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

#ifndef CLUSTERING_JH_2003
#define CLUSTERING_JH_2003


#include "conf.h"
#include "databin.h"

class clustering {

    conf * par;

 public:

    USED_DATA_TYPE ** centres;
    int * partition; 
    
    


 public:
    int num;
   
    clustering(conf * c);
    ~clustering();
    void init(int n);

    int & operator[](int i);
    void newcentre(int index, data<USED_DATA_TYPE> * coords);
};
    
#endif

