package gui;

import gamelogic.Game;

import javax.swing.JFrame;
import javax.swing.JInternalFrame;
import javax.swing.JScrollPane;
 
public class editFrame extends JInternalFrame {
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	static int openFrameCount = 0;
    static final int xOffset = 100, yOffset = 50;
	private static editPanel edit = new editPanel();
    private JScrollPane editScrollPane = new JScrollPane(edit);
    
    public editFrame(int w, int h) {
        super(setTitle(),
              true, //resizable
              true, //closable
              true, //maximizable
              true);//iconifiable
 
        //...Create the GUI and put it in the window...
        add(editScrollPane);
        
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
    