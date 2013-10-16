package br.edu.ufam.icomp.ammd;

import java.awt.image.BufferedImage;

import javax.swing.JFrame;

public class Main {

    public static void main(String[] args) {
        new ManualClassifierFrame().setVisible(true);
    }

}

class ManualClassifierFrame extends JFrame {

    public ManualClassifierFrame() {
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
    }

}

class ARRFDataProvider {

    public static void loadData() {
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