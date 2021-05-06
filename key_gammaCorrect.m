function [ y ] = key_gammaCorrect (x, power)
%KEYENCE_GAMMACORRECT
    narginchk (1, 2)
    if nargin < 2, power = 0.45; end    % default gamma power
    
    % linear fitting constants
    slopeEq      = 2.8389;
    interceptEq  = -0.3851;
    slopeRt      = 445.7088;
    interceptRt  = 0.5506;
    % where to do which correction
    changePt = 38 * 256 + 102;
    lineMax  = 256 ^ 2 - 1;
    
    % do gamma correction
    y = zeros (size (x));               % preallocate
    y = y + (x>=0 & x<=changePt) .* (slopeEq .* x + interceptEq);
    y = y + (x>changePt & x<=lineMax) .* (slopeRt .* x.^power + interceptRt);
end