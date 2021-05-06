function [ stitch ] = key_heightBlender (stitch, new_img, stitch_view)
% KEYENCE_HEIGHTBLENDER blends `new_img` into the stitch by remapping the
% image values into `new_img` so that they match those in the overlapping
% regions of the existing stitch
% 
% The signature for this function roughly matches that of `vision.AlphaBlender`
% PARAMETERS:
%  stitch :  existing stitch image
%  new_img : image to blend into `stitch`. Should be the same size as
%   `stitch` so its already been placed into the right spot in the stitch
    
    narginchk (3, 3)
    % find overlapping pixels that are nonzero
    [nzy, nzx] = find (stitch ~= 0 & new_img ~= 0);
    if isempty (nzy)                    % no overlap, just insert
        stitch = stitch + new_img;
    else
        % % figure out the transform between the two images
        % % this is just the least-squares solution
        % % TODO: this returns values for the x & y transform as well -- why?
        % keep = randperm (numel (nzy), 500);
        % nzy = transpose (nzy(keep)); nzx = transpose (nzx(keep));
        % src = cell2mat (arrayfun (@(r,c) matrixForSourcePoint (...
        %     r, c, new_img(r,c)), nzy', nzx', 'UniformOutput', false));
        % tar = cell2mat (arrayfun (@(r,c) [r,c,stitch(r,c)], ...
        %                           nzy, nzx, 'UniformOutput', false));
        % tar = tar';
        % T = double (src) \ double (tar);
        % T = reshape (T, 3, 3).';
        
        % % add the z-component, then use a 2D affine transformation to warp
        % % the image into the "right"(er) place
        % to_add = T(3,3);                % keep track of height offset
        % T(:,3) = [0 0 1]';              % HACK
        % new_img = imwarp (new_img, affine2d (T), 'OutputView', stitch_view);
        
        % fit surface to overlap region
        nzz = arrayfun(@(x,y) stitch(y,x)-new_img(y,x), nzx, nzy);
        surf_fit = fit ([nzx, nzy], nzz, 'poly11');
        % apply surface correction to image
        [nzy, nzx] = find (stitch==0 & new_img ~= 0);
        to_add = feval (surf_fit, nzx, nzy);
        for ii = 1:numel (nzy)
            row = nzy(ii); col = nzx(ii);
            stitch(row,col) = new_img(row,col) + to_add(ii);
        end
        
        % % just add the mean difference to new_img and move on
        % meanDiff = median (arrayfun (@(r,c) stitch(r,c)-new_img(r,c), nzy, nzx));
        % [nzy,nzx] = find (new_img ~= 0);
        % for ii = 1:numel (nzy)
        %     new_img(nzy(ii),nzx(ii)) = new_img(nzy(ii),nzx(ii)) + meanDiff;
        % end
        
        % and add the nonoverlapping parts to the image
        % [nzr,nzc] = find (stitch==0 & new_img ~= 0);
        % for ii = 1:numel(nzr)
        %     stitch(nzr(ii),nzc(ii)) = new_img(nzr(ii), nzc(ii)) + to_add;
        % end
    end
end


function [ M ] = matrixForSourcePoint (r, c, h)
% MATRIXFORSOURCEPOINT
    M = [r,c,h,0,0,0,0,0,0;
         0,0,0,r,c,h,0,0,0;
         0,0,0,0,0,0,r,c,h];
end
