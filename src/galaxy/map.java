package galaxy;

import java.util.ArrayList;

public class map {
        public Tile currentMap[][];
	    public int mapLength, mapWidth;
		public biomes biomesCount;
		public int mapHeight[][];
	        
	    public map(int row, int col, ArrayList<Tile> mapList, biomes biomesCount2) {
	    	mapWidth = col;
	    	mapLength = row;
	    	currentMap = new Tile [row][col];
	    	mapHeight = new int [row][col];
	    	biomesCount = biomesCount2;
	    	int pos = 0;
	        for(int i=0;i<row;i++)
	            for(int j=0;j<col;j++)
	            {
                  currentMap[i][j] = mapList.get(pos);
                  pos++;
	            }
	    }
	    
	    public int getLength()
	    {
	    	return(mapLength);
	    }
	    
	    public int getWidth()
	    {
	    	return(mapWidth);
	    }
	    
	    public Tile [][] getMap()
	    {
	    	return(currentMap);
	    }

	    public void setLength(int Length)
	    {
	    	mapLength = Length;
	    }
	    
	    public void setWidth(int Width)
	    {
	    	mapWidth = Width;
	    }

	    public void setMap(Tile [][] newMap)
	    {
	    	currentMap = newMap;
	    }

}
