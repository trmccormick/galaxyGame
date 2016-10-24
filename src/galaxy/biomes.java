package galaxy;
public class biomes {
    //object variables
    private int GRASSLANDS, DESERT, ARTIC, JUNGLE, PLAINS, SWAMP, TUNDRA, DEEP_SEA, OCEAN, SHELF, FOREST, BOREAL, ROCK;

	public biomes () {
		setGRASSLANDS(0);
		setDESERT(0);
		setARTIC(0);
		setJUNGLE(0);
		setPLAINS(0);
		setSWAMP(0);
		setTUNDRA(0);
		setDEEP_SEA(0);
		setOCEAN(0);
		setSHELF(0);
		setFOREST(0);
		setBOREAL(0); 
		setROCK(0);
	}
	
	public void incGrasslands() {
		setGRASSLANDS(getGRASSLANDS() + 1);
	}

	public void incDesert() {
		setDESERT(getDESERT() + 1);
	}

	public void incArtic() {
		setARTIC(getARTIC() + 1);
	}

	public void incJungle() {
		setJUNGLE(getJUNGLE() + 1);
	}

	public void incPlains() {
		setPLAINS(getPLAINS() + 1);
	}

	public void incSwamp() {
		setSWAMP(getSWAMP() + 1);
	}

	public void incTundra() {
		setTUNDRA(getTUNDRA() + 1);
	}

	public void incDeep_Sea() {
		setDEEP_SEA(getDEEP_SEA() + 1);
	}
	
	public void incOcean() {
		setOCEAN(getOCEAN() + 1);
	}
	
	public void incShelf() {
		setSHELF(getSHELF() + 1);
	}
	
	public void incForest() {
		setFOREST(getFOREST() + 1);
	}

	public void incBoreal() {
		setBOREAL(getBOREAL() + 1);
	}

	public void incRock() {
		setROCK(getROCK() + 1);
	}

	public int getGRASSLANDS() {
		return GRASSLANDS;
	}

	public void setGRASSLANDS(int gRASSLANDS) {
		GRASSLANDS = gRASSLANDS;
	}

	public int getDESERT() {
		return DESERT;
	}

	public void setDESERT(int dESERT) {
		DESERT = dESERT;
	}

	public int getARTIC() {
		return ARTIC;
	}

	public void setARTIC(int aRTIC) {
		ARTIC = aRTIC;
	}

	public int getJUNGLE() {
		return JUNGLE;
	}

	public void setJUNGLE(int jUNGLE) {
		JUNGLE = jUNGLE;
	}

	public int getPLAINS() {
		return PLAINS;
	}

	public void setPLAINS(int pLAINS) {
		PLAINS = pLAINS;
	}

	public int getSWAMP() {
		return SWAMP;
	}

	public void setSWAMP(int sWAMP) {
		SWAMP = sWAMP;
	}

	public int getTUNDRA() {
		return TUNDRA;
	}

	public void setTUNDRA(int tUNDRA) {
		TUNDRA = tUNDRA;
	}

	public int getDEEP_SEA() {
		return DEEP_SEA;
	}

	public void setDEEP_SEA(int dEEP_SEA) {
		DEEP_SEA = dEEP_SEA;
	}

	public int getOCEAN() {
		return OCEAN;
	}

	public void setOCEAN(int oCEAN) {
		OCEAN = oCEAN;
	}

	public int getSHELF() {
		return SHELF;
	}

	public void setSHELF(int sHELF) {
		SHELF = sHELF;
	}

	public int getFOREST() {
		return FOREST;
	}

	public void setFOREST(int fOREST) {
		FOREST = fOREST;
	}

	public int getBOREAL() {
		return BOREAL;
	}

	public void setBOREAL(int bOREAL) {
		BOREAL = bOREAL;
	}

	public int getROCK() {
		return ROCK;
	}

	public void setROCK(int rOCK) {
		ROCK = rOCK;
	}
	
	public int getCount() {
		int count;
		count = GRASSLANDS + DESERT + ARTIC + JUNGLE + PLAINS + SWAMP + TUNDRA + DEEP_SEA + OCEAN + SHELF + FOREST + BOREAL + ROCK;
		return(count);
	}
	
	public double calcAlbedo() {
    	//snow is 85% Reflective
    	//ocean water is 7% Reflective
		
		double a = 0; //albedo
		double c = getCount(); //biomes count
		
		a = a + (((GRASSLANDS + PLAINS) / c) * .25);
		a = a + ((DESERT / c) * .4);		
		a = a + ((ARTIC / c) * .85);
		
		a = a + (((DEEP_SEA + OCEAN + SHELF) / c) * .07);
		
		a = a + (((JUNGLE + FOREST + BOREAL + SWAMP) / c) * .13);
		a = a + ((ROCK / c) * .17);
		a = a + ((TUNDRA / c) * .25);
		
		return(a);	
	}
}
