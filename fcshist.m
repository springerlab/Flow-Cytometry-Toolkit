function h = fcshist(chandata,varargin)
%FCSHIST plots a histogram of flow cytometry data.
%
%   Created 20121002 JW
p = inputParser;
addRequired(p,'data',@isnumeric);
addParamValue(p,'nbins',100,@isnumeric);
addParamValue(p,'xrange',[0 6],@isnumeric);
addParamValue(p,'linestyle',{'-'},@(x) iscell(x) || ischar(x));

parse(p,chandata,varargin{:});
nbins = p.Results.nbins;
xrange = p.Results.xrange;
linestyle = p.Results.linestyle;

if ischar(linestyle)
    linestyle = {linestyle};
end

X = linspace(xrange(1),xrange(2),nbins);
Y = histc(chandata,X)./numel(chandata);

h = plot(X,Y,linestyle{:});