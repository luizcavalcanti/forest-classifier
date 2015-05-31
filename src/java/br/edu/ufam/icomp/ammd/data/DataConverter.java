package br.edu.ufam.icomp.ammd.data;

import java.awt.Color;
import java.awt.image.BufferedImage;

public class DataConverter {

    public static String datToArff(char[][] dat, BufferedImage img) {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < dat.length; i++) {
            for (int j = 0; j < dat[i].length; j++) {
                char cls = dat[i][j];
                if (cls == '\u0000')
                    continue;
                Color c = new Color(img.getRGB(i, j));
                sb.append(c.getRed()).append(',');
                sb.append(c.getGreen()).append(',');
                sb.append(c.getBlue()).append(',');
                sb.append((c.getRed() + c.getGreen() + c.getBlue()) / 3).append(',');
                sb.append(cls);
                sb.append('\n');
            }
        }
        return sb.toString();
    }

    
    public static final String ARFF_HEADER="@RELATION forest \n\n"+
//                                            "@ATTRIBUTE filename STRING\n"+
//                                            "@ATTRIBUTE sourceImage STRING\n"+
                                            "@ATTRIBUTE averageRed NUMERIC\n"+
                                            "@ATTRIBUTE averageGreen NUMERIC\n"+
                                            "@ATTRIBUTE averageBlue NUMERIC\n"+
                                            "@ATTRIBUTE averageGray NUMERIC\n"+
//                                            "@ATTRIBUTE hist0 NUMERIC\n"+
//                                            "@ATTRIBUTE hist1 NUMERIC\n"+
//                                            "@ATTRIBUTE hist2 NUMERIC\n"+
//                                            "@ATTRIBUTE hist3 NUMERIC\n"+
//                                            "@ATTRIBUTE hist4 NUMERIC\n"+
//                                            "@ATTRIBUTE hist5 NUMERIC\n"+
//                                            "@ATTRIBUTE hist6 NUMERIC\n"+
//                                            "@ATTRIBUTE hist7 NUMERIC\n"+
//                                            "@ATTRIBUTE hist8 NUMERIC\n"+
//                                            "@ATTRIBUTE hist9 NUMERIC\n"+
//                                            "@ATTRIBUTE hist10 NUMERIC\n"+
//                                            "@ATTRIBUTE hist11 NUMERIC\n"+
//                                            "@ATTRIBUTE hist12 NUMERIC\n"+
//                                            "@ATTRIBUTE hist13 NUMERIC\n"+
//                                            "@ATTRIBUTE hist14 NUMERIC\n"+
//                                            "@ATTRIBUTE hist15 NUMERIC\n"+
                                            "@ATTRIBUTE class {f,w,r,b}\n\n"+
                                            "@DATA\n";
}
