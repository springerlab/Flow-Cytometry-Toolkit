function h = plothistseries(Z, varargin)
% PLOTHISTSERIES plots a series of vertically-rotated histograms. Usually
% the horizontal axis is time.
%
%   Created 20120922 JW
%   Updated 20131023 JW

% parse arguments, set defaults
p = inputParser;
addOptional(p,'xgrid',[],@isnumeric);
addOptional(p,'ygrid',[],@isnumeric);
addParamValue(p,'plottype','histograms',@ischar);
addParamValue(p,'peakheight',0.05,@isnumeric);
addParamValue(p,'color',[0 0 1],@isnumeric);
addParamValue(p,'alpha',1,@isnumeric);
addParamValue(p,'drawoutline',false,@islogical);
addParamValue(p,'plotoptions',{},@iscell);

parse(p,varargin{:});
xgrid = p.Results.xgrid;
ygrid = p.Results.ygrid;
peakheight = p.Results.peakheight;
color = p.Results.color;
alpha = p.Results.alpha;
drawoutline = p.Results.drawoutline;
plotoptions = p.Results.plotoptions;

% default x, y grids
if isempty(xgrid)
    xgrid = 1:size(Z,1);
end
if isempty(ygrid)
    ygrid = 1:size(Z,2);
end

scalefactor = size(Z,2).*mean(diff(xgrid)).*peakheight;

% assume 1st dim is time and 2nd dim is yfp bins
for ix = 1:size(Z,1)
    x = -scalefactor .* squeeze(Z(ix,:)) ...
        + xgrid(ix);
    y = ygrid;
    
    if drawoutline
        plot(x,y,'-','color',colors(1,:));
    end
    
    patch([x x(1)],[y y(1)],color,'facealpha',alpha,...
        'edgecolor','none',plotoptions{:});
    hold all
end

set(gca,'xticklabelmode','auto')
set(gca,'yticklabelmode','auto')
