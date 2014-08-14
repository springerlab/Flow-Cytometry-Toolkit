function subpops = fcsthresh(data,chan,varargin)
% 20130107
chandata=log10(data.(chan));

thresh = graythresh((chandata-min(chandata))./range(chandata));
thresh = range(chandata).*thresh+min(chandata);

subpops = fcsselect(data,[chandata<thresh]);
subpops(2) = fcsselect(data,[chandata>=thresh]);
