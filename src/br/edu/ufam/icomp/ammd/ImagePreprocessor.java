package br.edu.ufam.icomp.ammd;

import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.imageio.ImageIO;

import br.edu.ufam.icomp.ammd.data.Configuration;
import br.edu.ufam.icomp.ammd.data.DataManager;
import br.edu.ufam.icomp.ammd.data.ImageUtil;

public class ImagePreprocessor {

    private static Configuration config;
    private static List<String> imageList;

    private static int imageCount = 0;

    public static void main(String[] args) {
        config = Configuration.loadConfiguration();
        preprocessImages();
    }

    private static void preprocessImages() {
        loadImageList();
        DataManager.createARFFFile();
        long splitStart = System.currentTimeMillis();
        File pid = new File(config.getProcessedDataDirectory());
        if (!pid.exists())
            pid.mkdir();
        for (String imagePath : imageList) {
            splitImage(imagePath);
        }
        long splitEnd = System.currentTimeMillis();
        DataManager.persistARFFFile();
        System.out.println("Images splited in " + (splitEnd - splitStart) + "ms");
    }

    private static void splitImage(String imagePath) {
        try {
            File source = new File(imagePath);
            BufferedImage img = ImageIO.read(source);
            int chunkHeight = config.getChunkHeight();
            int chunkWidth = config.getChunkWidth();
            int verticalPieces = img.getHeight() / chunkHeight;
            int horizontalPieces = img.getWidth() / chunkWidth;
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
                    collectData(chunk, source, output);
                }
            }
        } catch (IOException e) {
            System.err.println("could not process image " + imagePath + ": " + e.getMessage());
        }
    }

    private static void collectData(BufferedImage chunk, File source, File output) {
        Color c = ImageUtil.getAverageColor(chunk);
        int greyAverage = (c.getRed()+c.getBlue()+c.getGreen())/3;
        int[] histogram = ImageUtil.generateBWHistogram(chunk, 16);
        StringBuilder sb = new StringBuilder();
        sb.append(output.getName()+',');
        sb.append(source.getName()+',');
        sb.append(c.getRed()+",");
        sb.append(c.getGreen()+",");
        sb.append(c.getBlue()+",");
        sb.append(greyAverage+",");
        sb.append(histogram[0]+",");
        sb.append(histogram[1]+",");
        sb.append(histogram[2]+",");
        sb.append(histogram[3]+",");
        sb.append(histogram[4]+",");
        sb.append(histogram[5]+",");
        sb.append(histogram[6]+",");
        sb.append(histogram[7]+",");
        sb.append(histogram[8]+",");
        sb.append(histogram[9]+",");
        sb.append(histogram[10]+",");
        sb.append(histogram[11]+",");
        sb.append(histogram[12]+",");
        sb.append(histogram[13]+",");
        sb.append(histogram[14]+",");
        sb.append(histogram[15]+",");
        DataManager.appendARFFData(sb.toString());
    }

    private static void loadImageList() {
        long listStart = System.currentTimeMillis();
        imageList = new ArrayList<String>();
        File rawDir = new File(config.getRawDataDirectory());
        File[] files = rawDir.listFiles();
        for (File f : files) {
            if (f.getName().endsWith(".jpg")) {
                imageList.add(f.getAbsolutePath());
            }
        }
        long listEnd = System.currentTimeMillis();
        System.out.println("Image list (" + imageList.size() + ") composed in " + (listEnd - listStart) + "ms");
    }

}
