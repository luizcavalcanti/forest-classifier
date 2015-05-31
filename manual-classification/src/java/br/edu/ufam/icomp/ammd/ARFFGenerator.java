package br.edu.ufam.icomp.ammd;

import java.awt.image.BufferedImage;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

import br.edu.ufam.icomp.ammd.data.Configuration;
import br.edu.ufam.icomp.ammd.data.DataConverter;
import br.edu.ufam.icomp.ammd.data.ImageDataProvider;

public class ARFFGenerator {

    public static void main(String[] args) throws IOException {
        if (args.length != 1) {
            System.err.println("Usage: ARFFGenerator <output-arff-file>");
            System.exit(1);
        }
        String outputFile = args[0];
        File f = new File(outputFile);
        if (f.exists()) {
            f.delete();
        }
        f.createNewFile();
        FileWriter fw = new FileWriter(f);

        Configuration conf = Configuration.loadConfiguration();
        ImageDataProvider provider = new ImageDataProvider(conf.getRawDataDirectory(), conf.getProcessedDataDirectory());
        BufferedImage currentImage = provider.getNextImage();
        fw.write(DataConverter.ARFF_HEADER);
        while (currentImage != null) {
            fw.write(DataConverter.datToArff(provider.loadCurrentData(), currentImage));
            fw.flush();
            currentImage = provider.getNextImage();
        }
        fw.close();
    }

}
