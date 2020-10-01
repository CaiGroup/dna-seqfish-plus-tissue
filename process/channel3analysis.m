function [] = channel3analysis(experimentDir, experimentName, position, segoption, processedImages)
%channel3analysis(experimentDir, experimentName, processedImages, position, maskDir, segoption)
% get mask from the ilastik trained images (20), and remove any ambiguous
% masks, assign point to each mask, return the point associated to a mask,
% which mask and which cell.
%
% requirements: 
% 1. processed images
% 2. trained ilastik images for simple segmentation of dapi, and each
% chromosome mask
% 3. RoiSet.zip for nucleus
%
% Need to do: 
% 1. simplify the regions as the same because this can be grouped in the
% post analysis
% 2. write documentation


    % make the option to get segmentation from roi or labeled matrix from
    % ilastik
    switch segoption
        case 'roi'
            %% get ROI set data for the nucleus
            %segmentPath = fullfile(experimentDir, 'segmentation', ['ch' num2str(channel)], 'RoiSet.zip');
            maskPath = fullfile(maskDir, 'RoiSet.zip');
            chrmask = selfsegzip(maskPath);
        case 'ilastik'

            %% Get the trained data from ilastik and convert to a binary mask
            %maskDir = fullfile(experimentDir, ['aligned-Pos' num2str(position) '-binned_Multicut Segmentation.h5']);
            % count number of ilastik files
            chrmaskDir = fullfile(experimentDir, 'segmentation', 'chrmask');
            a = dir(fullfile(chrmaskDir, '*.h5'));
            numChrs = numel(a);
            % get chrmask and dapi mask
            chrmask = getchrmask(chrmaskDir, numChrs, position);
            
            dapisegmaskDir = fullfile(experimentDir, 'segmentation', 'ch3');
            dapisegoption = '2d';
            dapisegmask = getdapisegmask(dapisegmaskDir, dapisegoption);
            sizeZ = size(chrmask{1},3);
            dapimask = getdapimask(dapisegmaskDir, dapisegoption, sizeZ, position);
            % organize the masks based on chromosome and background masks
            [allchrmask, backmask, ambmask] = orgmask(chrmask, dapimask);

        otherwise
            error 'variable segment variable is not correct';
    end


    %% get the points from the images - use processing package
    chArray = 1; % use channels 1 and 2
    folderArray = 0:59; % number of folders or hybcycles
    typedots = 'exons';
    superres = 'radial'; 
    sqrtradius = 6;
    %segoption = '2d'; % no 3d option yet

    %[pointspercell, points] = seqimprocess(experimentDir, experimentName, ...
    %    processedImages, position, folderArray, chArray, segoption, ...
    %    sqrtradius, typedots, superres);


    %% assign points according to the masks
    savePath = fullfile(experimentDir, ['chromosome-points-ch3-pos' num2str(position) '-' experimentName '.csv']);
    assignpoints2masks(chrmask, dapimask, dapisegmask, allchrmask, backmask, ambmask, pointspercell, savePath)


end

function chrmask = getchrmask(binaryMaskDir, numChrs, position)
    % create a cell array for the binary images
    chrmask = cell(numChrs,1);
    for i = 1:numChrs % 0 is the X chromosome
        fileName = [num2str(position) '-chr' num2str(i) '-'];
        binaryMaskPath = getfile(binaryMaskDir, fileName, 'match');
        chrmaskTemp = geth5mask(binaryMaskPath);
        chrmask{i} = uint8((double(chrmaskTemp) - 2) .* -1);
    end
end

function dapimask = getdapimask(dapimaskDir, segoption, sizeZ, position)
    switch segoption
        case '3d'
            % create a cell array for the binary images
            fileName = 'dapi';
            dapiMaskPath = getfile(dapimaskDir, fileName, 'match');
            dapimask = geth5mask(dapiMaskPath);
        case '2d'
            sizeIm = 2048;
            dapimask = zeros(sizeIm, sizeIm, sizeZ);
            dapimaskPath = getfile(dapimaskDir, 'RoiSet', 'match');
            vertex = selfsegzip(dapimaskPath);
            for i = 1:length(vertex)
                dapiMaskCell = repmat(poly2mask(vertex(i).x,vertex(i).y,sizeIm,sizeIm), [1 1 sizeZ]);
                dapimask = or(dapimask, dapiMaskCell);
            end
    end
end

function [allchrmask, backmask, ambmask] = orgmask(chrmask, dapimask)
    %% variables
    numChrs = length(chrmask);
    sizeIm = 2048;
    zSlices = size(dapimask, 3);
    initmask = zeros(sizeIm, sizeIm, zSlices);

    %% make background mask
    backmask = not(dapimask);
    
    %% make allchrmask
    %  loop through all chromosomes and make the masks - skip first one, chrX
    allchrmaskfull = initmask;
    ambmask = initmask;
    for chr1 = 1:numChrs
        startChr2 = chr1 + 1;
        for chr2 = startChr2:numChrs
                allchrmasktemp = or(chrmask{chr1}, chrmask{chr2});
                allchrmaskfull = or(allchrmaskfull, allchrmasktemp);
                ambmasktemp = and(chrmask{chr1}, chrmask{chr2});  
                ambmask = or(ambmask, ambmasktemp);
        end
    end
    
    % only get the mask inside the nucleus
    ambmask = and(ambmask, dapimask);

    % take out ambmask from allchrmask
    allchrmaskfull = and(allchrmaskfull, dapimask);
    %dapimask = xor(dapimaskfull, allchrmaskfull);
    allchrmaskremove = and(allchrmaskfull, ambmask);
    % mask for all chromosomes without ambiguous mask
    allchrmask = xor(allchrmaskremove, allchrmaskfull);
end

function dapisegmask = getdapisegmask(dapimaskDir, dapisegoption)

    switch dapisegoption
        case '2d'
            sizeIm = 2048;
            dapimaskPath = getfile(dapimaskDir, 'RoiSet', 'match');
            vertex = selfsegzip(dapimaskPath);
            dapisegmask = cell(length(vertex), 1);
            for i = 1:length(vertex)
                dapisegmask{i} = poly2mask(vertex(i).x,vertex(i).y,sizeIm,sizeIm);
            end
        case '3d' % need to debug and write code for this
            dapimaskPath = getfile(dapimaskDir, 'dapi', 'match');
            dapisegmask = geth5mask(dapimaskPath);
    end
    

end

function [] = assignpoints2masks(chrmask, dapimask, dapisegmask, allchrmask, backmask, ambmask, pointspercell, savePath)
% write a csv file assigning each point to the cell, chr, x, y, z and intensity

fileID = fopen(savePath,'w');
            fprintf(fileID,'%s,%s,%s,%s,%s,%s,%s\n', ...
                'cell', 'chr', 'hyb', 'x', 'y', 'z', 'int');
    
    % declare variables
    numHybs = length(pointspercell{1});
    numCells = length(pointspercell);
    backcellcount = ones(numHybs,1);
    dapicellcount = backcellcount;
    ambcellcount = backcellcount;
    chrpointscount = backcellcount;
    chrcellcount = ones(numHybs, length(chrmask));
    maxZ = size(chrmask{1},3);
    maxXY = 2048;
    min = 1;
    for hyb = 1:numHybs
        for c = 1:numCells
            numPoints = size(pointspercell{c}{hyb}.channels,1);
            %numpoints(hyb) = numPoints;
            points = pointspercell{c}{hyb}.channels;
            intensity = pointspercell{c}{hyb}.intensity;
            if isempty(points)
                continue;
            end
            for p = 1:numPoints 
                x = points(p,1);
                xc = round(x);
                y = points(p,2);
                yc = round(y);
                z = points(p,3);
                zc = round(z);
                if z > maxZ
                    zc = maxZ;
                elseif z < min
                    zc = min;
                end
                if x > maxXY
                    xc = maxXY;
                elseif x < min
                    xc = min;
                end
                if y > maxXY
                    yc = maxXY;
                elseif y < min
                    yc = min;
                end
                int = intensity(p);

                % check for each binary mask
                if backmask(yc, xc, zc)
                    %backcell{hyb} = cat(1, backcell{hyb}, points);
                    backcellcount(hyb) = backcellcount(hyb) + 1;
                    %backcellint{hyb} = cat(1, backcellint{hyb}, intensity);
                %elseif dapimask(y, x, z)
                %    for d = 1:length(dapimasks)
                %        if dapimasks{d}(y, x) % dapimasks{d}(x, y, z) when the 3d picture is here
                            %dapicell{hyb, d} = cat(1, dapicell{hyb, d}, points);
                %            dapicellcount(hyb, d) = dapicellcount(hyb,d) + 1;
                            %dapicellint{hyb,d} = cat(1, dapicellint{hyb,d}, intensity);
                %            break;
                %        end
                %    end

                elseif ambmask(yc, xc, zc)
                    %ambcell{hyb} = cat(1, ambcell{hyb}, points);
                    ambcellcount(hyb) = ambcellcount(hyb) + 1;
                    chrID = 'unk'; 
                    fprintf(fileID, '%.0f,%s,%.0f,%.3f,%.3f,%.3f,%.3f\n', c, chrID, hyb,x,y,z,int);
                    %ambcellint{hyb} = cat(1, ambcellint{hyb}, intensity);
                elseif allchrmask(yc, xc, zc)
                    % find which chromosome from the label matrix
                    chrpointscount(hyb) = chrpointscount(hyb) + 1;
                    %for d = 1:length(dapimasks) % dapimasks is all the dapi
                    %    if dapimasks{d}(y, x)% dapimasks{d}(x, y, z) when the 3d picture is here
                            % need to create a special matrix...two column
                            % organization...by cell and chromosome
                            for chr = 1:length(chrmask)
                                if chrmask{chr}(yc, xc, zc)
                                    % assign to the cell
                                    %chrcell{hyb, b} = cat(1, chrcell{hyb, b}, points);
                                    chrcellcount(hyb, chr) = chrcellcount(hyb,chr) + 1;
                                    %chrcellint{hyb, b} = cat(1, chrcellint{hyb, b}, intensity);
                                    
                                    
                                    chrID = chr - 1;
                                    if chrID ~= 0

                                        fprintf(fileID, '%.0f,%.0f,%.0f,%.3f,%.3f,%.3f,%.0f\n', c, chrID, hyb,x,y,z,int);
                                    else
                                        chrID = 'X';
                                        fprintf(fileID, '%.0f,%s,%.0f,%.3f,%.3f,%.3f,%.0f\n', c, chrID, hyb,x,y,z,int);
                                    end
                                    %col = (b - 1) * numChrs + d;
                                    %allchrcell{hyb, col} = cat(1, allchrcell{hyb, col}, points);
                                    %allchrcellcount(hyb, col) = allchrcellcount(hyb, col) + 1;
                                    %allchrcellint{hyb, col} = cat(1, allchrcellint{hyb, col}, intensity);
                                    break;
                                end
                            end
                            break;
                    %    end
                    %end
                else
                    warning('hyb %.0f, point %.0f does not match to a mask', hyb, p);
                end
            end
        end
    end
    fclose(fileID);

end