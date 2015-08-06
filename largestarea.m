function [ outputimage ] = largestarea( inputimage )
%largestarea filters all the pixels of a bw image by size and keep only the
%largest one.
%   [ outputimage ] = largestarea( inputimage )

if max(inputimage(:))>0
    % Label image
    area_labeled=uint16(bwlabel(inputimage > 0,8));

    % Get all the areas
    area_struct=regionprops(area_labeled,'Area');

    % Convert areas to matrix form
    area_mat=cell2mat({area_struct.Area});

    % Find max
    [~, maxindex] = max(area_mat);

    % Output
    outputimage = area_labeled == maxindex;
else
    % There is nothing to do here
    outputimage = inputimage;
end

end

