package gui;

import java.awt.Color;
import java.util.ArrayList;

import gamelogic.Game;

import javax.swing.JFrame;
import javax.swing.JInternalFrame;
import javax.swing.JScrollPane;
 
public class barFrame extends JInternalFrame {
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	static int openFrameCount = 0;
    static final int xOffset = 100, yOffset = 50;
    
	@SuppressWarnings("rawtypes")
	ArrayList values = new ArrayList();
	 
	static int primaryIncrements = 20; 
	static int secondaryIncrements = 10; 
	static int tertiaryIncrements = 5;
	static Axis yAxis = new Axis(100, 0, primaryIncrements, secondaryIncrements, 
	                     tertiaryIncrements, "Number of Fruits");
	 
	private static BarChart bar;
    private JScrollPane barScrollPane;
    
    @SuppressWarnings("unchecked")
	public barFrame(int w, int h) {
        super(setTitle(),
              true, //resizable
              true, //closable
              true, //maximizable
              true);//iconifiable
        
    	values.add(new Bar(90, Color.RED, "Apple"));
    	values.add(new Bar(14, Color.BLUE, "Banana"));
    	values.add(new Bar(67, Color.GREEN, "Plum"));
    	values.add(new Bar(30, Color.ORANGE, "Radish"));
    	values.add(new Bar(10, Color.YELLOW, "Corn"));
    	
    	bar = new BarChart(values, yAxis);
    	
    	barScrollPane = new JScrollPane(bar);
 
        //...Create the GUI and put it in the window...
        add(barScrollPane);
        
        //...Then set the window size or call pack...
        setSize ((int) (w *.5), (int) (h*.7));
        
        //Set the window's location.
        setLocation(xOffset, yOffset); 
        
        setDefaultCloseOperation(DISPOSE_ON_CLOSE);
    }    
        
   private static String setTitle()
   {
	   String title;
	   if (Game.currentPlanet != null)
	   {
		 title = Game.currentPlanet.getName();
	   }
	   else
	   {
		 title = "Edit Window";  
	   }
	   return title;
   }
}
    