function [] = savech3images(images, saveDir, position)
% saves the cell array of images into individual images for channel 3, that 
% will be trained using ilastik
%
% Date: 10/28/2019

% what number is the X chromosome?

    numImages = length(images);
    for i = 1:numImages
        fileName = ['binarymaskch3-pos' num2str(position) '-chr' num2str(i) '.tif'];
        savePath = fullfile(saveDir, fileName);
        saveastiff(images{i}, savePath);
    end

end