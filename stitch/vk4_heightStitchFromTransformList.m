function [ stitch ] = vk4_heightStitchFromTransformList ( imgs, tforms, ...
                                                      verbose)
% VK4_HEIGHTSTITCHFROMTRANSFORMLIST stitch the images 
    
    narginchk (2, 3);
    if nargin < 3, verbose = false; end
    N = numel (imgs);
    assert (N == numel (tforms), ['keyence_heightStitchFromTransformList :: ' ...
                        '# files doesnt equal # transforms']);
    img_is_numeric = isnumeric (imgs{1});
    % compute the limits (in world coordinates) of each transform
    xlim = zeros (numel (tforms), 2);
    ylim = zeros (numel (tforms), 2);
    for ii = 1:numel (tforms)
        if img_is_numeric
            [nrow, ncol] = size (imgs{ii});
        else
            [nrow, ncol] = size (imread (imgs{ii}));
        end
        [xlim(ii,:),ylim(ii,:)] = outputLimits (...
            tforms{ii}, [1 ncol], [1 nrow]);
    end
    % use the transform-output limits to figure out size of stitch
    xMin = min ([1; xlim(:)]);
    xMax = max ([ncol; xlim(:)]);
    yMin = min ([1; ylim(:)]);
    yMax = max ([nrow; ylim(:)]);
    width = round (xMax - xMin);
    height = round (yMax - yMin);
    
    if verbose, fprintf ('stitch will be %d x %d pix\n', height, width); end
    
    xLimits = [xMin, xMax];
    yLimits = [yMin, yMax];
    % preallocate
    stitch = zeros ([height, width], 'double');
    stitchView = imref2d ([height, width], xLimits, yLimits); % defines world
                                                              % coordinate
                                                              % system
    % loop over files to stitch together                      
    if verbose, revstr = ''; end
    for ii = 1:N                        
        % read the file in & warp it according to transform
        if img_is_numeric
            wI = double (imwarp (imgs{ii}, tforms{ii}, ...
                                 'OutputView', stitchView));
        else
            wI = double (imwarp (keyence_readTiff (imgs{ii}), tforms{ii}, ...
                                 'OutputView', stitchView));
        end
        % stitch into existing stitch
        stitch = keyence_heightBlender (stitch, wI, stitchView);
        if verbose
            percent_done = 100 * ii / N;
            msg = sprintf ('Stitching progress: %3.1f pct complete', percent_done);
            fprintf ([revstr, msg]);
            revstr = repmat(sprintf('\b'), 1, length(msg));
        end
    end
    if verbose, fprintf('\n'), end
end
