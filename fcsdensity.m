function out = fcsdensity(X,Y,varargin)
%FCSDENSITY makes a 2D heatmap of flow cytometry data.
%
% Created 20120807 JW
% Edited 20160526 JW  
p = inputParser;
addParameter(p,'xi',[],@isnumeric);
addParameter(p,'yi',[],@isnumeric);

parse(p,varargin{:});
xi = p.Results.xi;
yi = p.Results.yi;

if isempty(xi)
    xi = linspace(min(X),max(X),50);
end
if isempty(yi)
    yi = linspace(min(Y),max(Y),50);
end

density = hist3([X Y],{xi yi})./numel(X);
imagesc(xi,yi,density')
ax=gca;
ax.YDir = 'normal';
cmap = flipud(bone);
colormap(cmap);
set(gca,'color',cmap(1,:));

out = density;