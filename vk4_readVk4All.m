function [ varargout ] = vk4_readVk4All (vk4_file)
%VK4_READVK4ALL read all images in a Vk4 file
%
% PARAMETERS
%   vk4_file : file path or fileID
%   gamma_power : power for gamma correction (0 = do not gamma correct)
%     if you want to gamma correct but don't know what power to use, use 0.45
% OUTPUTS
%   varargout : images in order optical, laser+optical, intensity, height
%     1 outputs, returns all images in single cell array
%     4 outputs, [optical, laser+optical, intensity, height]
    narginchk (1, 2);
    nargoutchk (1, 4);
    if nargout == 2 || nargout == 3
        error ('vk4_readVk4All :: invalid # output args, must be 1 or 4')
    end
    
    types = { 'o', 'lo', 'i', 'h' };
    if nargout == 1
        varargout{1:nargout} = cellfun (@(t) vk4_readVk4ImageType (...
            vk4_file, t), {'o', 'lo', 'i', 'h'}, ...
                                        'UniformOutput', false);
    else                                % nargout == 4
        varargout = cell (4, 1);
        for t = 1:numel(types)
            varargout{t} = vk4_readVk4ImageType (...
                vk4_file, types{t});
        end
    end 
end