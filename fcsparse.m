function [datastruct metadata]= fcsparse(filename, paramstokeep, varargin)
% FCSPARSE parses an FCS 3.0 file. It works on tube-mode and plate-mode
% (single-well) data files.
%
%   Created 2012/07/12 JW
%   Modified 20120714 BH, include expr_name in metadata for both LSRII and
%       Stratedigm, update well_id extraction for LSRII. Still need to work
%       on tube data for both machine
%   Modified 20120906 JW does parameter translations for LSRII as well.
%   Updated  20120914 BH solve LSRII plate_name bug
%   Updated  20130212 BH solve problems to read LSRII temp files directly,
%   due to unspecified Cytometer type, by adding optional input argument

% parse input
parser = inputParser;
addRequired(parser,'filename',@ischar);
addRequired(parser,'paramstokeep',@(x) isstruct(x) || ischar(x));
addParamValue(parser,'cytometer','',@ischar);

parse(parser, filename, paramstokeep, varargin{:});

cytometer = parser.Results.cytometer;

%
% read data
% filename
[data,paramVals,textHeader] = fcsread(filename);

% which instrument?
cytometer = textHeader{find(strcmp('$CYT',{textHeader{:,1}})),2};
if strcmpi(cytometer,'1400-8') || strcmpi(cytometer,'S1400EX')
    translatefunc = @pstrat;
elseif strcmpi(cytometer,'LSRII')
    translatefunc = @plsrii;
end

% process data for each parameter (i.e. fluorescence channel)
% works on both stratedigm and lsrii except where noted
datastruct = struct;
pnamelist = {paramVals.Name};

if exist('paramstokeep') ~= 1
    paramstokeep = 'all';
end

if ischar(paramstokeep)
    % keyword mode
    if strcmp(paramstokeep,'all')
        % grab all parameters (DEFAULT)
        for c=1:length(pnamelist)
            parname = underscorify(pnamelist{c});
            datastruct.(parname) = data(:,c);
        end
    elseif strcmp(paramstokeep,'common')
        % grab only common channels and rename them
        datastruct = grab_specific_params(data, pnamelist, translatefunc([],0));
        
    elseif strcmp(paramstokeep,'rename')
        % grab all channels but rename common ones
        nameconversions = translatefunc([],1); % param names -> nicknames
        for c=1:length(pnamelist)
            parname = underscorify(pnamelist{c});
            
            % use any default nicknames that are available
            if isfield(nameconversions, parname) && ~isempty(nameconversions.(parname))
                parname = nameconversions.(parname);
            end
            
            datastruct.(parname) = data(:,c);
        end
    end
elseif isstruct(paramstokeep)
    % grab only wanted parameters and rename them
    datastruct = grab_specific_params(data, pnamelist, paramstokeep);
else
    error('PARAMSTOKEEP must be ''all'', ''common'', or a struct with flow cytometry parameter name conversions');
end

% process metadata
metadata = struct;
metadata.cytometer = cytometer;

% metadata common to stratedigm and LSRII
% works on both - verified 2012/07/14 JW
Date = textHeader{find(strcmp('$DATE',{textHeader{:,1}})),2};
BTim = textHeader{find(strcmp('$BTIM',{textHeader{:,1}})),2};
BTim_tmp = regexp(BTim, '^(\d{2}:\d{2}:\d{2})', 'tokens');
metadata.begin_time = datenum([Date, ' ', BTim_tmp{1}{1}]);

etim = textHeader{find(strcmp('$ETIM',{textHeader{:,1}})),2};
etim_tmp = regexp(etim, '^(\d{2}:\d{2}:\d{2})', 'tokens');
metadata.end_time = datenum([Date, ' ', etim_tmp{1}{1}]);

if strcmp(cytometer,'LSRII')
    % LSRII-specific metadata
    metadata.plate_name = find(strcmp('PLATE NAME',{textHeader{:,1}}));
    % metadata.plate_name = textHeader{find(strcmp('PLATE NAME',{textHeader{:,1}})),2};  % Bo's version, not sure which one is better
    
    %     % this works but isn't useful
    %     plate_id_idx = find(strcmp('PLATE ID',{textHeader{:,1}}));
    %     if ~isempty(plate_id_idx)
    %         metadata.plate_id = textHeader{plate_id_idx,2};
    %     end
    
    well_id_idx = find(strcmp('WELL ID',{textHeader{:,1}}));
    if ~isempty(well_id_idx)
        well_id = textHeader{well_id_idx,2};
        metadata.row = well_id(1)-'A'+1;
        metadata.col = str2num(well_id(2:end));
        metadata.well_id = well_id;
    end
else
    % stratedigm-specific metadata
    plate_id_idx = find(strcmp('PLATE_ID',{textHeader{:,1}}));
    if ~isempty(plate_id_idx)
        metadata.plate_id = textHeader{plate_id_idx,2};
    end
    
    Date_idx = find(strcmp('$DATE',{textHeader{:,1}}));
    if ~isempty(Date_idx)
        metadata.date = textHeader{Date_idx,2};
    end
    
    well_id_idx = find(strcmp('WELL_ID',{textHeader{:,1}}));
    if ~isempty(well_id_idx)
        well_id = textHeader{well_id_idx,2};
        metadata.row = well_id(1)-'A'+1;
        metadata.col = str2num(well_id(2:end));
        metadata.well_id = well_id;
    end
    
end

% expr_name
idx_expr_strat = find(strcmp('EXPERIMENT_NAME',{textHeader{:,1}}));
idx_expr_LSR = find(strcmp('EXPERIMENT NAME',{textHeader{:,1}}));

if ~isempty(idx_expr_LSR)
    idx_expr = idx_expr_LSR;
    metadata.expr_name = textHeader{idx_expr, 2};
elseif ~isempty(idx_expr_strat)
    idx_expr = idx_expr_strat;
    metadata.expr_name = textHeader{idx_expr, 2};
else
    warning('no expr id identified')
    metadata.expr_name = '';
end

metadata.expr_name = textHeader{idx_expr, 2};

% BTIM
BTIMIdx = find(cellfun(@(x) ~isempty(x), regexp(textHeader, 'BTIM')));
metadata.BTim = textHeader{BTIMIdx, 2};

% helper functions
function datastruct = grab_specific_params(data, pnamelist, paramstokeep)
for par = fieldnames(paramstokeep)'
    par = par{1};
    k = find(strcmp(paramstokeep.(par),pnamelist));
    if ~isempty(k)
        datastruct.(par) = data(:,k);
    end
end