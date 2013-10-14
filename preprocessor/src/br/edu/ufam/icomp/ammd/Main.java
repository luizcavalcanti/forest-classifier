package br.edu.ufam.icomp.ammd;

import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;

import javax.imageio.ImageIO;

public class Main {

    private static Configuration config;
    private static List<String> imageList;

    private static int imageCount = 0;

    public static void main(String[] args) {
        loadConfiguration();
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

    private static void loadConfiguration() {
        try {
            Properties prop = loadConfigFile();
            setupProperties(prop);
            displayConfiguration();
        } catch (IOException e) {
            System.err.println("Cound not load configuration file: " + e.getMessage());
            System.exit(-1);
        }
    }

    private static Properties loadConfigFile() throws IOException {
        Properties prop = new Properties();
        FileInputStream fis = new FileInputStream("config.properties");
        prop.load(fis);
        return prop;
    }

    private static void setupProperties(Properties prop) {
        validateProperties(prop);
        config = new Configuration();
        config.setRawDataDirectory(prop.getProperty("path.raw"));
        config.setProcessedDataDirectory(prop.getProperty("path.processed"));
        config.setChunkWidth(Integer.parseInt(prop.getProperty("chunk.width")));
        config.setChunkHeight(Integer.parseInt(prop.getProperty("chunk.height")));
    }

    private static void validateProperties(Properties prop) {
        if (prop.getProperty("path.raw") == null) {
            System.err.println("configuration path.raw is obligatory");
            System.exit(-1);
        }
        if (prop.getProperty("path.processed") == null) {
            System.err.println("configuration path.processed is obligatory");
            System.exit(-1);
        }
        if (prop.getProperty("chunk.width") == null) {
            System.err.println("configuration chunk.width is obligatory");
            System.exit(-1);
        }
        if (prop.getProperty("chunk.height") == null) {
            System.err.println("configuration chunk.height is obligatory");
            System.exit(-1);
        }
    }

    private static void displayConfiguration() {
        System.out.println("[Configuration loaded]");
        System.out.println("Raw data directory: " + config.getRawDataDirectory());
        System.out.println("Processed data directory: " + config.getProcessedDataDirectory());
    }

    private static Color getAverageColor(BufferedImage bitmap) {
        long redBucket = 0;
        long greenBucket = 0;
        long blueBucket = 0;
        long pixelCount = 0;
        // byte[] pixels = ((DataBufferByte) bitmap.getRaster().getDataBuffer()).getData();
        for (int y = 0; y < bitmap.getHeight(); y++) {
            for (int x = 0; x < bitmap.getWidth(); x++) {
                Color c = new Color(bitmap.getRGB(x, y));
                pixelCount++;
                redBucket += c.getRed();
                greenBucket += c.getGreen();
                blueBucket += c.getBlue();
                // does alpha matter?
            }
        }
        return new Color((int)(redBucket/pixelCount), (int)(greenBucket/pixelCount), (int)(blueBucket/pixelCount));
    }

}
