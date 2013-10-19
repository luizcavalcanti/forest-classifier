package br.edu.ufam.icomp.ammd.ui;

import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.FlowLayout;
import java.awt.Graphics;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.image.BufferedImage;

import javax.swing.ImageIcon;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;

import br.edu.ufam.icomp.ammd.data.ARFFDataProvider;
import br.edu.ufam.icomp.ammd.data.Configuration;

public class VisualClassifierFrame extends JFrame {

	private static final long serialVersionUID = 1L;
	
	private BufferedImage currentImage;
	private BufferedImage sourceImage;
	private int sampleRow;
	private int sampleColumn;

	private JLabel imageLabel;
	private JLabel sourceLabel;
	private JButton btnForest;
	private JButton btnNonForest;

	
	public VisualClassifierFrame() {
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        initComponents();
        showNextData();
    }

	private void initComponents() {
		imageLabel = new JLabel();
		sourceLabel = new JLabel();
		
		btnForest = new JButton("Forest");
		btnForest.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(ActionEvent e) {
				classificateAsForest();
			}
		});
		
		btnNonForest = new JButton("Non-forest");
		btnNonForest.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(ActionEvent e) {
				classificateAsNonForest();
			}
		});
		
		JPanel buttonPanel = new JPanel();
		buttonPanel.setLayout(new FlowLayout());
		buttonPanel.add(btnForest);
		buttonPanel.add(btnNonForest);
		
		getContentPane().setLayout(new BorderLayout());
		getContentPane().add(sourceLabel, BorderLayout.NORTH);
		getContentPane().add(imageLabel, BorderLayout.CENTER);
		getContentPane().add(buttonPanel, BorderLayout.SOUTH);
		pack();
	}

	private void showNextData() {
		if (ARFFDataProvider.hasUnclassifiedData()) {
			currentImage = ARFFDataProvider.getNextSample();
			sourceImage = ARFFDataProvider.getSampleSource();
			sampleRow = ARFFDataProvider.getSampleRow();
			sampleColumn = ARFFDataProvider.getSampleColumn();
			updateScreen();
		} else {
			JOptionPane.showMessageDialog(this, "All done. Off you go.");
			ARFFDataProvider.saveAndCloseFile();
			this.dispose();
		}
	}

	private void updateScreen() {
		imageLabel.setIcon(new ImageIcon(currentImage));
		highlighSampleInSourceImage();
		sourceLabel.setIcon(new ImageIcon(sourceImage));
		pack();
	}
	
	private void highlighSampleInSourceImage() {
		Graphics g = sourceImage.getGraphics();
		Configuration conf = Configuration.loadConfiguration();
		g.setColor(Color.YELLOW);
		g.drawRect(conf.getChunkWidth()*sampleColumn, conf.getChunkHeight()*sampleRow,
				conf.getChunkWidth(), conf.getChunkHeight());
	}

	protected void classificateAsForest() {
		ARFFDataProvider.setSampleClassification("Forest");
		showNextData();
	}
	
	protected void classificateAsNonForest() {
		ARFFDataProvider.setSampleClassification("Non-forest");
		showNextData();
	}
	
}
