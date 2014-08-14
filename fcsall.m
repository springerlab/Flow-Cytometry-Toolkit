function idx = fcsall(data)

data_all = [];

for field_name = fieldnames(data)'
    data_all(:,end+1) = data.(field_name{1});
end

idx = all(data_all,2);