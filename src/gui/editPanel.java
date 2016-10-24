package gui;
import galaxy.Tile;
import galaxy.map;
import gamelogic.Game;

import java.awt.Color;
import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.GridBagLayout;
import java.awt.Image;
import java.awt.Toolkit;

import javax.swing.JPanel;
import javax.swing.JScrollPane;
 
public class editPanel extends JPanel{
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private static final int tW = 16; // tile width
    private static final int tH = 16; // tile height
     
    private Image tileset;
 
    public editPanel() {
        tileset = Toolkit.getDefaultToolkit().getImage(this.getClass().getResource("../resources/tileset - simearth.png"));
        initGUI();
    }
 
    public void initGUI() {
		setPreferredSize(new Dimension(400, 400));
    }
    
    @Override
    protected void paintComponent(Graphics g) {
    	Game.output.append("paint component");
    	Game.output.append(Game.currentPlanet.getName());
    	map planetMap = Game.currentPlanet.getMap();
        if (planetMap != null) {
        	this.setPreferredSize(new Dimension(planetMap.mapWidth*16, planetMap.mapLength*16));
        	g.setColor(Color.black);
        	g.fillRect(0, 0, getWidth(), getHeight());
        	for(int i=0;i<planetMap.mapWidth;i++)
        		for(int j=0;j<planetMap.mapLength;j++)
        			drawTile(g, planetMap.currentMap[j][i], i*tW,j*tH);
        	}
    }
 
    protected void drawTile(Graphics g, Tile t, int x, int y){
        // map Tile from the tileset
        int mx = t.ordinal()%16;
        int my = t.ordinal()/16;
        g.drawImage(tileset, x, y, x+tW, y+tH,
                mx*tW, my*tH,  mx*tW+tW, my*tH+tH, this);
    }
}
