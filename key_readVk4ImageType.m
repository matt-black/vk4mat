function [ img ] = key_readVk4ImageType (vk4_file, image_type)
%KEYENCE_READVK4IMAGETYPE read an image from a vk4 file
%
% PARAMETERS
%   vk4_file : file path or fileID 
%   image_type : the type of image to read from the file, one of 
%     ['optical', 'laser+optical', 'intensity', 'height'] 
%     or ['o', 'lo', 'i', 'h']
% OUTPUTS
%   img : image data
%     for 'optical' and 'laser+optical' images, type is `uint8`, dimension is [r,c,3]
%     for 'intensity' and 'height' images, type is `uint32`, dimension is [r,c]
%     height data is returned in the output units of the microscope. to
%     convert those to microns, divide the output by 10^4
    narginchk (2, 2);                   
    % sanitize the `image_type` input
    image_type = lower (image_type);
    switch image_type
      case 'optical', image_type = 'o';
      case 'laser+optical', image_type = 'lo';
      case 'intensity', image_type = 'i';
      case 'height', image_type = 'h';
    end
    switch image_type
      case 'o'
        image_off = 2;
      case 'lo'
        image_off = 3;
      case 'i'
        image_off = 4;
      case 'h'
        image_off = 7;
      otherwise
        error ('keyence_readVk4ImageType :: invalid image type, %s', ...
               image_type);
    end
    
    % grab binary & hex data
    bin_data = keyence_readVk4Binary (vk4_file); 
    % compute offsets
    [offsets, bases] = keyence_computeVk4Offsets (bin_data);
    
    % whether or not its an "optical" image affects read location
    is_optical = or (strcmp (image_type, 'o'), ...
                     strcmp (image_type, 'lo'));
    if is_optical
        strt_addoff = 21;
    else
        strt_addoff = 797;
    end
    % read the image
    end_offset = min (offsets((offsets-offsets(image_off)) > 0));
    raw_img = bin_data(offsets(image_off)+strt_addoff:end_offset)';
    
    % figure out some parameters for the image
    rows = bin_data(offsets(image_off)+1:offsets(image_off)+4)' * bases;
    % disp(rows)
    cols = bin_data(offsets(image_off)+5:offsets(image_off)+8)' * bases;
    % disp(cols)
    coding_base = bin_data(offsets(image_off)+9:offsets(image_off)+12)' * ...
        bases;                          % unsigned integer size
    largest_allow = bin_data(offsets(image_off)+29:offsets(image_off)+32)' * ...
        bases;                          % largest allowed value
    
    % figure out what type of image to output
    switch coding_base
      case 16
        convFn = @(A) uint16 (A);       % 16 bit image
      case 24                           % this is an RGB (so you have 3x8bit)
        convFn = @(A) uint8 (A);
      case 32                           % 32 bit image
        convFn = @(A) uint32 (A);
      otherwise
        % HACK: Cassidy's optical images give 0 coding base (TODO: why?)
        % I don't know what's going on or why exactly, but we know optical
        % images always have base 24 b/c they're 8-bit RGB, so we'll just
        % add in this special case to catch this error
        if coding_base == 0 & is_optical
            convFn = @(A) uint8 (A);
        else
            error ('keyence_readVk4ImageType :: unknown coding base (%d)', ...
               coding_base);
        end
        
    end
    % reshape image
    if is_optical                       % reshape optical images to (R x C x 3)
        img = reshape (reshape (raw_img, 3, rows*cols)', ...
                       [rows cols 3]);
        % now reshape so that it matches Keyence software (rows <-> cols)
        img = permute (img, [2, 1, 3]);
    else                                % reshape is dependent on type
        switch image_type
          case 'i'                     % laser intensity
            img = reshape (raw_img, 2, rows*cols)' * [1 16^2]';
            img = reshape (img, rows, cols);
          case 'h'                      % height
            img = reshape (raw_img, 4, rows*cols)' * bases;
            img = reshape (img, rows, cols);
            % convert units to microns
            % NOTE: conversion factor is 10^4 (per Katie)
            % img = img ./ 10^4;  
          otherwise
            error ('keyence_readVk4ImageType :: shouldnt get here');
        end
        img = transpose (img);          % switch rows & cols
    end
    % convert the image to the write unsigned integer type
    img = convFn (img);
end