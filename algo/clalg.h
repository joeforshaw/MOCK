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



#ifndef CLALG_JH_2003
#define CLALG_JH_2003

#include "databin.h"
#include "conf.h"
#include "clustering.h"
#include "evaluation.h"




class clalg {
 protected:
    conf * par;
    databin<USED_DATA_TYPE> * bin;
    evaluation * e;

    clustering * clust;
   

 public:
    clalg(conf * par, databin<USED_DATA_TYPE> * bin, evaluation * e);
    virtual ~clalg();
    virtual void init() = 0;
    virtual void run() = 0;
    clustering * getclustering();
  	
};



#endif
