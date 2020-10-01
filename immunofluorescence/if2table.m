function [T, T_int] = if2table(S, binSize, varargin)
% outputs a table of each IF pixel from a structure using getif.m and an
% average of intensities table.
%
% S is the structure
% csvPath is the path to save
%
% added option
% 
% date: 2/21/2019


    %% Set up optional Parameters
    argsLimit = 1;
    numvarargs = length(varargin);
    if numvarargs > argsLimit
        error('seqfish:if2table:TooManyInputs', ...
            'requires at most 1 optional inputs');
    end
    % set defaults for optional inputs
    optargs = {false};
    optargs(1:numvarargs) = varargin;
    [avgPerZ] = optargs{:};
    
    
    
    %% variables for T_int
    cell_ID = [];
    max_int = S.MaxIntensity;
    min_int = S.MinIntensity;
    % if cell set null to 0
    if iscell(max_int)
        indmax = cellfun('isempty', min_int);
        indmin = cellfun('isempty', min_int);
        max_int(indmax) = {uint16(0)};
        min_int(indmin) = {uint16(0)};
        max_int = cell2mat(max_int);
        min_int = cell2mat(min_int);
    end
    
    mean_int = S.MeanIntensity;
    %indmean = isnan(mean_int);
    %mean_int(indmean) = {uint16(0)};
    volume = S.Volume;
    centroid_x = S.Centroid(:,1);
    centroid_y = S.Centroid(:,2);
    centroid_z = S.Centroid(:,3);
    % variables for T
    cellID = [];
    x = [];
    y = [];
    z = [];
    int = [];
    sum_int = [];
    z_int = [];
    
    % for each cell, get avg int
    numCells = size(S.VoxelList, 1);
    % numZ for all cells
    maxZ = cell2mat(cellfun(@max, S.VoxelList, 'UniformOutput', false));
    numZ = max(maxZ(:,3));
    fprintf('Cell: ');
    for c = 1:numCells
        fprintf(' %.0f', c);
        cell_ID = cat(1, cell_ID, c);
        x = cat(1, x, S.VoxelList{c}(:,1).*binSize);
        y = cat(1, y, S.VoxelList{c}(:,2).*binSize);
        z = cat(1, z, S.VoxelList{c}(:,3));
        int = cat(1, int, S.VoxelValues{c});
        numPixels = size(S.VoxelList{c}, 1);
        cell_mat = ones(numPixels, 1) * c;
        cellID = cat(1, cellID, cell_mat); 
        sum_int = cat(1, sum_int, sum(S.VoxelValues{c}));
        if avgPerZ
            z_sum = [];
            for i = 1:numZ
                ind = find(S.VoxelList{c}(:,3) == i);
                z_sum = cat(2, z_sum, sum(S.VoxelValues{c}(ind,:)));  
            end
            z_int = cat(1, z_int, z_sum);
        end
        
    end
    fprintf('\n');
    
    T = table(cellID, x, y, z, int);
    % remove zeros
    T(int == 0,:) = [];
    
    cellID = cell_ID;
    T_int = table(cellID, sum_int, mean_int, centroid_x, centroid_y, centroid_z, ...
        volume, max_int, min_int);
    if avgPerZ
        T_per_z = array2table(z_int);
        T_int = cat(2, T_int, T_per_z);
    end

end