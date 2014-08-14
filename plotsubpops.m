function ha = plotsubpops(subpops,chans,varargin)
% 20130411
p = inputParser;
addParamValue(p,'plotoptions',{'.','markersize',3},@iscell);
parse(p,varargin{:});
plotoptions = p.Results.plotoptions;

colors = lines;

for ipop=1:length(subpops)
    xdata = log10(subpops(ipop).(chans{1}));
    ydata = log10(subpops(ipop).(chans{2}));
    plot(xdata,ydata,plotoptions{:},'color',colors(ipop,:))
    hold all
end