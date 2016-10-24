package gui;

import gamelogic.Game;

import javax.swing.JInternalFrame;
import javax.swing.JScrollPane;
 
public class modifyFrame extends JInternalFrame {
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	static int openFrameCount = 0;
    static final int xOffset = 100, yOffset = 50;
	private static modifyPanel modify = new modifyPanel();
    private JScrollPane modifyScrollPane = new JScrollPane(modify);
    
    public modifyFrame(int w, int h) {
        super(setTitle(),
              true, //resizable
              true, //closable
              true, //maximizable
              true);//iconifiable
 
        //...Create the GUI and put it in the window...
        add(modifyScrollPane);
        
        //...Then set the window size or call pack...
        setSize ((int) (w *.4), (int) (h*.6));
        
        //Set the window's location.
        setLocation(xOffset, yOffset); 
        
        setDefaultCloseOperation(DISPOSE_ON_CLOSE);
    }    
        
   private static String setTitle()
   {
	   String title;
	   if (Game.currentPlanet != null)
	   {
		 title = ("Modify (" + Game.currentPlanet.getName() + ")");  
	   }
	   else
	   {
		 title = "Modify Planet";  
	   }
	   return title;
   }
}
    