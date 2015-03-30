function srm_experiment(imagesPath)
    images  = dir([imagesPath '*.jpg']);
    for i=1:length(images)
        disp(['processing ' images(i).name]);
        image=double(imread([imagesPath images(i).name]));
        % Choose different scales
        % Segmentation parameter Q; Q small few segments, Q large may segments
        Qlevels=2.^(8:-1:0);
        % This creates the following list of Qs [256 128 64 32 16 8 4 2 1]
        % Creates 9 segmentations
        [mapList,imseg]=srm(image,Qlevels);
        % And plot them
        generate_seg_file(imseg, mapList, strcat('out/',images(i).name));
    end
    exit;
end


function generate_seg_file(imseg,mapList,filename)
    precision=numel(mapList);
    Iedge=zeros([size(imseg{1},1),size(imseg{1},2)]);

    quick_I1 = cell(precision,1);
    quick_I2 = cell(precision,1);

    for k=1:precision
        map=reshape(mapList{k},size(Iedge));
        quick_I1{k} = srm_randimseg(map) ;
        quick_I2{k} = imseg{k} ;
        figure(101);vl_tightsubplot(precision, k) ;
        imagesc(quick_I1{k});axis off;
        figure(102);vl_tightsubplot(precision, k) ;
        imagesc(uint8(quick_I2{k}));axis off;
        borders = srm_getborders(map);
        Iedge(borders) = Iedge(borders) + 1;
    end


    Iedge=precision-Iedge;
    imwrite(Iedge, filename);
end