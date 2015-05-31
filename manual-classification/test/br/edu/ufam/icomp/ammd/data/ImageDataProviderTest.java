package br.edu.ufam.icomp.ammd.data;

import java.io.IOException;

import org.junit.Assert;
import org.junit.Test;

public class ImageDataProviderTest {

    @Test
    public void getImageCount() {
        Configuration conf = Configuration.loadConfiguration();
        ImageDataProvider dp = new ImageDataProvider(conf.getRawDataDirectory());
        Assert.assertTrue(dp.getImageCount() >= 0);
    }

    @Test
    public void getNextImage_toTheEnd() {
        Configuration conf = Configuration.loadConfiguration();
        ImageDataProvider dp = new ImageDataProvider(conf.getRawDataDirectory());
        int imgs = dp.getImageCount();
        try {
            for (int i = 0; i < imgs; i++) {
                Assert.assertNotNull(dp.getNextImage());
            }
        } catch (IOException e) {
            Assert.fail(e.getMessage());
        }
    }

    @Test
    public void getNextImage_offByOne() {
        Configuration conf = Configuration.loadConfiguration();
        ImageDataProvider dp = new ImageDataProvider(conf.getRawDataDirectory());
        int imgs = dp.getImageCount();
        try {
            for (int i = 0; i < imgs; i++) {
                Assert.assertNotNull(dp.getNextImage());
            }
            Assert.assertNull(dp.getNextImage());
        } catch (IOException e) {
            Assert.fail(e.getMessage());
        }
    }

}
