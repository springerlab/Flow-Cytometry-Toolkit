function h = plothistdensity(Z, varargin)
% PLOTHISTDENSITY plots a series of histograms as a heatmap. Usually the
% horizontal axis is time.
%
%   Created 20120922 JW
%   Updated 20131023 JW

% parse arguments, set defaults
p = inputParser;
addOptional(p,'tgrid',[],@isnumeric);
addOptional(p,'ygrid',[],@isnumeric);

parse(p,varargin{:});
tgrid = p.Results.tgrid;
ygrid = p.Results.ygrid;

% default x, y grids
if isempty(tgrid)
    tgrid = 1:size(Z,1);
end
if isempty(ygrid)
    ygrid = 1:size(Z,2);
end
% ensure all are row vectors
if size(tgrid,2) < size(tgrid,1)
    tgrid = tgrid';
end
if size(ygrid,2) < size(ygrid,1)
    ygrid = ygrid';
end

% plot density series
% imagesc(tgrid,ygrid, Z');
% axis xy

% pad data so that pcolor doesn't cut off last row+column of data
% see http://www.matlab-cookbook.com/recipes/0050_Plotting/0040_2D_Data/missing_pcolor_data.html
Zpadded = padarray(Z',[1,1],'post');
tgrid = [tgrid, tgrid(end) + mean(diff(tgrid))];
ygrid = [ygrid, ygrid(end) + mean(diff(ygrid))];

pcolor(tgrid, ygrid, Zpadded);   

colormap(flipud(bone));
shading flat