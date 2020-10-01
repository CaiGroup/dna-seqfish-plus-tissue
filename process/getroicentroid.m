function [centroid, xbox, ybox] = getroicentroid(roiPath)
% script for getting center rois of teh slide explorer for each field of
% view
%
% Dependencies:
% need ReadJROI.m and selfseg.m
%
% Date: 5/16/2019

    % need PathName of ROIs
    vertex = selfsegzip(roiPath);
    numROI = length(vertex);
    centroid = cell(1, numROI);
    xbox = cell(1, numROI);
    ybox = cell(1, numROI);

    for i = 1:numROI
        xbox{i} = vertex(i).x; % get x value
        ybox{i} = vertex(i).y; % get y value
        centroid{i} = [mean(xbox{i}) mean(ybox{i})];
    end
  
end