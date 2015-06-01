package br.edu.ufam.icomp.ammd;

import br.edu.ufam.icomp.ammd.ui.VisualClassifierForm;

public class VisualClassifier {

    public static void main(String[] args) {
        if (args.length != 1) {
            System.err.println("Wrong parameters!");
            System.err.println("Usage: VisualClassifier images-dir");
            System.exit(1);
        }
        new VisualClassifierForm().setVisible(true);
    }

}