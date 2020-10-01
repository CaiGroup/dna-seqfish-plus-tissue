function NucCyto = Match3dRoiNuc2Cyto(cellnum, cellnumcyto)

nucNum = unique(cellnum);

for i = 1:length(nucNum)-2 % first two numbers in cellnum (nucleus) are considered to be background label
    
    BW = cellnum == nucNum(i+2);
    %BW = ismember(cellnum, nucNum(i+2));
    %cytonum = unique(cellnumcyto(BW)); % checking with the entire nuclear ROI.
    
    % checking with the centroid of the nuclear ROI
    stats = regionprops(BW);
    centroid = int16(stats.Centroid);
    cytonum = cellnumcyto(centroid(2),centroid(1),centroid(3));
    
    NucCyto(i,1) = nucNum(i+2);
    if length(cytonum)>1
        NucCyto(i,2) = cytonum(2); % cytonum(1) could be 0.
    else
        NucCyto(i,2) = cytonum;
    end
end
    