function maskedPD = applyMask(obj, mask, pathData)
%applyMask  One-time apply mask object to position data or user |pathData|
%           (without changing position data's X, Y, or TS)
% 
% SYNTAX:
%	maskedPD = applyMask(obj, mask, pathData)
%
% |mask| will be applied to the position data only if pathData is not
% supplied.
%
% If |pathData| is provided the position data object will not be affected.
%
% In this case an output argument must be provided to collect the output,
% otherwise no function will be performed and a warning will be displayed.
%
% |pathData| must be a non-empty struct with non-empty fields of same
% length (i.e. number of elements);

% Siavash Ahmadi
% 11/4/2015

if ~isa(mask, 'dataanalyzer.mask')
	error('DataAnalyzer:PositionData:MaskObjectNeeded', '|mask| must be of |dataanalyzer.mask| type.');
end

if ~exist('pathData', 'var') || isempty(pathData)
	pathData.x = obj.getX();
	pathData.y = obj.getY();
	pathData.t = obj.getTS();
elseif nargout == 0
	error('Please provide an output argument. Will not overwrite position data''s contents based on |pathData|.');
end

if ~auxFunc_validPathData(pathData)
	error('DataAnalyzer:PositionData:InvalidPathData', '|pathData| must be a struct every field of which has the same number of elements.');
end

idx = mask.mask2idx(obj);

fn = fieldnames(pathData);

if nargout > 0 || ~(isfield(pathData, 'x') && isfield(pathData, 'y') && isfield(pathData, 't'))
	if nargout == 0
		warning('No output argument provided. Since |pathData| doesn''t contain all three fields, |x|, |y|, and |t|, no function will be performed.');
		return;
	end
	
	for i = 1:length(fn)
		maskedPD.(fn{i}) = pathData.(fn{i})(idx);
	end
elseif nargout == 0 || ~exist('pathData', 'var') || isempty(pathData)
	obj.X = pathData.x;
	obj.Y = pathData.y;
	obj.TS = pathData.t;
	
	maskedPD = obj; % if not provided a |pathData| but an output argument is provided this will ensure that something is returned.
end

function I = auxFunc_validPathData(pathData)

I = false;

fn = fieldnames(pathData);
nl = zeros(size(fn));

if isempty(pathData) || ~isstruct(pathData) || isempty(fn)
	return;
end

for i = 1:length(fn)
	nl(i) = numel(pathData.(fn{i}));
end

if any(nl - nl(1)) || any(nl == 0) % number of elements of at least one field is different from another
	return;
end

I = true;