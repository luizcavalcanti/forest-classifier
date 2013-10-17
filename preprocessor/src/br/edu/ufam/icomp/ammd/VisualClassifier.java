package br.edu.ufam.icomp.ammd;

import java.io.IOException;

import br.edu.ufam.icomp.ammd.data.ARFFDataProvider;
import br.edu.ufam.icomp.ammd.ui.VisualClassifierFrame;

public class VisualClassifier {

    private static final String ARFF_FILENAME = "forest.arff";

	public static void main(String[] args) {
        try {
			ARFFDataProvider.loadData(ARFF_FILENAME);
			new VisualClassifierFrame().setVisible(true);
		} catch (IOException e) {
			e.printStackTrace();
		}
    }

}

// class DataEntry {

//     private String filename;
//     private String class;

//     public void setFilename(String value) {
//         filename = value;
//     }

//     public String getFilename() {
//         return filename;
//     }

//     public void setClass() {

//     }

// }