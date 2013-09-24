
import java.io.*;
import java.util.*;

class Neighbor{
    double dist;
    int index;
}

class ValueComparator implements Comparator<Neighbor> {

  
  public ValueComparator() {
  }

  public int compare(Neighbor a, Neighbor b) {

      if(a.dist < b.dist) {
      return -1;
    } else if(a.dist == b.dist) {
      return 0;
    } else {
      return 1;
    }
  }
}



class ClusterViz {

    public static void evaluate(double [][] data, int []cluster, int n, int d) {


	// calculate centroids
	double [][] centroids = new double[n][d];
	int [] ctr = new int[n];
	for (int i=0;i<n;i++) {
	    ctr[i] = 0;
	    for (int j=0;j<d;j++) {
		centroids[i][j]=0.0;
	    }
	}
	for (int i=0;i<n;i++) {
	    int index = cluster[i]-1;
	    if (index < 0) {
		System.err.println("problem");
	    }
	    for (int j=0; j<d;j++) {
		centroids[index][j] += data[i][j];
	    }
	    ctr[index]++;
	}
	int k = 0;
	for (int i=0;i<n;i++) {
	    if (ctr[i] > 0) {
		k++;
	
		for (int j=0; j<d;j++) {
		    centroids[i][j] /= ctr[i];
		}
		//	System.err.println(centroids[i][0] + " " + centroids[i][1]);
	    }
	}

	

	double connectivity = 0.0;
	double [][] distances = new double[n][n];
	Neighbor[][] nn = new Neighbor[n][n];
	ValueComparator comp = new ValueComparator();
	
	for (int i=0;i<n;i++) {
	    for (int j=0;j<n;j++) {
		nn[i][j] = new Neighbor();
		distances[i][j] = 0.0;
		for (int m=0; m<d;m++) {
		    distances[i][j] += (data[i][m]-data[j][m])*(data[i][m]-data[j][m]);
		}
		distances[i][j] = Math.sqrt(distances[i][j]);
		nn[i][j].index=j;
		nn[i][j].dist=distances[i][j];

	    }
	    Arrays.sort(nn[i],comp);

	}
	
	double conn = 0.0;
	for (int i=0;i<n;i++) {
	    /* for (int j=0;j<n;j++) {
		System.err.println(nn[i][j].dist + " " + nn[i][j].index);
		}*/
	    
	    for (int j=1; j<=10;j++) {
		if (cluster[nn[i][j].index] != cluster[i]) {
		    conn += 1.0/((double)j);
		}
	    }
	}


	double maxd = 0.0;
	double mind=1e100;
	for (int i=0;i<n;i++) {
	    for (int j=0;j<i;j++) {
		if (cluster[i] == cluster[j]) {
		    maxd = Math.max(maxd, distances[i][j]);
		}
		else if (cluster[i] != cluster[j]) {
		    mind = Math.min(mind, distances[i][j]);
		}
	    }
	}
	//	System.err.println(k + " " + maxd + " " + 1.0/(1.0+mind));

	double overall_deviation = 0.0;
	for (int i=0;i<n;i++) {
	    int index = cluster[i]-1;
	    double dev = 0.0;
	    for (int j=0; j<d;j++) {
		dev += (data[i][j]-centroids[index][j])*(data[i][j]-centroids[index][j]);
	    }
	    dev = Math.sqrt(dev);

	    overall_deviation += dev;
	}


	System.err.print(k + " " + overall_deviation + " " + conn + " ");
	
    }


    // Adjusted Rand Index (as unary measure)
    public static void adjustedrandindex(int [] cluster, int [] classlabel, int n) {
  
	double sum = 0.0;
	int [] ctr = new int [n];
	int [] size_class = new int [n];
  
	int [][] assignments = new int[n][n];

	// intitialize matrix
	for (int i=0; i<n; i++) {
	    ctr[i] = 0;
	    size_class[i] = 0;
	    for (int j=0; j<n; j++) {
		assignments[i][j] = 0;
	    }
	}

	// count assignments of known class labels
	// to identified clusters
	for (int i=0; i<n; i++) {
	    int p = cluster[i];
	    int real_p = classlabel[i];
	    assignments[p][real_p]++;
	    ctr[p]++;
	    size_class[real_p]++;
	}

	double sumij = 0.0;
	double sumi = 0.0;
	double sumj = 0.0;


	for (int i=0; i<n; i++) {
	    for (int j=0; j<n; j++) {
		sumij += cover(2,assignments[j][i]);
	    }
	}
	for (int i=0; i<n; i++) {
	    sumi += cover(2,size_class[i]);    
	}  
	for (int j=0; j<n; j++) {
	    sumj += cover(2,ctr[j]); 
	}

	double top = sumij-(sumi*sumj)/cover(2,n);
	double low = 0.5*(sumi+sumj)-(sumi*sumj)/cover(2,n);

	double r = top/low;

	System.err.println(r);	

	return;
    }



    public static double fac(int xstart, int xend) {
	double sum = 1.0;
	while (xstart > xend) {
	    sum *= (double)xstart;
	    xstart--;
	}
	return sum;
    }
    

    // Compute binomial coefficient n over x
    public static int cover(int x, int n) {
 
	if (x > n) return 0;
	if (x == n) return 1;
	return (int)(fac(n,n-x)/fac(x,1));
    }


    public static void read(int n, int d, int m, String name){
        try {
            
	    //	    System.out.println(n);
	    //	    System.out.println(d);
	    //	    System.out.println(m);
	    //	    System.out.println(name);
	    
	    double[][]data = new double[n][d];
	    int[][]labels = new int[n][m];
	    int[]classlabels = new int[n];

            /*  Sets up a file reader to read the file passed on the command
                line one character at a time */
            FileReader input = new FileReader(name);
            
            /* Filter FileReader through a Buffered read to read a line at a
               time */
            BufferedReader bufRead = new BufferedReader(input);
            
            String line;    // String that holds current file line
            int count = 0;  // Line number of count 
            
            // Read first line
            line = bufRead.readLine();
            
	    //  System.out.println("N = " + n + ", D = " + d + ", M = " + m);

            // Read through file one line at time. Print line # and line
            while (line != null && count < n){
		
                
		String[] tokens = line.split(" ");
		for (int i=0;i<d;i++) {
		    data[count][i] = Double.parseDouble(tokens[i]);
		    //System.out.println(data[count][i]);
		}
		classlabels[count]=Integer.parseInt(tokens[d]);
		//		System.out.println(classlabels[count]);

		for (int i=0;i<m;i++) {
		    labels[count][i] = Integer.parseInt(tokens[d+1+i]);
		    
		}
                count++;
		line = bufRead.readLine();
		//	System.out.println(count+": "+line);
            }
            
            bufRead.close();

	  
	   
	    int level[][]=new int[n][n];
	    for (int i=0;i<n;i++) {
		for (int j=0;j<i;j++) {
		    level[i][j]=0;//m*(m-1)/2;
		}
	    }
	    for (int i=0;i<n;i++) {
		for (int j=0;j<i;j++) {
		    for (int k=0; k<m; k++) {
			if (labels[i][k]==labels[j][k]) {
				level[i][j]++;
			
			    }
		    }
		}
	    }

	   

	    FileWriter output = new FileWriter(name + ".diss");
            
            /* Filter FileReader through a Buffered read to read a line at a
               time */
            BufferedWriter bufWrite = new BufferedWriter(output);
	    for (int i=0;i<n;i++) {
		for (int j=0;j<n;j++) {
		    if ( j < i) {
		
			bufWrite.write(Double.toString(1.0-(double)(level[i][j])/(double)m));
			bufWrite.write(" ");
			
		    }
		    if (j > i) {
			
			bufWrite.write(Double.toString(1.0-(double)(level[j][i])/(double)m));
			bufWrite.write(" ");
		    }
		    if (i==j) {
			bufWrite.write("0.0 ");
		    }
		    
		   
		}
		bufWrite.newLine();
	    }
	    bufWrite.flush();
	    bufWrite.close();


	    //   System.out.println("test");
	    int [][] cluster = new int[m][n];
	    for (int l=m-1;l>=0;l--) {
		int ctr=0;
		for (int i=0;i<n;i++) {
		    cluster[l][i]=0;
		}
		for (int i=0;i<n;i++) {
		    for (int j=0;j<i;j++) {
			if (level[i][j]>=l+1) {
			    if (cluster[l][i]!=0 && cluster[l][j]!=0 && cluster[l][i] != cluster[l][j]) {
				for (int ii=0;ii<n;ii++) {
				    if (cluster[l][ii]==cluster[l][i] ) {
					cluster[l][ii]= cluster[l][j];
				    }
				}
				cluster[l][i]= cluster[l][j];
			    }
			    else if (cluster[l][i]!=0) {
				cluster[l][j]= cluster[l][i];
			    }
			    else if (cluster[l][j]!=0) {
				cluster[l][i]= cluster[l][j];
			    }
			    else {
				cluster[l][i]= ++ctr;
				cluster[l][j]= ctr;
			    }
			}
			/*	else {
			    cluster[l][i]= ++ctr;
			    cluster[l][j]= ++ctr;
			    }*/
		    }
		}
		for (int i=0;i<n;i++) {
		    if (cluster[l][i]==0) {
			cluster[l][i]=++ctr;
		    }
		    //System.out.print(cluster[l][i] + " ");
		}
		//System.out.print("\n");

	    }
	    /*	    for (int i=0;i<n;i++) {
		for (int j=0;i<d;j++) {
		    System.out.print(data[i][j] + " ");
		}
		}*/


	    for (int i=0;i<n;i++) {
		System.out.print("1 ");
	    }
	    System.out.print("\n");
	    
	    for (int l=0;l<m;l++) {
		for (int i=0;i<n;i++) {
		    System.out.print(cluster[l][i] + " ");
		}
		System.out.print("\n");
		evaluate(data,cluster[l],n,d);
		adjustedrandindex(cluster[l],classlabels,n);
	    }

	    // System.out.println("test");
	    
	    //for (int i=0;i<n;i++) {
		//	int l=m-1;
		//while (l >= 0 && cluster[l][i] == 0) {
		//   l--;
		//}
		//int lev=m-l;
		//int k=(m-l-1)*100+cluster[l][i];
		//System.out.println(lev + " " + k);
		//}

	


	    /*	    // Graph<V, E> where V is the type of the vertices
	    // and E is the type of the edges
	    Graph<Integer, String> svg = new SparseMultigraph<Integer, String>();
	    // Add some vertices. From above we defined these to be type Integer.
	    svg.addVertex((Integer)1);
	    svg.addVertex((Integer)2);
	    svg.addVertex((Integer)3);
	    // Add some edges. From above we defined these to be of type String
	    // Note that the default is for undirected edges.
	    svg.addEdge("Edge-A", 1, 2); // Note that Java 1.5 auto-boxes primitives
	    svg.addEdge("Edge-B", 2, 3);
	    // Let's see what we have. Note the nice output from the
	    // SparseMultigraph<V,E> toString() method
	    System.out.println("The graph g = " + g.toString());
	    // Note that we can use the same nodes and edges in two different graphs.
	   



	    //SimpleGraphView sgv = new SimpleGraphView(); //We create our graph in here
	    // The Layout<V, E> is parameterized by the vertex and edge types
	    Layout<Integer, String> layout = new CircleLayout(sgv.g);
	    layout.setSize(new Dimension(300,300)); // sets the initial size of the space
	    // The BasicVisualizationServer<V,E> is parameterized by the edge types
	    BasicVisualizationServer<Integer,String> vv =
		new BasicVisualizationServer<Integer,String>(layout);
	    vv.setPreferredSize(new Dimension(350,350)); //Sets the viewing area size
	
	    JFrame frame = new JFrame("Simple Graph View");
	    frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
	    frame.getContentPane().add(vv);
	    frame.pack();
	    frame.setVisible(true);
	    */


            
        }catch (ArrayIndexOutOfBoundsException e){
            /* If no file was passed on the command line, this expception is
            generated. A message indicating how to the class should be
            called is displayed */
            System.out.println("Usage: java ReadFile filename\n");          

        }catch (IOException e){
            // If another exception is generated, print a stack trace
            e.printStackTrace();
        }
        
    }// end main

    public static void main(String[] args) {
	//        System.out.println("Hello World!"); // Display the string.

	read(Integer.parseInt(args[0]),Integer.parseInt(args[1]),Integer.parseInt(args[2]),args[3]);
    }
}

