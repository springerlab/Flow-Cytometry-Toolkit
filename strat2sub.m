function [row,col] = strat2sub(stratind)
% converts a stratedigm well number to index of well in matlab matrix order
% 
% 20130108
row = idivide(uint8(stratind),12);
rem = mod(stratind,12);
if rem == 0
    col = 12;
else
    row = row+1;
    if rem<=6
        col = rem*2-1;
    else
        col = (rem-6)*2;
    end
end
