#ifndef KMEANS_JH_2003
#define KMEANS_JH_2003

#include "conf.h"
#include "databin.h"
#include "clalg.h"
#include "clustering.h"
#include "evaluation.h"

class kmeans:public clalg {

private:
    int * partition;
    int * mem_ctr;


    data<USED_DATA_TYPE> ** center;

     

 public:

    kmeans(conf * par, databin<USED_DATA_TYPE> * bin, evaluation * e);
    ~kmeans();
    double square(double x);
    void init();
    void run();
 
};

#endif
