classdef maskarray < dataanalyzer.master
	properties(SetAccess=private, GetAccess=public)
		List = [];
	end
	methods
		function obj = maskarray(masks, parent)
			if nargin>0
				if numel(masks) == 0
					error('DataAnalyzer:MaskArray:EmptyMaskArrayBeingInitiated', 'A MaskArray object cannot be empty.');
				end
				if ~isempty(masks)
					obj.add(masks);
				end
				obj.Parent = parent;
			end
		end
		
		function I = hasmask(obj, mask)
			mask = obj.getMask(mask);
			I = numel(mask) > 0;
		end
		
		function mask = add(obj, mask)
			if numel(mask) > 0 && any(~isa(mask, 'dataanalyzer.mask')) % using @numel rather than @isempty b/c Mask can be an empty object but not an empty array (hence isempty == true, but numel > 0) (cf. dataanzlyer.mask specification)
				error('DataAnalyzer:MaskArray:NonMaskObjectsBeingAdded', 'At least one item in the array is not a dataanalyzer.mask object.');
			end
			obj.List = [obj.List; mask];
		end
		function mask = remove(obj, mask)
			[~, idx] = obj.getMask(mask);
			obj.List(idx) = [];
		end
		function [mask, idx] = getMask(obj, maskOrNameOrIndex)
			if isa(maskOrNameOrIndex, 'dataanalyzer.mask')
				idx = obj.List == maskOrNameOrIndex;
			elseif ischar(maskOrNameOrIndex)
				idx = arrayfun(@(x) strcmp(x.name, maskOrNameOrIndex), obj.List);
			elseif iscellstr(maskOrNameOrIndex)
				idx = ismember({obj.List.name}, maskOrNameOrIndex);
			elseif isidx(maskOrNameOrIndex, obj.List)
				idx = maskOrNameOrIndex;
			else
				error('"%s" must be a string or dataanalyzer.mask object', inputname(2));
			end
			
			if ~any(idx)
				mask = [];
				return;
			end
			mask = obj.List(idx);
		end
		
		function l = len(obj)
			l = length(obj.List);
		end
		
		function ivls = mask2ivl(obj)
			ivls = arrayfun(@(x) x.mask2ivl, obj.List, 'UniformOutput', false);
		end
		
		function idx = mask2idx(obj)
			idx = arrayfun(@(x) x.mask2idx, obj.List, 'UniformOutput', false);
		end
		
		function seqs = mask2seq(obj)
			seqs = arrayfun(@(x) x.mask2seq, obj.List, 'UniformOutput', false);
		end

		idx = apply(obj, maskable)
		
		function i = isempty(obj)
			i = arrayfun(@(obj) isempty(obj.List), obj);
		end
	end
end