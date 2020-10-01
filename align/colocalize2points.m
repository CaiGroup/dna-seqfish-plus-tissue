function [match, mismatch] = colocalize2points(refPoints, matchPoints, D2, idx2, limiter, intref, intch)
% function to grab the closest points using a radius
% D2 is the distance of all the refPoints matching to the other channel

    finalRefPoints = [];
    finalMatchPoints = [];
    refInt = [];
    matchInt = [];
    distance = [];
    match = [];
    % set up cell with all zeros
    mismatchLog1 = zeros(length(refPoints), 1); % for refPoints
    mismatchLog2 = ones(length(matchPoints), 1); % for matchPoints
    
    numberOfPoints = length(idx2);
    for i = 1:numberOfPoints
       if ~isempty(D2{i}) 
           [M, I] = min(D2{i}); % M is the value and I is the index
           if M < limiter + 0.00001
                finalRefPoints = [finalRefPoints; refPoints(i,:)];
                refInt = [refInt; intref(i)];
                finalMatchPoints = [finalMatchPoints; matchPoints(idx2{i}(I),:)];
                matchInt = [matchInt; intch(idx2{i}(I),:)];
                % add intensity
                %intensity = [intensity; int(idx2
                distance = [distance; M];
                % get the logical indice
                mismatchLog1(i) = true;
                mismatchLog2(idx2{i}(I)) = false;
           end

       end
       
    end
    
    match.ref = finalRefPoints;
    match.points = finalMatchPoints;
    match.intref = refInt;
    match.intmatch = matchInt;
    % add distance
    match.distance = distance;
    mismatch.ref = refPoints(logical(mismatchLog1),:);
    mismatch.points = matchPoints(logical(mismatchLog2),:); % for the refpoints....possible to get the other points
    
end