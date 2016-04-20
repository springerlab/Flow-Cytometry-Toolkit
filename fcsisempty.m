function out = fcsisempty(data)
% 20130423
if isempty(data)
    out = true;
    return
end
for idx = 1:length(data)
    out(idx) = isempty(data(idx)) || isempty(data(idx).t);
end