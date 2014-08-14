function h=plothistseries2(xgrid,ygrid,z)
%PLOTHISTSERIES2 makes an intensity plot of a histogram series.
% 
%   Created 20120922 JW
%   revamped 20130322
%   20130417 revamped to use pcolor; renamed to plothistseries2
pcolor(xgrid,ygrid,z)
colormap(flipud(bone));
shading flat