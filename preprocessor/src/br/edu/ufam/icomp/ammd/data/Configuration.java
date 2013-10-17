package br.edu.ufam.icomp.ammd.data;

import java.io.FileInputStream;
import java.io.IOException;
import java.util.Properties;

public class Configuration {

	private static Configuration instance;
	
    private String rawDataDirectory;
    private String processedDataDirectory;
    private int chunkWidth;
    private int chunkHeight;

    private Configuration() {
    }

    public static Configuration loadConfiguration() {
    	if (instance==null) {
	        try {
	            Properties prop = loadConfigFile();
	            instance = setupProperties(prop);
	        } catch (IOException e) {
	            System.err.println("Cound not load configuration file: " + e.getMessage());
	            System.exit(-1);
	        }
    	}
    	return instance;
    }

    private static Properties loadConfigFile() throws IOException {
        Properties prop = new Properties();
        FileInputStream fis = new FileInputStream("config.properties");
        prop.load(fis);
        return prop;
    }

    private static Configuration setupProperties(Properties prop) {
        validateProperties(prop);
        Configuration config = new Configuration();
        config.setRawDataDirectory(prop.getProperty("path.raw"));
        config.setProcessedDataDirectory(prop.getProperty("path.processed"));
        config.setChunkWidth(Integer.parseInt(prop.getProperty("chunk.width")));
        config.setChunkHeight(Integer.parseInt(prop.getProperty("chunk.height")));
        return config;
    }

    private static void validateProperties(Properties prop) {
        if (prop.getProperty("path.raw") == null) {
            System.err.println("configuration path.raw is obligatory");
            System.exit(-1);
        }
        if (prop.getProperty("path.processed") == null) {
            System.err.println("configuration path.processed is obligatory");
            System.exit(-1);
        }
        if (prop.getProperty("chunk.width") == null) {
            System.err.println("configuration chunk.width is obligatory");
            System.exit(-1);
        }
        if (prop.getProperty("chunk.height") == null) {
            System.err.println("configuration chunk.height is obligatory");
            System.exit(-1);
        }
    }

    public String getRawDataDirectory() {
        return rawDataDirectory;
    }

    public void setRawDataDirectory(String rawDataDirectory) {
        this.rawDataDirectory = rawDataDirectory;
    }

    public String getProcessedDataDirectory() {
        return processedDataDirectory;
    }

    public void setProcessedDataDirectory(String processedDataDirectory) {
        this.processedDataDirectory = processedDataDirectory;
    }

    public int getChunkWidth() {
        return chunkWidth;
    }

    public void setChunkWidth(int chunkWidth) {
        this.chunkWidth = chunkWidth;
    }

    public int getChunkHeight() {
        return chunkHeight;
    }

    public void setChunkHeight(int chunkHeight) {
        this.chunkHeight = chunkHeight;
    }

}
