package fileManager;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintStream;
import java.util.StringTokenizer;

public class Settings 
{
	private static final int DEFAULT_MINES = 10, DEFAULT_SIZE = 25;
	private static int numberOfMines = DEFAULT_MINES,tableSize = DEFAULT_SIZE;
	
	public static void set()
	{
		numberOfMines = DEFAULT_MINES;
		tableSize = DEFAULT_SIZE;
	}
	
	public static void set(int newTableSize,int newNumberOfMines)
	{
		numberOfMines = newNumberOfMines;
		tableSize = newTableSize;
	}
	
	public static int getTableSize() 
	{
		return tableSize;
	}

	public static int getNumberOfmines() 
	{
		return numberOfMines;
	}
	
	public static void readFromFile() throws IOException
	{
		BufferedReader fin= new BufferedReader(new InputStreamReader
				(new FileInputStream("Settings.txt")));
		String line = fin.readLine();
		StringTokenizer strtok = new StringTokenizer(line," ");
		numberOfMines = Integer.parseInt(strtok.nextToken().toString());
		tableSize = Integer.parseInt(strtok.nextToken().toString());
		fin.close();  //Close the stream
	}
	
	public static void writeToFile() throws IOException
	{
		PrintStream fout = new PrintStream(new FileOutputStream("Settings.txt"));
		fout.println(numberOfMines + " " + tableSize);
		fout.close();
	}
			
	

}
