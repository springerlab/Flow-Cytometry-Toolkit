function [hf ha] = plotdoubgrad(platedata, varargin)
% PLOTDOUBGRAD plots a heat map of a metric calculated on a double
% gradient. If no metrics are provided, the mean yfp signal of each well is
% plotted. By default, the yfp histograms of each well are also overlaid on
% the heatmap.
%
% Created 20141021 by JW

% parse arguments, set defaults
p = inputParser;
addOptional(p,'metrics',[],@isnumeric);

parse(p,varargin{:});
metrics = p.Results.metrics;

% compute metrics if necessary
if isempty(metrics)
    metrics = calcmetricplate(platedata, @meanmetric);
end

% plot heatmap
nplots = size(metrics,3);

[hf ha] = gridplot(nplots,1,400,400);

climits = [];
for iplot = 1:nplots
    axes(ha(iplot))
    imagesc(flipud(metrics(:,:,iplot)));
    
    colormap(bone);
    
    % standardize color axis
    if isempty(climits)
        climits = caxis;
    else
        caxis(climits);
    end
end