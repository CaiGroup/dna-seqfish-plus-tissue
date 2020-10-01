function [pointsSR, intensitySR] = SuperResPoints(points,image,xyPixSize,zPixSize)
%#codegen
pointsSR = points;
intensitySR = zeros(size(points, 1), 1);

[y,x,z] = size(image);
for k = size(points,1):-1:1
    
    if points(k,2)-1 == 0 || points(k,2)+1 > y ||...
       points(k,1)-1 == 0 || points(k,1)+1 > x ||...
       points(k,3)-1 == 0 || points(k,3)+1 > z
        pointsSR(k,:) = 0;
        intensitySR(k,:) = 0;
    else   
        I = image(points(k,2)-1:points(k,2)+1,...
                               points(k,1)-1:points(k,1)+1,...
                               points(k,3)-1:points(k,3)+1);
        [rc, sigma] = radialcenter3D(double(I), zPixSize/xyPixSize);
        rc([1 2]) = rc([2 1]);
        pointsSR(k,:) =((rc-[2;2;3]+points(k,:)').*[xyPixSize;xyPixSize;zPixSize])';
        intensitySR(k) = sigma;
    end
end
