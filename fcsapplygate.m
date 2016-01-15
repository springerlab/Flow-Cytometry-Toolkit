function [ datOut ] = fcsapplygate( datIn, gate)
%FCSAPPLYGATE, apply gate on datIn, and output datOut
% example of gate,
%   gate.xfunc = @(x) log2(x);
%   gate.yfunc = @(y) log2(y);
%   gate.xcha = 'ssc';
%   gate.ycha = 'fsc';
%   gate.polygon = sscfscgate;

switch gate.gatemethod
    case 'polygon'
        datX = gate.xfunc(datIn.(gate.xcha));
        datY = gate.yfunc(datIn.(gate.ycha));
        
        gatePolygon = gate.polygon;
        datOut = fcsselect ( datIn, inpolygon(datX, datY, gatePolygon(:,1), gatePolygon(:,2)) );
    case 'polygonfunc'
        datX = gate.xfunc(datIn.(gate.xcha));
        datY = gate.yfunc(datIn.(gate.ycha));
        
        gatefunc = gate.gatefunc;
        datOut = fcsselect( datIn, gatefunc(datX, datY));
        
    case 'range1d'
        datX = gate.xfunc(datIn.(gate.xcha));
        
        gatefunc = gate.rangefunc;
        datOut = fcsselect( datIn, gatefunc(datX));
end

end