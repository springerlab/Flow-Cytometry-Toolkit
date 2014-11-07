function ParamStruct = pstrat(paramsToConvert,isReverse)
% PSTRAT translates parameter (channel) names on the Stratedigm into
% easier-to-type nickNames
%
%   2012/07/12 JW
%   2014/11/3 MS
allNames=
    {'FSC LogH','';
    'FSC LinH','fsc';
    'SSC LogH','';
    'SSC LinH','ssc';
    'FITC(530/30) LogH','yfp';
    'FITC(530/30) LogA','';
    'AmCyan(530/30) LogH','cfp';
    'AmCyan(530/30) LogA','';
    'PE(B)(586/20) LogH','';
    'PE(B)(586/20) LogA','';
    'PE(Y)(586/20) LogH','';
    'PE(Y)(586/20) LogA','';
    'PETred(615/30) LogH','';
    'PETred(615/30) LogA','';
    'MCherry(615/30) LogH','mch';
    'MCherry(615/30) LogA','';
	'PECy5(676/29) LogH','';
    'PECy5(676/29) LogA','';
	'APC(676/29) LogH','';
    'APC(676/29) LogA','';
	'PECy5.5(690/40) LogH','';
    'PECy5.5(690/40) LogA','';
	'ALexa700(690/40) LogH','';
    'ALexa700(690/40) LogA','';
	'PECy7(740LP) LogH','';
    'PECy7(740LP) LogA','';
	'APCCy7(740LP) LogH','';
    'APCCy7(740LP) LogA','';
	'PACB(445/60) LogH','bfp';
    'PACB(445/60) LogA','';
	'Width','';
    'Time','t'}

paramNames = allNames(:,1);
nickNames = allNames=(:,2);

if nargin == 0
    % display default conversions
    disp('Default nicknames and parameter names for Stratedigm:');
    disp({'Nickname','Parameter'});
    disp([nickNames,paramNames]);
else
    % return struct with nickname conversions
    if nargin < 2;
        isReverse = false;
    end
    
    ParamStruct = struct;
    
    if ~isReverse
        % return struct with nickNames -> param names
        if ~isempty(paramsToConvert)
            % find user-supplied nickNames and return conversions
            for c = 1:length(paramsToConvert)
                k = find(strcmp(paramsToConvert{c},nickNames));
                if ~isempty(k)
                    ParamStruct.(nickNames{k}) = paramNames{k};
                end
            end
        else
            % use default conversions
            for c = 1:length(nickNames)
                if ~isempty(nickNames{c})
                    ParamStruct.(nickNames{c}) = paramNames{c};
                end
            end
        end
    else
        % return struct with param names -> nickNames
        if ~isempty(paramsToConvert)
            % find user-supplied param names and return nickNames
            for c = 1:length(paramsToConvert)
                k = find(strcmp(paramsToConvert{c},nickNames));
                if ~isempty(k)
                    ParamStruct.(underscorify(paramNames{k})) = nickNames{k};
                end
            end
        else
            % use default conversions
            for c = 1:length(paramNames)
                if ~isempty(paramNames{c})
                    ParamStruct.(underscorify(paramNames{c})) = nickNames{c};
                end
            end
        end
    end
end
    