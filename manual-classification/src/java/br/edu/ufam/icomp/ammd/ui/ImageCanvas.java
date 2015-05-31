package br.edu.ufam.icomp.ammd.ui;

import java.awt.Canvas;
import java.awt.Color;
import java.awt.Graphics;
import java.awt.image.BufferedImage;

import br.edu.ufam.icomp.ammd.model.Classification;

public class ImageCanvas extends Canvas {

    private static final long serialVersionUID = 1L;
    private char[][] classesData;
    private BufferedImage baseImage;
    private BufferedImage overlay;
    private int covered;
    private int brushSize = 10;

    public ImageCanvas(BufferedImage baseImage) {
        classesData = new char[baseImage.getWidth()][baseImage.getHeight()];
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

    public void setClass(int x, int y, char c) {
        if (x >= 0 && x < getWidth() && y >= 0 && y < getHeight()) {
            int startX = Math.max(0, x - brushSize / 2);
            int endX = Math.min(getWidth() - 1, x + brushSize / 2);
            int startY = Math.max(0, y - brushSize / 2);
            int endY = Math.min(getHeight() - 1, y + brushSize / 2);
            for (int i = startX; i <= endX; i++) {
                for (int j = startY; j <= endY; j++) {
                    if (classesData[i][j] == '\u0000')
                        covered++;
                    classesData[i][j] = c;
                    updateImageOverlay(i, j, c);
                }
            }
        }
        repaint();
    }

    private void updateImageOverlay(int x, int y, char c) {
        overlay.setRGB(x, y, 0x00000000);
        Graphics g = overlay.getGraphics();
        g.setColor(getClassColor(classesData[x][y]));
        g.fillRect(x, y, 1, 1);
    }

    private Color getClassColor(char cls) {
        switch (cls) {
            case Classification.FOREST:
                return new Color(0, 1, 0, .3f);
            case Classification.ROAD:
                return new Color(0.98f, 0.5f, 0.24f, .3f);
            case Classification.WATER:
                return new Color(0, 0, 1, .3f);
            case Classification.BUILDING:
                return new Color(1, 0, 1, .2f);
            case Classification.NONE:
                return new Color(0, 0, 0, 0);
            default:
                return Color.BLACK;
        }
    }

    public double getCoveredPercentage() {
        return (double) covered / (getWidth() * getHeight());
    }

    public char[][] getClassesData() {
        return classesData;
    }

    public void setClassesData(char[][] classesData) {
        this.classesData = classesData;
        reloadOverlayData();
    }

    private void reloadOverlayData() {
        covered = 0;
        overlay = new BufferedImage(this.getWidth(), this.getHeight(), BufferedImage.TYPE_INT_ARGB);
        Graphics g = overlay.getGraphics();
        for (int x = 0; x < getWidth(); x++) {
            for (int y = 0; y < getHeight(); y++) {
                if (classesData[x][y] != '\u0000') {
                    covered++;
                    g.setColor(getClassColor(classesData[x][y]));
                    g.fillRect(x, y, 1, 1);
                }
            }
        }
        repaint();
    }
}