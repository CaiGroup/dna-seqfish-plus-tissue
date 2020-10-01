function tform = get2dtform(image1, image2, zSlices)
% function finds tform between two images using correlation fuction in
% MATLAB. The tform is from image2 reflected onto the reference image1.
%
% Get 2d tform of the median of each z-slice.
%
% Update 2/12/2019
% - changed function to get the median of each 2d transformation; 3d
% transformation changes the z-slice to equal 0 or more than the maximum
% zslice.
% 
%
% Future Additions: 
% 1. options for using a different imregconfig
%
% Author: Nico Pierson
% Date: 1/29/2019
% nicogpt@caltech.edu
% Modified: 2/12/2019


    % get all the 2d tforms between the images and grab the median
    [optimizer, metric] = imregconfig('multimodal');
    if zSlices < 16
        xTform = [];
        yTform = [];
        for z = 1:zSlices
            %med50 = round(median(zSlices));
            gettform = imregtform(image2(:,:,z), image1(:,:,z), 'translation', optimizer, metric);
            xTform = cat(2, xTform, gettform.T(3,1));
            yTform = cat(2, yTform, gettform.T(3,2));
        end
        medXtform = median(xTform);
        medYtform = median(yTform);
        tform = affine2d([1 0 0; 0 1 0; medXtform medYtform 1]);
    else
        tform = imregtform(image2, image1, 'translation', optimizer, metric);
    end



end