function [subpops, regions] = ...
    WatershedSegMchBfp(fcdata, nclusters, makeplot)
% 20160301

if ~exist('makeplot','var')
    makeplot = false;
end

segFracThresh = 0.9;
nbins = 200;
smRadius = 10;
nContours = 20;
% maxEccentricity = 0.7;

fcdata = fcsselect(fcdata, fcdata.ssc<9999 & fcdata.fsc<9999);

xdata = log10(fcdata.mch./fcdata.ssc);
ydata = log10(fcdata.bfp./fcdata.ssc);

% xi = linspace(min(xdata), max(xdata),500);
% yi = linspace(min(ydata), max(ydata),500);
xi = linspace(-3.5, -.5, nbins);
yi = linspace(-3.5, -.5, nbins);

density = hist3([xdata ydata],{xi yi})./numel(xdata);
density = density';
density = imgaussfilt(density,smRadius);

lab = watershed(-density);

fracEvents = arrayfun(@(x) sum(density(lab==x)), 1:max(lab(:)));
[~,idx] = sort(fracEvents,'descend');
if length(idx)<nclusters
    warning('Watershed segmentation failed.');
    subpops = [];
    return;
end
ifilt = idx(1:nclusters);

goodBounds = {};
meanMchBfpRatio = nan(length(ifilt),1);

for ireg = 1:length(ifilt)
    density2 = zeros(size(density));
    density2(lab==ifilt(ireg)) = density(lab==ifilt(ireg));
    density2 = density2./sum(density2(:));
    
    allpx = density2(density2>0);
    
    allThresh = logspace(log10(max(allpx)),log10(min(allpx))+1,nContours);
    for ith = 1:length(allThresh)
        bw = im2bw(density2,allThresh(ith));
        
        [B,L] = bwboundaries(bw);
        %         rp = regionprops(L,'Eccentricity');
        nreg = max(L(:));
        
        f = arrayfun(@(x) sum(density2(L==x)), 1:nreg);
        
        density3 = density2;
        density3(L~=1) = 0;
        
        if nreg == 1 && f > segFracThresh
            goodBounds{ireg} = B{1};
            px = sum(density3,1);
            bfpMean = sum(px.*xi)./sum(px);
            py = sum(density3,2);
            mchMean = sum(py'.*yi)./sum(py);
            meanMchBfpRatio(ireg) = mchMean./bfpMean;
            break
        end
    end
end

if length(goodBounds)<nclusters
    warning('Watershed segmentation failed.');
    subpops = [];
    return;
end

% sort regions by mean mch/bfp ratio
idx = cellfun(@isempty,goodBounds);
goodBounds(idx) = [];
meanMchBfpRatio(idx) = [];
[meanMchBfpRatio,idx] = sort(meanMchBfpRatio,'descend');
goodBounds = goodBounds(idx);

allidx = zeros(fcsnumel(fcdata),1);
clear subpops;
colors = lines;
for ipop=1:length(goodBounds)
    boundPx = goodBounds{ipop};
    x = xi(boundPx(:,2));
    y = yi(boundPx(:,1));
    
    idx = inpolygon(xdata,ydata, x,y);
    subpops(ipop) = fcsselect(fcdata,idx);
    
    if makeplot
        plot(xdata(idx),ydata(idx),'.','color',colors(ipop,:),'markersize',3);
        hold all
        plot(x,y,'color',colors(ipop,:),'LineWidth',0.5);
    end
    
    allidx = allidx | idx;
end

if makeplot
    plot(xdata(~allidx),ydata(~allidx),'k.','markersize',3);
end

regions = goodBounds;