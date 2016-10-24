package tools;

import galaxy.Gas;
import galaxy.planet;
import galaxy.sun;
import gamelogic.Game;

import java.lang.Math;

public class TerraSim1_1 {

	//{{GLOBAL NUMERICAL VARIABLES
	private double pole; // Polar reservoir of CO2
	private double regolith; // Regolith capacity of CO2
	private double Pr; // Regolith inventory of CO2
	private double totCO2; // Total CO2 inventory of Mars
	private double Td; // Temperature increment to outgas 1/e of regolith
    private double S, a; //Insolation factor and albedo
    private double PCO2, PN2, PCH4, PNH3, PCFC, PH2O, PKR, PO2, PAR ; // Partial pressures
    private double Tb, Ts, Tp, Tt; // Effective, global surface, polar and tropical temperatures
    private double C; // Normalization constant for regolith calculations
    private double dT; // Delta T
    private double iceLat, habRatio; // Habitable parameters
    private double Sm; //Present day martian solar constant
    
	planet p;
	sun s;
    
    public TerraSim1_1() {
	    pole = 0;
	    regolith = 0;
	    Pr = 0;
    	
    	totCO2 = 0;
	    Td = 30;  
	    S = 0;
	    a = 0;
	    PCO2 = 0;
	    PN2 = 0;
	    PCH4 = 0; 
        PNH3 = 0;
        PCFC = 0;
        Tb = 0;
        Ts = 0;
        Tp = 0;
        Tt = 0;
        C = 0;
        dT = 0;
        iceLat = 0;
        habRatio = 0;
        Sm = 0;
    }
    
    public void setInfo() {
    	p = Game.currentPlanet;
    	s = Game.currentSystem.getCurrentSun();
    }
    

    public planet calcCurrent() {
    	setInfo();
    	Game.output.append("calcCurrent" + " " + p.getName());
    	
    	a = Double.parseDouble(p.getAlbedo());
        S = p.getIns();
        
        Gas current = p.getGas("CO2");
        if (current != null) {
        	PCO2 = current.getMB();
        	pole = current.getPole();
        	regolith = current.getRegolith();
        	Pr = current.getPr();
        	Td = current.getTd();
        }
        else
        {
        	PCO2 = 0;
        	pole = 0;
        	regolith = 0;
        	Pr = 0;
        	Td = 0;        	
        }
        
        current = p.getGas("N");
        if (current != null) {
        	PN2 = current.getMB();
        }
        else
        {
        	PN2 = 0;
        }

        current = p.getGas("O2");
        if (current != null) {
        	PO2 = current.getMB();
        }
        else
        {
        	PO2 = 0;
        }
        
        current = p.getGas("Ar");
        if (current != null) {
        	PAR = current.getMB();
        }
        else
        {
        	PO2 = 0;
        }
        
        current = p.getGas("Kr");
        if (current != null) {
        	PKR = current.getMB();
        }
        else
        {
        	PKR = 0;
        }

        current = p.getGas("CH4");
        if (current != null) {
        	PCH4 = current.getMB();
        }
        else
        {
        	PCH4 = 0;
        }
        
        current = p.getGas("PNH3");
        if (current != null) {
        	PNH3 = current.getMB();
        }
        else
        {
        	PNH3 = 0;
        }
        
        current = p.getGas("PCFC");
        if (current != null) {
        	PCFC = current.getMB();
        }
        else
        {
        	PCFC = 0;
        }

        current = p.getGas("PH2O");
        if (current != null) {
        	PH2O = current.getMB();
        }
        else
        {
        	PH2O = 0;
        }
        
        Sm = Double.parseDouble(p.getSolarConstant(s));
        
        pole = pole / 1E3; // Convert millibars to bars
        Pr = Pr / 1E3; // Convert millibars to bars
        regolith = regolith / 1E3; // Convert millibars to bars
        PCO2 = PCO2 / 1E3; // Convert millibars to bars
        PN2 = PN2 / 1E3; // Convert millibars to bars
        PN2 = PN2 + (PO2 / 1E3);
        PN2 = PN2 + (PAR / 1E3);
        PN2 = PN2 + (PKR / 1E3);        
        
        
        PCH4 = PCH4 / 1E6; // Convert microbars to bars
        PNH3 = PNH3 / 1E6; // Convert microbars to bars
        PCFC = PCFC / 10; // Convert microbars to pascals
        C = regolith * Math.pow(0.006, -0.275) * Math.exp(149 / Td);  // Normalization constant for regolith calculations
        totCO2 = Pr + pole + PCO2;
        
        greenhouse();
        output();
        return p;
    }
            
    void greenhouse()
    {
        final double sigma = 0.0000000567; // Stefan-Boltzmann constant
                
        double tH2O; // Water vapour opacity
        
        Tb = Math.pow(((1 - 0.2) * Sm) / (4 * sigma), 0.25); // Effective temperature of present day Mars
        Ts = Tb; // Initialize surface temperature
        Tp = Ts - 75; // Initialize polar temperature
        
        // Loop calculates surface temperature and iterates water vapour
        // opacity and CO2-cap dynamics 100 times
        
        for (int loop = 1; loop <= 100; loop++)
            {
                tH2O = Math.pow(PH2O(), 0.3);
                
                Ts = Math.pow(((1 - a) * Sm * S) / (4 * sigma), 0.25) 
                    * Math.pow((1 + tCO2() + tH2O + tCH4() + tNH3() + tCFC()), 0.25);
                // Mean global surface temperature
                Tp = Ts - 75 / (1 + 5 * Ptot()); // Polar temperature      
                
                PCO2 = PCO2();
            }        
        
        Tt = Ts * 1.1; // Max tropic temperature
        dT = Ts - Tb; // Delta T: degrees of warming over effective temperature
        
        biosphere();
    }
    
    public planet output()
    {
    	p.setGas("CO2", (PCO2 * 1000), (Pr * 1000), (regolith  * 1000), (pole * 1000), Td);
    	p.setGas("H20", (PH2O * 1000), 0, 0, 0, 0);
    	    	
    	p.setEffectiveTemp(Double.toString(Tb));
    	p.setGreenhouseTemp(Double.toString(Ts));
    	p.setPolarTemp(Double.toString(Tp));
    	p.setTropicTemp(Double.toString(Tt));
    	p.setDeltaT(Double.toString(dT));
        double val = iceLat * 180 / Math.PI;
        p.setIceLat(Double.toString(val));
        p.setHabRatio(Double.toString(habRatio));
		return p;        
    }
    
    double PH2O()
    // Calculates water vapour pressure
    {
        final double Rh = 0.7; // Relative humidity
        final double Rgas = 8.314; // Gas constant for water
        final double Lheat = 43655.0; // Latent heat (?)
        final double P0 = 1.4E6; //Reference pressure
        
        return Rh * P0 * Math.exp(-Lheat / (Rgas * Ts));
    }
    
    double Ptot()
        // Calculates total atmospheric pressure
    {
        return PCO2 + PN2 + PCH4 + PNH3 + (PCFC / 1E5) + PH2O();
    }
    
    double tCO2()
        // Calculates opacity of CO2
    {
        return 0.9 * Math.pow(Ptot(), 0.45) * Math.pow(PCO2, 0.11);
    }
    
    double tCH4()
         // Calculates opacity of methane
    {
        return 0.5 * Math.pow(PCH4, 0.278);
    }
    
    double tNH3()
         // Calculates opacity of ammonia
    {
        return 9.6 * Math.pow(PNH3, 0.32);
    }
    
    double tCFC()
        // Calculates opacity of CFCs
    {
        return (1.1 * PCFC) / (0.015 + PCFC);
    }
    
    double PCO2()
        // Calculates pressure of CO2 after partitioning between cap
        // atmosphere and regolith
    {
        double Pv; // CO2 polar vapour pressure
        double Pa; // Temporary variable for CO2 pressure estimate
        double X,Y; // Working variables
        double top, bottom; // Bisection method variables
        
        Pa = PCO2;
        
        Pv = 1.23E7 * Math.exp(-3168 / Tp);
        
        if (Pv > Pa && pole > 0 && Pv < Pa + pole)
            {
                pole = pole - (Pv - Pa);
                Pa = Pv;
            }
        
        if (Pv > Pa + pole && pole > 0)
            {
                Pa = Pa + pole;
                pole = 0;
            }
        
        if (Pv < Pa)
            {
                pole = pole - (Pv - Pa);
                Pa = Pv;
            }
  
        X = Pa + Pr;
            if (X > totCO2)
                X = totCO2;
        Y = C * Math.exp(-Tp / Td);
        top = totCO2;
        bottom = 0;
        Pa = 0.5 * regolith;
        
        // Calculation of Pr by bisection method
        for (int loop = 1; loop <= 50; loop++)
            {
                if (Y * Math.pow(Pa, 0.275) + Pa < X)
                    bottom = Pa;
                else
                    top = Pa;
                Pa = bottom + (top - bottom) / 2;
            }
        
        Pr = Y * Math.pow(Pa, 0.275);
            if (Pr > regolith)
                {
                    Pa = Pa + Pr - regolith;
                    Pr = regolith;
                }
            
        return Pa;
    }
    
    void biosphere()
        // Calculates habitable characteristics of Mars---more to come
        // habRatio is the fraction of the planetary area above freezing
        // iceLat is the latitude of the freezing isotherm
    {
        if (Tt > 273 && Tp < 273)
        {
            habRatio = Math.pow(((Tt - 273) / (Tt - Tp)), 0.666667);
            iceLat = Math.asin(habRatio);
        }
        
        if (Tt < 273)
        {
            habRatio = 0;
            iceLat = 0;
        }
        
        if (Tp > 273)
        {
            habRatio = 1;
            iceLat = Math.asin(1);
        }
    }

}


