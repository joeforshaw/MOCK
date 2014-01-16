


#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include "math.h"
#include<fstream>
#include <iostream>   


using namespace std;


int main(int argc, char *argv[])
{


  char * name = argv[1];
  int N = atoi(argv[2]);
  int D = atoi(argv[3]);
  double data[N][D];
  int label[N];
  double mean[D];
  double sd[D];

  ifstream in(name);


  for (int j=0; j<D; j++) {
    mean[j] = 0;
    sd[j] = 0;
  }

  for (int i=0;i<N;i++) {
    for (int j=0; j<D; j++) {
      in >> data[i][j];
      mean[j] += data[i][j];
    }
    in >> label[i];
  }


 for (int j=0; j<D; j++) {
   mean[j] = mean[j] / N;
 }

 for (int i=0;i<N;i++) {
   for (int j=0; j<D; j++) {
     sd[j] += (double(data[i][j])-mean[j])*(double(data[i][j])-mean[j]);
   }
 }

 for (int j=0; j<D; j++) {
   sd[j] = sqrt(sd[j] / N);
   //   cout << mean[j] << " " << sd[j] << endl;
 }



 for (int i=0;i<N;i++) {
   for (int j=0; j<D; j++) {
     cout << ((double)(data[i][j]) - mean[j]) / sd[j] << " ";
   }
   cout << label[i] << endl;
 }
  
}
