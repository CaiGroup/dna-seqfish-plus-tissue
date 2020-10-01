function ifwrapperimage(experimentDir, posArray, I, cycleArray, ...
    chArray, chaTform, immunokey, binSize, intPerZ, imagejbacksub, edges, varargin)
% wrapper function to retrieve and print all if
%
% Requirements: processed and aligned images are saved in:
% experimentDir/processedimages/pos[0-9]/imStartName


    %% Set up optional Parameters
    argsLimit = 1;
    numvarargs = length(varargin);
    if numvarargs > argsLimit
        error('src:ifwrapper:TooManyInputs', ...
            'requires at most 1 optional inputs');
    end
    % set defaults for optional inputs
    optargs = {[]};
    optargs(1:numvarargs) = varargin;
    [dapitform] = optargs{:};
    
    
    %% variables
    numCh = length(chArray);
    chaTformCh = cell(numCh, 1);
    chidx = 1;
    for ch = chArray
        chaTformCh{chidx} = chaTform{chArray};
        chidx = chidx+1;
    end
    
    for position = posArray     
        tic
        fprintf('IF position: %.0f\n', position);
        sizeZ = size(I{1,1}, 3);



        %% imagej background subtraction
        if imagejbacksub
            uniqueString = ['imageTempProcess-3535fsfsg-pos' num2str(position)];
            for f = size(I,1)
                for ch = 1:numCh
                    I{f,ch} = imagejbackgroundsubtraction(I{f,ch}, uniqueString,...
                        experimentDir);
                    if edges
                        I{f,ch} = imagejfindedges(I{f,ch}, uniqueString, experimentDir);
                    end
                end
            end
        end

        % apply dapi tforms if input
        if ~isempty(dapitform)
            I = applyalltform(I, dapitform);
        end
        
         % apply chromatic aberration
        I = applyallchatform(I, chaTformCh);

        numHybs = size(I,1);
        segDir = fullfile(experimentDir, 'segmentation');
        segPath = getfile(fullfile(segDir, ['pos' num2str(position)]), '.');
        L = getlabel(segPath, sizeZ);

        % make sure label is same size: cut out rest
        sizeZLabel = size(L, 3);
        numCh = size(I,2);
        for row = 1:numHybs
            for col = 1:numCh
                I{row,col} = I{row,col}(:,:,1:sizeZLabel);
            end
        end    


        experimentLabel = ['bin' num2str(binSize)];
        saveDir = fullfile(experimentDir, 'analysis', 'immuno-data', experimentLabel);
        mkdir(saveDir);
        [T_cell, T_avg] = getifbycell(experimentDir, experimentLabel, I, ...
            L, immunokey, binSize, intPerZ, cycleArray);
        expName = ['if-' num2str(binSize) 'bin'];
        printifallhyb(saveDir, T_cell, T_avg, position, expName);

        toc
    end
end
