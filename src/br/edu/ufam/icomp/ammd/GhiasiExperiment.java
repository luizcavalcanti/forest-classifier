package br.edu.ufam.icomp.ammd;

import br.edu.ufam.icomp.ammd.data.Configuration;
import ij.ImagePlus;
import sc.fiji.CMP_BIA.segmentation.structures.Labelling2D;
import sc.fiji.CMP_BIA.segmentation.superpixels.jSLIC;

public class GhiasiExperiment {

    private static final Configuration config = Configuration.loadConfiguration();

    public static void main(String[] args) {
        createTrainingData();
        ImagePlus im = new ImagePlus(config.getTrainingDirectory() + "/00001.jpg");
        createSuperpixels(im);
    }

    private static void createTrainingData() {
        ImagePlus im = new ImagePlus(config.getTrainingDirectory() + "/00001.jpg");
        
    }

    private static void createSuperpixels(ImagePlus im) {
        jSLIC slic = new jSLIC(im);
        slic.process(30, 0.2f);
        Labelling2D segmentation = slic.getSegmentation();
        segmentation.exportToFile("superpixel.txt");
    }
    
    

}
