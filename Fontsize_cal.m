function marker_size = Fontsize_cal(fig_handle, ratio)

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