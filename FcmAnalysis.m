classdef FcmAnalysis < handle
    properties
        fcm_data_folder = '';
        gate_list = {};
        cell_population_list = {};
        data_table = table();
        parameter = '';
        plate_id_list = {};
        dat_sample = fcsstruct();
    end
    
    methods
        function obj = FcmAnalysis(data_folder, parameter)
            % create a data table based on data_folder; load all samples
            % once to pool fcs sample;
            obj.fcm_data_folder = data_folder;
            obj.parameter = parameter;
            fprintf('set data folder as: %s\n', obj.fcm_data_folder);
            obj = obj.populatefcsfiles();
        end
        
        function obj = loadgate(obj, filepath)
            % load gate from file
            if ~exist(filepath)
                error('gate file not found')
            else
                load(filepath);
                obj.gate_list = gate_list;
            end
        end
        
        function obj = savegate(obj, filepath)
            gate_list = obj.gate_list;
            save(filepath, 'gate_list')
        end
        
        function obj = addgate(obj, varargin)
            % addgate, defines a gate; can be used to add a single-variable
            % or double variable gate to obj
            
            % a set of commonly used gate assignment
            % fcm = fcm.addgate(...
            %     'name', {'cell'}, ...
            %     'channel', {'fsc', 'ssc'}, ...
            %     'scale', {'linear', 'linear'} );
            % fcm = fcm.addgate(...
            %     'name', {'mcherry_cell'}, ...
            %     'preprocess', {'cell'}, ...
            %     'channel', {'mch', 'bfp'}, ...
            %     'scale', {'log2', 'log2'} );
            % fcm = fcm.addgate(...
            %     'name', {'bfp_cell'}, ...
            %     'preprocess', {'cell'}, ...
            %     'channel', {'mch', 'bfp'}, ...
            %     'scale', {'log2', 'log2'} );
            % fcm = fcm.addgate(...
            %     'name', {'mid_size'}, ...
            %     'preprocess', {'cell'}, ...
            %     'channel', {'ssc'}, ...
            %     'scale', {'log2'} );
            
            p = inputParser;
            addOptional(p,'name', 'default_gate_name', @iscell);
            addOptional(p,'preprocess',{},@iscell)
            addRequired(p,'channel',@(x) true);
            addOptional(p,'scale',{'linear', 'linear'},@(x) true);
            addOptional(p,'value', [] ,@isnumeric);
            parse(p,varargin{:})
            new_gate = p.Results;
            
            n_gate = length(new_gate.name);
            
            dat = obj.dat_sample; % preprocess data
            for pre_gate = new_gate.preprocess
                dat = obj.applygate(dat, obj.findgate(pre_gate));
            end
            
            [figHandle, figLocation] = obj.plotdat(dat, new_gate); % plot data
            
            if n_gate ~= 1 & ~isempty(new_gate.value)
                error('gates can only be assign with value if there is one gate')
            end
            for i_gate = 1:n_gate
                if ~isempty(new_gate.value) % gate data exist and there is only one gate
                    gate_value = new_gate.gate_value;
                else
                    if length(new_gate.channel) == 1
                        gate_value = ginput(2);
                        gate_value = gate_value(:,1);
                    elseif length(new_gate.channel) == 2
                        gate_value = ginput();
                    end
                end
                
                if length(new_gate.channel) == 1 % draw gate
                    hold on
                    addzeroline2('xpos', gate_value')
                elseif length(new_gate.channel) == 2
                    hold on
                    [poly_x, poly_y] = obj.gatetopolygon(gate_value);
                    plot(poly_x, poly_y, 'r-', 'linewidth', 1)
                end
                
                gate_to_be_added = new_gate; % create a gate struct to be saved
                gate_to_be_added.name = new_gate.name{i_gate};
                gate_to_be_added.value = gate_value;
                
                flag_gate_exist = 0; % save gate into obj
                for i = 1:length(obj.gate_list)
                    if strcmpi(obj.gate_list{i}.name, gate_to_be_added.name)
                        obj.gate_list{i} = gate_to_be_added;
                        flag_gate_exist = 1;
                        fprintf('updated gate %s\n', gate_to_be_added.name)
                        break
                    end
                end
                if ~flag_gate_exist
                    obj.gate_list = {obj.gate_list{:}, gate_to_be_added};
                    fprintf('created gate %s\n', gate_to_be_added.name)
                end
            end
            savefig3
            
        end
        
        function [h_fig, fig_location] = plotdat(obj, fcs_dat, spec, current_axes, plot_spec)
            
            if nargin < 4
                current_axes = 0;
            end
            if nargin < 5
                plot_spec = {};
            end
            
            if current_axes ~= 0
                axes(current_axes)
            else
                if length(spec.channel) == 1 % single variable plot
                    fig_name = spec.channel{1};
                elseif length(spec.channel) == 2 % double-variable plot
                    fig_name = [spec.channel{1}, '_', spec.channel{2}];
                end
                [h_fig, fig_location] = createfig4('figSubfolder', 'segmentation', 'figName', fig_name);
            end
            
            if length(spec.channel) == 1 % single variable plot
                func = obj.gettransformfunction(spec.scale{1});
                dat = func(fcs_dat.(spec.channel{1}));
                nb = calcnbins(dat, 'all');
                %                 [h_count, h_center] = hist(dat, nb.fd);
                %                 plot(h_center, h_count, plot_spec{:})
                hist(dat, nb.fd)
            elseif length(spec.channel) == 2 % double-variable plot
                func_x = obj.gettransformfunction(spec.scale{1});
                func_y = obj.gettransformfunction(spec.scale{2});
                dat_x = func_x(fcs_dat.(spec.channel{1}));
                dat_y = func_y(fcs_dat.(spec.channel{2}));
                plot(dat_x, dat_y, 'k.', 'linewidth', 1, 'markersize', 2, plot_spec{:})
                if strcmpi(spec.scale{2}, 'log2')
                    xlim([min(dat_x), max(dat_x)])
                    ylim([min(dat_y), max(dat_y)])
                end
            else
                error('too many channels')
            end
            xlabel(sprintf('%s (%s)', spec.channel{1}, spec.scale{1}))
            ylabel(sprintf('%s (%s)', spec.channel{1}, spec.scale{1}))
        end
        
        function gated_dat = applygate(obj, dat, gate)
            gated_dat = dat;
            for pre_gate_name = gate.preprocess
                pre_gate = obj.findgate(pre_gate_name);
                gated_dat = obj.applygate(gated_dat, pre_gate);
            end
            if length(gate.channel) == 1 % single-channel gate
                cha = gate.channel{1};
                func = obj.gettransformfunction(gate.scale{1});
                gate_value = gate.value;
                gated_dat = fcsselect(gated_dat, ...
                    func(gated_dat.cha)>gate_value(1) & func(gated_dat.cha)<gate_value(2) ...
                    );
            elseif length(gate.channel) == 2 % two-channel gate
                cha_x = gate.channel{1};
                cha_y = gate.channel{2};
                func_x = obj.gettransformfunction(gate.scale{1});
                func_y = obj.gettransformfunction(gate.scale{2});
                gate_value = gate.value;
                gated_dat = fcsselect(gated_dat, inpolygon(...
                    func_x(gated_dat.(cha_x)), func_y(gated_dat.(cha_y)), ...
                    gate_value(:,1), gate_value(:,2) ...
                    ));
            else
                error('too many channels in the gate')
            end
        end
        
        function gate = findgate(obj, str)
            for gate = obj.gate_list
                gate = gate{1};
                if strcmpi(gate.name, str)
                    return
                end
            end
        end
        
        function obj = setsegment(obj, varargin)
            % assign population of cells
            
            % below is a set of commonly used population assignment
            % fcm = fcm.setsegment(...
            %     {'cells', 'all', {'cell'}}, ...
            %     {'uninduced_cells', 'cells', {'uninduced'}}, ...
            %     {'induced_cells', 'cells', {'induced'}}...
            %     );
            
            
            cell_population_list = struct('name', {}, 'base_population', {}, 'gates', {});
            for i = 1:length(varargin)
                cell_population = struct(...
                    'name', varargin{i}{1}, ...
                    'base_population', varargin{i}{2},...
                    'gates', {varargin{i}{3}});
                cell_population_list(i) = cell_population;
            end
            obj.cell_population_list = cell_population_list;
        end
        
        function obj = extract(obj, varargin)
            trait_list = varargin;
            fprintf('parse the following traits for all samples:\n')
            
            warning('off','MATLAB:table:RowsAddedNewVars')
            fprintf('\tsilenced warning RowsAddedNewVars\n')
            
            for i_trait = 1:length(trait_list)
                fprintf('%s\n', trait_list{i_trait}{1});
            end
            
            for i_sample = 1:height(obj.data_table)
                
                filepath = obj.data_table{i_sample, 'filepath'}{1}; % load data
                dat = fcsparse(filepath, obj.parameter);
                
                event_populations = obj.getpopulation(dat);
                
                for i_trait = 1:length(trait_list)
                    trait_name = trait_list{i_trait}{1};
                    function_handle = trait_list{i_trait}{2};
                    obj.data_table{i_sample, trait_name} = function_handle(event_populations);
                end
            end
            
            warning('on','MATLAB:table:RowsAddedNewVars')
            fprintf('\trestored warning RowsAddedNewVars\n')
            
            fprintf('finished trait extraction\n')
        end
        
        function event_populations = getpopulation(obj, dat)
            % use population information in the obj to segment data into
            % different populations
            population_list = obj.cell_population_list;
            event_populations = struct('all', dat); % segmentation
            for i_population = 1:length(population_list)
                event_population = event_populations.(population_list(i_population).base_population);
                for gate_name = population_list(i_population).gates
                    event_population = obj.applygate( event_population, obj.findgate(gate_name{1}) );
                end
                event_populations.(population_list(i_population).name) = event_population;
            end
        end
        
        function label_table = addlabel(obj, file_path)
            fprintf('add label using metadata from %s\n', file_path)
            label_table = obj.parselabel(file_path);
            try
                obj.data_table.(label_table.Properties.VariableNames{end}) = [];
            catch
            end
            
            obj.data_table = outerjoin(...
                obj.data_table, label_table, ...
                'keys', label_table.Properties.VariableNames(1:end-1), ...
                'mergekeys', 1, 'type', 'left');
        end
        
        function checkplot(obj, varargin)
            n_fig = length(varargin);
            plot_option = varargin;

            fprintf('n_fig: %d\n', n_fig)
            close all % prep figure
            fig_handle_list = cell([0 0]);
            fig_location_list = cell([0 0]);
            ha_list = cell([0 0]);
            color_list = varycolor2(5);
            for i_fig = 1:n_fig
                for i_plate = 1:length(obj.plate_id_list)
                    fig_name = sprintf('%s_%s_%d_%s', plot_option{i_fig}.channel{1}, plot_option{i_fig}.channel{2}, i_plate, obj.plate_id_list{i_plate});
                    [ figHandle, figLocation, ha ] = creategrid( 8, 12, [.1 1 0 .1], [.1 1 0 .1], {'figClassName', 'segmentation', 'figName', fig_name, 'flagclosepreviousplot', 'off'} );
                    fig_handle_list{i_fig, i_plate} = figHandle;
                    fig_location_list{i_fig, i_plate} = figLocation;
                    ha_list{i_fig, i_plate} = ha;
                end
            end
            
            for i_sample = 1:height(obj.data_table)
                
                filepath = obj.data_table{i_sample, 'filepath'}{1}; % load data
                dat = fcsparse(filepath, obj.parameter);
                dat = fcsthin(dat, 300);
                i_plate = obj.data_table{i_sample, 'i_plate'}; % load data
                i_row = obj.data_table{i_sample, 'i_row'}; % load data
                i_col = obj.data_table{i_sample, 'i_col'}; % load data
                
                event_populations = obj.getpopulation(dat);
                
                for i_fig = 1:n_fig
                    figure(fig_handle_list{i_fig, i_plate})
                    ha = ha_list{i_fig, i_plate};
                    axes(ha(sub2ind([12,8], i_col, i_row)))
                    population_list = plot_option{i_fig}.population;
                    for i_population = 1:length(population_list)
                        dat = event_populations.(population_list{i_population});
                        func_x = obj.gettransformfunction(plot_option{i_fig}.scale{1});
                        func_y = obj.gettransformfunction(plot_option{i_fig}.scale{2});
                        plot(func_x(dat.(plot_option{i_fig}.channel{1})),...
                            func_y(dat.(plot_option{i_fig}.channel{2})), ...
                            'markersize', 3, 'marker', '.', ...
                            'linestyle', 'none', ...
                            'color', color_list(i_population,:));
                        hold on
                    end
                    xlim(plot_option{i_fig}.xlim), ylim(plot_option{i_fig}.ylim)
                    set(gca, 'xtick', [], 'ytick', [])
                end
            end
            for i_fig = 1:n_fig
                for i_plate = 1:length(obj.plate_id_list)
                    fig_name = sprintf('%s_%s_%d_%s', plot_option{i_fig}.channel{1}, plot_option{i_fig}.channel{2}, i_plate, obj.plate_id_list{i_plate});
                    figHandle = fig_handle_list{i_fig, i_plate};
                    figLocation = fig_location_list{i_fig, i_plate};
                    figure(figHandle)
                    if ismember(i_plate, obj.data_table.i_plate)
                        savefig3('eps', 'off')
                    else
                        close(figHandle)
                    end
                end
            end
        end
        
        function [q_table, flag] = query(obj, varargin)
            flag = ones(height(obj.data_table), 1);
            for i = 1:2:length(varargin)
                if isnumeric(varargin{i+1})
                    flag = flag & (obj.data_table.(varargin{i}) == varargin{i+1});
                else
                    flag = flag & strcmpi(obj.data_table.(varargin{i}), varargin{i+1});
                end
            end
            q_table = obj.data_table(flag,:);
        end
        
        function label_table = parselabel(obj, file_path)
            
            % format of the label file, first line first three cols show
            % the label of rows cols, and new label. second line as empty
            % line, following that is the data. first row and col are
            % cols of existing table. the rest is new label to be atteched
            % to the data table
            n_header = 2;
            
            raw = csv2cell(file_path, ','); % read raw data
            
            n_row = size(raw,1) - n_header - 1;
            n_col = max(find(~cellfun(@isempty, raw(n_header+1,:))))-1;
            
            label_x_name = regexp(raw{1,1}, 'row:(.*)', 'tokens'); % get label names for rows and cols
            label_x_name = label_x_name{1}{1};
            
            label_y_name = regexp(raw{1,2}, 'col:(.*)', 'tokens');
            label_y_name = label_y_name{1}{1};
            
            label_new_name = regexp(raw{1,3}, 'new:(.*)', 'tokens'); % new label name
            label_new_name = label_new_name{1}{1};
            
            label_y_list = raw(n_header+1, 2:(n_col+1));
            label_y_list = repmat(label_y_list, n_row, 1);
            label_y_list = label_y_list(:);
            if isnumeric( label_y_list{1,1} )
                label_y_list = [label_y_list{:}]';
            end
            
            label_x_list = raw(n_header+1+[1:n_row], 1);
            label_x_list = repmat(label_x_list, 1, n_col);
            label_x_list = label_x_list(:);
            if isnumeric( label_x_list{1,1} )
                label_x_list = [label_x_list{:}]';
            end
            
            label_content = raw(n_header+1 + [1:n_row], 1+ [1:n_col]);
            if isnumeric( label_content{1,1} )
                tmp = label_content(:);
                label_content = reshape([tmp{:}], size(label_content));
            end
            label_table = table(label_x_list(:), label_y_list(:), label_content(:),...
                'variablenames', {label_x_name, label_y_name, label_new_name});
            
            if strcmpi(label_y_name, 'dummy')
                label_table.(label_y_name) = [];
            end
        end
        
        function resample(obj)
            n_dat_sample_rate = 100; % the number of events initially sampled from each fcs file
            n_dat_sample = 3000; % the end number of events sampled
            dat_sample = fcsstruct();
            for i_file = 1:height(obj.data_table)
                filepath = obj.data_table{i_file, 'filepath'}{1};
                [dat, met] = fcsparse(filepath, obj.parameter);
                dat_sample = fcsappend(fcsthin(dat, n_dat_sample_rate), dat_sample);
            end
            dat_sample = fcsthin(dat_sample, n_dat_sample);
            obj.dat_sample = dat_sample;
        end
    end
    
    methods (Access = private)
        function obj = populatefcsfiles(obj)
            % populatefcsfiles: populate all the fcs files in the
            % subfolders of fcm_data_folder
            
            % find out all fcs files in each subfolder of fcm_data_folder
            subfolder = dir(obj.fcm_data_folder);
            subfolder(~[subfolder.isdir]) = [];
            filepath_list = {};
            for i_folder = 1:length(subfolder)
                files = dir(fullfile(obj.fcm_data_folder, subfolder(i_folder).name, '*.fcs'));
                files = {files.name};
                for i_file = 1:length(files)
                    files{i_file} = fullfile(obj.fcm_data_folder, subfolder(i_folder).name, files{i_file});
                end
                filepath_list = {filepath_list{:}, files{:}};
            end
            obj.data_table.filepath = filepath_list';
            
            % sample each file and get iplate, irow and icol for each file
            % from meta data
            fprintf('starting to sample %d fcs file(s)\n', height(obj.data_table))
            
            n_dat_sample_rate = 100; % the number of events initially sampled from each fcs file
            n_dat_sample = 3000; % the end number of events sampled
            plate_id_array = []; % tmp variable to store plate_id, row, col and btim
            row_array = [];
            col_array = [];
            btim_array = {};
            dat_sample = fcsstruct();
            
            for i_file = 1:height(obj.data_table)
                filepath = obj.data_table{i_file, 'filepath'}{1};
                try
                    [dat, met] = fcsparse(filepath, obj.parameter);
                catch
                    fprintf('had trouble reading file %s\nfile ignored\n', filepath)
                    continue
                end
                dat_sample = fcsappend(fcsthin(dat, n_dat_sample_rate), dat_sample);
                %                 plate_id_array(i_file) = str2num(met.plate_id);
                [~, tmp] = ismember(met.plate_id, obj.plate_id_list);
                if tmp == 0 % not in the list
                    obj.plate_id_list{end+1} = met.plate_id;
                    plate_id = length(obj.plate_id_list);
                else
                    plate_id = tmp;
                end
                plate_id_array(i_file) = plate_id;
                row_array(i_file) = met.row;
                col_array(i_file) = met.col;
                btim_array{i_file} = met.BTim;
            end
            
            dat_sample = fcsthin(dat_sample, n_dat_sample);
            obj.dat_sample = dat_sample;
            
            % filter wells that are bad
            id = find(plate_id_array ==0); % missing data
            row_array(id) = [];
            col_array(id) = [];
            plate_id_array(id) = [];
            btim_array(id) = [];
            obj.data_table(id,:) = [];
            
            obj.data_table.i_row = row_array';
            obj.data_table.i_col = col_array';
            obj.data_table.i_plate = plate_id_array';
            obj.data_table.btim = btim_array';
            obj.data_table.plate_label = obj.plate_id_list(plate_id_array)';
        end
        
        function func = gettransformfunction(obj, str)
            if strcmpi( str, 'linear' )
                func = @(x) x;
            elseif strcmpi( str, 'log2' )
                func = @(x) log2(x);
            else
                error('no transformation function matched')
            end
            return
        end
        
        function [polygon_node_x, polygon_node_y] = gatetopolygon(obj, gate_value)
            gate_value = gate_value([1:end, 1],:);
            polygon_node_x = gate_value(:,1);
            polygon_node_y = gate_value(:,2);
        end
        
    end
end
