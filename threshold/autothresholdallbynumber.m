function [points, intensity, sigma, adjustedThreshold, numpointError] = ...
    autothresholdallbynumber(I, numRefPoints, threshold, typedots, filtersigma, ...
    saveFigDir)
% wrapper function to use the autothreshold using the number of points


    %% variables
    numHybCycles = size(I,1);
    numCh = size(I,2);
    points = cell(numHybCycles, numCh);
    intensity = cell(numHybCycles, numCh);
    sigma = cell(numHybCycles, numCh);
    adjustedThreshold = ones(numHybCycles, numCh)*999999;
    numpointError = ones(numHybCycles, numCh);
    
    
    
    %% autothreshold
    for c = 1:numCh
        for h = 1:numHybCycles
            fprintf('AutoThreshold for hyb %.0f ch %.0f\n', h, c);
            if h == 5 && c == 1
                disp('debug');
            end
            [points{h,c}, intensity{h,c}, adjustedThreshold(h,c), numpointError(h,c)] = autothresholdbynumberpoints(I{h,c}, numRefPoints, threshold(h,c), typedots);
            
            % filter sigma
            if filtersigma && ~isempty(points{h,c})
                removeidx = [];
                [~, sigmaTemp] = getradialcenter(points{h,c},I{h,c});
                sigma{h,c} = sigmaTemp';
                intThreshold = 10;
                for i = 1:size(points{h,c},1)
                    sigcheck = sigma{h,c}(i);
                    if sigcheck < 0.5 || sigcheck > 1.25 || intensity{h,c}(i) < intThreshold 
                        removeidx = cat(1, removeidx, i);
                    end
                end
                points{h,c}(removeidx, :) = [];
                intensity{h,c}(removeidx, :) = [];
                sigma{h,c}(removeidx, :) = [];
            else
                sigma = [];
            end
            
            % save the graph
            saveName = ['fig-h' num2str(h) '-c' num2str(c) '.fig'];
            saveFigPath = fullfile(saveFigDir, saveName);
            imRange = [];
            savegraph(I{h,c}, points{h,c}, saveFigPath, imRange)
        end
    end
end