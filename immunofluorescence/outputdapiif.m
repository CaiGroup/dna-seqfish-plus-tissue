function [T, T_avg] = outputdapiif(saveDir, experimentDir, binSize, chaTform, varargin)
% output a folder of if
%
% assumes dapi folder is 'HybCycle_0' in the experimentDir
%
% date: 2/27/2020

    %% Set up optional Parameters for the reference folder
    argsLimit = 1;
    numvarargs = length(varargin);
    if numvarargs > argsLimit
        error('src:outputdapiif:TooManyInputs', ...
            'requires at most 1 optional inputs');
    end
    optargs = {fullfile(experimentDir, 'HybCycle_0')}; % options 'select' or 'match'
    optargs(1:numvarargs) = varargin;
    [imDir] = optargs{:};
    
    
    %% Run the function
    segDir = fullfile(experimentDir, 'segmentation');
    [T, T_avg] = getdapiif(imDir, segDir, binSize, chaTform);
    printifbyfov(saveDir, T, T_avg, 'dapi');

end


