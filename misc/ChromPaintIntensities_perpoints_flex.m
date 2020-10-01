function points_paints = ChromPaintIntensities_perpoints_flex(experimentDir, experimentName, experimentLabel, points, I, position, varargin)
% This works for ch3 analysis for DNA seqFISH+ experiments.
% Changed format to pass variables from seqfish pipeline.
% points: (1:60,1) hyb1-60 points (already aligned and corrected for shifts)
% I: (1:20,1) hyb61-80 of ch3 for chromosome paint. (already aligned and corrected for shifts)
%
% Author: Yodai Takei
% Date updated: 01/13/20
% Email: ytakei@caltech.edu


% Set up optional Parameters
numvarargs = length(varargin);
argsLimit = 2;
if numvarargs > argsLimit
    error('myfuns:preprocessimages:TooManyInputs', ...
        'requires at most 2 optional inputs');
end
% set defaults for optional inputs
optargs = {1,[experimentDir, '\segmentation\pos' num2str(position) '\RoiSet.zip']}; 
optargs(1:numvarargs) = varargin;
% Place optional args in memorable variable names
[ch, segmentfilename] = optargs{:};

%vertex = selfsegzip([experimentDir, '\segmentation\pos' num2str(position) '\RoiSet.zip']);
vertex = selfsegzip(segmentfilename);
numCells = length(vertex);
points_paints = points;
x_max = size(I{1},2);
y_max = size(I{1},1);
z_max = size(I{1},3);
num_hyb = size(points,1);
num_paint = size(I,1);
indices = [];

for hyb = 1:num_hyb
    idx = 1;
    for dot = 1:length(points{hyb,1}.channels)
        location = round(points{hyb,1}.channels(dot,:));
        if (points{hyb,1}.intensity(dot)~=0)&&(1<=location(2))&&(location(2)<=x_max)&&(1<=location(1))&&(location(1)<=y_max)&&(1<=location(3))&&(location(3)<=z_max) % to remove dots outside the images.
            for i = 1:num_paint
                points_paints{hyb,1}.intensitypaint(dot,i) = I{i,1}(location(2),location(1),location(3));
            end
        else
            indices(idx) = dot;
            idx = idx+1;
            for i = 1:20
                points_paints{hyb,1}.intensitypaint(dot,i) = 0; % in case for last rows
            end
        end
        % initial fiducial intensity
        %points_paints{hyb,1}(3).intensitypaint(dot,21) = I2{1,3}(location(2),location(1),location(3));
        % final fiducial intensity
        %points_paints{hyb,1}(3).intensitypaint(dot,22) = I2{2,3}(location(2),location(1),location(3));
    end
    
    
    % filter out problematic dots above.
    
    points_paints{hyb,1}.channels(indices,:) = [];
    points_paints{hyb,1}.intensity(indices,:) = [];
    points_paints{hyb,1}.intensitypaint(indices,:) = [];
    
    indices = [];
    
    points_paints{hyb,1}.cellID(:,1) = zeros(length(points_paints{hyb,1}.channels),1);
    for i =1:numCells
    polygonIn = inpolygon(points_paints{hyb,1}.channels(:,1),points_paints{hyb,1}.channels(:,2),vertex(i).x,vertex(i).y);
        for dot = 1:length(polygonIn)
            if polygonIn(dot) ~= 0
                points_paints{hyb,1}.cellID(dot,1) = i*polygonIn(dot);
            end
        end
    end
end

saveDirPath = fullfile(experimentDir, 'analysis', experimentLabel, 'paint analysis');
if exist(saveDirPath, 'dir') ~= 7
    mkdir(saveDirPath);
end

savePath = fullfile(saveDirPath, ['points-paints-ch' num2str(ch) '-pos' num2str(position) '-' experimentName '.mat']);
save(savePath, 'points_paints', 'position');


