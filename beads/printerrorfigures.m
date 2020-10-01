function [rIntPeak, rIntArea, fwhmLocation, fwhmIntPeak, fwhmIntArea] = printerrorfigures(rawData1, rawData2, zSlices, gateareafigures)
% printfigures is a function used to print the figures of the localization
% and intensity error between two images.
%
%
% Author: Nico Pierson
% Email: nicogpt@caltech.edu
% Date: 1/28/2019
% Modified On: 2/12/2019
% Adapted Graphs from: Mike Lawson and Sheel Shah
% Date: May 2018
%
% To Do List:
% 1. Add Save option to save figures in a specified directory
% 1. Add options for processing images, align by dapi (tform), threshold
% (two for each image or one for both or choose a threshold), and to save.
%
% 2. Move Figures so it can be seen in an organized manner
%
% 4. Make and adjust error graphs: add correlation graph of roi selected
% area between two images
%
% 6. Able to select a region of interest in MATLAB????
% 7. Fix bug for using inensity values for final data
% 8. Add options for Carsten: Compare intensity of all dots vs colocalized,
% values to show up, different graphs(intensity median line with average),
% 9. Area for Lincoln
% 10. Link figures for Yodai
% 11. Add ROI selection???
% 14. Save option
% 15. Easier functionality: type string for image, grab chosen channels and
% compares, even from the start of z-slices
% 16. R-value on correlation graph - take out high outliers???


    %% Check if othercolor package is in the path
    %{
    try
        pathCell = regexp(path, pathsep, 'split');
        othercolorFolder = 'othercolor';
        
        foundOthercolor = false;
        for i = 1:size(pathCell, 2)
            pathCell2 = regexp(pathCell{i}, filesep, 'split');
            if strcmp(pathCell2{end}, 'othercolor') 
                foundOthercolor = true;
                fprintf('othercolor directory already in path\n');
                break;
            end
        end
        
        % if not on path, add to MATLAB path
        if ~foundOthercolor
            fprintf('Finding othercolor\\othercolor folder, and mij.jar files\n\n');
            if ispc
                othercolorDirectory = getdirectory(othercolorFolder, othercolorFolder);
                addpath(othercolorDirectory, '-end');
            else
                othercolorDirectory = getdirectory(othercolorFolder, othercolorFolder, '/Applications');
                addpath(othercolorDirectory, '-end');
            end
        end
    catch
        error(['othercolor package not found or unable to add to path' ...
            'Download package at https://nl.mathworks.com/matlabcentral/mlc-downloads/downloads/submissions/30564/versions/8/download/zip']);
        % later add download function:
        % https://nl.mathworks.com/matlabcentral/mlc-downloads/downloads/submissions/30564/versions/8/download/zip
    end
%}
    
        
    %% Declare Variables
    close all; % close all figures beforehand
    FWHM_CONSTANT = 2.355;
    
    % Look into raw location of points...and see if there is a difference
    % between the gaussian fitted points
    
    % gaussData: 1. gauss fit x 2. gauss fit y 3.z 4.raw intensity peak
    % 5. gaussian fit intensity peak 6. raw area of intensity 7.
    % gaussian fit intensity area
    rawDots1 = rawData1(:, 1:3);
    rawDots2 = rawData2(:, 1:3);
    locationError = rawDots1 - rawDots2;
    rawIntensity1 = rawData1(:, 4);
    rawIntensity2 = rawData2(:, 4);
    rawIntensityError = rawIntensity1 - rawIntensity2;
    rawIntArea1 = rawData1(:, 5);
    rawIntArea2 = rawData2(:, 5);
    rawIntAreaError = rawIntArea1 - rawIntArea2;
    
    % Take out outliers?
    
    %% Figure 1: image for dot colocalization
    figure;
    g(1:length(rawDots1), 1) = 1;
    g(length(rawDots1)+1:2*length(rawDots1), 1) = 2;
    vec = rawDots2 - rawDots1;
    allpts = [rawDots1;rawDots2];
    z = allpts(:,3);
    % call GSCATTER and capture output argument (handles to lines)
    h = gscatter(allpts(:,1), allpts(:,2), g,[],'ox+*sdv^<>ph.',5);
    % for each unique group in 'g', set the ZData property appropriately
    gu = unique(g);
    for k = 1:numel(gu)
          set(h(k), 'ZData', z( g == gu(k) ));
    end
    view(3)
    % Do I need to change the order???? I don't thing so because they were
    % switched in the main function.
    hold on; quiver3(rawDots1(:,1),rawDots1(:,2),rawDots1(:,3),vec(:,1),vec(:,2),vec(:,3),0,'MaxHeadSize',0.5)
    title('Dot Colocalization Pairwise Distance', 'FontSize', 14)
    xlabel('x-axis [px]', 'FontSize', 12);
    ylabel('y-axis [px]' , 'FontSize', 12);
    zlabel('z-slices', 'FontSize', 12);
    movegui(1, 'north');
    
    
    
    %% Figure 2: Bin graph of all the intensity peak values for image1 and image2
    figure;
    subplot(2,1,1)
    h1 = histogram(rawIntensity1);
    xlabel('Intensity Values', 'FontSize', 11);
    ylabel('Counts' , 'FontSize', 11);
    title('Image 1 Raw Intensity Peaks Histogram', 'FontSize', 11);
    subplot(2,1,2)
    h2 = histogram(rawIntensity2);
    h2.NumBins = h1.NumBins;
    xlabel('Intensity Values', 'FontSize', 11);
    ylabel('Counts' , 'FontSize', 11);
    title('Image 2 Raw Intensity Peaks Histogram', 'FontSize', 11);
    movegui(2, 'northwest');
 
    
    
    %% Figure Histogram of the area in both images, then show the values for the error,std dev, standard error
    % How to display the differences between the raw values and gaussian
    % fitted values for intensity peaks and area (area is similar)
    
    
    
    %% Figure 3: intensity error FWHM and Correleation
    figure;
    fwhmIntPeak = (FWHM_CONSTANT*std(rawIntensityError(:,1))) / sqrt(size(rawIntensityError, 1));
    %edges = -(maxIntSD + 50):5:(maxIntSD + 50);
    histogram(rawIntensityError(:,1))
    hold on;
    % place r value on top left
    str = sprintf('FWHM = +-%.3f\n', fwhmIntPeak);
    T = text(min(get(gca, 'xlim')), max(get(gca, 'ylim')), str); 
    set(T, 'fontsize', 14, 'verticalalignment', 'top', 'horizontalalignment', 'left');
    title('Intensity Standard Error');
    movegui(3, 'northeast');
    
    
    
    %% Figure 4: Correlation between Intensities
    % Add slope and normalize the graph
    [rIntPeak, intensityPvalue] = corr(rawIntensity1, rawIntensity2);
    figure;
    s1 = plot(rawIntensity1, rawIntensity2, 'b+');
    set(s1, 'MarkerSize', 8, 'LineWidth', 2);
    hold on;
    l = lsline;
    set(l, 'LineWidth', 2);
    hold on;
    % place r value on top left
    str = sprintf('R = %.3f\n', rIntPeak);
    T = text(min(get(gca, 'xlim')) + 30, max(get(gca, 'ylim')) - 30, str); 
    set(T, 'fontsize', 14, 'verticalalignment', 'top', 'horizontalalignment', 'left');
        %%% axis display 
    xlabel('Image 1 Intensity', 'FontSize', 11);
    ylabel('Image 2 Intensity' , 'FontSize', 11);
    set(gca, 'FontSize', 11, 'YMinorTick', 'on','XMinorTick', 'on');
    title('Raw Intensity Peak Correlation', 'FontSize', 12); % use 2.355 as it is the std of the fwhm (full width half maximum)
    %savefig([loc_path sprintf([filesep 'Analysis_Details_NO_FISH_RCE' filesep 'Bead_Alignment' filesep 'Pos%.0f_BEAD_by_BEAD_%.0fnm.fig'],my_pos, channel_nm)])
    movegui(4, 'southwest');

    
    %% Figure 5: dot displacement
    % add standard error along with full width half maximum error
    % standard error = fwhm / squrt(sample size)
    figure;
    dotlocationStandardErrorX = (FWHM_CONSTANT*std(locationError(:,1))) / sqrt(size(locationError, 1)); % maybe change that
    dotlocationStandardErrorY = (FWHM_CONSTANT*std(locationError(:,2))) / sqrt(size(locationError, 1));
    fwhmLocation = [dotlocationStandardErrorX dotlocationStandardErrorY];
    subplot(3,1,1)
    histogram(locationError(:,1))
    xlabel('X Difference [px]', 'FontSize', 10);
    ylabel('Counts' , 'FontSize', 10);
    % place FWHMx value on top left
    str = sprintf('FWHMx = %.3f\n', dotlocationStandardErrorX);
    T = text(min(get(gca, 'xlim')) + 15, max(get(gca, 'ylim')), str); 
    set(T, 'fontsize', 10, 'verticalalignment', 'top', 'horizontalalignment', 'left');
    title('Point Error in X', 'FontSize', 11) % use 2.355 as it is the std of the fwhm (full width half maximum)
    subplot(3,1,2)
    histogram(locationError(:,2))
    xlabel('Y Difference [px]', 'FontSize', 10);
    ylabel('Counts' , 'FontSize', 10);
    % place FWHMy value on top left
    str = sprintf('FWHMy = %.3f\n', dotlocationStandardErrorY);
    T = text(min(get(gca, 'xlim')) + 15, max(get(gca, 'ylim')), str); 
    set(T, 'fontsize', 10, 'verticalalignment', 'top', 'horizontalalignment', 'left');
    title('Point Error in Y', 'FontSize', 11)
    subplot(3,1,3)
    histogram2(locationError(:,1),locationError(:,2))
    title('Point Error in X and Y Coordinates', 'FontSize', 11);
    xlabel('X Difference [px]', 'FontSize', 10);
    ylabel('Y Difference [px]' , 'FontSize', 10);
    zlabel('Counts' , 'FontSize', 10);
    movegui(5, 'southeast');
    
    
    %% Figure 6: bead intensity Per ZSlice
    %intensityCorrPerZslice = zeros(zSlices, 1)*NaN;
    %intensityPvalue = zeros(zSlices, 1)*NaN;
    %intensityStandError = zeros(zSlices, 1)*NaN;
    intensityMedian1 = [];
    intensityMedian2 = [];
    intensityMean1 = [];
    intensityMean2 = [];
    for i = 1:zSlices
        % get points and intensity for each z-slice
        indRow1 = find(rawData1(:,3) == i);
        indRow2 = find(rawData2(:,3) == i);
        if ~isempty(indRow1) && ~isempty(indRow2)
            % At least need 3 points to evaluate
            if size(indRow1, 1) > 3
                %[intensityCorrPerZslice(i), intensityPvalue(i)] = corr(intensity1(indRow), intensity2(indRow));
                %intensityStandError(i) = (FWHM_CONSTANT * std(rawIntensityError(indRow))) / sqrt(size(indRow, 1));
                intensityMedian1 = cat(1, intensityMedian1, [i median(rawIntensity1(indRow1))]);
                intensityMean1 = cat(1, intensityMean1, [i mean(rawIntensity1(indRow1))]);
                
            end
            if size(indRow2, 1) > 3
                intensityMedian2 = cat(1, intensityMedian2, [i median(rawIntensity2(indRow2))]);
                intensityMean2 = cat(1, intensityMean2, [i mean(rawIntensity2(indRow2))]);
            end
            
        end
    end
    figure;
    %yyaxis left
    %plot(intensityMedian1,'b.-');
    m1Data  = line(intensityMedian1(:, 1), intensityMedian1(:, 2));
    set(m1Data                         , ...
      'LineStyle'       , '--'      , ...
      'Marker'          , '.'         );
    set(m1Data                         , ...
      'Marker'          , 'o'         , ...
      'MarkerSize'      , 8           , ...
      'MarkerEdgeColor' , 'none'      , ...
      'LineWidth'       , 1.5         , ...
      'Color'       , [.75 .75 1] , ...
      'MarkerFaceColor' , [.75 .75 1] );
    hold on;
    % grean mean
    me1Data  = line(intensityMean1(:, 1), intensityMean1(:, 2));
    set(me1Data                         , ...
      'LineStyle'       , '-.'      , ...
      'Marker'          , '.'         );
    set(me1Data                         , ...
      'Marker'          , 'o'         , ...
      'MarkerSize'      , 8           , ...
      'MarkerEdgeColor' , 'none'      , ...
      'LineWidth'       , 1.5         , ...
      'Color'       , [0 .5 0] , ...
      'MarkerFaceColor' , [0 .5 0] );
    hold on;
    %red median 2
    m2Data  = line(intensityMedian2(:, 1), intensityMedian2(:, 2));
    set(m2Data                         , ...
      'LineStyle'       , '--'      , ...
      'Marker'          , '.'         );
    set(m2Data                         , ...
      'Marker'          , 'o'         , ...
      'MarkerSize'      , 8           , ...
      'MarkerEdgeColor' , 'none'      , ...
      'LineWidth'       , 1.5         , ...
      'Color'       , 'b' , ...
      'MarkerFaceColor' , 'b' );
    hold on;
    % magenta mean 2
    me2Data  = line(intensityMean2(:, 1), intensityMean2(:, 2));
    set(me2Data                         , ...
      'LineStyle'       , '-.'      , ...
      'Marker'          , '.'         );
    set(me2Data                         , ...
      'Marker'          , 'o'         , ...
      'MarkerSize'      , 8           , ...
      'MarkerEdgeColor' , 'none'      , ...
      'LineWidth'       , 1.5         , ...
      'Color'       , 'g' , ...
      'MarkerFaceColor' , 'g' );
    hold on; % do I need this here
    ylabel('Intensity Value');
    xlabel('Z-slices');
    legend('img 1 int med', 'img 1 int avg', 'img 2 int med', 'img 2 int avg','Location','best');
    movegui(6, 'south');
    
    
    %% Figure Box plot - experiment with other plots...violin, anova
    % make a box plot for the intensity in image 1 and 2
    % not a good image...because most o fthe values are in the 100-300
    % range
    %figure;
    %boxplot([rawIntensity1,rawIntensity2],'Notch','on','Labels',{'Image 1','Image 2'},'Whisker',100);
    %title('Raw Intensity Between Image 1 and 2');
    
    
    if gateareafigures
        %% Try Correlation in Area
        % Figure 7: Bin graph of all the intensity peak values for image1 and image2
        figure;
        subplot(2,1,1)
        h1 = histogram(rawIntArea1);
        xlabel('intensity units', 'FontSize', 11);
        ylabel('Counts' , 'FontSize', 11);
        title('Image 1 Raw Intensity Area Histogram', 'FontSize', 11);
        subplot(2,1,2)
        h2 = histogram(rawIntArea2);
        h2.NumBins = h1.NumBins;
        xlabel('intensity units', 'FontSize', 11);
        ylabel('Counts' , 'FontSize', 11);
        title('Image 2 Raw Intensity Area Histogram', 'FontSize', 11);
    end
    
    
    
    % Figure 8: Correlation between Intensities
    % Add the R value
    [rIntArea, intensityAreaPvalue] = corr(rawIntArea1, rawIntArea2);
    if gateareafigures
        figure;
        s1 = plot(rawIntArea1, rawIntArea2, 'b+');
        set(s1, 'MarkerSize', 8, 'LineWidth', 2);
        hold on;
        l = lsline;
        set(l, 'LineWidth', 2);
        hold on;
        % place r value on top left
        str = sprintf('R = %.3f\n', rIntArea);
        T = text(min(get(gca, 'xlim')) + 30, max(get(gca, 'ylim')) - 30, str); 
        set(T, 'fontsize', 14, 'verticalalignment', 'top', 'horizontalalignment', 'left');
            %%% axis display 
        xlabel('Image 1 Intensity Area', 'FontSize', 11);
        ylabel('Image 2 Intensity Area' , 'FontSize', 11);
        set(gca, 'FontSize', 11, 'YMinorTick', 'on','XMinorTick', 'on');
        title('Raw Intensity Area Correlation', 'FontSize', 12);
    end
    
    
    
    % Figure 9: intensity error FWHM and Correleation
    fwhmIntArea = (FWHM_CONSTANT*std(rawIntAreaError(:,1))) / sqrt(size(rawIntAreaError, 1));
    if gateareafigures
        figure;
        h3 = histogram(rawIntAreaError(:,1));
        hold on;
        % place r value on top left
        str = sprintf('FWHM = +-%.3f\n', fwhmIntArea);
        T = text(max(get(gca, 'xlim')) - 25, max(get(gca, 'ylim')), str); 
        set(T, 'fontsize', 14, 'verticalalignment', 'top', 'horizontalalignment', 'right');
        title('Raw Intensity Area Standard Error');
    end

end
