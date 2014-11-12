function wells = coord2well(r, c)
%COORD2WELL converts a numerical well coordinate on a 96-well plate to
%a string name for the well. If inputs are arrays, then output is a cell
%array of well names.
%
%   2012/07/25 JW
if exist('c')~=1
    c = r(2);
    r = r(1);
end
    
wells = {};
for k=1:length(r)
    if r(k)<1 || r(k)>8 || c(k)<1 || c(k)>12
        error('Coordinate out of bounds.');
    end


    letters = 'ABCDEFGH';
    wells{k} = sprintf([letters(r(k)) '%02d'],c(k));
end
if length(wells)==1
    wells = wells{1};
end