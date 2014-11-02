function h = plothistseries(Z, varargin)
% PLOTHISTSERIES plots a series of vertically-rotated histograms. Usually
% the horizontal axis is time.
%
%   Created 20120922 JW
%   Updated 20131023 JW

% parse arguments, set defaults
p = inputParser;
addOptional(p,'tgrid',[],@isnumeric);
addOptional(p,'ygrid',[],@isnumeric);
addParamValue(p,'plottype','histograms',@ischar);
addParamValue(p,'peakheight',0.05,@isnumeric);
addParamValue(p,'colors',[0 0 1],@isnumeric);
addParamValue(p,'drawoutline',false,@islogical);
addParamValue(p,'plotoptions',{},@iscell);

parse(p,varargin{:});
tgrid = p.Results.tgrid;
ygrid = p.Results.ygrid;
plottype = p.Results.plottype;
peakheight = p.Results.peakheight;
colors = p.Results.colors;
drawoutline = p.Results.drawoutline;
plotoptions = p.Results.plotoptions;


% default x, y grids
if isempty(tgrid)
    tgrid = 1:size(Z,1);
end
if isempty(ygrid)
    ygrid = 1:size(Z,2);
end

scalefactor = size(Z,2).*mean(diff(tgrid)).*peakheight;

if strcmp(plottype,'histograms')
    % assume 1st dim is time and 2nd dim is yfp bins
    for itime = 1:size(Z,1)
        x = -scalefactor .* squeeze(Z(itime,:)) ...
            + tgrid(itime);
        y = ygrid;
        
        if drawoutline
            plot(x,y,'-','color',colors(1,:));
        end
        
        patch([x x(1)],[y y(1)],colors(1,:),'facealpha',0.5,...
            'edgecolor','none',plotoptions{:});
        hold all
    end
    
    set(gca,'xticklabelmode','auto')
    set(gca,'yticklabelmode','auto')
    
elseif strcmp(plottype,'density')
    % density series
    imagesc(tgrid,ygrid, flipud(Z'));
%     pcolor(tgrid,ygrid,Z');   % TODO: correct pcolor off-by-one artifact
    colormap(flipud(bone));
    shading flat
end