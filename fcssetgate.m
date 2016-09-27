function [ gateOut ] = fcssetgate( dat, nGate, gateplot, gatenameArray )
%FCSSETGATE will let user to design gate on dat, using plotting method
%specified in gateplot, the gatename is only used to prompt which gate is
%being created. all gates are created in gateOut

% Input:
%   dat: fcs data structure used in this package
%   nGate: the number of gate to be added manually
%   gateplot: a struct including fields to specify how to make a gate
%       xfunc: a function handle, used to convert x data
%       yfunc: a function handle, used to convert y data.
%       gatename: cell array of strings, the name for the game, will be
%       used for labeling plots and figures.

gatemethod = 'polygonfunc';

gateOut = struct(...
    'xfunc', gateplot.xfunc, ...
    'yfunc', gateplot.yfunc, ...
    'xcha', gateplot.xcha, ...
    'ycha', gateplot.ycha, ...
    'gatemethod', gatemethod, ...
    'gatename', gatenameArray ...
    );

[ figHandle, figLocation ] = createfig3('figClassName', 'Segmentation', 'figName', gatenameArray{1}, 'figsize', [6 6]);
formatax
printwidth = 3; set(gca, 'fontsize', convertFontsize('fontsize', 8, 'printwidth',printwidth))

quicklabel3(gateplot.xcha,gateplot.ycha,'', 'fontsize', convertFontsize('fontsize', 10, 'printwidth',printwidth));

datX = gateplot.xfunc(dat.(gateplot.xcha));
datY = gateplot.yfunc(dat.(gateplot.ycha));

plot(datX, datY, 'ko', 'markersize', 5)

for iGate = 1:nGate
    
    h = cornertxt(gatenameArray{iGate}, 'nw'...
        , 'fontsize', convertFontsize('fontsize', 12, 'printwidth',printwidth));
    
    tmp = ginput();
    tmp = [tmp(:,:); tmp(1,:)];
    
    plot(tmp(:,1), tmp(:,2), '-');
    
    %
    switch gatemethod
        case 'polygon'
            gateOut(iGate).polygon = tmp;
        case 'polygonfunc'
            gateOut(iGate).gatefunc = @(x, y) inpolygon(x, y, tmp(:,1), tmp(:,2));
    end
    
    delete(h)
    
    % eval(sprintf('%s = gateOut(%d);', gatenameArray{iGate}, iGate));
    % evalin('base', sprintf('%s = gateOut(%d);', gatenameArray{iGate}, iGate));
end

savefig3('eps', 'off')

end

