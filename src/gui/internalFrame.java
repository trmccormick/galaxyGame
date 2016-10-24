package gui;

import javax.swing.JInternalFrame;
import javax.swing.JScrollPane;
 
public class internalFrame extends JInternalFrame {
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	static int openFrameCount = 0;
    static final int xOffset = 220, yOffset = 5;
	private static dataPanel dataPanel = new dataPanel();
    private JScrollPane dataScrollPane = new JScrollPane(dataPanel);
    
    public internalFrame(int w, int h) {
        super("Document", 
              true, //resizable
              true, //closable
              true, //maximizable
              true);//iconifiable
 
        //...Create the GUI and put it in the window...
        add(dataScrollPane);
 
        //...Then set the window size or call pack...
        setSize((int) (w *.83), (int) (h*.62));
 
        //Set the window's location.
        setLocation(xOffset, yOffset);
    }
}