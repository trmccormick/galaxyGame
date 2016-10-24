package gui;

import gamelogic.Game;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.KeyEvent;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.util.LinkedList;

import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JMenu;
import javax.swing.JMenuBar;
import javax.swing.JMenuItem;
import javax.swing.KeyStroke;

public class MenuBar extends JMenuBar implements ActionListener {
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private JMenuBar menuBar;
    private JMenuItem menuItem;
    private JMenu dropdownMenu, subMenu;
	
    public MenuBar(JFrame frame) { 
        //Create the menu bar.
        menuBar = new JMenuBar();
        
	    dropdownMenu = new JMenu("File");
	    dropdownMenu.setMnemonic('F');
	    menuBar.add(dropdownMenu);

        //Set up the first menu item.
        menuItem = new JMenuItem("New");
        menuItem.setMnemonic(KeyEvent.VK_N);
        menuItem.setAccelerator(KeyStroke.getKeyStroke(
                KeyEvent.VK_N, ActionEvent.ALT_MASK));
        menuItem.setActionCommand("new");
        menuItem.addActionListener(this);
        dropdownMenu.add(menuItem);
        
        menuItem = new JMenuItem("Open");
        menuItem.setMnemonic('O');
        dropdownMenu.add(menuItem);
	    menuItem.addActionListener(this);
	    		    		    
	    menuItem = new JMenuItem("Close");
	    menuItem.setMnemonic('C');
	    dropdownMenu.add(menuItem);
	    
	    menuItem = new JMenuItem("Save");
	    menuItem.setMnemonic('S');
	    dropdownMenu.add(menuItem);		    

	    menuItem = new JMenuItem("Save As");
	    menuItem.setMnemonic('A');
	    menuItem.addActionListener(this);
	    dropdownMenu.add(menuItem);		
	    		    
	    subMenu = new JMenu("Import");
	    subMenu.setMnemonic('I');
	    dropdownMenu.add(subMenu);
	    
	    menuItem = new JMenuItem("Stargen CSV File");
	    menuItem.setToolTipText("Add Stargen CSV to Current Galaxy"); 
	    menuItem.addActionListener(this); 	    
	    subMenu.add(menuItem);
	    		    
	    subMenu = new JMenu("Export");
	    subMenu.setMnemonic('E');
	    dropdownMenu.add(subMenu);
	    
	    menuItem = new JMenuItem("Export Current System");
	    menuItem.setToolTipText("Export Current System to Stargen CSV"); 
	    menuItem.addActionListener(this); 
	    subMenu.add(menuItem);
	    		    
	    menuItem = new JMenuItem("Export Galaxy");
	    menuItem.setToolTipText("Export Galaxy to Stargen CSV"); 
	    menuItem.addActionListener(this); 
	    subMenu.add(menuItem);
	    
        //Set up the second menu item.
        menuItem = new JMenuItem("Exit");
        menuItem.setMnemonic(KeyEvent.VK_X);
        menuItem.setAccelerator(KeyStroke.getKeyStroke(
                KeyEvent.VK_X, ActionEvent.ALT_MASK));
        menuItem.setActionCommand("exit");
        menuItem.addActionListener(this);        
        dropdownMenu.add(menuItem);
	    
        dropdownMenu = new JMenu("Edit");
        dropdownMenu.setMnemonic('E');
        dropdownMenu.addActionListener(this); 
	    menuBar.add(dropdownMenu);
	    
	    menuItem = new JMenuItem("Find");
	    menuItem.addActionListener(this); 
	    dropdownMenu.add(menuItem);
	    
	    dropdownMenu = new JMenu("Help");
	    dropdownMenu.setMnemonic('H');
	    dropdownMenu.addActionListener(this); 
	    menuBar.add(dropdownMenu);
	    
	    menuItem = new JMenuItem("About Galaxy Game");
	    menuItem.setActionCommand("about");
	    menuItem.addActionListener(this);
        dropdownMenu.add(menuItem);
    }
    
    public JMenuBar get()
    {
        return menuBar;
    }

	@SuppressWarnings("rawtypes")
	public void actionPerformed(ActionEvent e) {
		int returnVal;
		// TODO Auto-generated method stub
	    switch (e.getActionCommand()) {
        case "about":
	        AboutDialog ad = new AboutDialog();
	        ad.setVisible(true);        
        	break;
	    case "exit":  
	    	quit();
	    	break;
	    case "Save As":        	        	
	        JFileChooser saveas = new JFileChooser();
	        returnVal = saveas.showDialog(null, "Save As");
	        if (returnVal == javax.swing.JFileChooser.APPROVE_OPTION) 
	        {
	        	java.io.File file = saveas.getSelectedFile();
		        try {
		            FileOutputStream fos = new FileOutputStream (file.toString());
		            ObjectOutputStream oos = new ObjectOutputStream(fos);
		            oos.writeObject(MainWindow.currentGame);
		            fos.close();
		          } 
		          catch (Exception event) {
		            Game.output.append(event.toString());   
		          }
	        }	        
	        break;
	    case "Open":        	        	        	
	        JFileChooser open = new JFileChooser();
	        returnVal = open.showOpenDialog(null);
	        if (returnVal == javax.swing.JFileChooser.APPROVE_OPTION) 
	        {
	        	  MainWindow.currentGame = new Game();
	        	  try {
	  	        	java.io.File file = open.getSelectedFile();
	        	    FileInputStream fis = new  FileInputStream(file.toString());
	        	    @SuppressWarnings("resource")
					ObjectInputStream ois = new ObjectInputStream(fis);
	        	    Object obj = ois.readObject();
	        	    MainWindow.currentGame = (Game) obj;
	        	  } 
		          catch (Exception event) {
			            Game.output.append(event.toString());   
			          }
	        	
	        	Game.systemNav.clearTree();
	        }
	        break;
	    case "Stargen CSV File":        	
	        JFileChooser importcsv = new JFileChooser();
	        returnVal = importcsv.showDialog(null, "Import Stargen CSV");
	        if (returnVal == javax.swing.JFileChooser.APPROVE_OPTION) 
	        {
	        	Game.systemNav.clearTree();
	        	java.io.File file = importcsv.getSelectedFile();
	        	Game.importGalaxy(file.toString());
	        }
	        break;	        
	    case "new":
	        //mainPanel.emptyList();
	        //splitPane.output.setText(null);
	        break;         	
	    default: 
	        break;
	    }			
	}
	
	//Quit the application.
	protected static void quit() {
		System.gc(); 
		System.exit(0);
	}
}
