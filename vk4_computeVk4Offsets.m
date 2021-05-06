function [ offsets, bases ] = vk4_computeVk4Offsets (bin_data)
%VK4_COMPUTEVK4OFFSETS compute offsets for where to read data from
% 
% PARAMETERS
%   bin_data : 
% OUTPUTS
%   offsets : 
    bases = transpose (arrayfun (@(p) 16^p, 0:2:6));
    offsets = zeros (18, 1);            % preallocate
    for io = 1:18
        i1 = 12 + 4 * (io - 1) + 1;
        offsets(io) = transpose (bin_data(i1:i1+3)) * bases;
    end
end