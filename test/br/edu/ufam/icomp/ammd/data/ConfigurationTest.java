package br.edu.ufam.icomp.ammd.data;

import org.junit.Assert;
import org.junit.Test;

public class ConfigurationTest {

    private Configuration getInstance() {
        Configuration conf = Configuration.loadConfiguration();
        return conf;
    }

    @Test
    public void loadConfiguration() {
        Configuration conf = getInstance();
        Assert.assertNotNull(conf);
        Assert.assertTrue(conf.getChunkHeight() > 0);
        Assert.assertTrue(conf.getChunkWidth() > 0);
        Assert.assertNotNull(conf.getProcessedDataDirectory());
        Assert.assertTrue(conf.getProcessedDataDirectory().length() > 0);
        Assert.assertNotNull(conf.getRawDataDirectory());
        Assert.assertTrue(conf.getRawDataDirectory().length() > 0);
    }

}
