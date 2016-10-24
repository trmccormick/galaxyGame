package gamelogic;

import java.awt.Dimension;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.LinkedList;

import javax.swing.JDesktopPane;
import javax.swing.JTable;

import galaxy.Gas;
import galaxy.planet;
import galaxy.solarSystem;
import gui.barFrame;
import gui.internalFrame;
import gui.editFrame;
import gui.messageFrame;
import gui.modifyFrame;
import gui.terrainFrame;
import gui.treeFrame;

import tools.TerraSim1_1;

public class Game implements Serializable {
	  /**
	  * 
	  */
	  private static final long serialVersionUID = 1L;
	  public static JDesktopPane desktop;
      public static internalFrame main;
      public static treeFrame systemNav;
      public static messageFrame output;
	  public static editFrame gameCanvas;
	  public static terrainFrame terrainMap;
	  public static modifyFrame modify;
	  public static barFrame bar;
	  public static TerraSim1_1 tsim;
	  
	  @SuppressWarnings("rawtypes")
	  public static LinkedList currentGalaxy;
	  public static String selected;
	  public static solarSystem currentSystem;
	  public static planet currentPlanet;
	  public static JTable planetList;
	  
	  public static Dimension screenSize;
	
	  // Depot Inventory
	  int gases; // Count of gases in the atmosphere:
	  Gas[] atmosphere; // Atmosphere composition
	  double[] gasprice; // Cost of Gases
	  double carbon; // Carbon
	  double carbonprice; // Cost of Carbon
	  
	  //constructor
	  public Game()
	  {
	   desktop = null;
	   main = null;
	   systemNav = null;
	   output = null;
	   gameCanvas = null;
	   terrainMap = null;
	   modify = null;
	   
	   tsim = new TerraSim1_1();
	   
	   currentGalaxy = null;
	   currentSystem = null;
	   currentPlanet = null;
	   planetList = null;
	  }
	  
	  public static void loadGalaxy(String file_name)
	  {
	    //new readCSV object          	
	    fileManager.readCSV obj = new fileManager.readCSV();
	    //start loading CSV file
	  	currentGalaxy = obj.run(file_name, null);
	  	solarSystem current;
	  	clearList();
    	for (int i = 0; i < currentGalaxy.size(); i++) {
      	  current = (solarSystem) currentGalaxy.get(i);
      	  // Create an ArrayList of strings.
      	  ArrayList<String> list = new ArrayList<>();
      	  list.add(current.currentSun.name);
  		  // Use toArray to copy ArrayList to string array.
  		  String[] array = new String[list.size()];
  		  array = list.toArray(array);  		    		  
  		  systemNav.append(array);
      	}
	  } 
	  
	  public static void importGalaxy(String file_name)
	  {
		    //new readCSV object          	
		    fileManager.readCSV obj = new fileManager.readCSV();
		    //start loading CSV file
		  	currentGalaxy = obj.run(file_name, currentGalaxy);
		  	solarSystem current;
		  	clearList();
			//create list to be added to side planet nav
	    	for (int i = 0; i < currentGalaxy.size(); i++) {
	      	  current = (solarSystem) currentGalaxy.get(i);
	      	  // Create an ArrayList of strings.
	      	  ArrayList<String> list = new ArrayList<>();
	      	  list.add(current.currentSun.name);
	  		  // Use toArray to copy ArrayList to string array.
	  		  String[] array = new String[list.size()];
	  		  array = list.toArray(array);  		    		  
	  		  systemNav.append(array);
	      	}		  
      } 
	  
	  public static void importMap(String file_name)
	  {
		    //new readCSV object          	
		    fileManager.readSAV obj = new fileManager.readSAV();
		  	  	  
		    //start loading SAV file
		  	currentPlanet.setMap(obj.run(file_name));
		  	//updatePlanet(currentPlanet);
		  	output.append(currentPlanet.getName());
      } 
	  	  
	  public static solarSystem getSystem(String systemName)
	  {
		  	solarSystem current, found;
			found = null;			
	    	for (int i = 0; i < currentGalaxy.size(); i++) {
	      	  current = (solarSystem) currentGalaxy.get(i);
	      	  if (current.currentSun.name.equals(systemName))
	      	  {
	      		  found = current;
	      	  }
	      	}
	    	return found;
      }
	  
	  public static planet getPlanet(String planetName)
	  {
		  	solarSystem currentSystem;
		  	planet currentPlanet, found;
			found = null;			
	    	for (int i = 0; i < currentGalaxy.size(); i++) {
	      	  currentSystem = (solarSystem) currentGalaxy.get(i);
	      	  for (int x = 0; x < currentSystem.getPlanetCount(); x++) {
	      	   currentPlanet = currentSystem.planetList.get(x);
	      	   if (currentPlanet.getName().equals(planetName))
	      	   {
	      		  found = currentPlanet;
	      	   }
	      	  }
	      	}
	    	return found;
      }
	  
	  public static void showGalaxyInfo()
	  {
		if (currentGalaxy != null) 
			output.append("Current system count: " + currentGalaxy.size());
		else
			output.append("No Galaxy Loaded");
	  }
	  
	  public static void clearList() {
			systemNav.clearTree();
	  }
	  
	  public static void setSelected (String currentSelection)
	  {
		  	selected = currentSelection;
		  	currentSystem = getSystem(currentSelection);
	  }

	  public static String getSelected ()
	  {
		  	return(selected);
	  }
	  
	  //@SuppressWarnings("unchecked")
	  //public static void updatePlanet(planet update) {
		//  	solarSystem system;
		//  	planet p;		  	
	    //	for (int i = 0; i < currentGalaxy.size(); i++) {
	    //  	  system = (solarSystem) currentGalaxy.get(i);
	    //  	  for (int x = 0; x < system.total_planets; x++) {
		//      	  p = system.planetList.get(x);
	    //  	      if (p.getName().equals(update.getName()))
	     // 	      { 
	     // 	    	  system.planetList.set(x, update);
	     // 	    	  currentGalaxy.set(i, system);
	     // 	      }
	     // 	  }
	    //	}
	  //}	 
	  
	  public static void resetCurrentPlanet() 
	  { // start resetCurrentPlanet
	    	boolean selected;
	    	for (int index = 0; index < planetList.getRowCount(); index++) 
			{ // start for						
				 selected = planetList.getSelectionModel().isSelectedIndex(index);
				 if (selected)
				 { // start if
					 //updatePlanet(currentPlanet);
					 currentPlanet = currentSystem.planetList.get(index);
					 output.append(currentPlanet.getName());
				 } // end if
			} // end for		
		} // end resetCurrentPlanet
}