package gamelogic;

import java.io.IOException;



import javax.swing.JFrame;


import fileManager.Settings;
//import gui.LoadingWindow;
import gui.MainWindow;
//import gui.MessageBox;

public class galaxyClient
{
	public static void main(String[] args) {
		try 
		{
			Settings.readFromFile();
		} 
		catch (IOException e) 
		{
			//MessageBox mes = new MessageBox(null,
			//								"COULD NOT FIND SETTINGS!",
			//								"Settings.txt not found. Loading default values");
			//mes.setVisible(true);
		}
		
		//LoadingWindow lw = new LoadingWindow(null,"AWTMinesweeper","Loading table");
		//lw.setVisible(true);
		//MinefieldModel model = new MinefieldModel(Settings.getNumberOfmines(),Settings.getTableSize());
		MainWindow mw = new MainWindow();
		mw.setExtendedState(JFrame.MAXIMIZED_BOTH);
		mw.setVisible(true);
		//lw.setVisible(false);
		//lw.dispose();
	}
}
