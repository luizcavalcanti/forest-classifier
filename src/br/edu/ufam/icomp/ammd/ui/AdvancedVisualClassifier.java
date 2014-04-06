package br.edu.ufam.icomp.ammd.ui;

import java.awt.BorderLayout;
import java.awt.Canvas;
import java.awt.Color;
import java.awt.FlowLayout;
import java.awt.Graphics;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;
import java.awt.event.MouseMotionListener;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.text.DecimalFormat;

import javax.swing.ButtonGroup;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JSlider;
import javax.swing.JToggleButton;
import javax.swing.event.ChangeEvent;
import javax.swing.event.ChangeListener;

import br.edu.ufam.icomp.ammd.data.ARFFDataProvider;
import br.edu.ufam.icomp.ammd.data.Configuration;
import br.edu.ufam.icomp.ammd.data.ImageDataProvider;

public class AdvancedVisualClassifier extends JFrame {

    private static final long serialVersionUID = 1L;
    private static final String TITLE = "Manual Classifier";

    private BufferedImage sourceImage;
    private ImageDataProvider dataProvider;

    private ImageCanvas imageCanvas;
    private JToggleButton btnForest;
    private JToggleButton btnRoad;
    private JToggleButton btnWater;
    private JLabel lblBrushSize;
    private JSlider sldBrushSize;

    private String selectedClass;
    private int brushSize = 10;

    public AdvancedVisualClassifier() {
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        initDataProvider();
        initComponents();
        showNextData();
        selectedClass = Classification.FOREST;
        setTitle(TITLE);
    }

    private void initDataProvider() {
        String path = Configuration.loadConfiguration().getRawDataDirectory();
        dataProvider = new ImageDataProvider(path);
    }

    private void initComponents() {
        lblBrushSize = new JLabel();
        lblBrushSize.setText("Brush size: " + brushSize);

        sldBrushSize = new JSlider();
        sldBrushSize.setMinimum(1);
        sldBrushSize.setMaximum(50);
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

        ButtonGroup buttonGroup = new ButtonGroup();
        buttonGroup.add(btnForest);
        buttonGroup.add(btnRoad);
        buttonGroup.add(btnWater);

        JPanel buttonPanel = new JPanel();
        buttonPanel.setLayout(new FlowLayout());
        buttonPanel.add(btnForest);
        buttonPanel.add(btnRoad);
        buttonPanel.add(btnWater);

        getContentPane().setLayout(new BorderLayout());
        getContentPane().add(brushPanel, BorderLayout.NORTH);
        getContentPane().add(buttonPanel, BorderLayout.SOUTH);
        pack();
    }

    protected void updateBrushSize() {
        brushSize = sldBrushSize.getValue();
        lblBrushSize.setText("Brush size: " + brushSize);
        imageCanvas.setBrushSize(brushSize);
    }

    private void showNextData() {
        BufferedImage img = null;
        try {
            img = dataProvider.getNextImage();
        } catch (IOException e) {
            JOptionPane.showMessageDialog(this, "Error: " + e.getMessage());
        }
        if (img != null) {
            sourceImage = img;
            updateScreen();
        } else {
            JOptionPane.showMessageDialog(this, "All done. Off you go.");
            ARFFDataProvider.saveAndCloseFile();
            this.dispose();
        }
    }

    private void updateScreen() {
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

class ImageCanvas extends Canvas {

    private static final long serialVersionUID = 1L;
    private String[][] classesData;
    private BufferedImage baseImage;
    private BufferedImage overlay;
    private int covered;
    private int brushSize = 10;

    public ImageCanvas(BufferedImage baseImage) {
        classesData = new String[baseImage.getWidth()][baseImage.getHeight()];
        setSize(baseImage.getWidth(), baseImage.getHeight());
        this.baseImage = baseImage;
        overlay = new BufferedImage(this.getWidth(), this.getHeight(), BufferedImage.TYPE_INT_ARGB);
    }

    public void setBrushSize(int brushSize) {
        this.brushSize = brushSize;
    }

    @Override
    public void paint(Graphics g) {
        super.paint(g);
        g.drawImage(baseImage, 0, 0, null);
        g.drawImage(overlay, 0, 0, null);
    }

    public void setClass(int x, int y, String c) {
        if (x >= 0 && x < getWidth() && y >= 0 && y < getHeight()) {
            int startX = Math.max(0, x - brushSize / 2);
            int endX = Math.min(getWidth() - 1, x + brushSize / 2);
            int startY = Math.max(0, y - brushSize / 2);
            int endY = Math.min(getHeight() - 1, y + brushSize / 2);
            for (int i = startX; i <= endX; i++) {
                for (int j = startY; j <= endY; j++) {
                    if (classesData[i][j] == null)
                        covered++;
                    classesData[i][j] = c;
                    updateImageOverlay(i, j, c);
                }
            }
        }
        repaint();
    }

    private void updateImageOverlay(int x, int y, String c) {
        overlay.setRGB(x, y, 0x00000000);
        Graphics g = overlay.getGraphics();
        g.setColor(getClassColor(classesData[x][y]));
        g.fillRect(x, y, 1, 1);
    }

    private Color getClassColor(String string) {
        if (string.equals(Classification.FOREST)) {
            return new Color(0, 1, 0, .2f);
        } else if (string.equals(Classification.ROAD)) {
            return new Color(1, 1, 1, .2f);
        } else if (string.equals(Classification.WATER)) {
            return new Color(0, 0, 1, .2f);
        }
        return Color.BLACK;
    }

    public double getCoveredPercentage() {
        return (double) covered / (getWidth() * getHeight());
    }

}

class Classification {
    public static final String ROAD = "road";
    public static final String FOREST = "forest";
    public static final String WATER = "water";
}
