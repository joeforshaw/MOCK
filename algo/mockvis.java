import java.lang.*;
import java.util.*;
import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import java.io.*;
import jahuwaldt.plot.*;
import javax.imageio.*;
import java.awt.image.*;
import com.touchgraph.graphlayout.*;

/** Close the associated window */
class WindowCloser extends WindowAdapter {
    public void windowClosing(WindowEvent e) {
      	System.exit(0);
    }
 }



class MyCanvas extends Canvas{


    public void paint(Graphics g) {
	Toolkit toolkit = Toolkit.getDefaultToolkit();
	Image i = toolkit.getImage("sillybig.gif");
	g.drawImage(i, 50, 50, this);
	g.setFont(null);
	g.drawString("MOCK -- Version 1.1", 200, 40) ;
	g.drawString("Copyright: Julia Handl", 200, 60) ;
	g.drawString("University of Manchester", 200, 80);
	g.drawString("13.04.2005", 200, 100);
	g.drawString("Julia.Handl@gmx.de", 200, 120) ;
    }
}



class tracker implements Runnable {

    private mockvis mock;

    public tracker(mockvis m) {
	this.mock = m;
    }

    public void run() {

	while (!mock.canceled && !mock.done) {
	    try {
		Thread.sleep(100); 
		//	mock.current ++;
		while (mock.lock == 1);
		int c = mock.current;
		if (c >= mock.lengthOfTask()) {
		    mock.done = true;
		    c = mock.lengthOfTask();
		}
		mock.progressBar.setValue(c);
		//frame.repaint();
		//System.out.println(c);
		
	    } catch (InterruptedException e) {
		System.out.println("ActualTask interrupted");
	    }
	}
	try {
	    Thread.sleep(1000); 
	    while (mock.finished == 0) {
		Thread.sleep(100); 
	    }
	    mock.show();
	} catch (InterruptedException e) {
	    System.out.println("ActualTask interrupted");
	}
    }
}
	
    


public class mockvis implements Runnable {

    private static JFrame frame;
    private static Configuration configuration;
    private static MyCanvas mockimage;
    private static double [][] solcol;
    private static int solN;
    public static JProgressBar progressBar;
    // private static PlotPanel panel = null;

    private static int jobnbr = 0;


    public static int current = 0;
    public static boolean done = false;
    public static int lock = 0;
    public static boolean canceled = false;
    public static int finished = 0;
    
    public native void runmock(int nbr);

    public int lengthOfTask() {
	return 500+new Integer(configuration.getCT()).intValue()*500;

    }


    static {
        System.loadLibrary("mock");
    }


    public void run() {
	runmock(jobnbr);
	finished = 1;
    }
            
   

    public void show() {
	try {
	    BufferedReader in = new BufferedReader(new FileReader("data/"+jobnbr+"-solution.pf"));
	    BufferedReader in2 = new BufferedReader(new FileReader("data/"+jobnbr+"-attainment.pf"));
	    String line;
	    String line2;
	    int [][] solution = new int[1000][2];
	    double [] solutionx = new double[1000];
	    double [] solutiony = new double[1000];
	    solcol = new double[1000][6];
	    int ctr = 0;
	    final int [] selected = new int[1000];
	    
	    
	    BufferedReader in3 = new BufferedReader(new FileReader("data/"+jobnbr+"-recommendation.pf"));
	    int n_ctr = 0;
	    while ((line = in3.readLine()) != null) {
		int end = line.indexOf(' ');
		line = line.substring(0,end);
		selected[n_ctr] = new Integer(line).intValue();
		n_ctr++;
	    }
	    final int n_selected = n_ctr;
	    
	    
	    while ((line = in.readLine()) != null) {
		
		int start = 0;
		
		int end = line.indexOf(' ');
		
		line2 = in2.readLine();
		int end2 = line2.indexOf(' ');
		line2 = line2.substring(end2+1);
		end2 = line2.indexOf(' ');
			
		solcol[ctr][4] = new Double(line2.substring(start,end2)).doubleValue();

		end2 = line2.indexOf(' ');
		line2 = line2.substring(end2+1);
		solcol[ctr][5] = new Double(line2).doubleValue();
		
		solution[ctr][0] = new Integer(line.substring(start,end)).intValue();
		solcol[ctr][0] = solution[ctr][0];
		line = line.substring(end+1);
		end = line.indexOf(' ');
		
		
		solution[ctr][1] = new Integer(line.substring(start,end)).intValue();
		solcol[ctr][1] = solution[ctr][1];
		line = line.substring(end+1);
		end = line.indexOf(' ');
		
		solutionx[ctr] = new Double(line.substring(start,end)).doubleValue();
		solcol[ctr][2] = solutionx[ctr];
		line = line.substring(end+1);
		end = line.indexOf(' ');
		
		solutiony[ctr] = new Double(line.substring(start,end)).doubleValue();
		solcol[ctr][3] = solutiony[ctr];
		ctr++;
	    }    
	    solN = ctr;
	    
	    Arrays.sort(solutionx, 0, ctr);
	    Arrays.sort(solutiony, 0, ctr);
	    
	    for (int i=0; i<Math.floor(ctr/2); i++) {
		double temp = solutiony[i];
		solutiony[i] = solutiony[ctr-1-i];
		solutiony[ctr-1-i] = temp;
	    }
	    
	    double [] ssx = new double[ctr];
	    double [] ssy = new double[ctr];
	    
	    for (int i=0; i<ctr; i++) {
		ssx[i] = solutionx[i];
		ssy[i] = solutiony[i];
	    }
	    
	    final int []lookup = new int[ctr];
	    for (int i=0; i<ctr;i++) {
		for (int j=0; j<ctr; j++) {
		    if ((solutionx[i] == solcol[j][2]) && (solutiony[i] == solcol[j][3])) {
			lookup[j] = i;
		    }
		}
	    }				    
 
	   
	    
	    SimplePlotXY aPlot = new SimplePlotXY(ssx, ssy, "Solution and control fronts", "Normalized connectivity", "Normalized overall deviation",null, null, new CircleSymbol(), false, 1, selected, n_selected, lookup);
	    
	    double [] sx = new double[ctr+ctr-1];
	    double [] sy = new double[ctr+ctr-1];
	    
	    int n = 0;
	    for (int i=0; i<ctr-1; i++) {
		sx[n] = solutionx[i];
		sy[n] = solutiony[i];
		n++;
		sx[n] = solutionx[i+1];
		sy[n] = solutiony[i];
		n++;
	    }
	    sx[n] = solutionx[ctr-1];
	    sy[n] = solutiony[ctr-1];
	    
	    
	    PlotRunList runs = aPlot.getRuns();			    
	    runs.add(new PlotRun(sx, sy, true, null, Color.red));
	    
	    
	    
	    in = new BufferedReader(new FileReader(jobnbr+"-control.pf"));
	    int [][] control = new int[1000][2];
	    double [] controlx = new double[1000];
	    double [] controly = new double[1000];
	    ctr = 0;
	    
	    while ((line = in.readLine()) != null) {
		
		int start = 0;
		
		int end = line.indexOf(' ');
		
		
		control[ctr][0] = new Integer(line.substring(start,end)).intValue();
		line = line.substring(end+1);
		end = line.indexOf(' ');
		
		control[ctr][1] = new Integer(line.substring(start,end)).intValue();
		line = line.substring(end+1);
		end = line.indexOf(' ');
		
		controlx[ctr] = new Double(line.substring(start,end)).doubleValue();
		line = line.substring(end+1);
		end = line.indexOf(' ');
		
		controly[ctr] = new Double(line).doubleValue();
		ctr++;
		
	    }  
	    
	    int N = ctr;
	    
	    
	    int nbr=0;					
	    for (int k=0; k<new Integer(configuration.getCT()).intValue(); k++) {
		double [] ccx = new double[1000];
		double [] ccy = new double[1000];
		int j=0;
		boolean first = true;
		while (true && nbr < N) {
		    if ((control[nbr][1] == 1) && (first == true)) {
			first = false;
		    }
		    else if ((control[nbr][1] == 1) && (first == false)) {
			break;
		    }
		    ccx[j] = controlx[nbr];
		    ccy[j] = controly[nbr];
		    j++;
		    nbr++;
		}

		
		
		Arrays.sort(ccx, 0, j);
		Arrays.sort(ccy, 0, j);
		
		for (int i=0; i<Math.floor(j/2); i++) {
		    double temp = ccy[i];
		    ccy[i] = ccy[j-1-i];
		    ccy[j-1-i] = temp;
		}
		
		double [] cx = new double[j+j-1];
		double [] cy = new double[j+j-1];
		
		n = 0;
		for (int i=0; i<j-1; i++) {
		    cx[n] = ccx[i];
		    cy[n] = ccy[i];
		    n++;
		    cx[n] = ccx[i+1];
		    cy[n] = ccy[i];
		    n++;
		}
		cx[n] = ccx[j-1];
		cy[n] = ccy[j-1];
		runs.add(new PlotRun(cx, cy, true, null, new Color(0,150,0)));
	    }
	    
	    
	    final PlotPanel panel = new PlotPanel(aPlot,solcol, solN, 1, configuration.getsize(),jobnbr);
	    panel.setBackground( Color.white );
	    //			    frame.getContentPane().remove(mockimage);
	    
	    MenuBar mainBar = new MenuBar();
	    Menu plot = new Menu("Plot");
	    MenuItem save = new MenuItem("Save in .jpg format");
	    save.addActionListener(new ActionListener() {
		    public void actionPerformed(ActionEvent e) {
			
			if (panel == null) return;
			
			try {
			    JFileChooser chooser = new JFileChooser(".");
			    JFrame frame = new JFrame();
			    int returnVal = chooser.showSaveDialog(frame);
			    String filename = "";
			    if (returnVal == JFileChooser.APPROVE_OPTION) {
				filename = chooser.getSelectedFile().getAbsolutePath();
				File f = new File(filename);
				
				BufferedImage image = new BufferedImage(panel.getWidth(), panel.getHeight(), BufferedImage.TYPE_INT_RGB);
				Graphics2D g = image.createGraphics();
				g.setRenderingHint(RenderingHints.KEY_FRACTIONALMETRICS,RenderingHints.VALUE_FRACTIONALMETRICS_ON);
				g.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING,RenderingHints.VALUE_TEXT_ANTIALIAS_ON);
				panel.paint(g);
				g.dispose();
				ImageIO.write(image, "jpeg", f);
				image.flush();
				
			    }
			    
			} catch (Exception ee) {
			    System.err.println("Error while trying to save plots");
			    System.err.println(ee.getMessage());
			    ee.printStackTrace();
			}
			
			
		    }});
	    plot.add(save);

	    MenuItem vis = new MenuItem("Activate graph layout");
	    vis.addActionListener(new ActionListener() {
		    public void actionPerformed(ActionEvent e) {
			panel.visualize = true;
		    }
		});
	    plot.add(vis);

	    MenuItem dvis = new MenuItem("Deactivate graph layout");
	    dvis.addActionListener(new ActionListener() {
		    public void actionPerformed(ActionEvent e) {
			panel.visualize = false;
		    }
		});
	    plot.add(dvis);
				 

	    
	    MenuItem att = new MenuItem("Plot distribution of attainment scores");
	    att.addActionListener(new ActionListener() {
		    public void actionPerformed(ActionEvent e) {
			JFrame newframe = new JFrame("Attainment scores");
			double [] ass1 = new double[solN];
			double [] ass2 = new double[solN];
			for (int i=0; i<solN; i++) {
			    ass1[i] = solcol[i][1];
			    ass2[i] = solcol[i][4];
			}
			
			
			SimplePlotXY aPlot2=new SimplePlotXY(ass1, ass2, "Attainment plot", "Number of clusters", "Attainment score",
							     null, null, new CircleSymbol(), false, 2, selected, n_selected, lookup);
			final PlotPanel panel2 = new PlotPanel(aPlot2,solcol, solN, 2, configuration.getsize(),jobnbr);
			panel2.setBackground(Color.white );
			newframe.getContentPane().add(panel2);
			
			MenuBar mainBar2 = new MenuBar();
			Menu plots = new Menu("Plot");
			MenuItem save2 = new MenuItem("Save in .jpg format");
			save2.addActionListener(new ActionListener() {
				public void actionPerformed(ActionEvent e) {
				    
				    try {     
					JFileChooser chooser = new JFileChooser(".");
					JFrame frame = new JFrame();
					int returnVal = chooser.showSaveDialog(frame);
					String filename = "";
					if (returnVal == JFileChooser.APPROVE_OPTION) {
					    filename = chooser.getSelectedFile().getAbsolutePath();
					    File f = new File(filename);
					    
					    BufferedImage image = new BufferedImage(panel2.getWidth(), panel2.getHeight(), BufferedImage.TYPE_INT_RGB);
					    Graphics2D g = image.createGraphics();
					    g.setRenderingHint(RenderingHints.KEY_FRACTIONALMETRICS,RenderingHints.VALUE_FRACTIONALMETRICS_ON);
					    g.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING,RenderingHints.VALUE_TEXT_ANTIALIAS_ON);
					    panel2.paint(g);
					    g.dispose();
					    ImageIO.write(image, "jpeg", f);
					    image.flush();
					    
					    
					}
					
				    } catch (Exception ee) {
					System.err.println("Error while trying to save plots");
					System.err.println(ee.getMessage());
					ee.printStackTrace();
				    }
				    
				    
				}});
			plots.add(save2);

			MenuItem vis = new MenuItem("Activate graph layout");
			vis.addActionListener(new ActionListener() {
				public void actionPerformed(ActionEvent e) {
				    panel2.visualize = true;
				}
			    });
			plots.add(vis);
			MenuItem dvis = new MenuItem("Deactivate graph layout");
			dvis.addActionListener(new ActionListener() {
				public void actionPerformed(ActionEvent e) {
				    panel2.visualize = false;
				}
			    });
			plots.add(dvis);
			mainBar2.add(plots);
			newframe.setMenuBar(mainBar2);
			newframe.pack();
			newframe.setSize(700,700);
			newframe.setLocation(200,100);
			newframe.show();
			newframe.setVisible(true);
		    }});
	    
	    plot.add(att);


    
	    mainBar.add(plot);
	    JFrame myframe = new JFrame("Solution and control front");
	    myframe.setMenuBar(mainBar);
	    myframe.getContentPane().add(panel);
	    myframe.pack();
	    myframe.setSize(700,700);
	    myframe.setLocation(50,50);
	    myframe.show();
	    myframe.setVisible(true);
	    
	} catch(Exception ex) {
	    System.err.println("Error while trying to read results");
	    ex.printStackTrace();
	}
    }

    
    
    public static void main(String[] args) {

	try {
	    UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
	    //    JFrame.setDefaultLookAndFeelDecorated(true);
	} catch (Exception e) {
       		
	    /// dann halt nicht ....
	}

	try {

	    // create configuration
	    configuration = new Configuration();
	    Configuration c = configuration.read();
	    if (c != null) configuration = c;
	    
	    // create frame and menu bars
	    frame = new JFrame();
	    JComponent newContentPane = new JPanel();
	    newContentPane.setBorder(BorderFactory.createEmptyBorder(20, 20, 20, 20));
	    newContentPane.setOpaque(true); //content panes must be opaque
	    frame.setContentPane(newContentPane);
	    frame.setTitle("MOCK Version 1.1");
	    frame.setBackground(Color.lightGray);
	    frame.getContentPane().setLayout(new BorderLayout());
	    mockimage = new MyCanvas();
	    progressBar = new JProgressBar(0, 500+new Integer(configuration.getCT()).intValue()*500);
	    progressBar.setValue(0);
	    progressBar.setStringPainted(true);
	    frame.getContentPane().add(progressBar,BorderLayout.SOUTH);
	    frame.getContentPane().add(mockimage,BorderLayout.CENTER);

	    
	    MenuBar mainBar = new MenuBar();

	    // File menu
	    Menu file = new Menu("Data");

	    MenuItem read = new MenuItem("Read data");
	    read.addActionListener(new ActionListener() {
		    public void actionPerformed(ActionEvent event) { 

			JFileChooser chooser = new JFileChooser(".");
			Frame f = new Frame();
			int retVal = chooser.showOpenDialog(frame);
			if (retVal == JFileChooser.APPROVE_OPTION) {
			    String filename = chooser.getSelectedFile().getAbsolutePath();
			    configuration.setfilename(filename);
			    try {

				BufferedReader in = new BufferedReader(new FileReader(filename));
				String line;
				int nrows = 0;
				int ncols = 0;
				while ((line = in.readLine()) != null) {
				    line = line.trim();
				    int start = 0;
				    int thiscols = 1;
				    while ((start = line.indexOf(' ')) != -1) {
					thiscols++;
					line = line.substring(start+1);
				    }
				    if (nrows == 0) {
					ncols = thiscols;
					//	System.out.println("Columns " + ncols);
				    }
				    else if (ncols != thiscols) {
					System.err.println("Error in file input at row " + nrows + " and column " + thiscols);
					return;
				    } 
				    nrows++;
				}
				//	System.out.println("Rows " + nrows);
				configuration.setsize(nrows);
				configuration.setdim(ncols);

				configuration.save();
				//				System.out.println("File " + filename + " selected.");
			    } catch (Exception e) {
				System.err.println("Exception occured when trying to read file " + filename);
			    }
			}
		    }	
			
      		});
	    file.add(read);
	    mainBar.add(file);

	    // Configuration menu
	    Menu confs = new Menu("Configuration"); 

	    // Allow configuration modifications
	    MenuItem configure = new MenuItem("Modify");
	    configure.addActionListener(new ActionListener() {
		    public void actionPerformed(ActionEvent e) {

			new ConfDialog(frame, configuration, progressBar);
			
		    }});
	    confs.add(configure);	
	    mainBar.add(confs);

	    // Run menu
	    Menu runs = new Menu("MOCK"); 

	    MenuItem run = new MenuItem("Run");
	    run.addActionListener(new ActionListener() {
		    public void actionPerformed(ActionEvent e) {
			
			current = 0;
			finished = 0;
			progressBar.setValue(current);
			done=false; canceled=false;
			jobnbr++;
		
			mockvis m = new mockvis();
			new Thread(m).start();
			new Thread(new tracker(m)).start();


		    }});
	    runs.add(run);	



	    mainBar.add(runs);   

	   

	    Menu info = new Menu("Info"); 

	    MenuItem help = new MenuItem("Help");
	    final String helpstring =
    					"How to use MOCK:\n\n" +
    					"1) Select data file.\n" +
    					"   Menu: Data -> Read data\n" +
		                        "   For a data set containing N data items described by D variables each\n" +
		                        "   the data must be in space separated row/colum format with the last colum\n" + 
                                        "   containing the class label/identifier (see example below):\n" +
		                        "   <item1_var1> <item1_var2> ... <item1_varD> <item1_id>\n" +
		                        "   <item1_var2> <item2_var2> ... <item2_varD> <item2_id>\n" +
		                        "                ....\n" +
                        		"   <itemN_var1> <itemN_var2> ... <itemN_varD> <itemN_id>\n" +
		                        "\n" +
    					"2) Specify configuration settings if desired.\n" +
    					"   Menu: Configuration->Modify\n" +
                                        "   Currently distance function (Euclidean/Cosine/Correlation/Jaccard), normalization (on/off), \n" +
		                        "   the value of parameter L (default: 10), the maximum number of clusters (default: 50) and the \n" +
                                        "   number of desired control surfaces (default: 3) can be specified.\n" +
		                        "   Configuration settings are saved and automatically loaded at relaunch.\n" +
		                        "\n" +
    					"3) Run MOCK.\n" +
		                        "   Menu: MOCK -> Run\n" +
		                        "   The progress of the clustering process is visualized in the main frame.\n" +
		                        "   Results are visualized in a plot of the solution and control fronts.\n" +
		                        "   All local maxima (recommended solutions) are highlighted in yellow.\n" +
		                        "   Clicking on individial clustering solutions provides summary informations\n" +
                                        "   or a visualization as a graph layout (needs to be activated, as it becomes\n" +
                                        "    quite slow for small data .\n\n\n";
   					
    					
	    help.addActionListener(new ActionListener() {
		    public void actionPerformed(ActionEvent event) {
			ImageIcon icon = new ImageIcon("silly.gif");
			JOptionPane.showMessageDialog(null,
						      helpstring, "Help",
						      JOptionPane.INFORMATION_MESSAGE, icon);
		    }});
	    info.add(help);
	    MenuItem about = new MenuItem("About");
	    about.addActionListener(new ActionListener() {
		    public void actionPerformed(ActionEvent event) {
			ImageIcon icon = new ImageIcon("silly.gif");
			
			JOptionPane.showMessageDialog(null, 
						      "For details on MOCK see:\n\n J. Handl and J. Knowles,\n Multiobjective clustering with automatic k-determination,\n Technical report TR-COMPSYSBIO-04-02, UMIST, Manchester, UK.\n\n If you use this software please cite the above technical report.\n\n", "About", 
						      JOptionPane.INFORMATION_MESSAGE, icon);
		    }});
	    info.add(about);
	    mainBar.add(info);

 	    
	    frame.setMenuBar(mainBar);
	    frame.addWindowListener(new WindowCloser()); 
	    frame.pack();
	    frame.setSize(400,300);
	    frame.setLocation(30,30);
	    frame.show();
	    frame.setVisible(true);
	    
	} catch (Exception e) {
	    System.err.println("Exception in Main Routine");
	    System.err.println(e.getMessage());
	    e.printStackTrace();
	    System.exit(0);
	}

    }
}





class ConfDialog extends JDialog {

	// GUI fields
	private static JCheckBox normalize;
	private static JTextField connectivity;
        private static JTextField number;
        private static JTextField numberct;
	private static JComboBox distancefunction;
    private JProgressBar progressBar;


	public ConfDialog(Frame frame, Configuration conf, JProgressBar p) {

	        // generate GUI
        
		this.setTitle("Configuration");
		this.setBackground(Color.lightGray);
		this.progressBar = p;
	    	
		ImageIcon icon = new ImageIcon("silly.gif");
		JTabbedPane tabbedPane = new JTabbedPane();


		// Configuration
        	JPanel global = new JPanel();
		global.setLayout(new BorderLayout());


        	JPanel box = new JPanel();
		box.setLayout(new BorderLayout());

		JPanel choicePanel = new JPanel();
		choicePanel.setLayout(new BorderLayout());
		JLabel choiceLabel = new JLabel("Distance function");
		choicePanel.add(choiceLabel, BorderLayout.WEST);
		String[] distStrings = { "Euclidean", "Cosine", "Correlation", "Jaccard"};
		distancefunction = new JComboBox(distStrings);
		distancefunction.setSelectedIndex(conf.getdistfct());
		choicePanel.add(distancefunction, BorderLayout.EAST);
		box.add(choicePanel,BorderLayout.NORTH);
		
		
		JPanel normPanel = new JPanel();
		normPanel.setLayout(new BorderLayout());
		JLabel normLabel = new JLabel("Normalization");
		normPanel.add(normLabel, BorderLayout.WEST);
	    	normalize = new JCheckBox();
    		normalize.setSelected(conf.getNorm());
		normPanel.add(normalize,BorderLayout.EAST);
		box.add(normPanel,BorderLayout.CENTER);

		JPanel lPanel = new JPanel();
		lPanel.setLayout(new BorderLayout());
		JLabel lLabel = new JLabel("L (connectivity)");
		lPanel.add(lLabel, BorderLayout.WEST);
	    	connectivity = new JTextField(conf.getL());
		connectivity.setPreferredSize(new Dimension(50,10));
		lPanel.add(connectivity,BorderLayout.EAST);
		box.add(lPanel, BorderLayout.SOUTH);
		global.add(box,BorderLayout.NORTH);


		JPanel box2 = new JPanel();
		box2.setLayout(new BorderLayout());

		JPanel lPanel2 = new JPanel();
		lPanel2.setLayout(new BorderLayout());
		JLabel choiceLabel2 = new JLabel("Maximum cluster number");
		lPanel2.add(choiceLabel2, BorderLayout.WEST);
		number = new JTextField(conf.getK());
		number.setPreferredSize(new Dimension(50,10));
		lPanel2.add(number,BorderLayout.EAST);
		box2.add(lPanel2,BorderLayout.NORTH);
	
		JPanel lPanel3 = new JPanel();
		lPanel3.setLayout(new BorderLayout());
		JLabel choiceLabel3 = new JLabel("Number of control surfaces");
		lPanel3.add(choiceLabel3, BorderLayout.WEST);
		numberct = new JTextField(conf.getCT());
		numberct.setPreferredSize(new Dimension(50,10));
		lPanel3.add(numberct,BorderLayout.EAST);
		box2.add(lPanel3, BorderLayout.SOUTH);
		global.add(box2,BorderLayout.CENTER);


		JPanel mapbuttonbox = new JPanel();
		mapbuttonbox.setLayout(new BorderLayout());
		JButton mapButton = new JButton("Apply");
		mapButton.setPreferredSize(new Dimension(150, 30));
		mapButton.addActionListener(new Save(conf, this, progressBar));
		mapbuttonbox.add(mapButton, BorderLayout.WEST);
		JButton mapcloseButton = new JButton("Close");
		mapcloseButton.setPreferredSize(new Dimension(150, 30));
		mapcloseButton.addActionListener(new Close(this));
		mapbuttonbox.add(mapcloseButton, BorderLayout.EAST);
		global.add(mapbuttonbox,BorderLayout.SOUTH);


       		tabbedPane.addTab("Parameters", icon, global, "Specify parameters");	
		tabbedPane.setSelectedIndex(0);

		// finish
		this.getContentPane().add(tabbedPane);
		this.pack();
		this.setSize(300, 220);
		this.show();
		this.setVisible(true);
	}


/************ small access functions ********************************************************************/


	public boolean getNorm() {
		return normalize.isSelected();
	}
	public String getL() {
		return connectivity.getText();
	}
	public String getK() {
		return number.getText();
	}
	public String getCT() {
		return numberct.getText();
	}
	public int getdistfct() {
		return distancefunction.getSelectedIndex();
	}

}



class Close implements ActionListener {
	private ConfDialog dialog;

	
	public Close(ConfDialog dialog) {
		this.dialog = dialog;
	}

	public void actionPerformed(ActionEvent evt) {
		dialog.hide();
	}
}
	
class Save implements ActionListener {
	private Configuration conf;
        private ConfDialog dialog;
        private JProgressBar progressBar;

	public Save(Configuration conf, ConfDialog d, JProgressBar p) {
	
		this.conf = conf;
		this.dialog = d;
		this.progressBar = p;

	}


	public void actionPerformed(ActionEvent evt) {
	    
	    conf.setCT(dialog.getCT());
	    conf.setK(dialog.getK());
	    conf.setL(dialog.getL());
	    conf.setdistfct(dialog.getdistfct());
	    conf.setNorm(dialog.getNorm());
	    conf.save();
	  
	    progressBar.setMaximum(500+new Integer(conf.getCT()).intValue()*500);
	
	}
}     


class Configuration  {


    private int size = 0;
    private int dim = 0;
    private int norm = 0;				
    private int distfct = 0;
    private int L = 10;
    private int CT = 3;
    private int K = 50;
    private String filename = "";




	public Configuration() {
		
	}
	

    public void setsize(int value) {
	this.size = value;
	}
    public void setdim(int value) {
	this.dim = value;
    }
    public void setL(String value) {
	this.L = new Integer(value).intValue();
    }
    public void setK(String value) {
	this.K = new Integer(value).intValue();
    }
    public void setCT(String value) {
	this.CT = new Integer(value).intValue();
    }
    public void setdistfct(int value) {
	this.distfct = value;
    }
    public void setNorm(boolean value) {
	if (value == false) norm = 0;
	else norm = 1;
    }
    
    public void setfilename(String n) {
	this.filename = n;
    }
	
    public int getsize() {
	return this.size;
    }

    public int getdim() {
	return this.dim;
    }
    
    	
    public String getfilename() {
	return this.filename;
    }
    
    public boolean getNorm() {
	if (this.norm == 0) return false;
	else return true;
    }

    public int getdistfct() {
	return this.distfct;
    }
    
    public String getL() {
	return (new Integer(this.L)).toString();
    }

    public String getCT() {
	return (new Integer(this.CT)).toString();
    }
    public String getK() {
	return (new Integer(this.K)).toString();
    }
	

	public void save() {
		try {	

			PrintWriter out = new PrintWriter(new FileOutputStream("System.conf"));
			out.print(filename);out.print('\n');
			out.print(size);out.print('\n');		
			out.print(dim);out.print('\n');		
			out.print(distfct);out.print('\n');
			out.print(norm);out.print('\n');
			out.print(L);out.print('\n');
			out.print(K);out.print('\n');
			out.print(CT);out.print('\n');
			out.flush();
			out.close();		

			
		} catch (Exception e) {
		}
	}

	public Configuration read() {
		Configuration newconf = null;
		BufferedReader in;


		try {
			in = new BufferedReader(new FileReader("System.conf"));
		} catch (Exception e) {
			return null;
		}
		try {
		    filename = in.readLine();
		    //  filename = "";
		    size = new Integer(in.readLine()).intValue();
		    //   size = 0;
		    dim = new Integer(in.readLine()).intValue();
		    //   dim = 0;
		    distfct = new Integer(in.readLine()).intValue();
		    norm = new Integer(in.readLine()).intValue();
		    L = new Integer(in.readLine()).intValue();
		    K = new Integer(in.readLine()).intValue();
		    CT = new Integer(in.readLine()).intValue();
		    in.close();
		    this.save();
		    		   

		} catch (Exception e) {
		    return newconf;
   		}
		return this;
		
	}

 

}
