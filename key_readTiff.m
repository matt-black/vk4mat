function [ imgData ] = key_readTiff ( file_path )
%KEYENCE_READTIFF read the TIFF file at `file_path`
% This handles making sure the file is properly closed so that the reference
% doesn't get left hanging
    tiffFile = Tiff (file_path, 'r');
    try
        imgData = read (tiffFile);
    catch err
        tiffFile.close();
        imgData = NaN;
        rethrow (err);
    end
    % make sure the file closed
    tiffFile.close();
end
