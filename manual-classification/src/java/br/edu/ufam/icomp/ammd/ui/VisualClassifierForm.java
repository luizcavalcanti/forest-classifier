package br.edu.ufam.icomp.ammd.ui;

import java.awt.BorderLayout;
import java.awt.FlowLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;
import java.awt.event.MouseMotionListener;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.text.DecimalFormat;

import javax.swing.ButtonGroup;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JSlider;
import javax.swing.JToggleButton;
import javax.swing.event.ChangeEvent;
import javax.swing.event.ChangeListener;

import br.edu.ufam.icomp.ammd.data.Configuration;
import br.edu.ufam.icomp.ammd.data.ImageDataProvider;
import br.edu.ufam.icomp.ammd.model.Classification;

public class VisualClassifierForm extends JFrame {

    private static final long serialVersionUID = 1L;
    private static final String TITLE = "Manual Classifier";

    private BufferedImage sourceImage;
    private ImageDataProvider dataProvider;

    private ImageCanvas imageCanvas;
    private JButton btnPrevious;
    private JButton btnNext;
    private JLabel lblBrushSize;
    private JSlider sldBrushSize;
    private JToggleButton btnForest;
    private JToggleButton btnRoad;
    private JToggleButton btnWater;
    private JToggleButton btnBuilding;

    private char selectedClass;
    private int brushSize = 10;

    public VisualClassifierForm() {
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        initDataProvider();
        initComponents();
        showNextData();
        selectedClass = Classification.FOREST;
    }

    private void initDataProvider() {
        Configuration conf = Configuration.loadConfiguration();
        dataProvider = new ImageDataProvider(conf.getRawDataDirectory(), conf.getProcessedDataDirectory());
    }

    private void initComponents() {
        lblBrushSize = new JLabel();
        lblBrushSize.setText("Brush size: " + brushSize);

        sldBrushSize = new JSlider();
        sldBrushSize.setMinimum(1);
        sldBrushSize.setMaximum(100);
        sldBrushSize.setValue(brushSize);
        sldBrushSize.addChangeListener(new ChangeListener() {
            @Override
            public void stateChanged(ChangeEvent e) {
                updateBrushSize();
            }
        });

        JPanel brushPanel = new JPanel();
        brushPanel.setLayout(new FlowLayout());
        brushPanel.add(lblBrushSize);
        brushPanel.add(sldBrushSize);

        btnForest = new JToggleButton("Forest");
        btnForest.setSelected(true);
        btnForest.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                selectedClass = Classification.FOREST;
            }
        });

        btnRoad = new JToggleButton("Road");
        btnRoad.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                selectedClass = Classification.ROAD;
            }
        });

        btnWater = new JToggleButton("Water");
        btnWater.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                selectedClass = Classification.WATER;
            }
        });

        btnBuilding = new JToggleButton("Building");
        btnBuilding.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                selectedClass = Classification.BUILDING;
            }
        });

        ButtonGroup buttonGroup = new ButtonGroup();
        buttonGroup.add(btnForest);
        buttonGroup.add(btnRoad);
        buttonGroup.add(btnWater);
        buttonGroup.add(btnBuilding);

        JPanel buttonPanel = new JPanel();
        buttonPanel.setLayout(new FlowLayout());
        buttonPanel.add(btnForest);
        buttonPanel.add(btnRoad);
        buttonPanel.add(btnWater);
        buttonPanel.add(btnBuilding);

        btnPrevious = new JButton();
        btnPrevious.setText("<");
        btnPrevious.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                showPreviousData();
            }
        });

        btnNext = new JButton();
        btnNext.setText(">");
        btnNext.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                showNextData();
            }
        });

        getContentPane().setLayout(new BorderLayout());
        getContentPane().add(brushPanel, BorderLayout.NORTH);
        getContentPane().add(buttonPanel, BorderLayout.SOUTH);
        getContentPane().add(btnPrevious, BorderLayout.WEST);
        getContentPane().add(btnNext, BorderLayout.EAST);
        pack();
    }

    protected void updateBrushSize() {
        brushSize = sldBrushSize.getValue();
        lblBrushSize.setText("Brush size: " + brushSize);
        imageCanvas.setBrushSize(brushSize);
    }

    private void showNextData() {
        if (sourceImage != null) {
            saveCurrentData();
        }
        BufferedImage img = null;
        try {
            img = dataProvider.getNextImage();
        } catch (IOException e) {
            JOptionPane.showMessageDialog(VisualClassifierForm.this, "Error: " + e.getMessage());
        }
        if (img == null) {
            JOptionPane.showMessageDialog(VisualClassifierForm.this, "No more images");
        } else {
            sourceImage = img;
            updateScreen();
            loadCurrentData();
        }
    }

    private void showPreviousData() {
        if (sourceImage != null) {
            saveCurrentData();
        }
        BufferedImage img = null;
        try {
            img = dataProvider.getPreviousImage();
        } catch (IOException e) {
            JOptionPane.showMessageDialog(this, "Error: " + e.getMessage());
        }
        if (img == null) {
            JOptionPane.showMessageDialog(this, "You are already on the first image");
        } else {
            sourceImage = img;
            updateScreen();
            loadCurrentData();
        }
    }

    private void loadCurrentData() {
        try {
            imageCanvas.setClassesData(dataProvider.loadCurrentData());
            updateFrameTitle();
        } catch (IOException e) {
            JOptionPane.showMessageDialog(this, e.getMessage());
        }
    }

    private void saveCurrentData() {
        try {
            dataProvider.saveData(imageCanvas.getClassesData());
        } catch (IOException e) {
            JOptionPane.showMessageDialog(this, e.getMessage());
        }
    }

    private void updateScreen() {
        if (imageCanvas != null)
            getContentPane().remove(imageCanvas);
        imageCanvas = new ImageCanvas(sourceImage);
        imageCanvas.addMouseMotionListener(new MouseMotionListener() {
            @Override
            public void mouseMoved(MouseEvent e) {
            }

            @Override
            public void mouseDragged(MouseEvent e) {
                imageCanvas.setClass(e.getX(), e.getY(), selectedClass);
                updateFrameTitle();
            }
        });

        imageCanvas.addMouseListener(new MouseListener() {
            @Override
            public void mouseReleased(MouseEvent e) {
            }

            @Override
            public void mousePressed(MouseEvent e) {
                imageCanvas.setClass(e.getX(), e.getY(), selectedClass);
                updateFrameTitle();
            }

            @Override
            public void mouseExited(MouseEvent e) {
            }

            @Override
            public void mouseEntered(MouseEvent e) {
            }

            @Override
            public void mouseClicked(MouseEvent e) {
            }
        });

        getContentPane().add(imageCanvas, BorderLayout.CENTER);

        pack();
    }

    protected void updateFrameTitle() {
        double progress = imageCanvas.getCoveredPercentage() * 100;
        DecimalFormat df = new DecimalFormat("###.00");
        setTitle(TITLE + " - " + df.format(progress) + "% classified");
    }

}
