package gui;

import java.awt.Color;

/**
* @copyright 2014 
* @author Oliver Watkins (www.blue-walrus.com) 
* 
* All Rights Reserved
*/
public class Bar {

   double value; 
   Color color;
   String name;

   Bar(int value, Color color, String name) {
       this.value = value;
       this.color = color;
       this.name = name;
   }
}