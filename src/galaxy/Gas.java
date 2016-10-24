package galaxy;
public class Gas {
    //object variables
	public int type;
    public String name;
    public double percentage;
	public double ppm;
	public double ipp;
	public double kpa;
	public double millibar;
	public double microbars;
	
	private double pole; // Polar reservoir of Gas frozen
	private double regolith; // Regolith capacity of Gas
	private double Pr; // Regolith inventory of Gas
	private double total; // Total inventory of Gas
	private double Td; // Temperature increment to outgas 1/e of regolith
	
    public String description;

	public Gas(){

	}

	public int getType() {
		return type;
	}
	
	public void setType(int val) {
		type = val;
	}
	
	public String getName() {
		return name;
	}

	public void setName(String val) {
		name = val;
	}

	public double getPercentage() {
		return percentage;
	}
	
	public void setPercentage(double val) {
		percentage = val;
	}
	
	public double getPPM() {
		return ppm;
	}

	public void setPPM(double val) {
		ppm = val;
	}
	
	public double getIPP() {
		return ipp;
	}
	
	public void setIPP(double val) {
		ipp = val;
	}
	
	public double getKPA() {
		return kpa;
	}

	public void setKPA(double val) {
		kpa = val;
	}

	public double getMB() {
		return millibar;
	}
	
	public void setMB(double val) {
		millibar = val;
	}
	
	public double getMicroBar() {
		return microbars;
	}
	
	public void setMicroBar(double val) {
		microbars = val;
	}
	
	public double getPole() {
		return pole;
	}
	
	public void setPole(double val) {
		pole = val;
	}

	public double getRegolith() {
		return regolith;
	}
	
	public void setRegolith(double val) {
		regolith = val;
	}
	
	public double getPr() {
		return Pr;
	}
	
	public void setPr(double val) {
		Pr = val;
	}
	
	public double getTotal() {
		return total;
	}
	
	public void setTotal(double val) {
		total = val;
	}
	
	public double getTd() {
		return Td;
	}

	public void setTd(double val) {
		Td = val;
	}
	
	public String getDescription() {
		return this.description;
	}

	public void setDescription(String val) {
		description = val;
	}
}