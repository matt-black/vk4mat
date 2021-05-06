function [ binary_data ] = vk4_readVk4Binary (vk4_file)
%VK4_READVK4 read data from a *.VK4 file
%
% PARAMETERS:
%   fpath : path to VK4 file or 
%   
% SEE: Los Alamos doc on how to do it
% https://permalink.lanl.gov/object/tr?what=info:lanl-repo/lareport/LA-UR-18-20810
    narginchk (1, 1);
    % see if we have a fileID or a filepath
    input_is_fpath = strcmp (class (vk4_file), 'char');
    if input_is_fpath
        vk4_file = fopen (vk4_file);
    end
    
    % read in binary data & convert to hex
    binary_data = fread (vk4_file, 'ubit8');
    %vk4_hex = dec2hex (vk4_bin);
    
    % if they gave us a file path, close the reference we made
    if input_is_fpath
        fclose (vk4_file);
    end
end