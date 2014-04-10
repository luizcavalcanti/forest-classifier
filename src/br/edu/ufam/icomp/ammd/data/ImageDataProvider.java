package br.edu.ufam.icomp.ammd.data;

import java.awt.image.BufferedImage;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileFilter;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;

import javax.imageio.ImageIO;

public class ImageDataProvider {

    private String dataDir;
    private File[] imageList;
    private int currentIndex = -1;

    public ImageDataProvider(String imagesDir) {
        dataDir = imagesDir;
        loadImageList();
    }

    public BufferedImage getNextImage() throws IOException {
        if (currentIndex + 1 >= imageList.length)
            return null;
        return ImageIO.read(imageList[++currentIndex]);
    }

    public BufferedImage getPreviousImage() throws IOException {
        if (currentIndex == 0)
            return null;
        return ImageIO.read(imageList[--currentIndex]);
    }

    public int getImageCount() {
        return imageList.length;
    }

    private void loadImageList() {
        File rawDir = new File(dataDir);
        imageList = rawDir.listFiles(new ImageFileFilter());
    }

    class ImageFileFilter implements FileFilter {
        @Override
        public boolean accept(File pathname) {
            return pathname.getName().endsWith(".jpg");
        }
    }

    public void saveData(String[][] classesData) throws IOException {
        File f = new File(imageList[currentIndex].getAbsolutePath() + ".dat");
        if (f.exists()) {
            f.delete();
        }
        f.createNewFile();
        FileWriter fw = new FileWriter(f);
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < classesData.length; i++) {
            sb.append('[');
            for (int j = 0; j < classesData[i].length; j++) {
                if (j != 0) {
                    sb.append(',');
                }
                String data = classesData[i][j];
                if (data != null) {
                    sb.append(data);
                }
            }
            sb.append(']');
        }
        fw.write(sb.toString());
        fw.close();
    }

    public String[][] loadData(int width, int height) throws IOException {
        String[][] data = new String[width][height];
        File f = new File(imageList[currentIndex].getAbsolutePath() + ".dat");
        if (f.exists()) {
            BufferedReader br = new BufferedReader(new FileReader(f));
            StringBuilder sb = new StringBuilder();
            String line = null;
            while ((line = br.readLine()) != null) {
                sb.append(line);
            }
            br.close();
            String fileData = sb.toString();
            int i = 0;
            int j = 0;
            String[] rows = fileData.substring(1).split("\\[");
            for (String row : rows) {
                String[] items = row.split(",");
                for (String item : items) {
                    if (item.trim().length() > 0) {
                        data[i][j] = item;
                    }
                    j++;
                }
                i++;
                j = 0;
            }
        }
        return data;
    }
}
