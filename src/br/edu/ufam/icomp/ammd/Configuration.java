package br.edu.ufam.icomp.ammd;

public class Configuration {

    private String rawDataDirectory;
    private String processedDataDirectory;
    private int chunkWidth;
    private int chunkHeight;

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
