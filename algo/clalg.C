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




#include "clalg.h"


clalg::clalg(conf * c, databin<USED_DATA_TYPE> * b, evaluation * ev) {
    bin = b;
    par = c;
    e = ev;
}


clalg::~clalg() {
    bin = NULL;
    par = NULL;
}


clustering * clalg::getclustering() {
    if (clust == NULL) {
	return NULL;
    }
    return clust;
}


