package br.edu.ufam.icomp.ammd.data;

import java.awt.image.BufferedImage;
import java.io.File;
import java.io.FileFilter;
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

}
