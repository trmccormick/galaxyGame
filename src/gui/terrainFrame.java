package gui;

import gamelogic.Game;

import javax.swing.JInternalFrame;
import javax.swing.JScrollPane;
 
public class terrainFrame extends JInternalFrame {
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	static int openFrameCount = 0;
    static final int xOffset = 20, yOffset = 100;
	private static terrainPanel terrain = new terrainPanel();
    private JScrollPane terrainScrollPane = new JScrollPane(terrain);
    
    public terrainFrame(int w, int h) {
        super("Terrain Map", 
              true, //resizable
              true, //closable
              true, //maximizable
              true);//iconifiable
 
        //...Create the GUI and put it in the window...
        add(terrainScrollPane);
        
        //...Then set the window size or call pack...
        //setSize ((int) (w *.66), (int) (h*.6));
        setSize ((int) ((Game.currentPlanet.planetMap.getWidth() + 2) * 5), (int) ((Game.currentPlanet.planetMap.getLength() + 7) * 5));
        
        //Set the window's location.
        setLocation(xOffset, yOffset); 
    }
}