package br.edu.ufam.icomp.ammd.data;

import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;

import javax.imageio.ImageIO;

import br.edu.ufam.icomp.ammd.Configuration;

public class ARFFDataProvider {

	private static final Configuration config = Configuration.loadConfiguration();

	private static List<String> data;
	private static int currentIndex = -1;
	
    public static void loadData(String arffFilePath) throws IOException {
    	List<String> lines = Files.readAllLines(Paths.get(arffFilePath), StandardCharsets.UTF_8);
    	data = new ArrayList<String>();
    	for (String line : lines) {
    		if (line.length()>0 && !line.startsWith("@")) {
    			data.add(line);
    		}
    	}
    }

    public static boolean hasUnclassifiedData() {
    	for (String d : data) {
    		if (d.endsWith(",")) {
    			return true;
    		}
    	}
        return false;
    }

    public static BufferedImage getNextSample() {
    	if (data.size()>currentIndex+1) {
    		try {
				return loadImageFromData(data.get(++currentIndex));
			} catch (IOException e) {
				e.printStackTrace();
			}
    	}
        return null;
    }
    
    private static BufferedImage loadImageFromData(String dataLine) throws IOException {
    	String[] lineData = dataLine.split(",");
    	return ImageIO.read(new File(config.getProcessedDataDirectory()+"/"+lineData[0]));
    }

    public static void setSampleClassification(String classification) {
    	String content = data.get(currentIndex);
    	data.remove(currentIndex);
    	data.add(currentIndex, content+classification);
    }

}