function [matchRef, mismatchRef, matchPoints, mismatchPoints] = matchpoints(pointsRef, pointsMatch, radius, intref, intch)
% Get all the points that match within a certain radius

% limiter is the maximum distance a point can be associated with another
% point

% returns structure match and mismatch with nested matrix of 'ref' and
% 'points'

    [idx,D]= rangesearch(pointsRef,pointsMatch,radius+.00001);
    [idx2,D2] = rangesearch(pointsMatch,pointsRef,radius+.00001);
    
    %limiter = 3; % matching point has to be less than 3; could be the same as the radius parameter
    [matchRef, mismatchRef] = colocalize2points(pointsRef, pointsMatch, D2, idx2, radius, intref, intch);
    [matchPoints, mismatchPoints] = colocalize2points(pointsMatch, pointsRef, D, idx, radius, intch, intref);
    % matchPoints.points gives the reference points without repeats and
    % matchPoints.ref gives the matching points
end

