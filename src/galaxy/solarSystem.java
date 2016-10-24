package galaxy;
//****************************************************************************
//   Programmer                       :  Tracy McCormick
//   Date                             :  September 26, 2015
//   Purpose                          :  Class to Manage Solar System
//****************************************************************************}
import java.util.LinkedList;

import tools.myMath;

public class solarSystem {
	tools.strConvert mystrConvert = new tools.strConvert();
	//create current sun
	public sun currentSun = new sun();

	public LinkedList<planet> planetList = new LinkedList<planet>();
	
    public int total_planets; // number of planets and or moons in this system
   
    public solarSystem() {
        // set initial value to 0
    	total_planets = 0;
    }
    
	public void loadSun(String line) {
		String cvsSplitBy = ",";

		// remove ' from string
		line = line.replace("'", "");
        //split string into separate elements
		String[] lineArray = line.split(cvsSplitBy);

		getCurrentSun().seed = Integer.parseInt(lineArray[0].trim()); 
		getCurrentSun().name = lineArray[1].trim();
		getCurrentSun().luminosity = mystrConvert.doubleConvert(lineArray[2].trim());
		getCurrentSun().mass = mystrConvert.doubleConvert(lineArray[3].trim());
		getCurrentSun().life = mystrConvert.doubleConvert(lineArray[4].trim());
		getCurrentSun().age = mystrConvert.doubleConvert(lineArray[5].trim());
		getCurrentSun().r_ecosphere = mystrConvert.doubleConvert(lineArray[6].trim());	
	}
	
	public void loadPlanet(String line) {
		String cvsSplitBy = ",";
   
		planet currentPlanet = new planet();
		
		// remove ' from string
		line = line.replace("'", "");
		
        //split string into separate elements
		String[] lineArray = line.split(cvsSplitBy);
		
	    // use comma as separator
		lineArray = line.split(cvsSplitBy);

		currentPlanet.name = lineArray[0].trim();

		// use space as separator to get planet number
		String templine = lineArray[0].trim();
		String[] templine2 = templine.split(" ");
		currentPlanet.planet_no = templine2[templine2.length-1];
		currentPlanet.a = mystrConvert.doubleConvert(lineArray[1].trim());
		currentPlanet.e = mystrConvert.doubleConvert(lineArray[2].trim());
		currentPlanet.axial_tilt = mystrConvert.doubleConvert(lineArray[3].trim());
		currentPlanet.mass = mystrConvert.doubleConvert(lineArray[4].trim());
		currentPlanet.gas_giant = Boolean.parseBoolean(lineArray[5].trim());
		currentPlanet.dust_mass = mystrConvert.doubleConvert(lineArray[6].trim());
		currentPlanet.gas_mass = mystrConvert.doubleConvert(lineArray[7].trim());
		currentPlanet.core_radius = mystrConvert.doubleConvert(lineArray[8].trim());
		currentPlanet.radius = mystrConvert.doubleConvert(lineArray[9].trim());
		currentPlanet.orbit_zone = mystrConvert.integerConvert(lineArray[10].trim());
		currentPlanet.density = mystrConvert.doubleConvert(lineArray[11].trim());
		currentPlanet.orb_period = mystrConvert.doubleConvert(lineArray[12].trim());
		currentPlanet.day = mystrConvert.doubleConvert(lineArray[13].trim());
		currentPlanet.resonant_period = Boolean.parseBoolean(lineArray[14].trim());
		currentPlanet.esc_velocity = mystrConvert.doubleConvert(lineArray[15].trim());
		currentPlanet.surf_accel = mystrConvert.doubleConvert(lineArray[16].trim());
		currentPlanet.surf_grav = mystrConvert.doubleConvert(lineArray[17].trim());
		currentPlanet.rms_velocity = mystrConvert.doubleConvert(lineArray[18].trim());
		currentPlanet.molec_weight = mystrConvert.doubleConvert(lineArray[19].trim());
		currentPlanet.volatile_gas_inventory = mystrConvert.doubleConvert(lineArray[20].trim());
		currentPlanet.surf_pressure = mystrConvert.doubleConvert(lineArray[21].trim());
		currentPlanet.greenhouse_effect = mystrConvert.integerConvert(lineArray[22].trim());
		currentPlanet.boil_point = mystrConvert.doubleConvert(lineArray[23].trim());
		currentPlanet.albedo = mystrConvert.doubleConvert(lineArray[24].trim());
		currentPlanet.exospheric_temp = mystrConvert.doubleConvert(lineArray[25].trim());
		currentPlanet.estimated_temp = mystrConvert.doubleConvert(lineArray[26].trim());
		currentPlanet.estimated_terr_temp = mystrConvert.doubleConvert(lineArray[27].trim());
		currentPlanet.surf_temp = mystrConvert.doubleConvert(lineArray[28].trim());
		currentPlanet.greenhs_rise = mystrConvert.doubleConvert(lineArray[29].trim());
		currentPlanet.high_temp = mystrConvert.doubleConvert(lineArray[30].trim());
		currentPlanet.low_temp = mystrConvert.doubleConvert(lineArray[31].trim());
		currentPlanet.max_temp = mystrConvert.doubleConvert(lineArray[32].trim());
		currentPlanet.min_temp = mystrConvert.doubleConvert(lineArray[33].trim());
		currentPlanet.hydrosphere = mystrConvert.doubleConvert(lineArray[34].trim());
		currentPlanet.cloud_cover = mystrConvert.doubleConvert(lineArray[35].trim());
		currentPlanet.ice_cover = mystrConvert.doubleConvert(lineArray[36].trim());
        if (lineArray[37].length() > 0)
        {	
        	currentPlanet.atmosphere = loadAtmosphere(lineArray[37].trim());
        	currentPlanet.gases = currentPlanet.atmosphere.length;
        }
        currentPlanet.planet_type = lineArray[38].trim();
		if (39 < lineArray.length)
        {				
			currentPlanet.minor_moons = mystrConvert.integerConvert(lineArray[39].trim());
        }	
		++total_planets;
		planetList.add(currentPlanet);
	}
	
	Gas[] loadAtmosphere(String line) {
		double temp;
		
		// remove % from string
		line = line.replace("%", "");

		// remove mb from string
		line = line.replace("mb", "");
		
		// remove (ipp: from string
		line = line.replace("(ipp:", "");
		
		// remove } from string
		line = line.replace(")", "");

		String[] lineArray = line.split(";");
		Gas[] atmosphere = new Gas[lineArray.length];
		
		for (int i = 0; i < lineArray.length; i++)
		{
			lineArray[i] = lineArray[i].trim();
			atmosphere[i] = new Gas();		
		    String[] lineArray2 = lineArray[i].split(" ");
		
		    if (0 < lineArray2.length)
		    {
	                //strip leading or trailing spaces
			    	String newString = lineArray2[0].trim();
			    	atmosphere[i].setName(newString);
		    }
		    if (1 < lineArray2.length)
		    {
	                //strip leading or trailing spaces
			    	String newString = lineArray2[1].trim();
			    	atmosphere[i].setPercentage(mystrConvert.doubleConvert(newString));
		    }
		    if (2 < lineArray2.length)
		    {
	                //strip leading or trailing spaces
			    	String newString = lineArray2[2].trim();
			    	atmosphere[i].setMB(mystrConvert.doubleConvert(newString));
			    	if (atmosphere[i].getMB() == 0) {
			    		if (i != 0) {
			    			temp = ((atmosphere[0].getMB() * 100) / atmosphere[0].getPercentage());
			    			atmosphere[i].setMB(temp * (atmosphere[i].getPercentage() / 100));
			    			atmosphere[i].setMicroBar(atmosphere[i].getMB() * 1E3);
			    		}
			    	}
		    }		    
		    if (3 < lineArray2.length)
		    {
	                //strip leading or trailing spaces
			    	String newString = lineArray2[3].trim();
			    	atmosphere[i].setIPP(mystrConvert.doubleConvert(newString));
		    }		    
		    if (4 < lineArray2.length)
		    {
	                //strip leading or trailing spaces
			    	String newString = lineArray2[4].trim();
			    	atmosphere[i].setDescription(newString);
		    }
		}
	    return(atmosphere);
	}		
	
	public static Gas GasCheck(double mb, Gas NewGas) {
		if (NewGas.ppm > 0)
		 NewGas.percentage = NewGas.ppm / 10000;
		
		if (Math.round(NewGas.percentage) < 0) throw new IllegalArgumentException();
		{
		  if (NewGas.ppm == 0)
			NewGas.ppm = (NewGas.percentage / 100) * 1000000;
		 
		  NewGas.kpa = myMath.percent2kpa(mb, NewGas.percentage); 		
		  NewGas.millibar = myMath.kpa2mb(NewGas.kpa); 
		  NewGas.microbars = myMath.mb2microbar(NewGas.millibar); 
		}
	    return (NewGas);
	}

	public sun getCurrentSun() {
		return currentSun;
	}

	public void setCurrentSun(sun currentSun) {
		this.currentSun = currentSun;
	}
	
    public int getPlanetCount() {
    	return total_planets;
    }
}
