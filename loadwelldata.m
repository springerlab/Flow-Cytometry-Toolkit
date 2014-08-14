function [data,meta] = loadwelldata(datadir,platename,wellid)
% LOADWELLDATA loads fcs data from a file whose name contains PLATENAME and
% whose header identifies it as being from well WELLID. The function relies
% on the metadata contained in the FCS header to determine the well
% corresponding to a certain file.
% 
% This is an older form of the function FCSREADWELL, but is being kept to
% maintain backwards compatibility.
% 
% Example:
% 
%   loadwelldata('../data/','plate1','A01')
% 
% loads data for well A01 from a file such as 'plate1_001_001.fcs'
% 
% 20130310


% load filename cache
global wellfilenameindex;
try
    load([datadir 'wellfilenameindex.mat']);
catch
    disp('No filename cache found. Generating...');
    makewellfilenameindex(datadir);
end

% standardize wellid string
[r,c] = well2coord(wellid);
wellid = coord2well(r,c);

platename = genvarname(platename);

if isfield(wellfilenameindex,platename) && ...
        isfield(wellfilenameindex.(platename),wellid)
    fn = wellfilenameindex.(platename).(wellid);
    [data meta] = fcsparse([datadir fn],'rename');
else
    disp(['File not found or not in cache: ' platename ' ' wellid]);
    data=[];
    meta=[];
end
