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

    private String imagesDir;
    private String datDir;
    private File[] imageList;
    private int currentIndex = -1;

    public ImageDataProvider(String imagesDir, String datDir) {
        this.imagesDir = imagesDir;
        this.datDir = datDir;
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
        File rawDir = new File(imagesDir);
        imageList = rawDir.listFiles(new ImageFileFilter());
    }

    class ImageFileFilter implements FileFilter {
        @Override
        public boolean accept(File pathname) {
            return pathname.getName().endsWith(".jpg");
        }
    }

    public void saveData(char[][] classesData) throws IOException {
        String filename = imageList[currentIndex].getName();
        File f = new File(datDir + "/" + filename.substring(0, filename.length()-4) + ".dat");
        if (f.exists()) {
            f.delete();
        }
        f.createNewFile();
        FileWriter fw = new FileWriter(f);
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < classesData.length; i++) {
            for (int j = 0; j < classesData[i].length; j++) {
                char data = classesData[i][j];
                if (data == '\u0000') {
                    sb.append('0');
                } else {
                    sb.append(data);
                }
            }
            if (i != classesData.length - 1)
                sb.append('|');
        }
        fw.write(sb.toString());
        fw.close();
    }

    public char[][] loadCurrentData() throws IOException {
        BufferedImage img = ImageIO.read(imageList[currentIndex]);
        char[][] data = new char[img.getWidth()][img.getHeight()];
        String filename = imageList[currentIndex].getName();
        File f = new File(datDir + "/" + filename.substring(0, filename.length()-4) + ".dat");
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
            String[] rows = fileData.split("[|]");
            for (String row : rows) {
                if (row.trim().length() == 0)
                    continue;
                row = row.trim();
                for (int k=0; k<row.length(); k++) {
                    char cls = row.charAt(k);
                    if (cls != '\u0000' && cls != '0') {
                        data[i][j] = cls;
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
