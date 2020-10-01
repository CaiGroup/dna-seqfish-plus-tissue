function [] = printifallhyb(saveDir, T_cell, T_avg, position, varargin)
% helper function to print all if data from iforghyb2cell.m output for each
% position
%
% date: 2/21/2020

    %% Set up optional Parameters
    argsLimit = 1;
    numvarargs = length(varargin);
    if numvarargs > argsLimit
        error('src:printifallch:TooManyInputs', ...
            'requires at most 1 optional inputs');
    end
    % set defaults for optional inputs
    optargs = {'if-hyb'};
    % assign defaults
    optargs(1:numvarargs) = varargin;
    % Default Value of ref image is 1
    [expName] = optargs{:};

    
    %% start the function
    numCells = size(T_cell,1);

    % output avg as csv
    csvPath = fullfile(saveDir, [expName '-avg-data-pos' num2str(position) '.csv']);
    writetable(T_avg, csvPath);

    for c = 1:numCells
        % output as csv
        csvPath = fullfile(saveDir, [expName '-data-pos' num2str(position) '-cell' num2str(c) '.csv']);
        writetable(T_cell{c}, csvPath);

    end
end