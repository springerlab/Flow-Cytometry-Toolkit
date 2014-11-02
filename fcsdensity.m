function out = fcsdensity(X,Y,varargin)
%FCSDENSITY makes a 2D heatmap of flow cytometry data.
%
%   Created 20120807 JW
p = inputParser;
addRequired(p,'X',@isnumeric);
addRequired(p,'Y',@isnumeric);
addParamValue(p,'xi',[],@isnumeric);
addParamValue(p,'yi',[],@isnumeric);
addParamValue(p,'nbins',[],@validate_nbins);
addParamValue(p,'cmap',flipud(bone),@isnumeric);
addParamValue(p,'plotstyle','density',@ischar);
addParamValue(p,'plotoptions',{'.'},@iscell);

parse(p,X,Y,varargin{:});
xi = p.Results.xi;
yi = p.Results.yi;
nbins = p.Results.nbins;
cmap = p.Results.cmap;
plotstyle = p.Results.plotstyle;
plotoptions = p.Results.plotoptions;

if isempty(nbins)
    % default: bin size adapted to plot pixel size
    set(gca,'Units','pixels')
    pos = get(gca,'position');
    set(gca,'Units','normalized')
    nx = floor(pos(3));
    ny = floor(pos(4));
    if strcmpi(plotstyle,'contour')
        nx = nx./2;
        ny = ny./2;
    end
elseif numel(nbins)==1   
    nx = nbins(1);
    ny=nx;
else  
    nx = nbins(1);
    ny = nbins(2);
end

if isempty(xi)
    xi = linspace(min(X),max(X),nx);
end
if isempty(yi)
    yi = linspace(min(Y),max(Y),ny);
end


if strcmpi(plotstyle,'density') 
    density = hist3([X Y],{xi yi})./numel(X);
    pcolor(xi,yi,density')
    shading flat
%     surf(xi,yi,density','edgecolor','none')
%     view([0 90])
    colormap(cmap);
    set(gca,'color',cmap(1,:));
    
elseif strcmpi(plotstyle,'contour')
    p=gkde2([X Y]);
    contour(p.x,p.y,p.pdf,20)
elseif strcmpi(plotstyle,'scatter');
    plot(X,Y,plotoptions{:});
end


function out = validate_nbins(nbins)
isnumeric(nbins) && any(numel(nbins)==[1 2]);
