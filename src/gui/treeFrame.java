package gui;

import javax.swing.JInternalFrame;
import javax.swing.JScrollPane;
import javax.swing.JTree;

import gui.treePanel;
 
public class treeFrame extends JInternalFrame {
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	static int openFrameCount = 0;
    static final int xOffset = 10, yOffset = 5;
	private static treePanel treePanel = new treePanel();
    private JScrollPane treeScrollPane = new JScrollPane(treePanel.getTree());
 
    public treeFrame(int w, int h) {
        super("System Navigation", 
              false, //resizable
              false, //closable
              false, //maximizable
              false);//iconifiable
 
        //...Create the GUI and put it in the window...
        add(treeScrollPane);
        
        //...Then set the window size or call pack...
        setSize((int) (w *.15), (int) (h*.83));
 
        //Set the window's location.
        setLocation(xOffset, yOffset);
    }
    
    public void append(String[] newNode){
    	treePanel.append(newNode);
    	treePanel.resetNav();
    }
    
	public void clearTree() {
		treePanel.clearTree();
		treePanel.repaint();
	}
}