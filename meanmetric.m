function metric = meanmetric(fcdata)
% MEANMETRIC calculates the mean log10(yfp) of some flow cytometry data.
%
% Created 20141021 by JW

metric = log10(mean(fcdata.yfp));