function [ ok, out_path ] = vk4_saveTiff ( img, out_path )
%VK4_SAVETIFF save the image array as a Tiff file
% this takes care of making sure the Tiff is properly formatted and that the
% data is encoded into the TIF losslessly from the 
    img_type = class (img);
    switch img_type
      case 'uint8'
        img_colSpc = Tiff.Photometric.RGB;
        img_bps = 8;
        img_spp = 3;
      case 'uint16'
        img_colSpc = Tiff.Photometric.MinIsBlack;
        img_bps = 16;
        img_spp = 1;
      case 'uint32'
        img_colSpc = Tiff.Photometric.MinIsBlack;
        img_bps = 32;
        img_spp = 1;
      otherwise
        error ('keyence_saveTiff :: unknown image type (%s)', img_type);
    end
    % build up structure of tags for TIFF
    tagStruct = struct ('ImageLength', size (img, 1), ...
                        'ImageWidth', size (img, 2), ...
                        'Photometric', img_colSpc, ...
                        'PlanarConfiguration', Tiff.PlanarConfiguration.Chunky, ...
                        'SampleFormat', Tiff.SampleFormat.UInt, ...
                        'BitsPerSample', img_bps, ...
                        'SamplesPerPixel', img_spp, ...
                        'Software', 'MATLAB');
    % write the image
    t = Tiff (out_path, 'w');
    try
        t.setTag (tagStruct);
        t.write (img);
        ok = true;
    catch me
        disp (getReport (me, 'extended', 'hyperlinks', 'on'));
        ok = false;
    end
    t.close();
end