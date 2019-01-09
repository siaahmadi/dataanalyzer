function [idx, varargout] = apply(obj, maskable, varargin)
%APPLY Apply mask to timeable object, double array, or cell array of
%doubles
%
% idx = APPLY(obj, maskable[, varargin[, 'un', false/true]])

if nargin > 2
	if numel(varargin) >= 2
		un = varargin{end-1};
		un0 = varargin{end};
	else
		un = 'un';
		un0 = 1;
	end
	if ~strcmpi(un, 'un')
		un = 'un';
		un0 = 1;
	elseif numel(varargin) >= 2
		varargin = varargin(1:end-2);
	end
end

if isa(maskable, 'dataanalyzer.tsable')
	if numel(maskable) > 1
		if iscell(maskable)
			idx = cellfun(@(m) obj.apply(m), maskable, 'un', 0);
		else
			idx = arrayfun(@(m) obj.apply(m), maskable, 'un', 0);
		end
		return;
	end
	maskable = maskable.getTS();
	if iscell(maskable)
		maskable = maskable{1};
	end
	masterIvl = obj.tEffectiveIvls;
	idx = masterIvl.restrict(maskable);
	idx = sum(extractcell(idx), 2) > 0;
elseif isa(maskable, 'dataanalyzer.timeable')
	1;
elseif isnumeric(maskable)
	if numel(obj) > 1
		ivls = arrayfun(@(obj) obj.tEffectiveIvls, obj, 'un', 0);
		ivls = cat(1, ivls{:});
		masterIvl = ivls.collapse('|');
		idx = masterIvl.restrict(maskable);
	else
		masterIvl = obj.tEffectiveIvls;
		idx = masterIvl.restrict(maskable);
	end
	if ~exist('un', 'var') || (strcmp(un, 'un') && un0)
		idx = sum(cat(2, idx{:}), 2) > 0; % OR all idx entries (each entry corresponds to a disjoint interval from ivlset)
	end
elseif all(cellfun(@isnumeric, maskable))
	idx = cellfun(@(x) obj.apply(x), maskable, 'un', 0);
	return;
else
	error('Type not supported yet.');
end

[~, varargout] = cellfun(@(item) masterIvl.restrict(maskable, item), varargin, 'un', 0);