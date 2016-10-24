package tools;

public class strConvert {
	public double doubleConvert(String line) 
	{	
		try 
		{
			return Double.parseDouble(line);
		} 
		catch (NumberFormatException e) 
		{
	    	return -1;
		}
	}
	
	public int integerConvert(String line) 
	{		
		try 
		{
			return Integer.parseInt(line);
		} 
		catch (NumberFormatException e) 
		{
	    	return -1;
		}
	}		
}
