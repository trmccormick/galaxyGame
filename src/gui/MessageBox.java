package gui;

import java.awt.BorderLayout;
import java.awt.Button;
import java.awt.Dialog;
import java.awt.Label;
import java.awt.Window;


@SuppressWarnings("serial")
public class MessageBox extends Dialog 
{
	private Button BUTOK;
	private Label LBLMessage;
	
	public MessageBox(Window owner, String title, String message)
	{
		super(owner,title);
		this.addWindowListener(new TemplateEvents.CloseWindowEvent(this));
		this.setLayout(new BorderLayout());
		LBLMessage = new Label(message);
		BUTOK = new Button("OK");
		BUTOK.addMouseListener(new TemplateEvents.CloseButtonMouseAdapter(this));
		this.add(LBLMessage, BorderLayout.PAGE_START);
		this.add(BUTOK);
		this.pack();
	}
}
