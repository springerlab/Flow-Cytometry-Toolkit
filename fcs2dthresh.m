function subpops = fcs2dthresh(data,chan,thresh)
% 20130411
xhi = log10(data.(chan{1}))>thresh(1);
yhi = log10(data.(chan{2}))>thresh(2);

popidx = [xhi & ~yhi, ~xhi & yhi, xhi & yhi, ~xhi & ~yhi];
subpops = fcsselect(data,popidx);