package gui;

import javax.swing.JInternalFrame;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;
 
public class messageFrame extends JInternalFrame {
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	static int openFrameCount = 0;
    static final int xOffset = 220, yOffset = 489;
    public static JTextArea output;
    public static String newline = "\n";
    
    public messageFrame(int w, int h) {
        super("Messages", 
              true, //resizable
              true, //closable
              true, //maximizable
              true);//iconifiable
 
        //...Create the GUI and put it in the window...
        //Create a scrolled text area.
        output = new JTextArea();
        output.setEditable(false);
        JScrollPane scrollPane = new JScrollPane(output);
        add(scrollPane);
        
        //...Then set the window size or call pack...
        setSize ((int) (w *.83), (int) (h*.2));
 
        //Set the window's location.
        setLocation(xOffset, yOffset); 
    }
    
    public void append(String text){
    	output.append(text);
    	output.append(newline);
    	output.setCaretPosition(output.getDocument().getLength()); 
    }
}