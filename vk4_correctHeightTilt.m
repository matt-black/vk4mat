function [ H_corr ] = vk4_correctHeightTilt ( hgtImg, method )
%VK4_CORRECTHEIGHTTILT corrects tilts in height image
    if ischar (hgtImg)
        [~, ~, ext] = fileparts (hgtImg);
        ext = lower (ext(2:end));
        switch ext
          case 'vk4'                  % read in height image
            hgtImg = vk4_readImageType (hgtImg, 'h');
          case 'tif'
            hgtImg = vk4_readTiff (hgtImg);
          case 'tiff'
            hgtImg = vk4_readTiff (hgtImg);
          otherwise 
            error ('vk4_correctHeightTilt :: Unknown file type %s', ext)
        end
    end
    hgtImg = double (hgtImg); 
    % make sure we have a numeric array to work with
    assert (isnumeric (hgtImg), ['vk4_correctHeightTilt :: hgtImg isnt' ...
                        ' a numeric']);
    method = lower (method);
    switch method
      case 'curvature'
        H_corr = correctHeightTiltByCurvFilt (hgtImg);
      case 'linfitedge'
        H_corr = correctHeightTiltByEdgeLine (hgtImg);
      otherwise
        error ('vk4_correctHeightTilt :: unknown method %s', method)
    end
end

function [ H_corr ] = correctHeightTiltByCurvFilt ( hgtImg )
%CORRECTHEIGHTTILTBYCURVFILT
    [Xm,Ym] = meshgrid (1:size(hgtImg,2), 1:size(hgtImg,1));
    [K, H] = surfature (Xm, Ym, imgaussfilt (hgtImg, 10));
    lowBound = quantile (K, 0.2);
    mask = hgtImg < quantile (hgtImg, 0.33) & K < quantile (K, 0.33);
    Xs = Xm(mask); Ys = Ym(mask); Hs = hgtImg(mask);
    surfFit = fit ([Xs, Ys], Hs, 'poly11');
    H_corr = hgtImg - feval (surfFit, Xm, Ym);
end

function [ H_corr ] = correctHeightTiltByEdgeLine ( hgtImg )
%CORRECTHEIGHTTILTBYEDGELINE
    imgSze = size (hgtImg);
    
    % 
    rows = (1:imgSze(1))';
    rvals = mean (hgtImg(:,1:11), 2);
    rvals2 = mean (hgtImg(:,end-11:end), 2);
    rcols = ones (size (rvals)) .* mean (1:11);
    rcols2 = ones (size (rvals2)) .* mean ((imgSze(2)-11):imgSze(2));
    
    cols = (1:imgSze(2))';
    cvals = mean (hgtImg(1:11,:), 1)';
    cvals2 = mean (hgtImg(end-11:end,:), 1)';
    crows = ones (size (cvals)) .* mean (1:11);
    crows2 = ones (size (cvals2)) .* mean ((imgSze(1)-11):imgSze(1));
    
    Xs = vertcat (cols, cols, rcols, rcols2);
    Ys = vertcat (crows, crows2, rows, rows);
    Hs = vertcat (cvals, cvals2, rvals, rvals2);
    surfFit = fit ([Xs, Ys], Hs, 'poly11');
    [Xm, Ym] = meshgrid (1:size(hgtImg,2), 1:size(hgtImg,1));
    H_corr = hgtImg - feval (surfFit, Xm, Ym);
end