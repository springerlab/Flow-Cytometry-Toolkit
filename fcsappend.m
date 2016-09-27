function [ data_append ] = fcsappend( data1, data2 )
%UNTITLED3 Summary of this function goes here
%   Updated 20121230 JW

%   Update 20160120, BH, check if either data1 or data2 is empty, if so,
%   directly copy the non-empty one to data_append; if both empty, return
%   empty struct;

if isempty(fieldnames(data1))
    if isempty(fieldnames(data2)) % both empty
        data_append = struct();
    else
        data_append = data2;
    end
else
    data_append = data1;
    if isempty(fieldnames(data2)) % return dat1
        return
    else
        
        for field_name = fieldnames(data1)'
            if isfield(data2, field_name{1})
                data_append.(field_name{1}) = ...
                    cat(1, data1.(field_name{1}), data2.(field_name{1}));
            else
                data_append = rmfield(data_append, field_name);
            end
        end
        
    end
end