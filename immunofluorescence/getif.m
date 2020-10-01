function S = getif(V, L, binSize)
% returns structure with IF data
%
% V is the grayscale image
% L is the labeled image
% binSize is the size to bin the image
% date: 2/21/2019

    factor = 1 / binSize;
    % bin the image and the labeled image
    VB = imresize(V, factor, 'bilinear');
    LB = imresize(L, factor, 'nearest');
    sizeZ = size(V,3);
    if sizeZ > 1
        S = regionprops3(LB, VB, 'VoxelList', 'VoxelValues', 'MaxIntensity', ...
            'MinIntensity', 'MeanIntensity', 'Volume', 'Centroid');
    elseif sizeZ == 1
        S = regionprops(LB, VB, 'PixelList', 'PixelValues', 'MaxIntensity', ...
        'MinIntensity', 'MeanIntensity', 'Area', 'Centroid');
    end

end