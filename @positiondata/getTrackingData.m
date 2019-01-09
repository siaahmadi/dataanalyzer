function td = getTrackingData(obj, resource, idx_Or_StandAloneMask, restriction)
%GETTRACKINGDATA Return time stamps, X, or Y-coord of position data
%
% USAGE:
%	td = GETTRACKINGDATA()
%		Return the runs due to the current mask array.
%
%		Output td will be a cell array of the same length as the number
%		of masks in the mask array. Each entry of videoX will be determined
%		as follows:
%			+ a cell array
%				- if the corresponding mask consists of more than one run
%			+ or an array of doubles 
%				- if the corresponding mask consists of a single run
%
%	videoX = GETTRACKINGDATA(idx)
%		Return the runs due to the mask array at mask indices specified
%		by |idx|.
%
%	videoX = GETTRACKINGDATA(standaloneMask)
%		Return the cell array of runs due to |standaloneMask|.
%		
%	videoX = GETTRACKINGDATA(restriction)
%		|restriction| can take on case-insenstive values specified in the
%		static field |validRestriction| of class |dataanalyzer.positiondata|.
%		These include 'restricted', 'unrestricted', 'restr', or 'unrestr'.
%
%		If a masked version is requested (DEFAULT), results will be the
%		same as calling getX() with no arguments.
%		
%		If an unmasked version is requested, the output will contain
%		the entire X-coord array of position data.
%		
%	videoX = GETTRACKINGDATA(idx, restriction)
%		If an unmasked version is requested, |idx| will be applied to the
%		entire X-coord array.
%
%		If a masked versions is requested, |idx| will be applied to the
%		mask array.

% Siavash Ahmadi
% 12/11/2015
% Modified 11/4/2015
% Modified 11/19/2015	Changing pd-level mask to trial-level mask
% TODO: implement maskarray instead of mask

% trParent = dataanalyzer.ancestor(obj, 'trial');
% effectiveMask = trParent.Mask; % named |effectiveMask| because AT THE MOMENT it can be flexible whether the mask is pd-level or trial-level. Must become entirely trial-level eventually. 11/19/2015

effectiveMask = obj.getMask('select', 'each'); % effectiveMask is supposed to be a maskarray? 4/11/2017
% DOES NOT HANDLE MORE THAN 1 MASK!!

if nargin < 3
	[restriction, mode, idxUnr] = validateInputArgs(obj, resource, effectiveMask);
elseif nargin < 4
	[restriction, mode, idxUnr, idxRestr] = validateInputArgs(obj, resource, effectiveMask, idx_Or_StandAloneMask);
elseif nargin < 5
	[restriction, mode, idxUnr, idxRestr] = validateInputArgs(obj, resource, effectiveMask, idx_Or_StandAloneMask, restriction);
end

if strcmp(restriction, 'restr')
	td = cellfun(@(x) getResource(obj, resource, x), idxRestr, 'UniformOutput', false);
else
	td = getResource(obj, resource, idxUnr);
end


function [restriction, mode, idxUnr, idxRestr] = validateInputArgs(obj, resource, effectiveMask, idx_Or_StandAloneMask, restriction)
mode = 'parent';
if numel(effectiveMask) == 0 || nargin < 4
	idxRestr = {};
	idxUnr = true(size(obj.(resource)));
	restriction = 'unrestr';
	return;
end

if nargin > 4
	if ~any(strcmpi(obj.validRestriction, restriction))
		error('DataAnalyzer:PositionData:Get:InvalidRestriction', ['Valid |restriction| values are', repmat(', %s', 1, length(obj.validRestriction))], obj.validRestriction{:});
	end
	restriction = validatestring(restriction, obj.validRestriction);
else
	restriction = 'restr';
end

if nargin > 3
	if ischar(idx_Or_StandAloneMask) % |idx_Or_StandAloneMask| is equiv. |restriction|
		if ~any(strcmpi(obj.validRestriction, idx_Or_StandAloneMask)) % string but not valid string
			error('DataAnalyzer:PositionData:Get:InvalidRestriction', ['Valid |restriction| values are', repmat(', %s', 1, length(obj.validRestriction))], obj.validRestriction{:});
		end
		restriction = validatestring(idx_Or_StandAloneMask, obj.validRestriction);
		idxUnr = true(size(obj.(resource)));
		idxRestr = effectiveMask.apply(obj.timeStamps, 'un', 0);
	elseif isa(idx_Or_StandAloneMask, 'dataanalyzer.mask') % accepts a single mask as well
		mode = 'independent';
		effectiveMask = idx_Or_StandAloneMask;
		idxRestr = effectiveMask.mask2idx;
		if ~iscell(idxRestr)
			idxRestr = {idxRestr}; % this is so that returning values will be streamlined in the main function using cellfun
		end
		notGood = cell2mat(cellfun(@(x) ~p___validIdx(x, numel(obj.(resource))), idxRestr, 'un', 0));
		restriction = 'restr';
		idxUnr = true(size(obj.(resource)));
		if any(notGood)
			error('DataAnalyzer:PositionData:Get:InvalidIdx', 'Some provided masks don''t match the Y-coord in indices.');
		end
	elseif iscellstr(idx_Or_StandAloneMask) % mask names provided
% 		[~, maskIdx] = effectiveMask.getMask(idx_Or_StandAloneMask); % this is for when effectiveMask is a maskarray, right?
		[~, maskIdx] = intersect({effectiveMask.name}, idx_Or_StandAloneMask, 'stable');
		idxRestr = effectiveMask(maskIdx).apply(obj.timeStamps, 'un', 0);
		idxUnr = true(size(obj.(resource)));
	else
		if strcmp(restriction, 'restr') % idx_Or_StandAloneMask is an index to a mask
			[~, maskIdx] = effectiveMask.getMask(idx_Or_StandAloneMask);
			idxRestr = effectiveMask.mask2idx;
			idxUnr = [];
		else % explicitly requested unrestricted
			idxRestr = [];
			idxUnr = idx_Or_StandAloneMask;
		end
	end
end

if strcmp(mode, 'parent')
	if strcmp(restriction, 'restr')
% 		if ~p___validIdx(maskIdx, numel(idxRestr))
% 			error('DataAnalyzer:PositionData:Get:MaskNotFound', 'Some mask(s) not found in the Mask list.');
% 		end
% 		idxRestr = idxRestr(maskIdx);
	else
		if ~p___validIdx(idxUnr, numel(obj.(resource)))
			error('DataAnalyzer:PositionData:Get:InvalidIdx', 'Invalid X-coord array index requested.');
		end
	end
end

function td = getResource(obj, resource, idx)
if ~isempty(idx)
	Idx = double(idx);
	Idx(Idx>0) = cumsum(Idx(Idx > 0));
	
	idx = lau.raftidx(idx);
	idx = reshape(idx(:), 2, numel(idx)/2)';
	
	if ismember('idx_global', fields(obj)) % a subbed positiondata object
		ivlIdx = ivlset(idx);
		idxVideo = ivlIdx.restrict(obj.idx_global);
		td = cellfun(@(idx) obj.(resource)(idx), idxVideo, 'un', 0);
	else
		td = arrayfun(@(i1,i2) obj.(resource)(i1:i2), idx(:, 1), idx(:, 2), 'UniformOutput', false);
	end
	if size(idx, 1) == 1 % A single continguous raft
		td = extractcell(td);
	end
else % when an empty mask is provided the idx range will be empty
	td = obj.(resource);
end