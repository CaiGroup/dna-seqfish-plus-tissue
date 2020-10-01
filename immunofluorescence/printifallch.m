function [] = printifallch(saveDir, T_cell, T_avg, position, varargin)
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
    numChannels = length(T_cell);
    numCells = size(T_cell{1},1);
    for ch = 1:numChannels
        
        % output avg as csv
        csvPath = fullfile(saveDir, [expName '-sumData-ch' ...
                num2str(ch) 'pos' num2str(position) '.csv']);
        writetable(T_avg{ch}, csvPath);
        
        for c = 1:numCells
            % output as csv
            csvPath = fullfile(saveDir, [expName '-data-ch' ...
                num2str(ch) '-pos' num2str(position) '-cell' num2str(c) '.csv']);
            writetable(T_cell{ch}{c}, csvPath);
            
        end
    end
end