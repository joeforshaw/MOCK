dim=13

data<-read.table("~/mock_ppsn/mock-vis-cec/no0.dat")
ass1=data;k=1;while( k <= 25 ){a<-kmeans(data[,1:dim],centers=k);ass1<-cbind(ass1,a$cluster);k=k+1}
write.table(ass1,file="no0.kmeans.dat",row.names=FALSE,col.names=FALSE)



d <- dist(data[,1:dim], method = "euclidean") 
fit <- hclust(d, method="average") 
ass2=data;k=1;while( k <= 25 ){a<- cutree(fit, k);ass2<-cbind(ass2,a);k=k+1}
write.table(ass2,file="no0.average.dat",row.names=FALSE,col.names=FALSE)

fit2 <- hclust(d, method="single") 
ass3=data;k=1;while( k <= 25 ){a<- cutree(fit2, k);ass3<-cbind(ass3,a);k=k+1}
write.table(ass3,file="no0.single.dat",row.names=FALSE,col.names=FALSE)

low=dim+2
up=dim+26
ass4=cbind(ass1,ass2[,low:up],ass3[,low:up])
write.table(ass4,file="no0.combined.dat",row.names=FALSE,col.names=FALSE)



#label<-read.table("no0.label.data")
#d<-read.table("kmeans.agglomerated.data")
#height.vec<-(c(26:1)/26)
#library(labeltodendro)
#plot(tabletodendro(label.mat,height.vec,label=label[,1]))