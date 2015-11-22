function gpb_experiment(imagesPath)
    setenv('DYLD_LIBRARY_PATH', [ getenv('DYLD_LIBRARY_PATH') ':/usr/local/lib' ])
    addpath lib;

    outDir = '../out';
    mkdir(outDir);
    D = dir([imagesPath '*.jpg']);

    for i=1:length(D)
        imgFile=fullfile(imagesPath,D(i).name);
        outFile = fullfile(outDir,[D(i).name(1:end-4) '.ppm']);

        if (exist(outFile, 'file') ~= 2)
            disp(D(i).name);
            gPb_orient = globalPb(imgFile, '');

            ucm2 = contours2ucm(gPb_orient, 'doubleSize');
            ucm = ucm2(3:2:end, 3:2:end);

            k = 0.4;
            bdry = (ucm >= k);
            imwrite(bdry, outFile, 'ppm');
        end
    end
    exit;
end