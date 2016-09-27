function metric = meanmetric(fcdata)
% MEANMETRIC calculates the log10(mean(yfp)) of some flow cytometry data.
%
% Created 20141021 by JW
% Updated 20160118 by CR

metric = log10(mean(fcdata.yfp));