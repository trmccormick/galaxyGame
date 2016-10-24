package gui;

import javax.swing.JDesktopPane;
import javax.swing.JFrame;

import java.awt.event.*;
import java.awt.*;

import gamelogic.Game;
 
public class MainWindow extends JFrame
                               implements ActionListener {
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

    public static Game currentGame;
    int w, h;
    
    public MainWindow() {   
    	super("Galaxy Game");    	
    	
        currentGame = new Game();
        
        //Make the big window be indented 50 pixels from each edge
        //of the screen.
        int inset = 50;
        Game.screenSize = Toolkit.getDefaultToolkit().getScreenSize();
        w = Game.screenSize.width;
        h = Game.screenSize.height;
        setBounds(inset, inset,
                  w  - inset*2,
                  h - inset*2);
 
        //Set up the GUI.
        Game.desktop = new JDesktopPane(); //a specialized layered pane
        createFrame(); //create first "window"
        setContentPane(Game.desktop);
        MenuBar menu = new gui.MenuBar(this);
        setJMenuBar(menu.get());
 
        //Make dragging a little faster but perhaps uglier.
        Game.desktop.setDragMode(JDesktopPane.OUTLINE_DRAG_MODE); 
    }
  
    //React to menu selections.
    public void actionPerformed(ActionEvent e) {
        if ("new".equals(e.getActionCommand())) { //new
            createFrame();
        } else { //quit
            quit();
        }
    }
 
    //Create a new internal frame.
    protected void createFrame() {
        Game.output = new messageFrame(w, h); 
        Game.main = new internalFrame(w, h);
        Game.systemNav = new treeFrame(w, h);

        Game.output.setVisible(true); //necessary as of 1.3                
        Game.main.setVisible(true); //necessary as of 1.3
        Game.systemNav.setVisible(true); //necessary as of 1.3

        Game.desktop.add(Game.output);
        Game.desktop.add(Game.main);
        Game.desktop.add(Game.systemNav);

        try {
        	Game.output.setSelected(false);                    	
        	Game.main.setSelected(false);
        	Game.systemNav.setSelected(true);
        } catch (java.beans.PropertyVetoException e) {}
    }
 
    //Quit the application.
    protected void quit() {
        System.exit(0);
    }
 
    /**
     * Create the GUI and show it.  For thread safety,
     * this method should be invoked from the
     * event-dispatching thread.
     */
    private static void createAndShowGUI() {
        //Make sure we have nice window decorations.
        JFrame.setDefaultLookAndFeelDecorated(true);
 
        //Create and set up the window.
        MainWindow frame = new MainWindow();
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
 
        //Display the window.
        frame.setVisible(true);
        
        frame.setExtendedState(frame.getExtendedState() | JFrame.MAXIMIZED_BOTH);   
    }
 
    public static void main() {
    	//Schedule a job for the event-dispatching thread:
        //creating and showing this application's GUI.
        javax.swing.SwingUtilities.invokeLater(new Runnable() {
            public void run() {
                createAndShowGUI();
            }
        });
    }
}
