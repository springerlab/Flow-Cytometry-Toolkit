function [gatearray, idx] = uigetgate(data, paramnames, scaling, varargin)
%UIGETGATE
%
%   UIGETGATE(DATA, PARAMNAMES) scatterplots flow cytometry data along two
%   given dimensions and prompts the user to draw polygons corresponding to
%   gates on the data. The function returns the coordinates of the gates in
%   a struct that can be used by the function APPLYGATE to filter data.
% 
%   Update 20140225 JW
p = inputParser;
addParamValue(p,'xlim',[],@isnumeric);
addParamValue(p,'ylim',[],@isnumeric);
addParamValue(p,'plotdata',true,@islogical);

parse(p, varargin{:});
xl = p.Results.xlim;
yl = p.Results.ylim;
plotdata = p.Results.plotdata;

if nargin<3
    scaling = 'lin';
end
[scalex scaley] = parsescaling(scaling);

xdata = data.(paramnames{1});
ydata = data.(paramnames{2});

if plotdata
    % plot data
    colors = lines;
    plot(scalex(xdata),scaley(ydata),'.','markersize',3,'color',[.5 .5 .5]);
    xlabel(paramnames{1})
    ylabel(paramnames{2})
    if ~isempty(xl), xlim(xl); end
    if ~isempty(yl), ylim(yl); end
    hold all;
    grid on
end

% prompt for gates
fprintf(['Select a gate by clicking its vertices, and then hitting\n'...
    '[Enter]. You can select more than one gate. To exit, hit [Enter]\n'...
    'without clicking any points.\n']);  

gatearray = struct;
k = 1;
while 1
    % user draws polygon
    [x,y]=ginput();
    
    % stop prompting
    if isempty(x)
        break;
    end
    
    % store this polygon as a gate
    x=[x; x(1)];
    y=[y; y(1)];
    gatearray(k).coords = [x y];
    gatearray(k).paramnames = paramnames;
    gatearray(k).scalex = scalex;
    gatearray(k).scaley = scaley;

    % draw polygon boundaries
    axis manual
    plot(x,y,'k','linewidth',2);
    
    idx = inpolygon(scalex(xdata),scaley(ydata), x,y);
        
    if plotdata
        % plot data within polygon in different color
        plot(scalex(xdata(idx)),scaley(ydata(idx)),'.','markersize',3,'color',colors(k,:));
    end
    % show count and percent
    xc = mean(x(1:end-1));
    yc = mean(y(1:end-1));
    count = sum(idx);
    percent = count./fcsnumel(data).*100;
    str = {num2str(count); sprintf('%4.2f%%',percent)};
    text(xc,yc,str,'horizontalalignment','center',...
        'verticalalignment','middle','fontweight','bold', 'Fontsize', calc_fontsize(gca,30));
    
    k = k+1;
end 


function [scalex scaley] = parsescaling(scaling)
% 20120703
if strcmp(scaling,'lin')
    scalex = @(x) x;    % identity function
    scaley = @(x) x;
elseif strcmp(scaling,'log')
    scalex = @log10;
    scaley = @log10;
elseif strcmp(scaling,'semilogx')
    scalex = @log10;
    scaley = @(x) x;
elseif strcmp(scaling,'semilogy')
    scalex = @(x) x;
    scaley = @log10;
end

function marker_size = calc_fontsize(fig_handle, ratio)

% define as the min of width and heigth of fig_handle, in unit of pixel
% by default, ratio is 20, fig_handle is gca
% try Fontsize_cal(gca, 20)
%
% written by Bo Hua

if nargin < 2
    ratio = 20;
end

if nargin <1
    fig_handle = gca;
end

backup = get(fig_handle, 'units');
set(fig_handle, 'units', 'pixels');
fig_dimensions = get(fig_handle, 'position');
marker_size = ceil(min(fig_dimensions(3), fig_dimensions(4))/ratio);
set(fig_handle, 'units', backup);