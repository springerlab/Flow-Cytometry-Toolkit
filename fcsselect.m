function filtered_data = fcsselect(data, idx)
%FCSSELECT selects events in DATA corresponding to indexes IDX. As with
%normal matrix indexing, IDX can be a list of indexes or a logical array
%containing 1's for desired elements and 0 for unwanted elements.
%
%   Updated 20120816 JW: Now can take a list of lists of indexes and
%   returns a struct array of data.
filtered_data = struct;

if islogical(idx) && ndims(idx)>1
    for c = 1:size(idx,2)
        for field_name = fieldnames(data)'
            channel = data.(field_name{1});
            filtered_data(c).(field_name{1}) = channel(idx(:,c));
        end
    end
elseif iscell(idx)
    for c = 1:length(idx)
        for field_name = fieldnames(data)'
            channel = data.(field_name{1});
            filtered_data(c).(field_name{1}) = channel(idx{c});
        end
    end
else
    for field_name = fieldnames(data)'
        channel = data.(field_name{1});
        filtered_data.(field_name{1}) = channel(idx);
    end
end