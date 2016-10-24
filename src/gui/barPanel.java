package gui;

import java.awt.Label;

import javax.swing.*;

public class barPanel extends JInternalFrame {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	
	//Constructor to establish the initial values in the program
	public barPanel()
	{
	  
	  scores = new int[numberOfScores];
	  for (int i = 0; i < scores.length; i++)
	    scores[ i ] = 0;
	  totalX = Xright - Xleft + 1;
	  totalY = Ybottom - Ytop + 1;
	  graphChoice = 'B';
	}	
}
