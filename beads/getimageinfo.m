function [channelNumber, zsliceNumber] = getimageinfo(imagePath, strCompare)
% function gets the number of channels for a given image
%
% Inputs: imagePath and string comparison to grab image
%
% Dependencies: bfmatlab package
%
% Author: Nico Pierson
% Date: 4/11/2019

    %% Get imagefile with bfopen and metadata
    imageFileName = getfile(imagePath, strCompare, 'match');
    
    % Use bfopen to get images with OMEmetadata
    data = bfopen(imageFileName);
    % get metadata for fileorder
    omeMeta = data{1, 4};
    % number of channels
    channelNumber = omeMeta.getChannelCount(0);
    fprintf('Image has %.0f channels\n', channelNumber);
    % number of z-slices
    zsliceNumber = omeMeta.getPixelsSizeZ(0).getValue();
    fprintf('Image has %.0f zslices\n', zsliceNumber);


end