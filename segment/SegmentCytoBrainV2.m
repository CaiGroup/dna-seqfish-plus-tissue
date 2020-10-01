function BWfinal = SegmentCytoBrainV2(cellnum,polya)
% inputs - 
%
%         cellnum - output of nuclear segmentation function SegmentNucleiBrain
%         polya - file name of the .h5 file exported after ilastik training
%                 of PolyA
% NOTE: 
%   For polyA training, train edge signal, cell interior, and
%   slide/tissue background.
%
% outputs - 
%          
%         BWfinal - 3D matrix with each pixel labeled with the
%                   corresponding cell number same as nuclear number from
%                   nuclear segmentation code

polya = h5read(polya,'/exported_data');

%format data
polya = permute(polya,[3 2 4 1]);

nuc = cellnum>0;
z = size(nuc,3);
lam = polya(:,:,1:z,2);
nuc2 = polya(:,:,1:z,1);
%bgm = lamin(:,:,1:z,3);

%grid for interpolation
p = 4;
[X,Y,Z] = meshgrid(1/p:1/p:size(nuc2,2),1/p:1/p:size(nuc2,1),1:size(nuc2,3));

% make seeds
se2 = strel('cuboid',[17,17,1]);
seeds = imerode(nuc,se2);
seeds = bwareaopen(seeds,5000);
for i = 1:size(seeds,3); seeds(:,:,i) = bwareaopen(seeds(:,:,i),100); end
seeds(:,:,1) = zeros(2048,2048);
seeds(:,:,end) = zeros(2048,2048);
test = ~ismember(unique(cellnum),unique(cellnum.*seeds));
kep = unique(cellnum);
seedsleft = ismember(cellnum,kep(test));
seeds = seeds | seedsleft;

% make edge image
newedges = lam.*(1-nuc2);
edges = interp3(newedges,X,Y,Z);
edges(edges<0.25)=0;

seeds(edges>.25)=0;
edges = edges.*(1-seeds);
seeds = imerode(seeds,strel('cuboid',[1,1,1]));
edges = edges * (2^16-1);
cellnumEroded = cellnum.*seeds;

%Background
nuc2full = interp3(nuc2,X,Y,Z);
bw = imbinarize(nuc2full);
D = bwdist(bw);
DL = watershed(D);
bgm = DL == 0;

% watershed
I2 = imimposemin(edges,seeds|bgm);
L = watershed(I2);
L2 = bwareaopen(L>0,5000);
L2 = L2-bwareaopen(L2,1000000);

%find left nuclei with no cytoplasm segmentation and add back in
leftover = seeds.*~L2;
leftclean = bwareaopen(leftover, 500);
Lia = ismember(cellnum,unique(cellnum(leftclean)));
overlap = L2 & Lia;
Lall = L2 | Lia;
Lall(imdilate(overlap,strel([1 1;1 1]))) = 0;
Lall = bwareaopen(Lall>0,5000);

%Find objects that need to be split and split them
cellnumcyto = bwlabeln(Lall);
NucNum = unique(cellnum);
cell = zeros(1,length(NucNum)-1);
for i = 2:length(NucNum)
    BW = cellnumEroded == NucNum(i);
    nunlist = cellnumcyto(BW);
    [N,B] = histcounts(nunlist,-.5:1:length(cellnumcyto));
    [m,I] = max(N(2:end));
    if m > 0 
        cell(i-1) = ceil(B(I+1));
    else
        cell(i-1) = 0;
    end
end
[~, ind] = unique(cell);
duplicate_ind = setdiff(1:size(cell,2), ind);
duplicate_value = unique(cell(duplicate_ind));
split = ismember(cellnumcyto,duplicate_value);
cellnumcyto(split) = 0;
Lall = cellnumcyto >0;
D = -bwdist(~split);
splitseeds = split.*seeds;
splitseeds = bwareaopen(splitseeds,500);
D2 = imimposemin(D,splitseeds);
Ld2 = watershed(D2);
splitter = bwlabeln(Ld2)==0;
split(splitter) = 0;
Lall = Lall | split;
cellnumcyto = bwlabeln(Lall);

% remove any cell that doesn't have an associated nucleus and make number
% scheme consistent
NucNum = unique(cellnum);
BWfinal = zeros(size(cellnumcyto));
for i = 2:length(NucNum)
    BW = cellnumEroded == NucNum(i);
    nunlist = cellnumcyto(BW);
    [N,B] = histcounts(nunlist,-.5:1:length(cellnumcyto));
    [m,I] = max(N(2:end));
    BW = cellnumcyto == ceil(B(I+1));
    if m > 0 
        BWfinal = BWfinal + BW*NucNum(i);
    end
end

% assign points to cells
%linInd = sub2ind(size(cellnum),points(:,2),points(:,1),points(:,3));
%cells = cellnum(linInd);
%[N,~] = histcounts(cells,0:max(max(max(cellnum)))+1);
%GeneCounts = N(2:end);