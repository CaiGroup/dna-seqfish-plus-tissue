function cellnumcyto = SegmentCytoBrain(cellnum,lamin)
% inputs - 
%
%         DAPI - output of nuclear segmentation function SegmentNucleiBrain
%         lamin - file name of the .h5 file exported after ilastik training
%                 of PolyA
% NOTE: 
%   For polyA training, train lamin signal, nucleus interior, and
%   slide.
%
% outputs - 
%          
%         cellnum - 3D matrix with each pixel labeled with the
%                   corresponding cell number
% 
% Example: 
%      
%

%DAPI = h5read(DAPI,'/exported_data');
lamin = h5read(lamin,'/exported_data');

%format data
%DAPI = permute(DAPI,[3 2 4 1]);
lamin = permute(lamin,[3 2 4 1]);

nuc = cellnum>0;
z = size(nuc,3);
lam = lamin(:,:,1:z,2);
nuc2 = lamin(:,:,1:z,1);
%bgm = lamin(:,:,1:z,3);

%grid for interpolation
p = 4;
[X,Y,Z] = meshgrid(1/p:1/p:size(nuc2,2),1/p:1/p:size(nuc2,1),1:size(nuc2,3));

% make seeds
% stat = regionprops(nuc,'centroid');
% data = struct2array(stat);
% data2 = reshape(data,3,size(data,2)/3)';
% dots = zeros(size(cellnum));
% dots(sub2ind(size(dots),round(data2(:,2)),round(data2(:,1)),round(data2(:,3)))) = 1;
% seeds = imdilate(dots,strel('cuboid',[11,11,2]));
se2 = strel('cuboid',[17,17,2]);
%nuc = imclose(nuc,se2);
seeds = imerode(nuc,se2);
%seeds = imerode(nuc,strel('sphere',5));
seeds = bwareaopen(seeds,500);
for i = 1:size(seeds,3); seeds(:,:,i) = bwareaopen(seeds(:,:,i),100); end
seeds(:,:,1) = zeros(2048,2048);
seeds(:,:,end) = zeros(2048,2048);

%seeds = imgaussfilt3(seeds,[2 2 1]);
%seeds = interp3(seeds,X,Y,Z);
%seeds = seeds > .6;
%seeds = imfill(bwareaopen(seeds,500),'holes');

% make edge image
newedges = lam.*(1-nuc2);
edges = interp3(newedges,X,Y,Z);
%edges = edges.*(1-seeds);
edges(edges<0.25)=0;
%edges = edges * (2^16-1);

seeds(edges>.25)=0;
edges = edges.*(1-seeds);
seeds = imerode(seeds,strel('cuboid',[1,1,1]));
edges = edges * (2^16-1);

% %make background
%bgm = interp3(bgm,X,Y,Z);
%bgm = bgm >.8;
nuc2full = interp3(nuc2,X,Y,Z);
bw = imbinarize(nuc2full);
D = bwdist(bw);
DL = watershed(D);
bgm = DL == 0;

%edge add in
%ed = interp3(edge,X,Y,Z);

% watershed
%nuc = imgaussfilt3(im,[2 2 1]);
%DEi = interp3(nuc,X,Y,Z);
I2 = imimposemin(edges,seeds|bgm);
L = watershed(I2);
L2 = bwareaopen(L>0,5000);
L2 = L2-bwareaopen(L2,1000000);
leftover = seeds.*~L2;
leftclean = bwareaopen(leftover, 500);
Lia = ismember(cellnum,unique(cellnum(leftclean)));
overlap = L2 & Lia;
Lall = L2 | Lia;
Lall(imdilate(overlap,strel([1 1;1 1]))) = 0;
Lall = bwareaopen(Lall>0,5000);
% MIJ.createImage('Lall',uint16(bwperim(Lall)*2^16-1),true)
% MIJ.createImage('edges',uint16(edges/(2^16-1)),true)
% MIJ.createImage('seeds2',uint16(seeds*(2^16-1)),true)
cellnumcyto = bwlabeln(Lall);