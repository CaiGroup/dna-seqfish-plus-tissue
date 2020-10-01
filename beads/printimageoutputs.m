function colocalizationData = printimageoutputs(rawData1, rawData2, numberOfDots, errorData, thresholdData)
% printimageouputs prints all of the data comparing two images.
%
% Input Structure:
% numberOfDots will have a structure [numDots1, numDots2, numColDots]
% errorData = [rIntPeak, rIntArea, fwhmLocation[x y], fwhmIntPeak, fwhmIntArea]
% thresholdData = [threshold1 threshold2]
%
% Update: 2/26/2019 
% - return colocalization percentage
%
% Author: Nico Pierson
% Email: nicogpt@caltech.edu
% Date: 2/12/2019
% Modified On: 

    %% Set up Variables
    numDots1 = numberOfDots(1);
    numDots2 = numberOfDots(2);
    numColDots = numberOfDots(3);
    rIntPeak = errorData(1);
    rIntArea = errorData(2);
    fwhmLocationX = errorData(3);
    fwhmLocationY = errorData(4);
    fwhmIntPeak = errorData(5);
    fwhmIntArea = errorData(6);
    threshold1 = thresholdData(1);
    threshold2 = thresholdData(2);
    % Calculate percentages
    percentDots1 = numColDots / numDots1;
    percentDots2 = numColDots / numDots2;
    colocalizationData = [numColDots numDots1 percentDots1; numColDots numDots2 percentDots2];
    
    
    
    %% Print output data
    fprintf('\n\n ---------------------------------------------------\n');
    fprintf('Output Varibles\n');
    fprintf('---------------------------------------------------\n');
    fprintf('Image 1:\n');
    fprintf('---------------------------------------------------\n');
    fprintf('Threshold Value: %.0f\n', threshold1);
    fprintf('Number of Dots Found: %.0f\n', numDots1);
    fprintf('Number of Dots Colocalized: %.0f\n', numColDots);
    fprintf('Percentage of Colocalized and Total Dots: %.3f\n', percentDots1);
    rawIntPeak1 = rawData1(:,4);
    fprintf('Raw Intensity Peak: \n\tAvg - %.0f \n\tMedian - %.0f \n\t25 percentile - %.0f \n\t75 percentile - %.0f \n\tstd - %.3f\n', ...
        mean(rawIntPeak1), median(rawIntPeak1), prctile(rawIntPeak1, 25), prctile(rawIntPeak1, 75), std(rawIntPeak1));
    rawIntArea1 = rawData1(:,5);
    fprintf('Raw Intensity Area: \n\tAvg - %.0f \n\tMedian - %.0f \n\t25 percentile - %.0f \n\t75 percentile - %.0f \n\tstd - %.3f\n\n', ...
        mean(rawIntArea1), median(rawIntArea1), prctile(rawIntArea1, 25), prctile(rawIntArea1, 75), std(rawIntArea1));
    fprintf('---------------------------------------------------\n');
    fprintf('Image 2:\n');
    fprintf('---------------------------------------------------\n');
    fprintf('Threshold Value: %.0f\n', threshold2);
    fprintf('Number of Dots Found: %.0f\n', numDots2);
    fprintf('Number of Dots Colocalized: %.0f\n', numColDots);
    fprintf('Percentage of Colocalized and Total Dots: %.3f\n', percentDots2);
    rawIntPeak2 = rawData2(:,4);
    fprintf('Raw Intensity Peak: \n\tAvg - %.0f \n\tMedian - %.0f \n\t25 percentile - %.0f \n\t75 percentile - %.0f \n\tstd - %.3f\n', ...
        mean(rawIntPeak2), median(rawIntPeak2), prctile(rawIntPeak2, 25), prctile(rawIntPeak2, 75), std(rawIntPeak2));
    rawIntArea2 = rawData2(:,5);
    fprintf('Raw Intensity Area: \n\tAvg - %.0f \n\tMedian - %.0f \n\t25 percentile - %.0f \n\t75 percentile - %.0f \n\tstd - %.3f\n\n', ...
        mean(rawIntArea2), median(rawIntArea2), prctile(rawIntArea2, 25), prctile(rawIntArea2, 75), std(rawIntArea2));
    fprintf('---------------------------------------------------\n');
    fprintf('Image Error Values:\n');
    fprintf('---------------------------------------------------\n');
    fprintf('Correlation of Intensity Peak: %.3f\n', rIntPeak);
    fprintf('Correlation of Intensity Area: %.3f\n', rIntArea);
    fprintf('Full Width Half Maximum of X Dot Location: %.3f\n', fwhmLocationX);
    fprintf('Full Width Half Maximum of Y Dot Location: %.3f\n', fwhmLocationY);
    fprintf('Full Width Half Maximum of Intensity Peak: %.3f\n', fwhmIntPeak);
    fprintf('Full Width Half Maximum of Intensity Area: %.3f\n', fwhmIntArea);


end