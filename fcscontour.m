function [C,H] = fcscontour(X,Y,varargin)
%FCSCONTOUR makes a 2D contour plot of flow cytometry data.
%
% 
% Created / Last Updated
% 20160526 / 20160721
p = inputParser;
addParameter(p,'xi',[],@isnumeric);
addParameter(p,'yi',[],@isnumeric);
addParameter(p,'smrad',1,@isnumeric);
addParameter(p,'minp',1e-5,@isnumeric);
addParameter(p,'ncontours',5,@isnumeric);
addParameter(p,'color','r',@(x) true);
addParameter(p,'scatterplot',{'.','color',[.7 .7 .7],'markersize',3},@iscell);

parse(p,varargin{:});
xi = p.Results.xi;
yi = p.Results.yi;
smrad = p.Results.smrad;
minp = p.Results.minp;
ncontours = p.Results.ncontours;
color = p.Results.color;
scatterplot = p.Results.scatterplot;

if isempty(xi)
    xi = linspace(min(X),max(X),50);
end
if isempty(yi)
    yi = linspace(min(Y),max(Y),50);
end

d = hist3([X Y],{xi yi})./numel(X);

if ~isempty(scatterplot)
    plot(X,Y,scatterplot{:});
    hold all
end

d = imgaussfilt(d,smrad);
d(d <= minp) = nan;
d = log10(d);

[C,H]=contour(xi,yi,d',ncontours,'color',color);
