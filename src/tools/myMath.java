package tools;

import galaxy.planet;
import galaxy.sun;

import java.math.BigDecimal;
import java.math.RoundingMode;

public class myMath {
	
   final static double STEFANB_CONSTANT = 5.67E-8;
   final double KELV_CELS_DIFF = 273.15;   //the difference between kelvin and celsius.

   //public static planet surfaceTemp(planet p, sun s) {
   //    double surfaceTemp; 
   //    final String Solar_Constant = p.getSolarConstant(s);
   //    int Sm = Integer.parseInt(Solar_Constant);
   //    int ALBEDO = Integer.parseInt(p.getAlbedo());
   //    int ORBIT_RAD = Integer.parseInt(p.getRadius());
       
       
   //    surfaceTemp = Math.pow(Sm/4)*(1.0 - ALBEDO) /(STEFANB_CONSTANT*epsilon*ORBIT_RAD*ORBIT_RAD), 0.25);
//	   return (p);	
//   }
   
   //public static double surfaceTemp (planet p, sun s) {
	//   int a = Integer.parseInt(p.getAlbedo());
    //   int r = Integer.parseInt(p.getRadius());
    //   int Sm = Integer.parseInt(p.getSolarConstant(s));	   
	   
    //   double e = Sm * (1 - a) * (3.14159 * Math.pow(r, 2));
	//   return (e);
   //}
   
  // public static planet effectiveTemp(planet p, sun s) {
  //     int Sm = Integer.parseInt(p.getSolarConstant(s));	   	   
	//   double Tb = Math.pow(((1 - 0.2) * Sm) / (4 * STEFANB_CONSTANT), 0.25);
	//   p.setEffectiveTemp(Double.toString(Tb));
	//   return(p);
   //}

	public static double round(double value, int places) {
	    if (places < 0) throw new IllegalArgumentException();

	    BigDecimal bd = new BigDecimal(value);
	    bd = bd.setScale(places, RoundingMode.HALF_UP);
	    return bd.doubleValue();
	}
	
	public static double mb2microbar(double millibar) {
    // convert millibar to microbar
		return (millibar * 1000);	
	}

	public static double mb2kpa(double millibar) {
	// convert millibar to kpa
			return (millibar / 10);	
	}	
	
	public static double atmPercent2ppm(double percentage) {
	// convert Atmospheric Percent to ppm	
		return ((percentage / 100) * 1000000);
	}
	
	public static double kpa2mb(double kpa) {
	// convert kpa to millibar	
		return (kpa * 10);
	}	
	
	public static double percent2kpa(double mb, double percentage) {
	// convert kpa to millibar	
		return (mb2kpa(mb) * (percentage / 100));
	}
}
