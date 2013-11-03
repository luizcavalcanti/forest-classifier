package br.edu.ufam.icomp.ammd.data;

import java.awt.Color;
import java.awt.image.BufferedImage;

public class ImageUtil {
	
    public static Color getAverageColor(BufferedImage bitmap) {
        long redBucket = 0;
        long greenBucket = 0;
        long blueBucket = 0;
        long pixelCount = 0;
        for (int y = 0; y < bitmap.getHeight(); y++) {
            for (int x = 0; x < bitmap.getWidth(); x++) {
                Color c = new Color(bitmap.getRGB(x, y));
                pixelCount++;
                redBucket += c.getRed();
                greenBucket += c.getGreen();
                blueBucket += c.getBlue();
            }
        }
        return new Color((int)(redBucket/pixelCount), (int)(greenBucket/pixelCount), (int)(blueBucket/pixelCount));
    }

    public static int[] generateBWHistogram(BufferedImage bitmap, int bucketCount) {
        int[] histogram = new int[bucketCount];
        for (int y = 0; y < bitmap.getHeight(); y++) {
            for (int x = 0; x < bitmap.getWidth(); x++) {
                Color c = new Color(bitmap.getRGB(x, y));
                int grey = (c.getRed() + c.getBlue() + c.getGreen())/3;
                int index = grey % bucketCount;
                histogram[index]++;
            }
        }
        return histogram;
    }

//    public static BufferedImage normalizeContrast(BufferedImage bitmap) {
//        BufferedImage result = copyImage(bitmap);
//        for (int y = 0; y < result.getHeight(); y++) {
//            for (int x = 0; x < result.getWidth(); x++) {
//                int color = result.getRGB(x, y);
//                result.setRGB(x, y, color | );
//            }
//        }
//        return result;
//    }
//
//    private static BufferedImage copyImage(BufferedImage source) {
//        ColorModel cm = source.getColorModel();
//        WritableRaster raster = source.copyData(null);
//        return new BufferedImage(cm, raster, cm.isAlphaPremultiplied(), null);
//    }

}