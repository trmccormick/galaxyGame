package gui;

/**
* @copyright 2014 
* @author Oliver Watkins (www.blue-walrus.com) 
* 
* All Rights Reserved
*/
public class Axis {

   int primaryIncrements = 0; 
   int secondaryIncrements = 0;
   int tertiaryIncrements = 0;

   int maxValue = 100;
   int minValue = 0;

   String yLabel;

   Axis(String name) {
       this(100, 0, 50, 10, 5, name);
   }

   Axis(int primaryIncrements, int secondaryIncrements, int tertiaryIncrements, String name) {
       this(100, 0, primaryIncrements, secondaryIncrements, tertiaryIncrements, name);
   }

   Axis(Integer maxValue, Integer minValue, int primaryIncrements, int secondaryIncrements, int tertiaryIncrements, String name) {

       this.maxValue = maxValue; 
       this.minValue = minValue;
       this.yLabel = name;

       if (primaryIncrements != 0)
           this.primaryIncrements = primaryIncrements; 
       if (secondaryIncrements != 0)
           this.secondaryIncrements = secondaryIncrements;
       if (tertiaryIncrements != 0)
           this.tertiaryIncrements = tertiaryIncrements;
   }
}