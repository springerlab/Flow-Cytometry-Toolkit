function [ data_new ] = fcsstruct( para )
%fcsstruct Create a new emptyfcs struct
%   Detailed explanation goes here

if nargin < 1
    data_new = struct;
else
    for para_name = para'
        data_new.(para_name{1}) = [];
    end

end

end

