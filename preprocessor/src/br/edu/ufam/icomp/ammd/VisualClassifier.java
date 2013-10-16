package br.edu.ufam.icomp.ammd;

import java.awt.image.BufferedImage;

import javax.swing.JFrame;

public class VisualClassifier {

    public static void main(String[] args) {
        if (args.length != 2) {
            System.err.println("Parameters needed: arff-file config-file");
        }
        String arffFilePath = args[0];
        ARFFDataProvider.loadData(arffFilePath);
        new ManualClassifierFrame().setVisible(true);
    }

}

class ManualClassifierFrame extends JFrame {

	private static final long serialVersionUID = 1L;

	public ManualClassifierFrame() {
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
    }

}

class ARFFDataProvider {

    public static void loadData(String arffFilePath) {
    }

    public static boolean hasUnclassifiedData() {
        return false;
    }

    public static BufferedImage getNextSample() {
        return null;
    }

    public static void setSampleClassification() {
    }

}

// class DataEntry {

//     private String filename;
//     private String class;

//     public void setFilename(String value) {
//         filename = value;
//     }

//     public String getFilename() {
//         return filename;
//     }

//     public void setClass() {

//     }

// }