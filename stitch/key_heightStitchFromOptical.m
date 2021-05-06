function [ hgt ] = key_heightStitchFromOptical ( optStitch, hgtFolder, refCfg, tarCfg )
%KEYENCE_HEIGHTSTITCHFROMOPTICAL constuct a stitch of the height images from
%a pre-stitched optical image
    narginchk (4, 4);
    % get size of image
    [nRow, nCol] = sizeOfImage (optStitch);
    hgt = zeros (nRow, nCol, 'uint32');
    
end

function [rows, cols] = sizeOfImage ( fpath_or_img )
%SIZEOFIMAGE
    if ischar (fpath_or_img)
        img = keyence_readTiff (fpath);
    else
        img = fpath_or_img;
    end
    x = size (img);
    rows = x(1); cols = x(2);
end