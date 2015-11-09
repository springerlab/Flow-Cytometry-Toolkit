function subpops = fcsseg1d(data,chan,varargin)
% FCSSEG1D fits a 2-gaussian mixture model to one fluorescence channel
% (XFP) and forward scatter (SSC) data. Data for 2 subpopulations is
% returned:
%
%   subpops(1) contains XFP+ events
%   subpops(2) contains XFP- events
%
% 20130107
% Updated 20151004
p = inputParser;
addRequired(p,'data',@isstruct);
addRequired(p,'chan',@ischar);
addParamValue(p,'sizenorm',false,@islogical);
addParamValue(p,'helperchan','fsc',@ischar);
addParamValue(p,'makeplot',false,@islogical);
addParamValue(p,'plotoptions',{'.','markersize',3},@iscell);
addParamValue(p,'showlegend',false,@islogical);
addParamValue(p,'debug',false,@islogical);

parse(p,data,chan,varargin{:});
sizenorm = p.Results.sizenorm;
helperchan = p.Results.helperchan;
makeplot = p.Results.makeplot;
plotoptions = p.Results.plotoptions;
showlegend = p.Results.showlegend;
debug = p.Results.debug;

if sizenorm
    % normalize fluorescence by SSC (as proxy for cell size)
    xdata = log10(data.(chan)./data.ssc);
else
    xdata = log10(data.(chan));
end
ydata = log10(data.(helperchan));

% seed distributions from graythresh
xdataNor = mat2gray(xdata);
xdataBinary = im2bw(xdataNor, graythresh(xdataNor));

gm = gmdistribution.fit([xdata ydata],2, 'Start', double(xdataBinary)+1);

idx = cluster(gm,[xdata ydata]);
idx1 = (idx == 1);
idx2 = (idx == 2);
m1 = mean(xdata(idx1));
m2 = mean(xdata(idx2));

% ensure that cluster 2 always has higher mean
if m1 < m2
    tmp = idx1;
    idx1 = idx2;
    idx2 = tmp;
end

% debug - remove when everything is perfect
if debug
    fig = figure('position',[100 100 1900 800]);
    set(fig,'color','w')
    plot(xdata(idx1),ydata(idx1),'.')
    hold all
    plot(xdata(idx2),ydata(idx2),'.')
    xlabel(chan);
    ylabel('ssc');
end

subpops = fcsselect(data,[idx1 idx2]);