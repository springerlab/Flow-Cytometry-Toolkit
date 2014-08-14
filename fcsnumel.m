function out = fcsnumel(data)
%
% 
% modified 201201025
out = [];
for c = 1:length(data)
    fn = fieldnames(data(c));
    out(c) = numel(data(c).(fn{1}));
end