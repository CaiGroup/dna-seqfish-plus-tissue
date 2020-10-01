function [] = printifbyfov(saveDir, T, T_avg, varargin)
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
    optargs = {'hyb'};
    % assign defaults
    optargs(1:numvarargs) = varargin;
    % Default Value of ref image is 1
    [expName] = optargs{:};

    
    %% start the function
    numChannels = size(T,2);
    numPos = size(T,1);
    for ch = 1:numChannels
        for p = 1:numPos
            
            if ~isempty(T{p,ch})
                % output avg as csv
                csvPath = fullfile(saveDir, ['if-' expName '-avg-data-pos' ...
                    num2str(p-1) '-ch' num2str(ch) '.csv']);
                writetable(T_avg{p,ch}, csvPath);


                % output as csv
                csvPath = fullfile(saveDir, ['if-' expName '-data-pos' ...
                    num2str(p-1) '-ch' num2str(ch) '.csv']);
                writetable(T{p,ch}, csvPath);
            end
            
        end
    end
end