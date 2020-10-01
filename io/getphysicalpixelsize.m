function [physicalsizeX, physicalsizeY] = getphysicalpixelsize(imagePath, position)
% function to get the pixel size of the image in um
%
% Dependencies: bfmatlab package
% 
% Some images will have the metadata for all of the positions and others
% will not.
%
% Date: 5/16/2019

    %{
    EXAMPLE
    use bfmatlab to get teh 
    
    width: 361.2694 um
    height:
    depth: 19 um
    resolution 5.6689 pixels per um
    voxel size: 0.1764x0.1764um
    
    %}

    % Test thes lines of code for the Anderson experiment
    %imagePath = 'K:\Anderson\Aggression\HybCycle_0\MMStack_Pos1.ome.tif';
    %position = 1;


    r = bfGetReader(imagePath);
    numSeries = r.getSeriesCount();
    if numSeries > 1
        r.setSeries(position)
    else
        r.setSeries(0);
    end
    % add this to the grabimseries function
    omeMeta = r.getMetadataStore();
    physicalsizeX = omeMeta.getPixelsPhysicalSizeX(0).value(ome.units.UNITS.MICROMETER).doubleValue();
    physicalsizeY = omeMeta.getPixelsPhysicalSizeY(0).value(ome.units.UNITS.MICROMETER).doubleValue();

end