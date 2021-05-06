function [ fnames, tforms, refCoords ] = vk4_affineTransformBetweenTileCfgs ( refCfg, tarCfg, rel_to_first )
%VK4_AFFINETRANSFORMBETWEENTILECFGS compute affine transform between all
%the tiles in the reference & target configurations
%
% All transforms are assumed purely translational
    narginchk (2, 3);
    if nargin < 3, rel_to_first = false; end
    
    [fnames, refCoords] = keyence_readStitchTileCfg (refCfg);
    [tarNames, tarCoords] = keyence_readStitchTileCfg (tarCfg);
    function [ coord ] = targetCoord4Ref ( name )
        ind = find (cellfun (@(n) strcmp (n, name), tarNames), 1);
        coord = tarCoords(ind,:);
    end
    tarCoords = cellfun (@targetCoord4Ref, fnames, ...
        'UniformOutput', false)';
    refCoords = num2cell (refCoords, 2);
    if rel_to_first
        tforms = cellfun (@(r,t) makeTranslationalAffineRelFirst (...
            r, t, refCoords{1}), refCoords, tarCoords, ...
            'UniformOutput', false);
    else
        tforms = cellfun (@makeTranslationalAffine, ...
            refCoords, tarCoords, ...
            'UniformOutput', false);
    end
end

function [ aff ] = makeTranslationalAffine (ref, tar)
%MAKEAFFINE take the two input coordinates and construct a purely
%translational affine transformation between them
    aff = affine2d ([1, 0, tar(1)-ref(1);
                     0, 1, tar(2)-ref(2);
                     0, 0, 1]');
end

function [ aff ] = makeTranslationalAffineRelFirst (ref, tar, fst)
    baseT = affine2d ([1, 0, ref(1)-fst(1);
                       0, 1, ref(2)-fst(2);
                       0, 0, 1]');
    affT = affine2d ([1, 0, tar(1)-ref(1)-fst(1);
                     0, 1, tar(2)-ref(2)-fst(2);
                     0, 0, 1]');
    aff = affine2d (baseT.T * affT.T);
end