function fovinfo = getfovinfo(experimentDir, experimentName, posArray, roiPath)

    %% Get the centroid of each position
    % Get ROI centroid for each fov
    %roiPath = fullfile(basePath, 'RoiSet.zip');
    [centroid, xbox, ybox] = getroicentroid(roiPath); % cell of fov centroids
    
    % get the pixel physical size for each fov and make a csv 
    numFOVs = length(posArray);
    initialFolder = 'HybCycle_0';
    fovBasePath = fullfile(experimentDir, initialFolder);
    numCellFields = 5;
    fovinfo = cell(numCellFields + 1, numFOVs + 1);
    fovinfo{2,1} = 'FOV Centroid';
    fovinfo{3,1} = 'FOV X Bounding Coordinates';
    fovinfo{4,1} = 'FOV Y Bounding Coordinates';
    fovinfo{5,1} = 'Single ROI Physical Pixel Size (um)';
    fovinfo{6,1} = 'Slide View Physical Pixel Size (um)';
    for col = 1:numFOVs
        fovinfo{1, col+1} = ['fov ' num2str(col)];
    end
    fovinfo(2, 2:end) = centroid;
    fovinfo(3, 2:end) = xbox;
    fovinfo(4, 2:end) = ybox;
    boxsize = [];
    for f = 1:length(xbox)
        boxsize = cat(2,boxsize,abs(xbox{f}(1)-xbox{f}(3)));
    end
    boxsizeavg = median(boxsize);
    ratio = 2048 / boxsizeavg;


    for fov = 1:numFOVs

        fovFileName = ['MMStack_Pos' num2str(fov-1) '.ome.tif'];
        fovPath = fullfile(fovBasePath, fovFileName);
        [physicalsizeX, physicalsizeY] = getphysicalpixelsize(fovPath, fov-1); % should all be equal

        fovinfo{5, fov+1} = physicalsizeX;
        fovinfo{6, fov+1} = ratio * physicalsizeX; % find out how to do this; find diff of xbox between the x or y, ratio of this 2048/128 = 16; then multiply by physicalpixelsizex
    end
    folderSaveName = 'points';
    folderSaveDir =  fullfile(experimentDir, folderSaveName);
    if exist(folderSaveDir, 'dir') ~= 7
        mkdir(folderSaveDir);
    end
    fovinfoSavePath = fullfile(folderSaveDir, ['fovinfo-' experimentName '.csv']);
    printfovcsv(fovinfo, fovinfoSavePath);

    
end