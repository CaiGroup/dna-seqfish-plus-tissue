function cellnum = SegmentNucleiBrain(DAPI,lamin,savePathCh)
% inputs - 
%
%         DAPI - file name of .h5 file exported after ilastik training of
%                dapi
%         lamin - file name of the .h5 file exported after ilastik training
%                 of lamin
% NOTE: 
%   For DAPI training, train DAPI area, slide area, and edge of nucleus
%   area. For lamin training, train lamin signal, nucleus interior, and
%   slide.
%
% outputs - 
%          
%         cellnum - 3D matrix with each pixel labeled with the
%                   corresponding cell number
% 
% Example: 
%      
% cellnum = SegmentNuclei('C:\Users\Sheel\Desktop\yodai\DAPI_Probabilities.h5','C:\Users\Sheel\Desktop\yodai\lamin_Probabilities.h5')
%

%DAPI = h5read('DAPI_Probabilities.h5','/exported_data');
%lamin = h5read('lamin_Probabilities.h5','/exported_data');

DAPI = h5read(DAPI,'/exported_data');
lamin = h5read(lamin,'/exported_data');

%format data
DAPI = permute(DAPI,[3 2 4 1]);
lamin = permute(lamin,[3 2 4 1]);

nuc = DAPI(:,:,:,1);
edge = DAPI(:,:,:,2);
bgm = DAPI(:,:,:,3);

lam = lamin(:,:,:,2);
nuc2 = lamin(:,:,:,1);

%grid for interpolation
p = 4;
[X,Y,Z] = meshgrid(1/p:1/p:size(nuc,2),1/p:1/p:size(nuc,1),1:size(nuc,3));

% make edge image
newedges = lam.*edge.*(1-nuc).*(1-nuc2);
edges = interp3(newedges,X,Y,Z);
edges(edges<0.03)=0;
edges = edges * 2^16-1;

% make seeds
seeds = (1-lam).*nuc;
%seeds = imgaussfilt3(seeds,[2 2 1]);
seeds = interp3(seeds,X,Y,Z);
seeds = seeds > .6;
seeds = imfill(bwareaopen(seeds,500),'holes');

% %make background
bgm = interp3(bgm,X,Y,Z);
bgm = bgm >.84;

%edge add in
%ed = interp3(edge,X,Y,Z);

% watershed
%nuc = imgaussfilt3(im,[2 2 1]);
%DEi = interp3(nuc,X,Y,Z);
I2 = imimposemin(edges,seeds|bgm);
L = watershed(I2);
L = bwareaopen(L>0,5000);
L = L-bwareaopen(L,1000000);
%MIJ.createImage('cellnum',bwlabeln(L), true)
%L = imclearborder(L);
cellnum = bwlabeln(L);

save(savePathCh, 'cellnum');