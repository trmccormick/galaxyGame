package gui;


import gamelogic.Game;

import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;

import javax.swing.BorderFactory;
import javax.swing.JButton;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JTextField;

import tools.TerraSim1_1;

import java.awt.Color;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

class modifyPanel extends JPanel
{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private GridBagConstraints gbc = new GridBagConstraints();
	private JButton b1 = new JButton("Submit");
	
	class ButtonListener implements ActionListener {
		   public void actionPerformed(ActionEvent e) {
			    switch (e.getActionCommand()) {
		        case "Submit":
		        	Game.output.append("modifyPanel submit");	
		        	Game.currentPlanet.setName(tf1.getText());
                    Game.currentPlanet.setPlanet_no(tf2.getText());
                    Game.currentPlanet.setDist(tf3.getText());
                    Game.currentPlanet.setEccentricity(tf4.getText());
                    Game.currentPlanet.setAxial_tilt(tf5.getText());
                    Game.currentPlanet.setMass(tf6.getText());
                    Game.currentPlanet.setDustMass(tf7.getText());
                    Game.currentPlanet.setGasMass(tf8.getText());
                    Game.currentPlanet.setCoreRadius(tf9.getText());
                    Game.currentPlanet.setRadius(tf10.getText());
                    Game.currentPlanet.setOrbitZone(tf11.getText());
                    Game.currentPlanet.setDensity(tf12.getText());
                    Game.currentPlanet.setOrbPeriod(tf13.getText());
                    Game.currentPlanet.setDay(tf14.getText());
                    Game.currentPlanet.setEscVelocity(tf15.getText());
                    Game.currentPlanet.setSurfAccel(tf16.getText());
                    Game.currentPlanet.setSurfGrav(tf17.getText());
                    Game.currentPlanet.setRmsVelocity(tf18.getText());
                    Game.currentPlanet.setMolecWeight(tf19.getText());
                    Game.currentPlanet.setVolatileGasInventory(tf20.getText());
                    Game.currentPlanet.setSurfPressure(tf21.getText());
                    Game.currentPlanet.setGreenhouseEffect(tf22.getText());
                    Game.currentPlanet.setBoilPoint(tf23.getText());
                    Game.currentPlanet.setAlbedo(tf24.getText());
                    Game.currentPlanet.setEffectiveTemp(tf25.getText());
                    Game.currentPlanet.setGreenhouseTemp(tf26.getText());
                    Game.currentPlanet.setDeltaT(tf27.getText());
                    Game.currentPlanet.setPolarTemp(tf28.getText());
                    Game.currentPlanet.setTropicTemp(tf29.getText());
                    Game.currentPlanet.setIceLat(tf30.getText());
                    Game.currentPlanet.setHabRatio(tf31.getText());
                    Game.currentPlanet.setSolarConstant(tf32.getText());
                    Game.currentPlanet.setExosphericTemp(tf33.getText());
                    Game.currentPlanet.setEstimatedTemp(tf34.getText());
                    Game.currentPlanet.setEstimatedTerrTemp(tf35.getText());
                    Game.currentPlanet.setSurfTemp(tf36.getText());
                    Game.currentPlanet.setGreenhsRise(tf37.getText());
                    Game.currentPlanet.setHighTemp(tf38.getText());
                    Game.currentPlanet.setLowTemp(tf39.getText());
                    Game.currentPlanet.setMaxTemp(tf40.getText());
                    Game.currentPlanet.setMinTemp(tf41.getText());
                    Game.currentPlanet.setHydrosphere(tf42.getText());
                    Game.currentPlanet.setCloudCover(tf43.getText());
                    Game.currentPlanet.setIceCover(tf44.getText());
                    Game.currentPlanet.setType(tf45.getText());

                    dataPanel.setTableData();
		        	Game.modify.dispose();
		        	
		        	break;
			    default: 
			        break;
			    }			
		    }
	}
	
	private ButtonListener bl = new ButtonListener();
	
	private static JTextField tf1 = new JTextField(10);
	private static JTextField tf2 = new JTextField(10);
	private static JTextField tf3 = new JTextField(10);
	private static JTextField tf4 = new JTextField(10);
	private static JTextField tf5 = new JTextField(10);
	private static JTextField tf6 = new JTextField(10);
	private static JTextField tf7 = new JTextField(10);
	private static JTextField tf8 = new JTextField(10);
	private static JTextField tf9 = new JTextField(10);
	private static JTextField tf10 = new JTextField(10);
	private static JTextField tf11 = new JTextField(10);
	private static JTextField tf12 = new JTextField(10);
	private static JTextField tf13 = new JTextField(10);
	private static JTextField tf14 = new JTextField(10);
	private static JTextField tf15 = new JTextField(10);
	private static JTextField tf16 = new JTextField(10);
	private static JTextField tf17 = new JTextField(10);
	private static JTextField tf18 = new JTextField(10);
	private static JTextField tf19 = new JTextField(10);
	private static JTextField tf20 = new JTextField(10);
	private static JTextField tf21 = new JTextField(10);
	private static JTextField tf22 = new JTextField(10);
	private static JTextField tf23 = new JTextField(10);
	private static JTextField tf24 = new JTextField(10);
	private static JTextField tf25 = new JTextField(10);
	private static JTextField tf26 = new JTextField(10);
	private static JTextField tf27 = new JTextField(10);
	private static JTextField tf28 = new JTextField(10);
	private static JTextField tf29 = new JTextField(10);
	private static JTextField tf30 = new JTextField(10);
	private static JTextField tf31 = new JTextField(10);
	private static JTextField tf32 = new JTextField(10);
	private static JTextField tf33 = new JTextField(10);
	private static JTextField tf34 = new JTextField(10);
	private static JTextField tf35 = new JTextField(10);
	private static JTextField tf36 = new JTextField(10);
	private static JTextField tf37 = new JTextField(10);
	private static JTextField tf38 = new JTextField(10);
	private static JTextField tf39 = new JTextField(10);
	private static JTextField tf40 = new JTextField(10);
	private static JTextField tf41 = new JTextField(10);
	private static JTextField tf42 = new JTextField(10);
	private static JTextField tf43 = new JTextField(10);
	private static JTextField tf44 = new JTextField(10);
	private static JTextField tf45 = new JTextField(10);
	
	private JLabel l1 = new JLabel("Name : ");
	private JLabel l2 = new JLabel("Planet Number : ");
	private JLabel l3 = new JLabel("Dist. : ");
	private JLabel l4 = new JLabel("Eccentricity : ");
	private JLabel l5 = new JLabel("Axial Tilt : ");
	private JLabel l6 = new JLabel("Mass (in solar masses) : ");
	private JLabel l7 = new JLabel("Mass, ignoring gas : ");
	private JLabel l8 = new JLabel("Mass, ignoring dust : ");
	private JLabel l9 = new JLabel("Radius of the rocky core (in km) : ");
	private JLabel l10 = new JLabel("Equatorial Radius (in km) : ");
	private JLabel l11 = new JLabel("The 'zone' of the planet : ");
	private JLabel l12 = new JLabel("Density (in g/cc) : ");
	private JLabel l13 = new JLabel("Length of the local year (days) : ");
	private JLabel l14 = new JLabel("Length of the local day (hours) : ");
	private JLabel l15 = new JLabel("Escape Velocity in units of cm/sec : ");
	private JLabel l16 = new JLabel("Surface Acceleration in units of cm/sec2 : ");
	private JLabel l17 = new JLabel("Surface Gravity in units of Earth gravities : ");
	private JLabel l18 = new JLabel("RMS Velocity in units of cm/sec : ");
	private JLabel l19 = new JLabel("smallest molecular weight retained : ");
	private JLabel l20 = new JLabel("Volatile Gas Inventory : ");
	private JLabel l21 = new JLabel("Surface Pressure in units of millibars (mb) : ");
	private JLabel l22 = new JLabel("Greenhouse Effect : ");
	private JLabel l23 = new JLabel("Boiling point of water (Kelvin) : ");
	private JLabel l24 = new JLabel("Albedo of the planet : ");
	private JLabel l25 = new JLabel("Effective Temp : ");
	private JLabel l26 = new JLabel("Current Temp with Greenhouse Effect : ");
	private JLabel l27 = new JLabel("Delta T - degrees of warming over effective temperature : ");
	private JLabel l28 = new JLabel("Polar Temp : ");
	private JLabel l29 = new JLabel("Tropical Temp : ");
	private JLabel l30 = new JLabel("Planet Frozen above Latitude : ");
	private JLabel l31 = new JLabel("Habitable Percentage of Surface : ");
	private JLabel l32 = new JLabel("Current Solar Constant : ");
	private JLabel l33 = new JLabel("Exospheric Temp - Units of Degrees Kelvin : ");
	private JLabel l34 = new JLabel("Estimated Temp - Quick non-iterative estimate (K) : ");
	private JLabel l35 = new JLabel("Estimated Temp - for terrestrial moons and the like : ");
	private JLabel l36 = new JLabel("Surface Temp in Kelvin : ");
	private JLabel l37 = new JLabel("Temperature rise due to greenhouse : ");
	private JLabel l38 = new JLabel("Day-time temperature : ");
	private JLabel l39 = new JLabel("Night-time temperature : ");
	private JLabel l40 = new JLabel("Summer/Day temperature : ");
	private JLabel l41 = new JLabel("Winter/Night temperature : ");
	private JLabel l42 = new JLabel("Hydrosphere - Fraction of Surface Covered : ");
	private JLabel l43 = new JLabel("Cloud Cover - Fraction of Surface Covered : ");
	private JLabel l44 = new JLabel("Ice Cover - Fraction of Surface Covered : ");
	private JLabel l45 = new JLabel("Planet / Moon Type : ");
	
	public modifyPanel()
	{
		refresh();
		initGUI();
	}
	
	public void initGUI() 
	{
		Game.output.append("modifyPanel initGUI()");
		Game.output.append(Game.currentPlanet.getName());
 
		JPanel panel = new JPanel(new GridBagLayout());
		this.add(panel);
 		
		JPanel planetPanel = createPlanetPanel();
		planetPanel.setBorder(BorderFactory.createLineBorder(Color.BLACK));
         
		panel.add(planetPanel, gbc);
		this.setVisible(true);
	}
		
	private JPanel createPlanetPanel() 
	{
	 
		JPanel panel = new JPanel();
	 	 
		panel.setLayout(new GridBagLayout());
	 
		GridBagConstraints gbc = new GridBagConstraints();
	 
		gbc.insets = new Insets(2,2,2,2);
		gbc.anchor = GridBagConstraints.NORTHEAST;

		int i=0;
		
		gbc.gridx = 0;
		gbc.gridy = i;
		gbc.gridwidth = 1;
		gbc.fill = GridBagConstraints.NONE;
		panel.add(l1,  gbc);
	 
		gbc.gridx = 1;
		gbc.gridy = i;
		gbc.gridwidth = 3;		
		gbc.fill = GridBagConstraints.HORIZONTAL;
		panel.add(tf1,  gbc);		
		
		i++;
	 
		gbc.gridx = 0;
		gbc.gridy = i;
		gbc.gridwidth = 1;		
		gbc.fill = GridBagConstraints.NONE;
		panel.add(l2,  gbc);
		
		gbc.gridx = 1;
		gbc.gridy = i;
		gbc.gridwidth = 3;		
		gbc.fill = GridBagConstraints.HORIZONTAL;		
		panel.add(tf2,  gbc);				
	 
		i++;
	 
		gbc.gridx = 0;
		gbc.gridy = i;
		gbc.gridwidth = 1;		
		gbc.fill = GridBagConstraints.NONE;
		panel.add(l3,  gbc);
	 
		gbc.gridx = 1;
		gbc.gridy = i;
		gbc.gridwidth = 3;
		gbc.fill = GridBagConstraints.HORIZONTAL;		
		panel.add(tf3,  gbc);		
	 
		i++;
	 
		gbc.gridx = 0;
		gbc.gridy = i;
		gbc.gridwidth = 1;
		gbc.fill = GridBagConstraints.NONE;
		panel.add(l4,  gbc);
	 
		gbc.gridx = 1;
		gbc.gridy = i;
		gbc.gridwidth = 3;		
		gbc.fill = GridBagConstraints.HORIZONTAL;				
		panel.add(tf4,  gbc);		
	 
		i++;
	 
		gbc.gridx = 0;
		gbc.gridy = i;
		gbc.gridwidth = 1;		
		gbc.fill = GridBagConstraints.NONE;
		panel.add(l5,  gbc);
	 
		gbc.gridx = 1;
		gbc.gridy = i;
		gbc.gridwidth = 3;
		gbc.fill = GridBagConstraints.HORIZONTAL;						
		panel.add(tf5,  gbc);
		
		i++;
		 
		gbc.gridx = 0;
		gbc.gridy = i;
		gbc.gridwidth = 1;		
		gbc.fill = GridBagConstraints.NONE;
		panel.add(l6,  gbc);
	 
		gbc.gridx = 1;
		gbc.gridy = i;
		gbc.gridwidth = 3;
		gbc.fill = GridBagConstraints.HORIZONTAL;						
		panel.add(tf6,  gbc);

		i++;
		 
		gbc.gridx = 0;
		gbc.gridy = i;
		gbc.gridwidth = 1;		
		gbc.fill = GridBagConstraints.NONE;
		panel.add(l7,  gbc);
	 
		gbc.gridx = 1;
		gbc.gridy = i;
		gbc.gridwidth = 3;
		gbc.fill = GridBagConstraints.HORIZONTAL;						
		panel.add(tf7,  gbc);
		
		i++;
		 
		gbc.gridx = 0;
		gbc.gridy = i;
		gbc.gridwidth = 1;		
		gbc.fill = GridBagConstraints.NONE;
		panel.add(l8,  gbc);
	 
		gbc.gridx = 1;
		gbc.gridy = i;
		gbc.gridwidth = 3;
		gbc.fill = GridBagConstraints.HORIZONTAL;						
		panel.add(tf8,  gbc);
		
		i++;
		 
		gbc.gridx = 0;
		gbc.gridy = i;
		gbc.gridwidth = 1;		
		gbc.fill = GridBagConstraints.NONE;
		panel.add(l9,  gbc);
	 
		gbc.gridx = 1;
		gbc.gridy = i;
		gbc.gridwidth = 3;
		gbc.fill = GridBagConstraints.HORIZONTAL;						
		panel.add(tf9,  gbc);
		
		i++;
		 
		gbc.gridx = 0;
		gbc.gridy = i;
		gbc.gridwidth = 1;		
		gbc.fill = GridBagConstraints.NONE;
		panel.add(l10,  gbc);
	 
		gbc.gridx = 1;
		gbc.gridy = i;
		gbc.gridwidth = 3;
		gbc.fill = GridBagConstraints.HORIZONTAL;						
		panel.add(tf10,  gbc);		

		i++;
		 
		gbc.gridx = 0;
		gbc.gridy = i;
		gbc.gridwidth = 1;		
		gbc.fill = GridBagConstraints.NONE;
		panel.add(l11,  gbc);
	 
		gbc.gridx = 1;
		gbc.gridy = i;
		gbc.gridwidth = 3;
		gbc.fill = GridBagConstraints.HORIZONTAL;						
		panel.add(tf11,  gbc);		
		
		i++;
		 
		gbc.gridx = 0;
		gbc.gridy = i;
		gbc.gridwidth = 1;		
		gbc.fill = GridBagConstraints.NONE;
		panel.add(l12,  gbc);
	 
		gbc.gridx = 1;
		gbc.gridy = i;
		gbc.gridwidth = 3;
		gbc.fill = GridBagConstraints.HORIZONTAL;						
		panel.add(tf12,  gbc);		
		
		i++;
		 
		gbc.gridx = 0;
		gbc.gridy = i;
		gbc.gridwidth = 1;		
		gbc.fill = GridBagConstraints.NONE;
		panel.add(l13,  gbc);
	 
		gbc.gridx = 1;
		gbc.gridy = i;
		gbc.gridwidth = 3;
		gbc.fill = GridBagConstraints.HORIZONTAL;						
		panel.add(tf13,  gbc);		
		
		i++;
		 
		gbc.gridx = 0;
		gbc.gridy = i;
		gbc.gridwidth = 1;		
		gbc.fill = GridBagConstraints.NONE;
		panel.add(l14,  gbc);
	 
		gbc.gridx = 1;
		gbc.gridy = i;
		gbc.gridwidth = 3;
		gbc.fill = GridBagConstraints.HORIZONTAL;						
		panel.add(tf14,  gbc);		
		
		i++;
		 
		gbc.gridx = 0;
		gbc.gridy = i;
		gbc.gridwidth = 1;		
		gbc.fill = GridBagConstraints.NONE;
		panel.add(l15,  gbc);
	 
		gbc.gridx = 1;
		gbc.gridy = i;
		gbc.gridwidth = 3;
		gbc.fill = GridBagConstraints.HORIZONTAL;						
		panel.add(tf15,  gbc);		

		i++;
		 
		gbc.gridx = 0;
		gbc.gridy = i;
		gbc.gridwidth = 1;		
		gbc.fill = GridBagConstraints.NONE;
		panel.add(l16,  gbc);
	 
		gbc.gridx = 1;
		gbc.gridy = i;
		gbc.gridwidth = 3;
		gbc.fill = GridBagConstraints.HORIZONTAL;						
		panel.add(tf16,  gbc);		
		
		i++;
		 
		gbc.gridx = 0;
		gbc.gridy = i;
		gbc.gridwidth = 1;		
		gbc.fill = GridBagConstraints.NONE;
		panel.add(l17,  gbc);
	 
		gbc.gridx = 1;
		gbc.gridy = i;
		gbc.gridwidth = 3;
		gbc.fill = GridBagConstraints.HORIZONTAL;						
		panel.add(tf17,  gbc);		
		
		i++;
		 
		gbc.gridx = 0;
		gbc.gridy = i;
		gbc.gridwidth = 1;		
		gbc.fill = GridBagConstraints.NONE;
		panel.add(l18,  gbc);
	 
		gbc.gridx = 1;
		gbc.gridy = i;
		gbc.gridwidth = 3;
		gbc.fill = GridBagConstraints.HORIZONTAL;						
		panel.add(tf18,  gbc);		
		
		i++;
		 
		gbc.gridx = 0;
		gbc.gridy = i;
		gbc.gridwidth = 1;		
		gbc.fill = GridBagConstraints.NONE;
		panel.add(l19,  gbc);
	 
		gbc.gridx = 1;
		gbc.gridy = i;
		gbc.gridwidth = 3;
		gbc.fill = GridBagConstraints.HORIZONTAL;						
		panel.add(tf19,  gbc);		
		
		i++;
		 
		gbc.gridx = 0;
		gbc.gridy = i;
		gbc.gridwidth = 1;		
		gbc.fill = GridBagConstraints.NONE;
		panel.add(l20,  gbc);
	 
		gbc.gridx = 1;
		gbc.gridy = i;
		gbc.gridwidth = 3;
		gbc.fill = GridBagConstraints.HORIZONTAL;						
		panel.add(tf20,  gbc);		
		
		i++;
		 
		gbc.gridx = 0;
		gbc.gridy = i;
		gbc.gridwidth = 1;		
		gbc.fill = GridBagConstraints.NONE;
		panel.add(l21,  gbc);
	 
		gbc.gridx = 1;
		gbc.gridy = i;
		gbc.gridwidth = 3;
		gbc.fill = GridBagConstraints.HORIZONTAL;						
		panel.add(tf21,  gbc);
		
		i++;
		 
		gbc.gridx = 0;
		gbc.gridy = i;
		gbc.gridwidth = 1;		
		gbc.fill = GridBagConstraints.NONE;
		panel.add(l22,  gbc);
	 
		gbc.gridx = 1;
		gbc.gridy = i;
		gbc.gridwidth = 3;
		gbc.fill = GridBagConstraints.HORIZONTAL;						
		panel.add(tf22,  gbc);		
		
		i++;
		 
		gbc.gridx = 0;
		gbc.gridy = i;
		gbc.gridwidth = 1;		
		gbc.fill = GridBagConstraints.NONE;
		panel.add(l23,  gbc);
	 
		gbc.gridx = 1;
		gbc.gridy = i;
		gbc.gridwidth = 3;
		gbc.fill = GridBagConstraints.HORIZONTAL;						
		panel.add(tf23,  gbc);		

		i++;
		 
		gbc.gridx = 0;
		gbc.gridy = i;
		gbc.gridwidth = 1;		
		gbc.fill = GridBagConstraints.NONE;
		panel.add(l24,  gbc);
	 
		gbc.gridx = 1;
		gbc.gridy = i;
		gbc.gridwidth = 3;
		gbc.fill = GridBagConstraints.HORIZONTAL;						
		panel.add(tf24,  gbc);		

		i++;
		 
		gbc.gridx = 0;
		gbc.gridy = i;
		gbc.gridwidth = 1;		
		gbc.fill = GridBagConstraints.NONE;
		panel.add(l25,  gbc);
	 
		gbc.gridx = 1;
		gbc.gridy = i;
		gbc.gridwidth = 3;
		gbc.fill = GridBagConstraints.HORIZONTAL;						
		panel.add(tf25,  gbc);		
		
		i++;
		 
		gbc.gridx = 0;
		gbc.gridy = i;
		gbc.gridwidth = 1;		
		gbc.fill = GridBagConstraints.NONE;
		panel.add(l26,  gbc);
	 
		gbc.gridx = 1;
		gbc.gridy = i;
		gbc.gridwidth = 3;
		gbc.fill = GridBagConstraints.HORIZONTAL;						
		panel.add(tf26,  gbc);	
		
		i++;
		 
		gbc.gridx = 0;
		gbc.gridy = i;
		gbc.gridwidth = 1;		
		gbc.fill = GridBagConstraints.NONE;
		panel.add(l27,  gbc);
	 
		gbc.gridx = 1;
		gbc.gridy = i;
		gbc.gridwidth = 3;
		gbc.fill = GridBagConstraints.HORIZONTAL;						
		panel.add(tf27,  gbc);		

		i++;
		 
		gbc.gridx = 0;
		gbc.gridy = i;
		gbc.gridwidth = 1;		
		gbc.fill = GridBagConstraints.NONE;
		panel.add(l28,  gbc);
	 
		gbc.gridx = 1;
		gbc.gridy = i;
		gbc.gridwidth = 3;
		gbc.fill = GridBagConstraints.HORIZONTAL;						
		panel.add(tf28,  gbc);		
		
		i++;
		 
		gbc.gridx = 0;
		gbc.gridy = i;
		gbc.gridwidth = 1;		
		gbc.fill = GridBagConstraints.NONE;
		panel.add(l29,  gbc);
	 
		gbc.gridx = 1;
		gbc.gridy = i;
		gbc.gridwidth = 3;
		gbc.fill = GridBagConstraints.HORIZONTAL;						
		panel.add(tf29,  gbc);		
		
		i++;
		 
		gbc.gridx = 0;
		gbc.gridy = i;
		gbc.gridwidth = 1;		
		gbc.fill = GridBagConstraints.NONE;
		panel.add(l30,  gbc);
	 
		gbc.gridx = 1;
		gbc.gridy = i;
		gbc.gridwidth = 3;
		gbc.fill = GridBagConstraints.HORIZONTAL;						
		panel.add(tf30,  gbc);		
		
		i++;
		 
		gbc.gridx = 0;
		gbc.gridy = i;
		gbc.gridwidth = 1;		
		gbc.fill = GridBagConstraints.NONE;
		panel.add(l31,  gbc);
	 
		gbc.gridx = 1;
		gbc.gridy = i;
		gbc.gridwidth = 3;
		gbc.fill = GridBagConstraints.HORIZONTAL;						
		panel.add(tf31,  gbc);		
		
		i++;
		 
		gbc.gridx = 0;
		gbc.gridy = i;
		gbc.gridwidth = 1;		
		gbc.fill = GridBagConstraints.NONE;
		panel.add(l32,  gbc);
	 
		gbc.gridx = 1;
		gbc.gridy = i;
		gbc.gridwidth = 3;
		gbc.fill = GridBagConstraints.HORIZONTAL;						
		panel.add(tf32,  gbc);
		
		i++;
		 
		gbc.gridx = 0;
		gbc.gridy = i;
		gbc.gridwidth = 1;		
		gbc.fill = GridBagConstraints.NONE;
		panel.add(l33,  gbc);
	 
		gbc.gridx = 1;
		gbc.gridy = i;
		gbc.gridwidth = 3;
		gbc.fill = GridBagConstraints.HORIZONTAL;						
		panel.add(tf33,  gbc);		
		
		i++;
		 
		gbc.gridx = 0;
		gbc.gridy = i;
		gbc.gridwidth = 1;		
		gbc.fill = GridBagConstraints.NONE;
		panel.add(l34,  gbc);
	 
		gbc.gridx = 1;
		gbc.gridy = i;
		gbc.gridwidth = 3;
		gbc.fill = GridBagConstraints.HORIZONTAL;						
		panel.add(tf34,  gbc);		

		i++;
		 
		gbc.gridx = 0;
		gbc.gridy = i;
		gbc.gridwidth = 1;		
		gbc.fill = GridBagConstraints.NONE;
		panel.add(l35,  gbc);
	 
		gbc.gridx = 1;
		gbc.gridy = i;
		gbc.gridwidth = 3;
		gbc.fill = GridBagConstraints.HORIZONTAL;						
		panel.add(tf35,  gbc);		
		
		i++;
		 
		gbc.gridx = 0;
		gbc.gridy = i;
		gbc.gridwidth = 1;		
		gbc.fill = GridBagConstraints.NONE;
		panel.add(l36,  gbc);
	 
		gbc.gridx = 1;
		gbc.gridy = i;
		gbc.gridwidth = 3;
		gbc.fill = GridBagConstraints.HORIZONTAL;						
		panel.add(tf36,  gbc);		

		i++;
		 
		gbc.gridx = 0;
		gbc.gridy = i;
		gbc.gridwidth = 1;		
		gbc.fill = GridBagConstraints.NONE;
		panel.add(l37,  gbc);
	 
		gbc.gridx = 1;
		gbc.gridy = i;
		gbc.gridwidth = 3;
		gbc.fill = GridBagConstraints.HORIZONTAL;						
		panel.add(tf37,  gbc);		
		
		i++;
		 
		gbc.gridx = 0;
		gbc.gridy = i;
		gbc.gridwidth = 1;		
		gbc.fill = GridBagConstraints.NONE;
		panel.add(l38,  gbc);
	 
		gbc.gridx = 1;
		gbc.gridy = i;
		gbc.gridwidth = 3;
		gbc.fill = GridBagConstraints.HORIZONTAL;						
		panel.add(tf38,  gbc);		

		i++;
		 
		gbc.gridx = 0;
		gbc.gridy = i;
		gbc.gridwidth = 1;		
		gbc.fill = GridBagConstraints.NONE;
		panel.add(l39,  gbc);
	 
		gbc.gridx = 1;
		gbc.gridy = i;
		gbc.gridwidth = 3;
		gbc.fill = GridBagConstraints.HORIZONTAL;						
		panel.add(tf39,  gbc);		
		
		i++;
		 
		gbc.gridx = 0;
		gbc.gridy = i;
		gbc.gridwidth = 1;		
		gbc.fill = GridBagConstraints.NONE;
		panel.add(l40,  gbc);
	 
		gbc.gridx = 1;
		gbc.gridy = i;
		gbc.gridwidth = 3;
		gbc.fill = GridBagConstraints.HORIZONTAL;						
		panel.add(tf40,  gbc);		
		
		i++;
		 
		gbc.gridx = 0;
		gbc.gridy = i;
		gbc.gridwidth = 1;		
		gbc.fill = GridBagConstraints.NONE;
		panel.add(l41,  gbc);
	 
		gbc.gridx = 1;
		gbc.gridy = i;
		gbc.gridwidth = 3;
		gbc.fill = GridBagConstraints.HORIZONTAL;						
		panel.add(tf41,  gbc);		

		i++;
		 
		gbc.gridx = 0;
		gbc.gridy = i;
		gbc.gridwidth = 1;		
		gbc.fill = GridBagConstraints.NONE;
		panel.add(l42,  gbc);
	 
		gbc.gridx = 1;
		gbc.gridy = i;
		gbc.gridwidth = 3;
		gbc.fill = GridBagConstraints.HORIZONTAL;						
		panel.add(tf42,  gbc);		

		i++;
		 
		gbc.gridx = 0;
		gbc.gridy = i;
		gbc.gridwidth = 1;		
		gbc.fill = GridBagConstraints.NONE;
		panel.add(l43,  gbc);
	 
		gbc.gridx = 1;
		gbc.gridy = i;
		gbc.gridwidth = 3;
		gbc.fill = GridBagConstraints.HORIZONTAL;						
		panel.add(tf43,  gbc);		

		i++;
		 
		gbc.gridx = 0;
		gbc.gridy = i;
		gbc.gridwidth = 1;		
		gbc.fill = GridBagConstraints.NONE;
		panel.add(l44,  gbc);
	 
		gbc.gridx = 1;
		gbc.gridy = i;
		gbc.gridwidth = 3;
		gbc.fill = GridBagConstraints.HORIZONTAL;						
		panel.add(tf44,  gbc);		
		
		i++;
		
		gbc.gridx = 0;
		gbc.gridy = i;
		gbc.gridwidth = 1;		
		gbc.fill = GridBagConstraints.NONE;
		panel.add(l45,  gbc);
	 
		gbc.gridx = 1;
		gbc.gridy = i;
		gbc.gridwidth = 3;
		gbc.fill = GridBagConstraints.HORIZONTAL;						
		panel.add(tf45,  gbc);		
		
		i++;

		gbc.gridx = 0;
		gbc.gridy = i;
		gbc.gridwidth = 1;		
		gbc.fill = GridBagConstraints.NONE;
		panel.add(b1,  gbc);
		
		b1.addActionListener(bl);
	 
		return panel;
	}
	
	public static void refresh()
	{
		Game.output.append("modifyPanel refresh()");
		Game.output.append(Game.currentPlanet.getName());
		if (Game.currentPlanet != null)
		{
			//Game.currentPlanet = Game.tsim.calcCurrent();
						
			Game.output.append("modifyPanel Game.currentPlanet is not null");
			Game.output.append(Game.currentPlanet.getName());

			tf1.setText(Game.currentPlanet.getName());
			tf2.setText(Game.currentPlanet.getPlanet_no());
			tf3.setText(Game.currentPlanet.getDist());
			tf4.setText(Game.currentPlanet.getEccentricity());
			tf5.setText(Game.currentPlanet.getAxial_tilt());
			tf6.setText(Game.currentPlanet.getMass());
			tf7.setText(Game.currentPlanet.getDustMass());
			tf8.setText(Game.currentPlanet.getGasMass());
			tf9.setText(Game.currentPlanet.getCoreRadius());
			tf10.setText(Game.currentPlanet.getRadius());			
			tf11.setText(Game.currentPlanet.getOrbitZone());
			tf12.setText(Game.currentPlanet.getDensity());
			tf13.setText(Game.currentPlanet.getOrbPeriod());
			tf14.setText(Game.currentPlanet.getDay());
			tf15.setText(Game.currentPlanet.getEscVelocity());
			tf16.setText(Game.currentPlanet.getSurfAccel());
			tf17.setText(Game.currentPlanet.getSurfGrav());
			tf18.setText(Game.currentPlanet.getRmsVelocity());
			tf19.setText(Game.currentPlanet.getMolecWeight());
			tf20.setText(Game.currentPlanet.getVolatileGasInventory());
			tf21.setText(Game.currentPlanet.getSurfPressure());
			tf22.setText(Game.currentPlanet.getGreenhouseEffect());
			tf23.setText(Game.currentPlanet.getBoilPoint());
			tf24.setText(Game.currentPlanet.getAlbedo());
			tf25.setText(Game.currentPlanet.getEffectiveTemp(Game.currentSystem.currentSun));
			tf26.setText(Game.currentPlanet.getGreenhouseTemp(Game.currentSystem.currentSun));
			tf27.setText(Game.currentPlanet.getDeltaT());
			tf28.setText(Game.currentPlanet.getPolarTemp());
			tf29.setText(Game.currentPlanet.getTropicTemp());
			tf30.setText(Game.currentPlanet.getIceLat());
			tf31.setText(Game.currentPlanet.getHabRatio());
			tf32.setText(Game.currentPlanet.getSolarConstant(Game.currentSystem.currentSun));
			tf33.setText(Game.currentPlanet.getExosphericTemp());
			tf34.setText(Game.currentPlanet.getEstimatedTemp());
			tf35.setText(Game.currentPlanet.getEstimatedTerrTemp());
			tf36.setText(Game.currentPlanet.getSurfTemp());
			tf37.setText(Game.currentPlanet.getGreenhsRise());
			tf38.setText(Game.currentPlanet.getHighTemp());
			tf39.setText(Game.currentPlanet.getLowTemp());
			tf40.setText(Game.currentPlanet.getMaxTemp());
			tf41.setText(Game.currentPlanet.getMinTemp());
			tf42.setText(Game.currentPlanet.getHydrosphere());
			tf43.setText(Game.currentPlanet.getCloudCover());
			tf44.setText(Game.currentPlanet.getIceCover());
			tf45.setText(Game.currentPlanet.getType());			
		}
		else
		{
			Game.output.append("modifyPanel Game.currentPlanet is null");			
		}
	}
 }
