package gui;

import java.awt.Dimension;
import java.awt.TextArea;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.Box;
import javax.swing.BoxLayout;
import javax.swing.JButton;
import javax.swing.JDialog;
import javax.swing.JLabel;

class AboutDialog extends JDialog {
  /**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	public AboutDialog() {
    setTitle("About Galaxy Game");
    setLayout(new BoxLayout(getContentPane(), BoxLayout.Y_AXIS));
    add(Box.createRigidArea(new Dimension(0, 10)));
 
    JLabel name = new JLabel("Notes");
    name.setAlignmentX(0.5f);
    add(name);
	
    add(Box.createRigidArea(new Dimension(0, 100)));

    JButton OK = new JButton("OK");
    OK.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent event) {
        dispose();
      }
    });

    OK.setAlignmentX(0.5f);
    add(OK);
    setModalityType(ModalityType.APPLICATION_MODAL);
    setDefaultCloseOperation(DISPOSE_ON_CLOSE);
    setSize(600, 200);
  }
}