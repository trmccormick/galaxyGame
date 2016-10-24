package gui;

import gui.MessageBox;
import galaxy.Gas;
import gamelogic.Game;

import java.awt.Dimension;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;

import javax.swing.BorderFactory;
import javax.swing.JButton;
import javax.swing.JFileChooser;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTable;
import javax.swing.JTextField;
import javax.swing.table.DefaultTableModel;

import java.awt.Color;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.ArrayList;

class dataPanel extends JPanel
{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private GridBagConstraints gbc = new GridBagConstraints();
	private JButton b1 = new JButton("Add");
	private JButton b2 = new JButton("Delete");
	private JButton b3 = new JButton("Modify");
	private JButton b4 = new JButton("View");
	private JButton b5 = new JButton("Update");
	private JButton b6 = new JButton("Print");
	private JButton b7 = new JButton("History");
	private JButton b8 = new JButton("Preferences");
	private JButton b9 = new JButton("Import FreeCiv Map");
	private JButton b10 = new JButton("View Terrain Map");
	private JButton b11 = new JButton("View Atmosphere");
	
	class ButtonListener implements ActionListener {
		   @SuppressWarnings("unchecked")
		public void actionPerformed(ActionEvent e) {
			    int returnVal;
		        int w = Game.screenSize.width;
		        int h = Game.screenSize.height;			    
			    
			    switch (e.getActionCommand()) {
		        case "Add":
		        	break;
			    case "Delete":  
			    	tableModel.removeRow(0);
			    	break;
			    case "Modify": 
			    	Game.resetCurrentPlanet();
			    	if (Game.currentPlanet != null)
			    	{
			    		Game.modify = new modifyFrame(w, h);
			    		modifyPanel.refresh();
			    		Game.desktop.add(Game.modify);
			    		Game.output.append(Game.currentPlanet.getName());
			    		Game.modify.setVisible(true);
			    	}
			    	else
			    	{
						MessageBox mes = new MessageBox(null,
								"Error",
								"No Planet Currently Loaded");
						mes.setVisible(true); 			    		
			    	}
			        break;
			    case "View":
			    	Game.resetCurrentPlanet();
			    	if (Game.currentPlanet.getMap() != null)
			    	{
			    	 Game.gameCanvas = new editFrame(w, h);
			    	 Game.desktop.add(Game.gameCanvas);
			    	 Game.output.append(Game.currentPlanet.getName());
			    	 Game.gameCanvas.setVisible(true);
			    	}
			    	else
			    	{
						MessageBox mes = new MessageBox(null,
								"Error",
								"No Map Currently Loaded for Planet");
						mes.setVisible(true); 			    		
			    	}
			        break;
			    case "Update":        	        	        	
			        break;
			    case "Print":        	
			        break;	        
			    case "History":
			        break; 
			    case "Preferences":
			    	break;
			    case "Import FreeCiv Map":
			    	Game.resetCurrentPlanet();
			    	Game.output.append(Game.currentPlanet.getName());
					
			    	if (Game.currentPlanet != null)
			    	{
			         JFileChooser open = new JFileChooser();
			         returnVal = open.showOpenDialog(null);
			         if (returnVal == javax.swing.JFileChooser.APPROVE_OPTION) 
			         {
			        	java.io.File file = open.getSelectedFile();
			        	Game.importMap(file.toString());
			         }
			    	}
			    	else {
						MessageBox mes = new MessageBox(null,
														"Galaxy or System not loaded",
														"No Planet Available to Import Map");
						mes.setVisible(true); }
			    	break;
			    case "View Terrain Map":
			    	Game.resetCurrentPlanet();
			    	if (Game.currentPlanet.getMap() != null)
			    	{
			    	 Game.terrainMap = new terrainFrame(w, h);
			    	 Game.desktop.add(Game.terrainMap);
			    	 Game.output.append(Game.currentPlanet.getName());
			    	 Game.terrainMap.setVisible(true);
			    	}
			    	else
			    	{
						MessageBox mes = new MessageBox(null,
								"Error",
								"No Map Currently Loaded for Planet");
						mes.setVisible(true); 			    		
			    	}
			        break;
			    case "View Atmosphere":
			    	Game.resetCurrentPlanet();
			    	if (Game.currentPlanet.getAtmosphere() != null)
			    	{
			    	 //Game.bar = new barFrame(w, h);
			    	 //Game.desktop.add(Game.bar);
			    	 //Game.output.append(Game.currentPlanet.getName());
			    	 //Game.bar.setVisible(true);
			    	}
			    	else
			    	{
						MessageBox mes = new MessageBox(null,
								"Error",
								"No Atmosphere Currently Loaded for Planet");
						mes.setVisible(true); 			    		
			    	}
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
	private JLabel l1 = new JLabel("System Name : ");
	private JLabel l2 = new JLabel("Planet / Moon Count : ");
	private JLabel l3 = new JLabel("Star Name : ");
	private JLabel l4 = new JLabel("Stellar Mass");
	private JLabel l5 = new JLabel("Stellar luminosity");
	private JLabel l6 = new JLabel("Age");
	private JLabel l7 = new JLabel("Habitable Ecosphere Radius");
	
	private static DefaultTableModel tableModel = new DefaultTableModel();	
	
	public dataPanel()
	{
		initGUI();
	}
	
	JTable setTable()
	{
		String[] columnNames = {"#",
				"Name",
                "Type",
                "Dist.",
                "Mass",
                "Radius"};
		
		tableModel.setColumnIdentifiers(columnNames);
		final JTable table = new JTable(tableModel);		
		return(table);
	}
	
	public void initGUI() 
	{
		//setTitle("");
 
		JPanel panel = new JPanel(new GridBagLayout());
		this.add(panel);
 
		Game.planetList = setTable();

		JLabel label = new JLabel("Planetary Overview");
 
		JPanel tableButtonPanel = new JPanel();
		tableButtonPanel.add(b1);
		b1.addActionListener(bl);
		
		tableButtonPanel.add(b2);
		b2.addActionListener(bl);
		
		tableButtonPanel.add(b3);
		b3.addActionListener(bl);
		
		tableButtonPanel.add(b4);
		b4.addActionListener(bl);

		tableButtonPanel.add(b5);
		b5.addActionListener(bl);
		
		JPanel buttonPanel = new JPanel();
		buttonPanel.add(b6);
		b6.addActionListener(bl);
		
		buttonPanel.add(b7);
		b7.addActionListener(bl);

		buttonPanel.add(b8);
		b8.addActionListener(bl);
		
		buttonPanel.add(b9);
		b9.addActionListener(bl);

		buttonPanel.add(b10);
		b10.addActionListener(bl);

		buttonPanel.add(b11);
		b11.addActionListener(bl);

		JPanel sunPanel = createSunPanel();
		sunPanel.setBorder(BorderFactory.createLineBorder(Color.BLACK));
				
		gbc.anchor = GridBagConstraints.WEST;
 
		gbc.gridx = 0;
		gbc.gridy = 0;
 
		panel.add(label, gbc);
 
		gbc.gridx = 0;
		gbc.gridy = 1;
		
		JScrollPane tableScrollPane = new JScrollPane(Game.planetList);
		tableScrollPane.setPreferredSize(new Dimension(800, 300));
		panel.add(new JScrollPane(tableScrollPane), gbc);
 
		gbc.gridx = 0;
		gbc.gridy = 2;
		panel.add(tableButtonPanel, gbc);
 
		gbc.gridx = 0;
		gbc.gridy = 3;
		gbc.gridwidth = 2;
		panel.add(buttonPanel, gbc);
 
		gbc.gridx = 1;
		gbc.gridy = 1;
		gbc.gridwidth = 1;
		gbc.gridheight = 2;
		gbc.anchor = GridBagConstraints.NORTHEAST;
         
		panel.add(sunPanel, gbc);

		this.setVisible(true);
	}
		
	private JPanel createSunPanel() 
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
		gbc.gridwidth = 2;		
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
		gbc.gridwidth = 2;		
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
		gbc.gridwidth = 2;		
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
		gbc.gridwidth = 2;		
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
		gbc.gridwidth = 2;
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
		gbc.gridwidth = 2;		
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
		gbc.gridwidth = 2;		
		gbc.fill = GridBagConstraints.HORIZONTAL;					
		panel.add(tf7,  gbc);
	 
		return panel;
	}
	
	public static void refresh()
	{
		String currentSystemName = Game.getSelected();
		Game.currentSystem = Game.getSystem(currentSystemName);	
		if (Game.currentSystem != null)
		{
			tf1.setText(currentSystemName);
			tf2.setText(Integer.toString(Game.currentSystem.total_planets));
			tf3.setText(Game.currentSystem.getCurrentSun().name);
			tf4.setText(Double.toString(Game.currentSystem.getCurrentSun().getMass())+ " solar masses");
			
			tf5.setText(Double.toString(Game.currentSystem.getCurrentSun().getLuminosity()));
			
			double val = Game.currentSystem.getCurrentSun().getAge();
			val = val / 1000000000;
			String result = String.format("%.3f", val);			
			tf6.setText(result + " billion years");
			
			tf7.setText(Double.toString(Game.currentSystem.getCurrentSun().get_r_ecosphere()) + " AU");	
            setTableData();
		}
	}
	
	public static void setTableData()
	{
		if (tableModel.getRowCount() > 0) 
		{
			clearTable();
		}
		for (int i = 0; i < Game.currentSystem.total_planets; i++) 
		{
		  Game.currentPlanet = Game.currentSystem.planetList.get(i);
		  String[] rowData = {Game.currentPlanet.getPlanet_no(),
				  Game.currentPlanet.getName(),
				  Game.currentPlanet.getType(),
				  Game.currentPlanet.getDist(),
				  Game.currentPlanet.getMass(),
				  Game.currentPlanet.getRadius()};
		  tableModel.addRow(rowData);
		}
	}
	
	
	public static void clearTable()
	{
		int rowCount = tableModel.getRowCount();
		//Remove rows one by one from the end of the table
		for (int i = rowCount - 1; i >= 0; i--) {
		    tableModel.removeRow(i);
		}
	}
 }
