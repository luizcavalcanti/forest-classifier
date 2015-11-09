% segment images with heavy texture
% This code segments gray level images

tic
clear

ws=25; % window size for computing features
segn=0; % number of segment. Determined automatically if set to 0. 

I=imread('./TestImg/M1.pgm'); 

figure(1), imshow(I,[]);
title('Input Image')
pause(.1)

% filters 
f1=1;
f2=fspecial('log',[3,3],.5);
f3=fspecial('log',[5,5],1);
f4=gabor_fn(1.5,pi/2);
f5=gabor_fn(1.5,0);
f6=gabor_fn(1.5,pi/4);
f7=gabor_fn(1.5,-pi/4);
f8=gabor_fn(2.5,pi/2);
f9=gabor_fn(2.5,0);
f10=gabor_fn(2.5,pi/4);
f11=gabor_fn(2.5,-pi/4);

Ig=subImg(I,f1,f2,f3,f4,f5,f6,f7,...
    f8,f9,f10,f11); % Change filters to see the effect
                    % For images with few regions, two or three filters can 
                    % work sufficiently well.
                                                 

[res]=FctSeg_tx(Ig,ws,segn,1);

% res_cc=RmSmRg(int32(res),100); % Remove small regions (optional)

figure(2), imshow(res,[]);
title('Segmentation result')

toc

