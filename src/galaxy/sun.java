package galaxy;
public class sun {
    int seed;
    public String name;
    double luminosity;
    double mass;
    double life;
    double age;
    double r_ecosphere;
    double R; // distance from system 0
    double RA; // distance from system 0
    double DEC; // 90 degrees at the north celestial pole to -90 at the south celestial pole

    public int getSeed() {
	return(seed);
    }

    public double getLuminosity() {
	return(luminosity);
    }

    public double getMass() {
	return(mass);
    }

    public double getLife() {
	return(life);
    }

    public double getAge() {
	return(age);
    }

    public double get_r_ecosphere() {
	return(r_ecosphere);
    }

    public double getR() {
	return(R);
    }

    public double getRA() {
	return(RA);
    }

    public double getDEC() {
	return(DEC);
    }
}
