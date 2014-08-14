function [textHeader] = fcsread_header(filename)
% FCSREAD_HEADER read the header of a FACS FCS format file.
%
%
%   [HEADER] = FCSREAD(FILENAME) returns the header of a fcs files
%   Example:
%
%       % Read a sample FCS file
%       [data,params] = fcsread('SampleFACS.fcs');
%
%       % Display a histogram of the first parameter values
%       hist(data(:,1),max(data(:,1))-min(data(:,1)));
%       title(params(1).LongName);
%
%       % Create a scatter plot the data using a log scale
%       numDecades = params(2).Amplification(1);
%       theRange = params(2).Range;
%       semilogy(data(:,1),10.^(data(:,2)/(theRange/numDecades)),'+');
%       xlabel(params(1).Name); ylabel(params(2).Name);
%

%   Copyright 2005 The MathWorks, Inc.
%   $Revision:  $  $Date: 2005/3/24 20:41:57 $

% FCS format specified here:
% http://www.isac-net.org/resources/fcs3.htm

% open the file...

correctEndian = false;
endianCount = 1;
endianOptions = {'l','b'};
while correctEndian == false
    try
        fid = fopen(filename,'rb',endianOptions{endianCount});
        if fid == -1
            if ~exist(filename)
                error('fcsread:CannotFindFile','%s does not appear to exist.',filename)
            end
        end
    catch
        if ~ischar(filename)
            error('fcsread:InvalidInput','Input must be a character array')
        end

        if endianCount == 3
            error('fcsread:CannotDetermineEndian','%s does not appear to be a valid FCS file.',filename)
        end
        rethrow(lasterr);
    end


    % read the header
    fileHeader = readHeader(fid,filename);

    % Check endian-ness
    correctEndian = checkByteOrder(fileHeader.textData,endianCount);
    if ~correctEndian
        fclose(fid);
        endianCount = endianCount+1;
    end
end

% get the number of parameters

textData = strrep(fileHeader.textData,char(0),'');
%Modified this line 2012/10/29 to make it work stratedigm and LSRII
if strcmpi(textData(1),'\')
    textCell = strread(textData,'%s','delimiter','\\');
else
    textCell = strread(textData,'%s','delimiter',char(12));
end
if isempty(textCell{1})
    textCell(1) = [];
end

if isempty(textCell{1})
    textCell(1) = [];
end
% disp(sprintf('%s\n%s\n%s\n%s\n%d', textData, textCell{1}, textCell{2}, textCell{3}, numel(textCell)))
textHeader = reshape(textCell,2,numel(textCell)/2)';

fclose(fid);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function header = readHeader(fid,filename)
% Extract the header information

% we could check here for
header.ver = fread(fid,6,'*char')';
if isempty(strfind(header.ver,'FCS'))
    error('fcsread:NoFCSTag','%s does not appear to be a valid FCS file.',filename)
end
header.skip = fread(fid,4,'*char');
header.textStart = str2num(fread(fid,8,'*char')');
header.textEnd = str2num(fread(fid,8,'*char')');
header.dataStart = str2num(fread(fid,8,'*char')');
header.dataEnd = str2num(fread(fid,8,'*char')');
header.analysisStart = str2num(fread(fid,8,'*char')');
header.analysisEnd = str2num(fread(fid,8,'*char')');
fseek(fid,header.textStart,-1);
header.textData = fread(fid,header.textEnd -header.textStart+1,'*char')';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function checkEndian = checkByteOrder(textData,endianCount);
% check the endianness of the file.
if endianCount == 1
    checkEndian = any(strfind(textData,'1,2,3,4'));
else
    checkEndian = any(strfind(textData,'4,3,2,1'));
end
