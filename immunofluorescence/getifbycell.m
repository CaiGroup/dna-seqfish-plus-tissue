function [T_cell, T_avg] = getifbycell(experimentDir, experimentLabel, I, ...
    L, immunokey, binSize, varargin)
% wrapper function to get all the if data from the hybs and channels
%
% return the tables for each cell, and the average of each
%
% date: 3/6/2020

    %% Set up optional Parameters for hybcycleArray
    argsLimit = 2;
    numvarargs = length(varargin);
    if numvarargs > argsLimit
        error('src:getifbycell:TooManyInputs', ...
            'requires at most 2 optional inputs');
    end
    % set defaults for optional inputs
    optargs = {false, []};
    % assign defaults
    optargs(1:numvarargs) = varargin;
    % Default Value of ref image is 1
    [intPerZ, cycleArray] = optargs{:};
    

    %% variables
    numCh = size(I, 2);
    numHybs = size(I, 1);
    cycle = cell(numHybs, numCh);
    if isempty(cycleArray)
        cycleArray = 1:numHybs;
    end
    % make the save directory
    saveDir = fullfile(experimentDir, 'analysis', 'immuno-data', experimentLabel);
    if exist(saveDir, 'dir') ~= 7
        mkdir(saveDir);
    end
    % get the pixel values from each image using segmentation L
    T_hyb = cell(numHybs, numCh);
    T_hyb_avg = cell(numHybs, numCh);
    for c = 1:numCh
        for h = 1:numHybs
            S = getif(I{h,c}, L, binSize);
            [T_hyb{h,c}, T_hyb_avg{h,c}] = if2table(S,binSize,intPerZ);
            cycle{h,c} = cycleArray(h);
        end
    end
    % stack the tables for the hyb and the channel
    T_hyb_Stack = stackrows(T_hyb);
    T_hyb_avg_Stack = stackrows(T_hyb_avg);
    cycle_Stack = stackrows(cycle);
    % organize the Table for each hyb and channel
    [T_cell, T_avg] = iforghyb2cell(T_hyb_Stack, T_hyb_avg_Stack, immunokey, ...
        cycle_Stack);
        
end