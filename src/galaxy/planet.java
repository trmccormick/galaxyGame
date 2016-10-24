package galaxy;

import gamelogic.Game;
import gui.terrainFrame;

public class planet {
	private final double STEFANB_CONSTANT = 5.67E-8;
	
	// fields
	String name; // name of planet
	String planet_no; // position of planet in system
	double a; // semi-major axis of the orbit (in AU)
    double e; // eccentricity of the orbit
	double axial_tilt; // units of degrees
	double mass; // mass (in solar masses)
	boolean gas_giant; // TRUE if the planet is a gas giant
	double dust_mass; // mass, ignoring gas
	double gas_mass; // mass, ignoring dust
	double core_radius;	// radius of the rocky core (in km)
	double radius; // equatorial radius (in km)
	int orbit_zone;	// the 'zone' of the planet
	double density;	// density (in g/cc)
	double orb_period; // length of the local year (days)
	double day;	// length of the local day (hours)
	boolean resonant_period; // TRUE if in resonant rotation
	double esc_velocity; // units of cm/sec
	double surf_accel; // units of cm/sec2
	double surf_grav; // units of Earth gravities
	double rms_velocity; // units of cm/sec
	double molec_weight; // smallest molecular weight retained
	double volatile_gas_inventory;
	double surf_pressure; // units of millibars (mb)
	int	greenhouse_effect;	// runaway greenhouse effect?
	double boil_point; // the boiling point of water (Kelvin)
	double albedo; // albedo of the planet
	
	double insolation; //Insolation factor
	double emissivity; //Emissivity
	
	double effective_temp = 0; // effective temp (Tb)
    double greenhouse_temp; // current temp with greenhouse effect (Ts)
	double deltaT; // Delta T: degrees of warming over effective temperature
	double Polar_temp; // Polar Temp (Tp)
	double Tropic_temp; // Tropical Temp (Tt)
    double iceLat; // Planet Frozen above Latitude
	double habRatio; // Habitable percentage of surface
	
	double Solar_Constant; // Current Solar Constant
	double exospheric_temp;	// units of degrees Kelvin
	double estimated_temp; // quick non-iterative estimate (K)
	double estimated_terr_temp; // for terrestrial moons and the like
	double surf_temp; // surface temperature in Kelvin
	double greenhs_rise; // Temperature rise due to greenhouse
	double high_temp; // Day-time temperature
	double low_temp; // Night-time temperature
	double max_temp; // Summer/Day
	double min_temp; // Winter/Night
	double hydrosphere; // fraction of surface covered
	double cloud_cover;	// fraction of surface covered
	double ice_cover; // fraction of surface covered
	
	int	gases; // Count of gases in the atmosphere
	Gas[] atmosphere; // Atmosphere composition
	
	String planet_type; // Type code
	int	minor_moons;
	double Ins; // Insolation Factor 1 for no change lower values to deflect sun away, higher to add to
	boolean is_moon; // Set to TRUE if is Moon FALSE if not 
	
	public static terrainFrame terrainMap;
	public map planetMap;
	
	public biomes biomesCount = new biomes();
	
	public planet(){
		terrainMap = null;
		planetMap = null;
		insolation = 1;
	}
	
	public double getIns() {
		return(this.insolation);
	}

	public Gas[] getAtmosphere() {
		return atmosphere;
	}
	
	public Gas getGas(String name) {
		Gas returnVal = null;
        for (int loop = 0; loop <= atmosphere.length-1; loop++)
        {
        	if (atmosphere[loop].getName().equals(name))
        	{        		
                returnVal = atmosphere[loop];
        	}            
        }
        return(returnVal);
	}	
	
	public void setGas(String name, double Value, double Pr, double Regolith, double Pole, double Td) {
		boolean found = false;
        for (int loop = 0; loop <= this.gases-1; loop++)
        {
        	if (atmosphere[loop].getName().equals(name))
        	{
        		found = true;
        		atmosphere[loop].setMB(Value);
        		atmosphere[loop].setMicroBar(Value * 1E3);
        		
        		atmosphere[loop].setPr(Pr);
        		atmosphere[loop].setRegolith(Regolith);
        		atmosphere[loop].setPole(Pole);
        		atmosphere[loop].setTd(Td);       		
        	}            
        }
        if (found == false) {
        	int count = this.gases;
        	count++;
        	Gas[] atmosphere2 = new Gas[count];
            for (int loop = 0; loop <= this.gases-1; loop++)
            {
            	atmosphere2[loop] = atmosphere[loop];
            }       	
            atmosphere2[this.gases] = new Gas();
            atmosphere2[this.gases].setName(name);
        	atmosphere2[this.gases].setMB(Value);
    		atmosphere2[this.gases].setMicroBar(Value * 1E3);
    		
    		atmosphere2[this.gases].setPr(Pr);
    		atmosphere2[this.gases].setRegolith(Regolith);
    		atmosphere2[this.gases].setPole(Pole);
    		atmosphere2[this.gases].setTd(Td);
    		
        	this.gases++; 
        	atmosphere = atmosphere2;
        }
    	//calcPressure();
    	//calcAtmPercent();
	}	
	
    public void calcPressure() {
    	this.surf_pressure = 0;
        for (int loop = 0; loop <= this.gases-1; loop++)
        {
        	this.surf_pressure = this.surf_pressure + atmosphere[loop].millibar;
        }
    }
    
    public void calcAtmPercent() {
        for (int loop = 0; loop <= atmosphere.length-1; loop++)
        {
        	atmosphere[loop].percentage = (atmosphere[loop].millibar / this.surf_pressure) * 100;
        }             
    }
    	
    public void setName(String name) {
        this.name = name;
    }

    public String getName() {
        return name;
    }
    
    public void setPlanet_no(String Value) {
        this.planet_no = Value;
    }    
    
    public String getPlanet_no() {
    	return planet_no;
    }
    
    public void setDist(String Value) {
        this.a = Double.valueOf(Value);
    }        
    
    public String getDist() {
		String result = String.format("%.3f", a);	
    	return result;    	
    }
    
    public void setEccentricity(String Value) {
        this.e = Double.valueOf(Value);
    }        
    
    public String getEccentricity() {
		String result = String.format("%.3f", e);	
    	return result;    	    	
    }
    
    public void setAxial_tilt(String Value) {
        this.axial_tilt = Double.valueOf(Value);
    }        
        
    public String getAxial_tilt() {
		String result = String.format("%.3f", axial_tilt);	
    	return result;    	    	    	
    }
    
    public void setMass(String Value) {
        this.mass = Double.valueOf(Value);
    }            
    
    public String getMass() {
		String result = String.format("%.3f", mass);	
    	return result;
    }
    
    public void setDustMass(String Value) {
        this.dust_mass = Double.valueOf(Value);
    }            
    
    public String getDustMass() {
		String result = String.format("%.3f", dust_mass);	
    	return result;
    }
    
    public void setGasMass(String Value) {
        this.gas_mass = Double.valueOf(Value);
    }            

    public String getGasMass() {
		String result = String.format("%.3f", gas_mass);	
    	return result;    	
    }
    
    public void setCoreRadius(String Value) {
        this.core_radius = Double.valueOf(Value);
    }            
    
    public String getCoreRadius() {
		String result = String.format("%.3f", core_radius);	
    	return result;    	    	
    }
    
    public void setRadius(String Value) {
        this.radius = Double.valueOf(Value);
    }            
    
    public String getRadius() {
		String result = String.format("%.3f", radius);	
    	return result;    	    	
    }
        
    public void setOrbitZone(String Value) {
        this.orbit_zone = Integer.valueOf(Value);
    }            
    
    public String getOrbitZone() {
		String result = Integer.toString(orbit_zone);	
    	return result;    	    	
    }
    
    public void setDensity(String Value) {
        this.density = Double.valueOf(Value);
    }            
    
    public String getDensity() {
		String result = String.format("%.3f", density);	
    	return result;    	    	
    }
    
    public void setOrbPeriod(String Value) {
        this.orb_period = Double.valueOf(Value);
    }            
    
    public String getOrbPeriod() {
		String result = String.format("%.3f", orb_period);	
    	return result;    	    	
    }
    
    public void setDay(String Value) {
        this.day = Double.valueOf(Value);
    }            
    
    public String getDay() {
		String result = String.format("%.3f", day);	
    	return result;    	    	
    }
    
    public void setEscVelocity(String Value) {
        this.esc_velocity = Double.valueOf(Value);
    }            
    
    public String getEscVelocity() {
		String result = String.format("%.3f", esc_velocity);	
    	return result;    	    	
    }
    
    public void setSurfAccel(String Value) {
        this.surf_accel = Double.valueOf(Value);
    }            

    public String getSurfAccel() {
		String result = String.format("%.3f", surf_accel);	
    	return result;    	    	
    }
    
    public void setSurfGrav(String Value) {
        this.surf_grav = Double.valueOf(Value);
    }            

    public String getSurfGrav() {
		String result = String.format("%.3f", surf_grav);	
    	return result;    	    	
    }
    
    public void setRmsVelocity(String Value) {
        this.rms_velocity = Double.valueOf(Value);
    }            
    
    public String getRmsVelocity() {
		String result = String.format("%.3f", rms_velocity);	
    	return result;    	    	
    }
    
    public void setMolecWeight(String Value) {
        this.molec_weight = Double.valueOf(Value);
    }            
    
    public String getMolecWeight() {
		String result = String.format("%.3f", molec_weight);	
    	return result;    	    	
    }
    
    public void setVolatileGasInventory(String Value) {
        this.volatile_gas_inventory = Double.valueOf(Value);
    }            
    
    public String getVolatileGasInventory() {
		String result = String.format("%.3f", volatile_gas_inventory);	
    	return result;    	    	
    }
    
    public void setSurfPressure(String Value) {
        this.surf_pressure = Double.valueOf(Value);
    }            
    
    public String getSurfPressure() {
    	//this.surf_pressure = this.volatile_gas_inventory * this.surf_grav; 
		String result = String.format("%.3f", surf_pressure);	
    	return result;    	    	
    }
    
    public void setGreenhouseEffect(String Value) {
        this.greenhouse_effect = Integer.valueOf(Value);
    }            
    
    public String getGreenhouseEffect() {
		String result = Integer.toString(greenhouse_effect);	
    	return result;    	    	
    }
    
    public void setBoilPoint(String Value) {
        this.boil_point = Double.valueOf(Value);
    }            

    public String getBoilPoint() {
		String result = String.format("%.3f", boil_point);	
    	return result;    	    	
    }
    
    public void setAlbedo(String Value) {
        this.albedo = Double.valueOf(Value);
    }            
    
    public void calcAlbedo() {
    	if (planetMap != null) {
    		if (planetMap.biomesCount.getCount() > 0) {
    			this.albedo = planetMap.biomesCount.calcAlbedo();
    		}
    	}
    }
    
    public String getAlbedo() {
    	calcAlbedo();
		String result = String.format("%.3f", albedo);	
    	return result;    	    	
    }

    public void setEffectiveTemp(String Value) {
        this.effective_temp = Double.valueOf(Value);
    }            
        
    public String getEffectiveTemp(sun s) {
        if (Solar_Constant == 0) {
            calcSolarConstant(s);
        }
        this.effective_temp = Math.pow(((1 - this.albedo) * this.Solar_Constant) / (4 * STEFANB_CONSTANT), 0.25);
    	String result = String.format("%.3f", this.effective_temp);	
    	return result;    	    	
    }
    
    public void setGreenhouseTemp(String Value) {
        this.greenhouse_temp = Double.valueOf(Value);
    }                
    
    public String getGreenhouseTemp(sun s) {
        if (Solar_Constant == 0) {
            calcSolarConstant(s);
        }
        Game.tsim.calcCurrent();
                
		String result = String.format("%.3f", greenhouse_temp);	
    	return result;    	    	
    }
    
    public void setDeltaT(String Value) {
        this.deltaT = Double.valueOf(Value);
    }            
        
    public String getDeltaT() {
    	if ((this.greenhouse_temp > 0) & (this.effective_temp >0)) {
    		this.deltaT = this.greenhouse_temp - this.effective_temp;
    	}
		String result = String.format("%.3f", deltaT);	
    	return result;    	    	
    }
    
    public void setPolarTemp(String Value) {
        this.Polar_temp = Double.valueOf(Value);
    }                
    
    public String getPolarTemp() {
		String result = String.format("%.3f", Polar_temp);	
    	return result;    	    	
    }
    
    public void setTropicTemp(String Value) {
        this.Tropic_temp = Double.valueOf(Value);
    }                    
    
    public String getTropicTemp() {
		String result = String.format("%.3f", Tropic_temp);	
    	return result;    	    	
    }

    public void setIceLat(String Value) {
        this.iceLat = Double.valueOf(Value);
    }   
    
    
    public String getIceLat() {
		String result = String.format("%.3f", iceLat);	
    	return result;    	    	
    }

    public void setHabRatio(String Value) {
        this.habRatio = Double.valueOf(Value);
    }                        
    
    public String getHabRatio() {
		String result = String.format("%.3f", habRatio);	
    	return result;    	    	
    }
    
    public void setSolarConstant(String Value) {
        this.Solar_Constant = Double.valueOf(Value);
    }                            
    
    public void calcSolarConstant(sun s) {
    	double c = 1366 * s.luminosity;
    	double val = 1/a;
    	this.Solar_Constant = c * Math.pow(val, 2); 
    }
    
    public String getSolarConstant(sun s) {
        calcSolarConstant(s);
    	String result = String.format("%.3f", Solar_Constant);	
    	return result;    	    	
    }
    
    public void setExosphericTemp(String Value) {
        this.exospheric_temp = Double.valueOf(Value);
    }                            
    
    public String getExosphericTemp() {
		String result = String.format("%.3f", exospheric_temp);	
    	return result;    	    	
    }
    
    public void setEstimatedTemp(String Value) {
        this.estimated_temp = Double.valueOf(Value);
    }                                
    
    public String getEstimatedTemp() {
		String result = String.format("%.3f", estimated_temp);	
    	return result;    	    	
    }
    
    public void setEstimatedTerrTemp(String Value) {
        this.estimated_terr_temp = Double.valueOf(Value);
    }                            
    
    public String getEstimatedTerrTemp() {
		String result = String.format("%.3f", estimated_terr_temp);	
    	return result;    	    	
    }
    
    public void setSurfTemp(String Value) {
        this.surf_temp = Double.valueOf(Value);
    }                            
    
    public String getSurfTemp() {
		String result = String.format("%.3f", surf_temp);	
    	return result;    	    	
    }
    
    public void setGreenhsRise(String Value) {
        this.greenhs_rise = Double.valueOf(Value);
    }                            
    
    public String getGreenhsRise() {
		String result = String.format("%.3f", greenhs_rise);	
    	return result;    	    	
    }
    
    public void setHighTemp(String Value) {
        this.high_temp = Double.valueOf(Value);
    }                                
    
    public String getHighTemp() {
		String result = String.format("%.3f", high_temp);	
    	return result;    	    	
    }
    
    public void setLowTemp(String Value) {
        this.low_temp = Double.valueOf(Value);
    }                                    
    
    public String getLowTemp() {
		String result = String.format("%.3f", low_temp);	
    	return result;    	    	
    }
    
    public void setMaxTemp(String Value) {
        this.max_temp = Double.valueOf(Value);
    }                                    
    
    public String getMaxTemp() {
		String result = String.format("%.3f", max_temp);	
    	return result;    	    	
    }

    public void setMinTemp(String Value) {
        this.min_temp = Double.valueOf(Value);
    }                                    
    
    public String getMinTemp() {
		String result = String.format("%.3f", min_temp);	
    	return result;    	    	
    }
    
    public void setHydrosphere(String Value) {
        this.hydrosphere = Double.valueOf(Value);
    }                                        
    
    public String getHydrosphere() {
		String result = String.format("%.3f", hydrosphere);	
    	return result;    	    	
    }
    
    public void setCloudCover(String Value) {
        this.cloud_cover = Double.valueOf(Value);
    }                                        
    
    public String getCloudCover() {
		String result = String.format("%.3f", cloud_cover);	
    	return result;    	    	
    }
    
    public void setIceCover(String Value) {
        this.ice_cover = Double.valueOf(Value);
    }                                        
    
    public String getIceCover() {
		String result = String.format("%.3f", ice_cover);	
    	return result;    	    	
    }
    
    public void setType(String Value) {
        this.planet_type = Value;
    }                                        
    
    public String getType() {
    	return planet_type;
    }
        
    public void setMap(map newMap) {
    	planetMap = newMap;
    } 
    
    public map getMap() {
    	return(planetMap);
    }
    
    public double pressure()
    {
    	//double equat_radius = KM_EARTH_RADIUS / equat_radius;
    	//return(this.volatile_gas_inventory * this.surf_grav * 
    	//		(EARTH_SURF_PRES_IN_MILLIBARS / 1000) / 
    	//		Math.pow(requat_radius));
    }

	public String getPolarReservoir() {
		
		// TODO Auto-generated method stub
		return null;
	}

}