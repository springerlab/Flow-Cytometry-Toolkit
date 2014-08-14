function out = makewellfilenameindex(datadir)
% MAKEWELLFILENAMEINDEX makes a cache of what filenames correspond to what
% platenames and well positions in a folder of fcs files. It is intended to
% improve the efficiency of LOADWELLDATA.
% 
% This function caches its results as the file wellfileindex.mat in
% DATADIR. To refresh the cache, just run this function again or simply
% delete the file from DATADIR.
% 
% 20130404
global wellfilenameindex;
outfn = 'wellfilenameindex.mat';
wellfilenameindex = struct;

% get all fcs files, ordered by date
fns = dir([datadir '*.fcs']);
[~, idx] = sort([fns.datenum]); 
fns = {fns(idx).name};

if ~isempty(fns)
    for ifn=1:length(fns)
        fn=fns{ifn};
        
        textHeader =fcsread_header([datadir fn]);
        
        platename = fn(1:strfind(fn,'_')-1);
        platename = genvarname(platename);
        icyto = find(strcmp('$CYT',{textHeader{:,1}}));
        if isempty(icyto), continue; end
        cytometer = textHeader{icyto,2};
        
        if strcmp(cytometer,'LSRII')
            % LSRII-specific metadata
            well_id_idx = find(strcmp('WELL ID',{textHeader{:,1}}));
            if ~isempty(well_id_idx)
                well_id = textHeader{well_id_idx,2};
            end
            
            %         TODO: implement plate name override
            %     metadata.plate_name = find(strcmp('PLATE NAME',{textHeader{:,1}}));
            
        else
            % stratedigm-specific metadata
            well_id_idx = find(strcmp('WELL_ID',{textHeader{:,1}}));
            if ~isempty(well_id_idx)
                well_id = textHeader{well_id_idx,2};
            end
            %     plate_id_idx = find(strcmp('PLATE_ID',{textHeader{:,1}}));
            %     if ~isempty(plate_id_idx)
            %         plate_id = textHeader{plate_id_idx,2};
            %     end
        end
        
        if ~isfield(wellfilenameindex,platename)
            wellfilenameindex.(platename)=struct;
        end
        
        wellfilenameindex.(platename).(well_id) = fn;
    end
end

save([datadir outfn],'wellfilenameindex');