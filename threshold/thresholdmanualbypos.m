function [threshold, points, intensity, pointsSuperRes, sigma] = ...
    thresholdmanualbypos(experimentDir, position, typedots, images, varargin)
% threshold for sequential imaging for each channel
%
% Outputs: threshold, points, intensity, pointsSuperRes, and sigma in hyb
% x channel cell array or matrix(threshold)
%
% Dependencies: ImageJ (mij.jar file in Fiji.app/scripts path) for
% despeckle option
%
% Author: Nico Pierson
% Date: 8/16/2019
% nicogpt@caltech.edu


    %% Set up optional Parameters
    numvarargs = length(varargin);
    argsLimit = 5;
    if numvarargs > argsLimit
        error('myfuns:thresholdmanual:TooManyInputs', ...
            'requires at most 5 optional inputs');
    end
    % set defaults for optional inputs
    optargs = {false, false, false, [], []}; 
    optargs(1:numvarargs) = varargin;
    % Place optional args in memorable variable names
    [filtersigma, despeckle, tophatfilter, folder, rawImage] = optargs{:};


    %% Set up variables
    options.typedetectdots = typedots; % 'log', 'log2d', 'exons', or 'introns'
    options.processimages = tophatfilter; % no preprocessing
    options.savefigs = false; % save figures
    options.pathsavedots = '';
    options.threshold = 'choose';
    options.expdir = experimentDir;
    options.rawimage = rawImage;
    if ~isempty(folder)
        options.folderLabel = folder;
    end

    
    %% despeckle if option is on
    if despeckle
        images = despeckleall(images, experimentDir);
    end

    
    %% manual threshold
    fprintf('Choose Threshold for pos: %.0f\n', position);
    [pointsSuperRes, points, intensity, threshold, sigma] = manualthresholdall(images, filtersigma, options);



end