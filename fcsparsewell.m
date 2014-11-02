function [data, meta] = fcsparsewell(datadir, platename, wellid)
% FCSPARSEWELL loads fcs data from a file whose name begins with the string
% PLATENAME and whose header identifies it as being from well WELLID. The
% function relies on the metadata contained in the FCS header to determine
% the well corresponding to a certain file.
% 
% This function used to be called LOADWELLDATA and FCSREADWELL but was
% renamed to be consistent with other functions.
% 
% Example:
% 
%   fcsreadwell('../data/','plate1','A01')
% 
% loads data for well A01 from a file such as 'plate1_001_001.fcs'
% 
% Created 20130310, updated 20141021 by JW

% load filename cache
global wellfilenameindex;
try
    load([datadir 'wellfilenameindex.mat']);
catch
    disp('No filename cache found. Generating...');
    makewellfilenameindex(datadir);
end

% standardize wellid string
if ischar(wellid)
    [r,c] = well2coord(wellid);
    wellid = coord2well(r,c);
elseif isnumeric(wellid) && numel(wellid) == 2
    r = wellid(1);
    c = wellid(2);
    wellid = coord2well(r,c);
else
    error('Please input [row, column] or a string like ''A01'' as the 3rd argument to FCSPARSEWELL.');
end

fieldname = genvarname(platename);

if isfield(wellfilenameindex,fieldname) && isfield(wellfilenameindex.(fieldname),wellid)
    fn = wellfilenameindex.(fieldname).(wellid);
    [data meta] = fcsparse([datadir fn],'rename');
else
    warning(['Plate/well not found or not in cache: ' platename ' ' wellid]);
    data=[];
    meta=[];
end
