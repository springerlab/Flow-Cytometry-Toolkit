function [ allStat, allDataPool] = fcscreateallstatForfolder( inputFolder )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

debug = 0; % flag for debug

% load experiment-level parameter
loadparameter

subDataPath = inputFolder;
% get all fcs files, and assort by acquisition time
filenameArray = dir(fullfile(subDataPath, '*.fcs'));
[~, tmp] = sort([filenameArray.datenum], 'ascend');
filenameArray = filenameArray(tmp);

nFile = length(filenameArray);

%% Start to extract data from *.fcs files

allStatRaw = struct();
allStat = struct();

% init
nbytes = 0;
for iFile = 1:nFile
    
    if nbytes ~= 0
        fprintf(repmat('\b', 1, nbytes))
    end
    nbytes = fprintf('reading file %d/%d', iFile, nFile);
    
    filename = filenameArray(iFile).name;
    filepath = fullfile(subDataPath, filename);
    
    % read .fcs file
    % filepath
    [data, met] = fcsparse(filepath, KEEPPARAMS);
    
    % calculate a putative position for this well.
    % find iPlate (putative, will update later using BTime)
    if iFile == 1
        iPlate = 1;
        allStat(iPlate).plateid = met.plate_id;
    elseif ~ismember(met.plate_id, {allStat.plateid})
        iPlate = length(allStat) + 1;
        allStat(iPlate).plateid = met.plate_id;
    else
        [~, iPlate]= ismember(met.plate_id, {allStat.plateid});
    end
    
    % parse met
    iRow = met.row;
    iCol = met.col;
        
    allStat(iPlate).data(iRow, iCol).iRow = iRow;
    allStat(iPlate).data(iRow, iCol).iCol = iCol;
    allStat(iPlate).data(iRow, iCol).wellPos = met.well_id;
    allStat(iPlate).data(iRow, iCol).plateid = met.plate_id;
    allStat(iPlate).data(iRow, iCol).BTim = met.BTim;
    allStat(iPlate).data(iRow, iCol).beginTime = met.begin_time;
    
%     % check if that file overlap with another file in terms of well
%     % position
%     if ~isempty(allStat(iPlate).data(iRow, iCol).filepath)
%         warning ('Data was written into position in allStat with existing data, \n%s\n%s\n', filepath, allStat(iPlate).data(iRow, iCol).filepath);
%     end
    
    % parse data
    data = fcsclean(data);
    datafdnArray = fieldnames(data);
    
    % process data - get histogram
    for i = 1:length(datafdnArray)
        
        datafdn = datafdnArray{i};
        if regexp(datafdn, '^t$')
            continue
        end
        datafdnName = [datafdn, '_hist'];
        
        paraCounts = histc(log2(data.(datafdn)), CHANNELBINS);
        allStat(iPlate).data(iRow, iCol).(datafdnName) = paraCounts;
        
    end
    
    allStat(iPlate).data(iRow, iCol).nCounts = fcsnumel(data);
    allStat(iPlate).data(iRow, iCol).rate = fcsestimaterate2( data.t );
    allStat(iPlate).data(iRow, iCol).filepath = filepath;
    
    % sample data to create allDataPool
    
    if iFile == 1
        allDataPool = fcsthin(data, 100);
    else
        allDataPool = fcsappend(allDataPool, fcsthin(data, 100));
    end
end

fprintf(' done\n');
nPlate = length(allStat);

%% fix empty wells
% if the last rows or cols are empty, it is possible that the size of
% allStat.data struct is not [nRow, nCol]. This section will fix this
% problem, by providing default values to those wells

for iPlate = 1:nPlate
    
    for iRow = 1:nRow
        for iCol = 1:nCol
            
            %             if (size(allStat(iPlate).data, 1) < nRow) | ... % last rows empty
            %                     (size(allStat(iPlate).data, 2) < nCol) | ... % last cols emtpy
            %                     (isempty(allStat(iPlate).data(iRow, iCol).iRow)) % empty wells
            
            if (size(allStat(iPlate).data, 1) < iRow) | (size(allStat(iPlate).data, 2) < iCol) | (isempty(allStat(iPlate).data(iRow, iCol).iRow))
                
                
                allStat(iPlate).data(iRow, iCol).iRow = iRow;
                allStat(iPlate).data(iRow, iCol).iCol = iCol;
                allStat(iPlate).data(iRow, iCol).wellPos = sprintf('%s%02d', 'A'-1+iRow, iCol);
                allStat(iPlate).data(iRow, iCol).plateid = allStat(iPlate).plateid;
                allStat(iPlate).data(iRow, iCol).BTim = '';
                allStat(iPlate).data(iRow, iCol).beginTime = nan;
                
                
                for i = 1:length(datafdnArray)
                    datafdn = datafdnArray{i};
                    %         para = para{1};
                    if regexp(datafdn, '^t$')
                        continue
                    end
                    datafdnName = [datafdn, '_hist'];
                    allStat(iPlate).data(iRow, iCol).(datafdnName) = nan(length(CHANNELBINS),1);
                    
                end
                allStat(iPlate).data(iRow, iCol).nCounts = nan;
                allStat(iPlate).data(iRow, iCol).rate = nan;
                allStat(iPlate).data(iRow, iCol).filepath = '';
                
            end
        end
    end
end


%% Sort plate by acqusition time

beginTimeMinArray = nan(nPlate, 1);
for iPlate = 1:nPlate
    
    beginTimeMinArray(iPlate) = min([allStat(iPlate).data.beginTime]);
    
end

[~, tmp] = sort(beginTimeMinArray);
allStat = allStat(tmp);

return

end

