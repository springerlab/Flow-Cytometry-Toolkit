function [ rate ] = fcsestimaterate2( dataT, varargin )
%fcsestimaterate2 Estimate the number of cells per second
%   Detailed explanation goes here

% dataT = sort(dataT, ascend);

if length(dataT) < 10
    rate = NaN;
    return
end

rangeMin = 0.3;
rangeMax = 0.7;

% nCount = length(dataT);
% nCountRange = ceil([rangeMin, rangeMax] * nCount);
% 
% dataTFilter = dataT([nCountRange(1):nCountRange(2)]);

dataTFilter = dataT;

dataTMax = max(dataTFilter);
dataTMin = min(dataTFilter);

dataThreMin = dataTMin + rangeMin*(dataTMax-dataTMin);
dataThreMax = dataTMin + rangeMax*(dataTMax-dataTMin);

counts = length(find(dataTFilter > dataThreMin & dataTFilter < dataThreMax));
rate = counts/(dataThreMax - dataThreMin);

end
