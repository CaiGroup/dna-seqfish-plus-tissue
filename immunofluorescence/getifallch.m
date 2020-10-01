function [T_hyb, T_hyb_avg] = getifallch(I,segPath,binSize)
% function gets all the if data for each channel
%
% I - processed images
% segPath - path of segmentation vertices (RoiSet.zip) or masks (.h5)
% binSize - bin size to downsample image (i.e. 2 would bin image 2x2x1)
%
% date: 2/21/2020
    
    numHybs = size(I, 1);
    numChannels = size(I,2);
    numZ = size(I{1},3);
    L = getlabel(segPath, numZ);
    T_hyb = cell(numHybs, numChannels);
    T_hyb_avg = cell(numHybs, numChannels);
    for c = 1:numChannels
        for h = 1:numHybs
            im = I{h,c};
            S = getif(im, L, binSize);
            [T_hyb{h,c}, T_hyb_avg{h,c}] = if2table(S,binSize);     
        end
    end

end