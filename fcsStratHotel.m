%% load each part of the screening

allStat = struct();
allDataPool = struct();

% parse folder name
subDataFolerArray = dir(dataFolder);
subDataFolerArray(~[subDataFolerArray.isdir])= []; %Remove all non directories.
subDataFolerArray = setdiff({subDataFolerArray.name},{'.','..'})


NSubDataFoler = length(subDataFolerArray);

for iSubDataFolder = 1:NSubDataFoler
   
    % get subfolder path
    subDataFolder = subDataFolerArray{iSubDataFolder};
    subDataPath = fullfile(dataFolder, subDataFolder);
    
    fprintf('Reading %s\n', subDataPath)
    
    % load all .fcs data from that folder, and create allStatTmp
    [allStatTmp, allDataPoolTmp]= fcscreateallstatForfolder(subDataPath);
    
    %% combind allStatTmp into allStat
    NAllStat = length(allStat);
    if iSubDataFolder == 1;
        NAllStat = 0;
    end
    NAllStatTmp = length(allStatTmp);
    for iAllStatTmp = 1:NAllStatTmp
        allStatTmp(iAllStatTmp).iPart = iSubDataFolder;
        allStatTmp(iAllStatTmp).dataFolder = subDataFolder;
    end
    
    if NAllStat == 0
        allStat = allStatTmp;
        allDataPool = allDataPoolTmp;
    else
        allStat(NAllStat+[1:NAllStatTmp]) = allStatTmp;
        allDataPool = fcsappend(allDataPool, allDataPoolTmp);
    end
    
end