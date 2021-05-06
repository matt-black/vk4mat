function [ stitch ] = vk4_heightStitchFromTileCfg ( ...
    imgFolder, refCfg, tarCfg, dtype_out, verbose )
%VK4_HEIGHTSTITCHFROMTILECFG 
    narginchk (3, 5);
    if nargin < 5, verbose = false; end % be loud?
    
    % make sure the folder exists and all the files exist
    if not (exist (imgFolder) == 7)
        error ('keyence_heightStitchFromTileCfg :: imgFolder doesnt exist');
    end
    if not (exist (refCfg, 'file') == 2)
        error ('keyence_heightStitchFromTileCfg :: refCfg doesnt exist');
    end
    if not (exist (tarCfg, 'file') == 2)
        error ('keyence_heightStitchFromTileCfg :: tarCfg doesnt exist');
    end
    % get size of the images in `imgFolder`
    [nrow, ncol, ext, dtype] = imageProperties (imgFolder);
    if verbose, fprintf ('Images are %d x %d pix\n', ncol, nrow); end
    if nargin < 4                       % default datatype
        dtype_out = dtype;
    end
    [fnames, tforms, ~] = keyence_affineTransformBetweenTileCfgs (...
        refCfg, tarCfg, true);
    N = numel (fnames);                 % number of images to stitch
    if verbose, fprintf ('%d images in stitch\n', N); end
    
    fpaths = cellfun (@(f) fullfile (imgFolder, strcat (f, '.', ext)), ...
                      fnames, 'UniformOutput', false);
    stitch = keyence_heightStitchFromTransformList (fpaths, tforms, verbose);
    
    % % compute the limits (in world coordinates) of each transform
    % xlim = zeros (numel (tforms), 2);
    % ylim = zeros (numel (tforms), 2);
    % for ii = 1:numel (tforms)
    %     [xlim(ii,:),ylim(ii,:)] = outputLimits (...
    %         tforms{ii}, [1 ncol], [1 nrow]);
    % end
    % % use the transform-output limits to figure out size of stitch
    % xMin = min ([1; xlim(:)]);
    % xMax = max ([ncol; xlim(:)]);
    % yMin = min ([1; ylim(:)]);
    % yMax = max ([nrow; ylim(:)]);
    % width = round (xMax - xMin);
    % height = round (yMax - yMin);
    % if verbose, fprintf ('stitch will be %d x %d pix\n', height, width); end
    
    % xLimits = [xMin, xMax];
    % yLimits = [yMin, yMax];
    
    % % preallocate
    % stitch = zeros ([height, width], 'double');
    % stitchView = imref2d ([height, width], xLimits, yLimits); % defines world
    %                                                           % coordinate
    %                                                           % system
    % % loop over files to stitch together                      
    % if verbose, revstr = ''; end
    % for ii = 1:N                        
    %     % read the file in & warp it according to transform
    %     fname = fullfile (imgFolder, sprintf ('%s.%s', fnames{ii}, ext));
    %     wI = double (imwarp (keyence_readTiff (fname), tforms{ii}, ...
    %                          'OutputView', stitchView));
    %     % stitch into existing stitch
    %     stitch = keyence_heightBlender (stitch, wI, stitchView);
    %     if verbose
    %         percent_done = 100 * ii / N;
    %         msg = sprintf ('Stitching progress: %3.1f pct complete', percent_done);
    %         fprintf ([revstr, msg]);
    %         revstr = repmat(sprintf('\b'), 1, length(msg));
    %     end
    % end
    % if verbose, fprintf('\n'), end
    
    switch dtype_out
      case 'double'
        return
      case 'single'
        stitch = single (stitch);
        return
      case 'uint64'
        ol = intmin (dtype_out);
        oh = intmax (dtype_out);
        fn = @(a) uint64 (a);
      case 'uint32'
        ol = intmin (dtype_out);
        oh = intmax (dtype_out);
        fn = @(a) uint32 (a);
      case 'uint16'
        ol = intmin (dtype_out);
        oh = intmax (dtype_out);
        fn = @(a) uint16 (a);
      case 'uint8'
        ol = intmin (dtype_out);
        oh = intmax (dtype_out);
        fn = @(a) uint8 (a);
      case 'int8'
        ol = intmin (dtype_out);
        oh = intmax (dtype_out);
        fn = @(a) int8 (a);
      case 'int16'
        ol = intmin (dtype_out);
        oh = intmax (dtype_out);
        fn = @(a) int16 (a);
      case 'int32'
        ol = intmin (dtype_out);
        oh = intmax (dtype_out);
        fn = @(a) int32 (a);
      case 'int64'
        ol = intmin (dtype_out);
        oh = intmax (dtype_out);
        fn = @(a) int64 (a);
      otherwise
        error ('keyence_heightStitchFromTileCfg :: invalid datatype (%s)', ...
               dtype_out)
    end
    il = min (min (stitch)); ol = double (ol);
    ih = max (max (stitch)); oh = double (oh);
    convFn = @(x) fn (round ((x-il)/(ih-il) * (oh-ol)));
    stitch = convFn (stitch);
end

function [ row, col, ext, dtype ] = imageProperties ( imgFolder )
%IMAGESIZES get the size of the images in `imgFolder`
    dir_list = dir (imgFolder);
    % find the first TIF(F) file
    exts  = arrayfun (@getFileExtension, dir_list, 'UniformOutput', false);
    isTif = cellfun (@isTiff, exts);
    index = find (isTif, 1, 'first');
    % get image path
    fpath = fullfile (imgFolder, dir_list(index).name);
    % get file extension
    [~, ~, ext] = fileparts (fpath);
    if strcmp(ext(1), '.'), ext = ext(2:end); end
    % load file, get size
    img = keyence_readTiff (fpath);
    dtype = class (img);
    [row, col] = size (img);
end

function [ bool ] = isTiff (ext)
% ISTIFF check if the extension is tif
    bool = strcmp (ext, 'tif') | strcmp (ext, 'tiff') | ...
           strcmp (ext, '.tif') | strcmp (ext, '.tiff');
end

function [ ext ] = getFileExtension ( dirEntry )
    [~, ~, ext] = fileparts (dirEntry.name);
    ext = ext(2:end);                   % get rid of period
end