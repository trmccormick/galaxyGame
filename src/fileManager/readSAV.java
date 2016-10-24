package fileManager;
//****************************************************************************
//   Programmer                       :  Tracy McCormick
//   Date                             :  December 8, 2015
//   Input (File)                     :  Loads FreeCiv SAV File
//   Purpose                          :  Load SAV File return Map Object
//****************************************************************************}

import galaxy.Tile;
import galaxy.biomes;
import galaxy.map;
import gamelogic.Game;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;

public class readSAV {

public map run(String savFile) {
	BufferedReader br = null;
	ArrayList<Tile> mapList = new ArrayList<Tile>();
	
	// Create new ArrayList.
	//ArrayList<Character> mapArray = new ArrayList<Character>();
	
	map planetMap = null;
	biomes biomesCount = new biomes();
	String line = "";
    int row;
    int col = 0;
    int i;
	try 
	{
		br = new BufferedReader(new FileReader(savFile));
		row = 0;
		while ((line = br.readLine()) != null) 
		{ // start while	
			i = 0;
			Game.output.append(line);
			int lineLength = line.length();
			if (lineLength > 0 )
			{
			 char a_char = line.charAt(i);
			
			 if (a_char == 't')
			 {
			  while (a_char != '=')
			  { // start while
				 i++;
				 a_char = line.charAt(i);
			  }
              i = i+2;
			  a_char = line.charAt(i);
			 
		      col = 0; //set column	
			 
   			  while (a_char != '"')
			  { // start while
				//mapArray.add(a_char);
			    switch (a_char) {
		        case 'a':  mapList.add(Tile.ARTIC);
                           biomesCount.incArtic();
                           break;
	            case ':':  mapList.add(Tile.DEEP_SEA);
		          		   biomesCount.incDeep_Sea();
		           		   break;
		        case 'd':  mapList.add(Tile.DESERT);
	                       biomesCount.incDesert();
                           break;
	            case 'f':  mapList.add(Tile.FOREST);
		                   biomesCount.incForest();
		           		   break;
		        case 'p':  mapList.add(Tile.PLAINS);
		                   biomesCount.incPlains();
		          		   break;
	            case 'g':  mapList.add(Tile.GRASSLANDS);
		                   biomesCount.incGrasslands();
                           break;
		        case 'h':  mapList.add(Tile.BOREAL); //map.add(Tile.HILLS); //increase height to create hills
		           		   biomesCount.incForest();
		                   break;
		        case 'j':  mapList.add(Tile.JUNGLE);
		           		   biomesCount.incJungle();
                           break;
		        case '+':  mapList.add(Tile.OCEAN); //map.add(Tile.LAKE); //decrease height to create lake
		          		   biomesCount.incOcean();
		           		   break;
		        case 'm':  mapList.add(Tile.BOREAL); //increase height to create mountain
		                   biomesCount.incBoreal();
		          		   break;
		        case ' ':  mapList.add(Tile.OCEAN);
		                   biomesCount.incOcean();
		           		   break;
		        case 's':  mapList.add(Tile.SWAMP);
		                   biomesCount.incSwamp();
		          		   break;
		        case 't':  mapList.add(Tile.TUNDRA);
		           		   biomesCount.incTundra();
                   		   break;
                default:   mapList.add(Tile.ROCK);
                           biomesCount.incRock();
         	   			   break;
		       } // end switch
			   i++;
			   col++;			  
			   a_char = line.charAt(i);
			   //Game.output.append(Character.toString(a_char));
			  } // end while
			 } // end if
  			 row++;
			} // end if 
		} // end while
     	br.close();	
     	Game.output.append(Integer.toString(row));
     	planetMap = new map(row, col, mapList, biomesCount);
     	
	} catch (FileNotFoundException event) {
		event.printStackTrace();
	} catch (IOException event) {
		event.printStackTrace();
	} finally {
		if (br != null) {
			try {
				br.close();
			} catch (IOException event) {
				event.printStackTrace();
			}
		}
	}
	return(planetMap);
  }
}