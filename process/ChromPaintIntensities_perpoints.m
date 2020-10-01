function points_paints = ChromPaintIntensities_perpoints(experimentDir, experimentName, points, I, pos,roiPath)
% Assign
%
% I2: aligned fiducial marker images
%
% Author: Yodai Takei
% Date: 11/07/2019
% Email: ytakei@caltech.edu

vertex = selfsegzip([roiPath '\Pos' num2str(pos) '\RoiSet.zip']);
numCells = length(vertex);
points_paints = points;
x_max = size(I{1},2);
y_max = size(I{1},1);
z_max = size(I{1},3);

for hyb = 1:length(points)
    for dot = 1:length(points{hyb,1}(3).channels)
        location = round(points{hyb,1}(3).channels(dot,:));
        if (1<=location(2))&&(location(2)<=x_max)&&(1<=location(1))&&(location(1)<=y_max)&&(1<=location(3))&&(location(3)<=z_max) % to remove dots outside the images.
            for i = 61:80 % chromosome paint (chrX,1 to 19)
                % changing the order from chr1, 2 to 19, X
                if i == 61
                    points_paints{hyb,1}(3).intensitypaint(dot,i-41) = I{i,3}(location(2),location(1),location(3));
                else
                    points_paints{hyb,1}(3).intensitypaint(dot,i-61) = I{i,3}(location(2),location(1),location(3));
                end
            end
        else
            for i = 61:80
                points_paints{hyb,1}(3).intensitypaint(dot,i-60) = 0;
            end
        end
        % initial fiducial intensity
        %points_paints{hyb,1}(3).intensitypaint(dot,21) = I2{1,3}(location(2),location(1),location(3));
        % final fiducial intensity
        %points_paints{hyb,1}(3).intensitypaint(dot,22) = I2{2,3}(location(2),location(1),location(3));
    end
    
    points_paints{hyb,1}(3).cellID(:,1) = zeros(length(points_paints{hyb,1}(3).channels),1);
    for i =1:numCells
    polygonIn = inpolygon(points_paints{hyb,1}(3).channels(:,1),points_paints{hyb,1}(3).channels(:,2),vertex(i).x,vertex(i).y);
        for dot = 1:length(polygonIn)
            if polygonIn(dot) ~= 0
                points_paints{hyb,1}(3).cellID(dot,1) = i*polygonIn(dot);
            end
        end
    end
end

savePath = fullfile([experimentDir '\ch3 analysis\decoded'], ['points-paints-ch3-pos' num2str(pos) '-' experimentName '.mat']);
save(savePath, 'points_paints');


