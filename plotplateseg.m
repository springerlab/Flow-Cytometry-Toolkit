function [hf ha] = plotplateseg(platedata, varargin)
% PLOTPLATESEG plots the results of a segmentation (such as obtained from
% FCSSEGPLATE) on an entire 96-well plate, as scatter plots of Fluor1
% versus Fluor2 with different colors for different segmented
% subpopulations.
%
% By default, Fluor1 = 'mch' and Fluor2 = 'bfp'. You can change what is
% plotted by setting the parameter FLUORS to a cell array containing 2
% strings.
%
% Created 20141021 by JW

% parse arguments, set defaults
p = inputParser;
addParamValue(p,'fluors',{'mch','bfp'},@iscell);
addParamValue(p,'plotoptions',{'.','markersize',3},@iscell);
addParamValue(p,'colors',[1 0 0; 0 0 1; 1 0 1; .5 .5 .5],@isnumeric);
addParamValue(p,'xlimit',[0 4],@isnumeric);
addParamValue(p,'ylimit',[0 4],@isnumeric);
addParamValue(p,'panelsize',[],@isnumeric);

parse(p,varargin{:});
fluors = p.Results.fluors;
plotoptions = p.Results.plotoptions;
colors = p.Results.colors;
xlimit = p.Results.xlimit;
ylimit = p.Results.ylimit;
panelsize = p.Results.panelsize;

if isempty(panelsize)
    screensize = get(0,'screensize');
    panelsize = min((screensize(3) - 100)./12, (screensize(4) - 100)./8);
end

[hf ha] = gridplot(8,12,panelsize,panelsize,'gapvert',2,'gaphorz',2);

for r = 1:8
    for c = 1:12
        axes(ha(sub2ind([12 8],c,r)));
        
        for ipop = 1:size(platedata,3)
            x = log10(platedata(r,c,ipop).(fluors{1}));
            y = log10(platedata(r,c,ipop).(fluors{2}));
            
            if ipop == size(platedata,3)
                col = colors(end,:);
            else
                col = colors(ipop,:);
            end
            
            plot(x,y,plotoptions{:},'color',col)
            hold all
        end
        
        xlim(xlimit);
        ylim(ylimit);
        xlabel(fluors{1});
        ylabel(fluors{2});
        
        adjustaxeslabels([8 12],[r c],1);
    end
end