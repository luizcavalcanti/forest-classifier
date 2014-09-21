package br.edu.ufam.icomp.ammd;

import ij.ImagePlus;
import ij.process.ColorProcessor;

import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.util.List;

import javax.imageio.ImageIO;

import sc.fiji.CMP_BIA.segmentation.structures.Labelling2D;
import sc.fiji.CMP_BIA.segmentation.superpixels.jSLIC;
import br.edu.ufam.icomp.ammd.data.Configuration;
import de.lmu.ifi.dbs.jfeaturelib.LibProperties;
import de.lmu.ifi.dbs.jfeaturelib.features.LocalBinaryPatterns;
import de.lmu.ifi.dbs.utilities.Arrays2;

public class GhiasiExperiment {

    private static final Configuration config = Configuration.loadConfiguration();

    public static void main(String[] args) throws IOException {
        ImagePlus im = new ImagePlus(config.getTrainingDirectory() + "/00001.jpg");
        Labelling2D segmentation = createSuperpixels(im);
        int[][] segmentationData = segmentation.getData();

        // get image Local Binary Pattern (LBP)
        LocalBinaryPatterns lbp = new LocalBinaryPatterns();
        ColorProcessor colorProcessor = new ColorProcessor(im.getBufferedImage());
        LibProperties prop = LibProperties.get();
        prop.setProperty(LibProperties.HISTOGRAMS_BINS, 8);
        lbp.setProperties(prop);
        lbp.run(colorProcessor);
        List<double[]> features = lbp.getFeatures();
        System.out.println("size: "+features.get(0).length);
//        for (double[] feature : features) {
//            System.out.println(Arrays2.join(feature, ", ", "%.5f"));
//        }

        // For every superpixel found, create histogram...
        for (int c = 1; c <= segmentation.getMaxLabel(); c++) {
            int[] hist = createColorHistogram(c, 32, segmentationData, im.getBufferedImage());
        }
        // renderSegmentationData(im, segmentationData);
        // createTrainingData();
    }

    private static Labelling2D createSuperpixels(ImagePlus im) {
        jSLIC slic = new jSLIC(im);
        slic.process(30, 0.2f);
        return slic.getSegmentation();
    }

    private static int[] createColorHistogram(int superpixelIndex, int bucketSize, int[][] segmentationData,
            BufferedImage image) {
        int bucketCount = 255 / bucketSize + 1;
        int[][][] ch = new int[bucketCount][bucketCount][bucketCount];
        for (int x = 0; x < segmentationData.length; x++) {
            for (int y = 0; y < segmentationData[0].length; y++) {
                if (segmentationData[x][y] == superpixelIndex) {
                    int color = image.getRGB(x, y);
                    // int alpha = (color & 0xff000000) >> 24;
                    int red = (color & 0x00ff0000) >> 16;
                    int green = (color & 0x0000ff00) >> 8;
                    int blue = color & 0x000000ff;
                    ch[red / bucketSize][green / bucketSize][blue / bucketSize]++;
                }
            }
        }
        int[] flatHist = new int[bucketCount * bucketCount * bucketCount];
        int index = 0;
        for (int i = 0; i < ch.length; i++)
            for (int j = 0; j < ch[i].length; j++)
                for (int k = 0; k < ch[i][j].length; k++)
                    flatHist[index] = ch[i][j][k];
        index++;
        return flatHist;
    }

    private static void renderSegmentationData(ImagePlus im, int[][] segmentationData) throws IOException {
        BufferedImage seg = im.duplicate().getBufferedImage();
        Graphics2D g = (Graphics2D) seg.getGraphics();
        for (int x = 0; x < segmentationData.length; x++) {
            for (int y = 0; y < segmentationData[0].length; y++) {
                g.setColor(getColor(segmentationData[x][y]));
                g.fillRect(x, y, 1, 1);
            }
        }
        ImageIO.write(seg, "jpg", new File("seg.jpg"));
    }

    private static Color getColor(int i) {
        int hash = 3 * i % 255;
        return new Color(hash, hash, hash);
    }

}
