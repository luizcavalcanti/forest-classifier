function gpb_experiment(imagesPath)
    setenv('DYLD_LIBRARY_PATH', [ getenv('DYLD_LIBRARY_PATH') ':/usr/local/lib' ])
    addpath lib;
    % for i=1:length(images)
    % clear all;close all;clc;
    outDir = '../out';
    mkdir(outDir);
    D = dir([imagesPath '*.jpg']);%dir(fullfile(imagesPath,'*.jpg'));

    % tic;
    for i=1:length(D)
        outFile = fullfile(outDir,[D(i).name(1:end-4) '.mat']);
        if exist(outFile,'file'), continue; end
        imgFile=fullfile(imagesPath,D(i).name);
        im2ucm(imgFile, outFile);
    end
    % toc;
end