package gui;

import gamelogic.Game;

import java.awt.event.*;
import javax.swing.*;
import javax.swing.event.*;
import javax.swing.tree.*;

public class treePanel extends JInternalFrame {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	// create a hierarchy of nodes
	private static MutableTreeNode root = new DefaultMutableTreeNode("Galaxy");

	private static DefaultTreeModel model;
	private static JTree tree;
	private static int rootCount;
	private JPopupMenu pm;

	public treePanel() {
		rootCount = -1;
		pm = new JPopupMenu();
	    ActionListener menuListener = new ActionListener() {
	        public void actionPerformed(ActionEvent event) {
	          gamelogic.Game.output.append("Popup menu item ["
	              + event.getActionCommand() + "] was pressed on " + event.toString());
	        }
	      };

	    JMenuItem item;
	    pm.add(item = new JMenuItem("Open"));
	    item.setHorizontalTextPosition(JMenuItem.RIGHT);
	    item.addActionListener(menuListener);
	    pm.add(item = new JMenuItem("Copy"));
	    item.setHorizontalTextPosition(JMenuItem.RIGHT);
	    item.addActionListener(menuListener);
	    pm.add(item = new JMenuItem("Paste"));
	    item.setHorizontalTextPosition(JMenuItem.RIGHT);
	    item.addActionListener(menuListener);
	    pm.add(item = new JMenuItem("Delete"));
	    item.setHorizontalTextPosition(JMenuItem.RIGHT);
	    item.addActionListener(menuListener);
	    pm.add(item = new JMenuItem("Rename"));
	    item.setHorizontalTextPosition(JMenuItem.RIGHT);
	    item.addActionListener(menuListener);	    
	    pm.addSeparator();
	    pm.add(item = new JMenuItem("Import"));
	    item.setHorizontalTextPosition(JMenuItem.RIGHT);
	    item.addActionListener(menuListener);	    
	    pm.add(item = new JMenuItem("Export"));
	    item.setHorizontalTextPosition(JMenuItem.RIGHT);
	    item.addActionListener(menuListener);
	    pm.addSeparator();	    
	    pm.add(item = new JMenuItem("Properties"));
	    item.addActionListener(menuListener);
	    
	    // create the JTree
		model = new DefaultTreeModel(root);
		tree = new JTree(model);
		tree.setBorder(BorderFactory.createEmptyBorder(5, 10, 5, 5));

		tree.addMouseListener(new MouseAdapter() {
			@Override
			public void mouseReleased(MouseEvent e) {
				if (e.isPopupTrigger()) {
					pm.show(e.getComponent(), e.getX(), e.getY());
				}
			}
		});

		// listen for selections
		tree.addTreeSelectionListener(new TreeSelectionListener() {
			public void valueChanged(TreeSelectionEvent event) {
				Object obj=((DefaultMutableTreeNode)event.getPath().getLastPathComponent()).getUserObject();
				String selected = obj.toString();
				Game.setSelected(selected);
				dataPanel.refresh();
     	        gamelogic.Game.output.append("Popup menu item ["
			              + selected + "] was pressed on " + event.toString());
     	         
     	        switch (selected) {
     	            case "Galaxy" :  gamelogic.Game.showGalaxyInfo();
     	                     break;
     	        }
			}
		});
	}

	JTree getTree() {
		return tree;
	}

	public static void treeInsert(String[] newNode, int nextRoot) {
		MutableTreeNode rootInsert = new DefaultMutableTreeNode(newNode[0]);
		root.insert(rootInsert, nextRoot);
		for (int i = 0; i < newNode.length - 1; i++) {
			rootInsert.insert(new DefaultMutableTreeNode(newNode[i + 1]), i);
		}
	}

	public void append(String[] newNode) {
		rootCount++;
		treeInsert(newNode, rootCount);
	}
	
	public void clearTree() { 
	    ((DefaultMutableTreeNode) root).removeAllChildren(); //this removes all nodes
	    model.reload(); //this notifies the listeners and changes the GUI
		rootCount = -1;	    
	}	
		
	public void resetNav()
	{
		model.reload();
		dataPanel.refresh();
	}
}
