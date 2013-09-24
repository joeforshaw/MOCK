LIBS = -lm 

CC = g++  
LD = g++  
CFLAGS = -O2 -finline-functions -I/usr/lib/java/ -I/usr/lib/java/include/linux  -fpic  -I/usr/lib/jvm/java-6-sun-1.6.0.14/include/ -I/usr/lib/jvm/java-6-sun-1.6.0.14/include/linux/ 
LFLAGS = $(LIBS) 
LFLAGS = $(LIBS)
TARGET = MOCK

MOCK : pesa2CLUST.o gaclust.o evaluation.o kmeans.o clalg.o clustering.o gasdev.o random.o pca.o conf.h databin.h
	$(LD) $(CFLAGS) pesa2CLUST.o gaclust.o evaluation.o kmeans.o clalg.o clustering.o gasdev.o random.o pca.o $(LIBS) -o MOCK

pesa2CLUST.o : pesa2CLUST.C conf.h databin.h
	$(CC) $(CFLAGS) -c pesa2CLUST.C
gaclust.o : gaclust.C pesa2CLUST.C conf.h databin.h
	$(CC) $(CFLAGS) -c gaclust.C
kmeans.o : kmeans.C clustering.C conf.h databin.h
	$(CC) $(CFLAGS) -c -o kmeans.o kmeans.C
clalg.o : clalg.C clustering.C conf.h databin.h
	$(CC) $(CFLAGS) -c -o clalg.o clalg.C
evaluation.o : evaluation.C pesa2CLUST.C conf.h databin.h
	$(CC) $(CFLAGS) -c -o evaluation.o evaluation.C
clustering.o : clustering.C pesa2CLUST.C conf.h databin.h
	$(CC) $(CFLAGS) -c -o clustering.o clustering.C
gasdev.o : gasdev.C
	$(CC) $(CFLAGS) -c gasdev.C
random.o : random.C
	$(CC) $(CFLAGS) -c random.C
pca.o : pca.C
	$(CC) $(CFLAGS) -c pca.C

clean: 
	rm -f $(TARGET)	
	rm -f *.o		
