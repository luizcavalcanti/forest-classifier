package br.edu.ufam.icomp.ammd;

import ij.ImagePlus;
import ij.gui.Roi;

import java.awt.Rectangle;
import java.io.File;
import java.io.FilenameFilter;
import java.io.IOException;

import javax.imageio.ImageIO;

import org.apache.commons.io.FileUtils;

import trainableSegmentation.WekaSegmentation;
import weka.classifiers.AbstractClassifier;
import weka.classifiers.bayes.NaiveBayes;
import weka.classifiers.functions.LibSVM;
import weka.classifiers.lazy.IBk;
import weka.classifiers.trees.J48;
import br.edu.ufam.icomp.ammd.data.Configuration;

public class ImageSegmentationExperiment {

    private static final Configuration config = Configuration.loadConfiguration();

    private static final boolean[] enableFeatures = new boolean[] { true, /* Gaussian_blur */
    true, /* Sobel_filter */
    true, /* Hessian */
    true, /* Difference_of_gaussians */
    false, /* Membrane_projections */
    false, /* Variance */
    false, /* Mean */
    false, /* Minimum */
    false, /* Maximum */
    false, /* Median */
    false, /* Anisotropic_diffusion */
    false, /* Bilateral */
    false, /* Lipschitz */
    false, /* Kuwahara */
    false, /* Gabor */
    false, /* Derivatives */
    false, /* Laplacian */
    false, /* Structure */
    false, /* Entropy */
    false /* Neighbors */
    };

    public static void main(String[] args) throws IOException {
        runExperiment(null, "randomforest");
        runExperiment(new J48(), "decisiontree");
        runExperiment(new IBk(5), "knn_2");
        runExperiment(new NaiveBayes(), "naivebayes");
        LibSVM svm = new LibSVM();
        svm.setGamma(0.021);
        svm.setDegree(1);
        svm.setEps(0.00001);
        runExperiment(svm, "svm");
    }

    private static FilenameFilter imageFilter = new FilenameFilter() {
        public boolean accept(File dir, String name) {
            return name.endsWith(".jpg") || name.endsWith(".jpeg");
        }
    };

    private static void runExperiment(AbstractClassifier cl, String experimentLabel) throws IOException {
        File trainingFolder = new File(config.getTrainingDirectory());
        ImagePlus ip = new ImagePlus(trainingFolder.getPath() + "/mashup.jpg");
        WekaSegmentation seg = new WekaSegmentation(ip);
        if (cl != null)
            seg.setClassifier(cl);
        prepareFileSystem(experimentLabel);
        trainClassifier(seg, experimentLabel);
        classifyImages(seg, experimentLabel);
    }

    private static void prepareFileSystem(String experimentLabel) throws IOException {
        File outputFolder = new File(config.getOutputDirectory());
        if (outputFolder.exists())
            FileUtils.deleteDirectory(outputFolder);
            outputFolder.mkdir();
        File output = new File(outputFolder + "/" + experimentLabel);
        if (output.exists()) {
            if (output.isDirectory()) {
                FileUtils.deleteDirectory(output);
            } else {
                output.delete();
            }
        }
        output.mkdir();
    }

    private static void trainClassifier(WekaSegmentation seg, String experimentLabel) {
        seg.setNumOfClasses(3);
        seg.setClassLabels(new String[] { "water", "vegetation", "man-made" });
        seg.setEnabledFeatures(enableFeatures);
        addExamples(seg);
        seg.trainClassifier();
        seg.saveClassifier(config.getOutputDirectory() + "/" + experimentLabel + ".model");
    }

    private static void addExamples(WekaSegmentation seg) {
        seg.addExample(0, new Roi(new Rectangle(16, 366, 20, 20)), 1);
        seg.addExample(0, new Roi(new Rectangle(466, 32, 20, 20)), 1);
        seg.addExample(0, new Roi(new Rectangle(1146, 506, 20, 20)), 1);
        seg.addExample(0, new Roi(new Rectangle(1100, 560, 20, 20)), 1);
        seg.addExample(1, new Roi(new Rectangle(490, 366, 20, 20)), 1);
        seg.addExample(1, new Roi(new Rectangle(218, 844, 20, 20)), 1);
        seg.addExample(1, new Roi(new Rectangle(1110, 412, 20, 20)), 1);
        seg.addExample(2, new Roi(new Rectangle(236, 620, 20, 20)), 1);
        seg.addExample(2, new Roi(new Rectangle(500, 612, 20, 20)), 1);
        seg.addExample(2, new Roi(new Rectangle(64, 708, 20, 20)), 1);
    }

    private static void classifyImages(WekaSegmentation seg, String experimentLabel) throws IOException {
        File validationFolder = new File(config.getValidationDirectory());
        File outputFolder = new File(config.getOutputDirectory());
        seg.loadClassifier(config.getOutputDirectory() + "/" + experimentLabel + ".model");
        for (File f : validationFolder.listFiles(imageFilter)) {
            ImagePlus img = new ImagePlus(f.getPath());
            seg.setTrainingImage(img);
            seg.applyClassifier(false);
            String ouputPath = outputFolder + "/" + experimentLabel + "/" + f.getName();
            ImageIO.write(seg.getClassifiedImage().getBufferedImage(), "jpg", new File(ouputPath));
        }
    }

}
