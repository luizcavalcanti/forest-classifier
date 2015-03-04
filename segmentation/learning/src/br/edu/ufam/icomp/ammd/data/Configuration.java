package br.edu.ufam.icomp.ammd.data;

import java.io.FileInputStream;
import java.io.IOException;
import java.util.Properties;

public class Configuration {

    private static Configuration instance;

    private String trainingDirectory;
    private String validationDirectory;
    private String outputDirectory;

    private Configuration() {
    }

    public static Configuration loadConfiguration() {
        if (instance == null) {
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
        Configuration config = new Configuration();
        config.setTrainingDirectory(prop.getProperty("path.training"));
        config.setValidationDirectory(prop.getProperty("path.validation"));
        config.setOutputDirectory(prop.getProperty("path.output"));
        return config;
    }

    public String getTrainingDirectory() {
        return trainingDirectory;
    }

    public void setTrainingDirectory(String trainingDirectory) {
        this.trainingDirectory = trainingDirectory;
    }

    public String getValidationDirectory() {
        return validationDirectory;
    }

    public void setValidationDirectory(String validationDirectory) {
        this.validationDirectory = validationDirectory;
    }

    public String getOutputDirectory() {
        return outputDirectory;
    }

    public void setOutputDirectory(String outputDirectory) {
        this.outputDirectory = outputDirectory;
    }

}
