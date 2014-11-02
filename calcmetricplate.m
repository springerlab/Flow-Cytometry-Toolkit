function metrics = calcmetricplate(platedata, metricfunc, varargin)
% CALCMETRICPLATE calculates a metric from the data in each well /
% subpopulation of PLATEDATA.
%
% Created 20141021 by JW

% parse arguments, set defaults
if ~isa(metricfunc, 'function_handle')
    metricfunc = @meanmetric;
end

% calculate metrics
metrics = nan(size(platedata));

for r = 1:size(platedata,1)
    for c = 1:size(platedata,2)
        for ipop = 1:size(platedata,3)
            metrics(r,c,ipop) = metricfunc(platedata(r,c,ipop));
        end
    end
end