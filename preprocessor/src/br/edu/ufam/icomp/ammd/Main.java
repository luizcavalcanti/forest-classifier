package br.edu.ufam.icomp.ammd;

import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.imageio.ImageIO;

public class Main {

    private static Configuration config;
    private static List<String> imageList;

    private static int imageCount = 0;

    public static void main(String[] args) {
        config = Configuration.loadConfiguration();
        preprocessImages();
    }

    private static void preprocessImages() {
        loadImageList();
        long splitStart = System.currentTimeMillis();
        File pid = new File(config.getProcessedDataDirectory());
        if (!pid.exists())
            pid.mkdir();
        for (String imagePath : imageList) {
            splitImage(imagePath);
        }
        long splitEnd = System.currentTimeMillis();
        System.out.println("Images splited in " + (splitEnd - splitStart) + "ms");
    }

    private static void splitImage(String imagePath) {
        try {
            BufferedImage img = ImageIO.read(new File(imagePath));
            int chunkHeight = config.getChunkHeight();
            int chunkWidth = config.getChunkWidth();
            int verticalPieces = img.getHeight() / chunkHeight;
            int horizontalPieces = img.getHeight() / chunkWidth;
            imageCount++;
            for (int x = 0; x < verticalPieces; x++) {
                for (int y = 0; y < horizontalPieces; y++) {
                    BufferedImage chunk = new BufferedImage(config.getChunkWidth(), config.getChunkHeight(),
                            img.getType());
                    Graphics2D g = chunk.createGraphics();
                    g.drawImage(img, 0, 0, chunkWidth, chunkHeight, chunkWidth * y, chunkHeight * x, chunkWidth * y
                            + chunkWidth, chunkHeight * x + chunkHeight, null);
                    File output = new File(config.getProcessedDataDirectory() + "/" + imageCount + "_" + x + "_" + y
                            + ".jpg");
                    ImageIO.write(chunk, "jpg", output);
                }
            }
        } catch (IOException e) {
            System.err.println("could not process image " + imagePath + ": " + e.getMessage());
        }
    }

    private static void loadImageList() {
        long listStart = System.currentTimeMillis();
        imageList = new ArrayList<String>();
        File rawDir = new File(config.getRawDataDirectory());
        File[] files = rawDir.listFiles();
        for (File f : files) {
            imageList.add(f.getAbsolutePath());
        }
        long listEnd = System.currentTimeMillis();
        System.out.println("Image list composed in " + (listEnd - listStart) + "ms");
    }

}
