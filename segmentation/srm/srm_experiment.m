function srm_experiment(imagesPath)
    images  = dir([imagesPath '*.jpg']);
    for i=1:length(images)
        image_name = images(i).name;
        disp(['processing ' image_name]);
        image=double(imread([imagesPath '/' image_name]));
        % Choose different scales
        % Segmentation parameter Q; Q small few segments, Q large may segments
        Qlevels=2.^(8:-1:2);
        % This creates the following list of Qs [256 128 64 32 16 8 4 2 1]
        % Creates 9 segmentations
        [mapList,~]=srm(image,Qlevels);
        % And plot them
        output_name = [image_name(1:length(image_name)-3) 'ppm'];
        generate_seg_file(mapList, strcat('out/', output_name));
    end
    exit;
end

function generate_seg_file(mapList, file_color)
    precision=numel(mapList);
    color_image = srm_randimseg(mapList{precision});
    imwrite(color_image, file_color, 'ppm');
end