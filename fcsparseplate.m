function [platedata, platemeta] = fcsparseplate(datadir, platename, varargin)
% FCSPARSEPLATE loads flow cytometry data from a 8x12 plate and returns a
% struct array (matrix) containing the results. After this you can call
% FCSSEGPLATE to automatically segment the entire plates' data.
% 
% Created 20141021 by JW

tic

% if LSRII, data is in a subfolder called PLATENAME
path = dir([datadir platename]);
if ~isempty(path) && path(1).isdir
    datadir = [datadir platename '/'];
end

% make a new filename cache in case there is an outdated existing cache
makewellfilenameindex(datadir);
    
% load a 96-well plate of data
fprintf(['Loading plate "' platename '": well    \n']);

platedata = [];
platemeta = [];

for r = 1:8
    for c = 1:12
        fprintf([ '\b\b\b\b' coord2well(r,c) '\n']);    % gives "scrolling" feedback
        [data meta] = fcsparsewell(datadir, platename, [r c]);
        if isempty(data) || fcsisempty(data)
            continue;
        end
        
        if r==1 && c == 1
            platedata = data;
            platemeta = meta;
        else
            platedata(r,c) = data;
            platemeta(r,c) = meta;
        end
    end
end

fprintf('Finished loading. ');
toc
end