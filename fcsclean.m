function outdata = fcsclean(indata)
%FCSCLEAN removes events with a zero or negative value or Inf in any parameter
%from a FCToolkit data structure.
%
%   Created 20120912 JW
fns = fieldnames(indata);
idx = logical(ones(fcsnumel(indata),1));
for f=1:length(fns)
    idx = idx & (indata.(fns{f})>0) & (~isinf(indata.(fns{f})));
end
outdata = fcsselect(indata, idx);