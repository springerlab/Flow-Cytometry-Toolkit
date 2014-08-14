function ind = getstratwellindex(r,c)
%GETSTRATWELLINDEX gets the numerical index of a well on a 96w plate
%according to Stratedigm's "high throughput" numbering mode.
% 
%   created 20121018 JW
if exist('c')~=1
    if ischar(r)
        [r,c]=well2coord(r);
    else
        [r,c]=ind2sub([8 12],r);
    end
end

ind = 12.*(r-1) + ceil(c./2) + (1-mod(c,2)).*6;