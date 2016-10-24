package fileManager;
//****************************************************************************
//   Programmer                       :  Tracy McCormick
//   Date                             :  September 26, 2015
//   Input (File)                     :  Loads CSV File
//   Purpose                          :  Load CSV File return Solar System Object
//****************************************************************************}

import galaxy.solarSystem;
import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.LinkedList;

public class readCSV {

@SuppressWarnings({ "unchecked", "rawtypes" })
public LinkedList run(String csvFile, LinkedList currentGalaxy) {
	LinkedList galaxy;
	if (currentGalaxy == null)
		{ galaxy = new LinkedList(); }
	else
		{ galaxy = currentGalaxy; }
  
	solarSystem current = null;	
	BufferedReader br = null;
	
	String line = "";
	final String sunHeader = "'seed', 'name', 'luminosity', 'mass', 'life', 'age', 'r_ecosphere'";
	final String planetHeader = "'planet_no', 'a', 'e', 'axial_tilt', 'mass', 'gas_giant', 'dust_mass', 'gas_mass', 'core_radius', 'radius', 'orbit_zone', 'density', 'orb_period', 'day', 'resonant_period', 'esc_velocity', 'surf_accel', 'surf_grav', 'rms_velocity', 'molec_weight', 'volatile_gas_inventory', 'surf_pressure', 'greenhouse_effect', 'boil_point', 'albedo', 'exospheric_temp', 'estimated_temp', 'estimated_terr_temp', 'surf_temp', 'greenhs_rise', 'high_temp', 'low_temp', 'max_temp', 'min_temp', 'hydrosphere', 'cloud_cover', 'ice_cover', 'atmosphere', 'type', 'minor_moons'";

	try 
	{
		br = new BufferedReader(new FileReader(csvFile));
		while ((line = br.readLine()) != null) 
		{ // start while			
			if(sunHeader.equals(line))
			{ // start if
				if (current != null)
				{	
				 galaxy.add(current);
				 current = new solarSystem();
				}
				else
				 current = new solarSystem();
				line = br.readLine();			
				current.loadSun(line);
			} // end if 
			else if (planetHeader.equals(line))
			{ // start else if
				line = br.readLine();
				current.loadPlanet(line);
			} // end else if
			else
			{ // start else if
			   //read planets			
			   current.loadPlanet(line);
			} // end else
		}
		galaxy.add(current);
     	br.close();			
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
	return(galaxy);
  }
}