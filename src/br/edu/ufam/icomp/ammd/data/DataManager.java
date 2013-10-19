package br.edu.ufam.icomp.ammd.data;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

/**
    Plain stupid ARFF file persistence helper
*/
public class DataManager {

    private static StringBuffer arffBuffer;

    public static void createARFFFile() {
        arffBuffer = new StringBuffer();
        arffBuffer.append("@RELATION forest\n");
        arffBuffer.append('\n');
        arffBuffer.append("@ATTRIBUTE filename STRING\n");
        arffBuffer.append("@ATTRIBUTE sourceImage STRING\n");
        arffBuffer.append("@ATTRIBUTE averageRed NUMERIC\n");
        arffBuffer.append("@ATTRIBUTE averageGreen NUMERIC\n");
        arffBuffer.append("@ATTRIBUTE averageBlue NUMERIC\n");
        arffBuffer.append("@ATTRIBUTE class {Forest,Non-forest}\n");
        arffBuffer.append('\n');
        arffBuffer.append("@DATA\n");
    }

    public static void appendARFFData(String data) {
        arffBuffer.append(data);
        arffBuffer.append('\n');
    }

    public static void persistARFFFile() {
        try {
            File f = new File("forest.arff");
            FileWriter fw = new FileWriter(f.getAbsoluteFile());
            BufferedWriter bw = new BufferedWriter(fw);
            bw.write(arffBuffer.toString());
            bw.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

}