function outstr = underscorify(str,leadingnum)
% UNDERSCORIFY cleans up a string for use as a variable name
%
%   UNDERSCORIFY(STR) replaces all non-alphanumeric characters in a string with
%   underscores. 
%   
%   UNDERSCORIFY(STR,LEADINGNUM) If LEADINGNUM is true (default) and the string
%   starts with a number, the letter 'x' is appended to the beginning of
%   the string.
%
%   Created 20120712 JW
%   Updated 20120814 to condense multiple _'s to a single _.
%   Updated 20120912 to trim leading whitespace

if ~exist('leadingnum')
    leadingnum=true;
end

outstr = strtrim(str);
outstr(~isstrprop(outstr,'alphanum')) = '_';

[idx1 idx2] = regexp(outstr, '_+');
toremove = [];
for c=1:length(idx1)
    toremove = [toremove idx1(c)+1:idx2(c)];
end

outstr(toremove)=[];

if leadingnum
    if isstrprop(outstr(1),'digit')
        outstr = ['x' outstr];
    end
end