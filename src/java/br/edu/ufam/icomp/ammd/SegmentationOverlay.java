package br.edu.ufam.icomp.ammd;

import ij.ImagePlus;

import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.FileFilter;
import java.io.FilenameFilter;
import java.io.IOException;

import javax.imageio.ImageIO;

import br.edu.ufam.icomp.ammd.data.Configuration;

public class SegmentationOverlay {

    private static final class DirectoryFiler implements FileFilter {
        @Override
        public boolean accept(File pathname) {
            return pathname.isDirectory();
        }
    }

    private static final class JPEGFilter implements FilenameFilter {
        @Override
        public boolean accept(File dir, String name) {
            return name.endsWith(".jpg");
        }
    }

    private static final Configuration config = Configuration.loadConfiguration();
    private static final Color ALPHA_MANMADE = new Color(0.98f, 0.5f, 0.24f, .3f);
    private static final Color ALPHA_FOREST = new Color(0, 1, 0, .3f);
    private static final Color ALPHA_WATER = new Color(0, 0, 1, .3f);

    public static void main(String[] args) throws IOException {
        File validPath = new File(config.getValidationDirectory());
        File outputPath = new File(config.getOutputDirectory());
        File[] experiments = outputPath.listFiles(new DirectoryFiler());
        File[] originals = validPath.listFiles(new JPEGFilter());
        System.out.printf("Processing images ");
        for (File original : originals) {
            ImagePlus img = new ImagePlus(original.getAbsolutePath());
            System.out.printf(".");
            for (File experiment : experiments) {
                File target = new File(experiment.getPath() + "/" + original.getName());
                if (target.exists()) {
                    BufferedImage mask = new ImagePlus(target.getAbsolutePath()).getBufferedImage();
                    BufferedImage source = img.duplicate().getBufferedImage();
                    applyMask(source, mask);
                    ImageIO.write(source, "jpg", target);
                }
            }
        }
    }

    private static void applyMask(BufferedImage image, BufferedImage mask) {
        Graphics2D g = image.createGraphics();
        for (int x = 0; x < image.getWidth(); x++) {
            for (int y = 0; y < image.getHeight(); y++) {
                int maskValue = new Color(mask.getRGB(x, y)).getRed();
                g.setColor(getClassColor(maskValue));
                g.fillRect(x, y, 1, 1);
            }
        }
    }

    private static Color getClassColor(int maskValue) {
        if (maskValue == 255) {
            return ALPHA_MANMADE;
        } else if (maskValue == 0) {
            return ALPHA_WATER;
        } else {
            return ALPHA_FOREST;
        }
    }

}
