package gui;

import java.awt.Dialog;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;

public class TemplateEvents
{	
	public static class CloseWindowEvent extends WindowAdapter 
	{
		private Dialog dialogPointer;
		
		public CloseWindowEvent(Dialog dial)
		{
			dialogPointer = dial; //Shallow copy
		}
		
		public void windowClosing(WindowEvent we)
		{
			dialogPointer.setVisible(false);
			dialogPointer.dispose();
		}
	}
	
	public static class CloseButtonMouseAdapter extends MouseAdapter
	{
		private Dialog dialogPointer;
		
		public CloseButtonMouseAdapter(Dialog dial)
		{
			dialogPointer = dial; //Shallow copy
		}
		
		public void mousePressed(MouseEvent e) 
		{  
			dialogPointer.setVisible(false);
			dialogPointer.dispose();
        }
	}
}
