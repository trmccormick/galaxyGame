package galaxy;

import gamelogic.Game;

import javax.swing.event.TableModelEvent;
import javax.swing.event.TableModelListener;
import javax.swing.table.DefaultTableModel;

public class planetTableModel extends DefaultTableModel {
     /**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private boolean DEBUG = false;
     
    public void clearTable()
	{
		int rowCount = this.getRowCount();
		if (rowCount > 0) {
		 //Remove rows one by one from the end of the table
		 for (int i = rowCount - 1; i >= 0; i--) {
		    this.removeRow(i);
		 }
		}
	}
	
	public void setRow(planet currentPlanet)
	{
		  String[] rowData = {currentPlanet.getNum(),
				  currentPlanet.getName(),
				  currentPlanet.getType(),
				  currentPlanet.getDist(),
				  currentPlanet.getMass(),
				  currentPlanet.getRadius()};
		  
		  addRow(rowData);
	}
	
	public int getRow()
	{
		return(this.getRow());
	}
	
        /*
         * JTable uses this method to determine the default renderer/
         * editor for each cell.  If we didn't implement this method,
         * then the last column would contain text ("true"/"false"),
         * rather than a check box.
         */
        @SuppressWarnings({ "unchecked", "rawtypes" })
		public Class getColumnClass(int c) {
            return getValueAt(0, c).getClass();
        }
 
        /*
         * Don't need to implement this method unless your table's
         * editable.
         */
        public boolean isCellEditable(int row, int col) {
            //Note that the data/cell address is constant,
            //no matter where the cell appears onscreen.
            if (col < 2) {
                return false;
            } else {
                return true;
            }
        }
 
        /*
         * Don't need to implement this method unless your table's
         * data can change.
         */
        public void setValueAt(Object value, int row, int col) {
           if (DEBUG) {
                Game.output.append("Setting value at " + row + "," + col
                                   + " to " + value
                                   + " (an instance of "
                                   + value.getClass() + ")");
            }
 
            this.setValueAt(value, row, col);
            fireTableCellUpdated(row, col);
            if (DEBUG) {
            	Game.output.append("New value of data:");
                printDebugData();
            }
        }
 
        private void printDebugData() {
            int numRows = getRowCount();
            int numCols = getColumnCount();
         
            for (int i=0; i < numRows; i++) {
            	Game.output.append("    row " + i + ":");
                for (int j=0; j < numCols; j++) {
                	Game.output.append("  " +  this.getValueAt(i, j));
                }
            }
            Game.output.append("--------------------------");
        }
        
}

