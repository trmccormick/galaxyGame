package tools;

import java.awt.Color;
import java.awt.image.BufferedImage;
import java.io.*;
import javax.imageio.ImageIO;
 
public class GetPixelColor {
 
    //int y, x, tofind, col;
 
    /**
     * @param args the command line arguments
     * @throws IOException  
     */
 
    public static void main(String args[]) throws IOException {
         
            //read image file
            File file1 = new File("E:\\dp.jpg");    
            BufferedImage image1 = ImageIO.read(file1);
 
            //write file
            FileWriter fstream = new FileWriter("E:\\pixellog.txt");
            BufferedWriter out = new BufferedWriter(fstream);
 
            //color object
            //Color cyan = new Color(0, 255, 255);
 
            //find cyan pixels
            for (int y = 0; y < image1.getHeight(); y++) {
                for (int x = 0; x < image1.getWidth(); x++) {
                     
                    int c = image1.getRGB(x,y);
                      
                    int red = (c & 0x00FF0000) >> 16;
                    int green = (c & 0x0000FF00) >> 8;
                    int blue = c & 0x000000FF;
                     
                    //  int tofind = 0x0000FFFF;
 
                    //int tofind = Color.cyan.getRGB();
 
                    //int  col = image1.getRGB(x, y);
 
                    //if (col == tofind){
 
                    //if (cyan.equals(image1.getRGB(x, y)){
                    //if (Color.cyan.getRGB() == image1.getRGB(x, y)) {
                     
                    if (red < 30 && green > 0xff && blue > 0xff) {   
                      out.write("CyanPixel found at=" + x + "," + y);
                    }
                }
            }
            out.close();
    }
}