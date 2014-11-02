function segdata = fcssegplate(platedata, varargin)
% FCSSEGPLATE does automatic segmentation on the flow cytometry data
% contained in PLATEDATA. Results are returned in SEGDATA, which is an
% 8x12x4 struct matrix containing for each well, data for each segmented
% subpopulation.
%
% By default, a 2-color segmentation is performed using mCherry (Fluor1)
% and BFP (Fluor2), and the subpopulations are returned in this order:
%
%   1. Fluor1+ Fluor2-
%   2. Fluor1- Fluor2+
%   3. Fluor1+ Fluor2+ (doublet)
%   4. Fluor1- Fluor2- (non-fluorescent)
%
% To segment on only 1 fluorescent marker or to use other pairs of fluors,
% set the FLUORS parameter to a string or a cell array containing
% strings. For example,
%
%   fcssegplate(platedata, 'mch')
%
% will segment mCherry+ cells from mCherry- cells and return them in that
% order.
%
% Created 20141021 by JW

% parse arguments, set defaults
p = inputParser;
addOptional(p,'fluors',{'mch','bfp'},@(x) iscell(x) || ischar(x));

parse(p,varargin{:});
fluors = p.Results.fluors;

% do segmentation
tic
warning('off','all')

fprintf(['Segmenting plate data: well    \n']);

for r = 1:8
    for c = 1:12
        fprintf([ '\b\b\b\b' coord2well(r,c) '\n']);
        
        if iscell(fluors) && numel(fluors) == 2
            subpops = fcssegment(platedata(r,c), fluors);
        elseif iscell(fluors) && numel(fluors) == 1
            subpops = fcsseg1d(platedata(r,c), fluors{1});
        elseif ischar(fluors)
            subpops = fcsseg1d(platedata(r,c), fluors);
        else
            error('Please set ''fluors'' parameter to a valid fluor name(s).');
        end
        
        if r==1 && c==1
            segdata = reshape(subpops,[1 1 numel(subpops)]);
        else
            segdata(r,c,:) = subpops;
        end
    end
end

fprintf('Finished segmentation. ');
warning('on','all')
toc