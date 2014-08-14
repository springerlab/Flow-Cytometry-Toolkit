function fcsplot( data, channel, scaling, xylabel)
%fcsplot PLOT FCS SINGLE WELL DATA
%   fcsplot( data ) plot fsc and ssc channels
%   fcsplot( data, channel ) plot specific channels
%
% created by BH 20120714

if nargin == 1
    channel = {'fsc', 'ssc'};
    scaling = 'lin';
elseif nargin == 2
    scaling = 'lin';
end

if nargin < 4
    xylabel = 1;
end

% define scale
if strcmp(scaling, 'lin')
    scafunc = @(x) x;
elseif strcmp(scaling, 'log10')
    scafunc = @(x) log10(x);
elseif strcmp(scaling, 'log2')
    scafunc = @(x) log2(x);
elseif strcmp(scaling, 'log')
    scafunc = @(x) log10(x);
else
    scafunc = @(x) x;
end

% data extract
data_x = scafunc(data.(channel{1}));
data_y = scafunc(data.(channel{2}));

% plot
if length(channel) == 2
    plot(data_x, data_y, '.', 'markersize', 1);
else
    data_z = scafunc(data.(channel{3}));
    plot3(data_x, data_y, data_z, '.', 'markersize', 1);
end

if xylabel
    xlabel([channel{1}, '\_', scaling], 'fontsize', Fontsize_cal)
    ylabel([channel{2}, '\_', scaling], 'fontsize', Fontsize_cal)
end

if length(channel) == 3
    zlabel([channel{3}, '\_', scaling])
end

box on
grid on

view(2)

end

