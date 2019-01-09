classdef placemaparray < dataanalyzer.master
	properties(SetAccess=private)
		Maps
	end
	methods
		function obj = placemaparray(parent, mapOpt, varargin)
			if ~isa(parent, 'dataanalyzer.neuron')
				error('DataAnalyzer:PlaceMapArray:InvalidParent', 'parent must be a dataanalyzer.neuron object.');
			end
			obj.Parent = parent;
			% make it possible to use alternate positiondata objects (other
			% than |parent|'s |positionData|
			[pdparent, varargin] = p___extractPdObj(varargin{:});
			if numel(pdparent) > 1 % more than one alternate pdObj
				obj = cellfun(@(pdp) dataanalyzer.placemaparray(parent, mapOpt, pdp, varargin{:}), pdparent, 'un', 0);
				return;
			elseif numel(pdparent) == 1 % p___extractPdObj will produce a cell array; here we're extracting it
				pdparent = pdparent{1};
			elseif numel(pdparent) == 0
				pdparent = dataanalyzer.ancestor(parent, 'trial').positionData;
			end
			
% 			S = parent.getSpikeTrain('unrestr');
			
			EffectiveMasks = cat(1, varargin{:});
			if isempty(EffectiveMasks) % use parent's masks
				allMasks = dataanalyzer.ancestor(obj, 'maskable').Mask.List;
			elseif isa(EffectiveMasks, 'dataanalyzer.mask') || isa(EffectiveMasks, 'dataanalyzer.maskarray') % maskarray is not handled
				allMasks = EffectiveMasks;
			else
				anc = dataanalyzer.ancestor(obj, 'trial');
				allMasks = anc.Mask.getMask(EffectiveMasks);
				if numel(allMasks) == 0
					error('MaskNotFound');
				end
			end
			
% 			[x, y, t, s] = p___handleInput(X, Y, T, S); % checks type, length, extracts cell for discontinguous masks
			
			obj.Maps = arrayfun(@(mask) dataanalyzer.placemap(obj, pdparent, mask, parent, mapOpt), allMasks, 'UniformOutput', false);
			
			obj.Maps = cat(1, obj.Maps{:});
			arrayfun(@(map,mask) p___assignMapName(map, mask.name), obj.Maps, allMasks);
		end
		
		function M = getMap(obj, maskName)
			
			if numel(obj) > 1
				maps = arrayfun(@(x) x.getMap(maskName), obj, 'un', 0);
				if any(cellfun(@numel, maps) ~= 1)
					M = maps;
				else
					M = cat(1, maps{:});
				end
				return;
			end
			
			if ~ischar(maskName)
				error('Provide a string as the mask name query.');
			end
			idx = arrayfun(@(x) strcmp(x.ParentMask.name, maskName), obj.Maps);
			M = obj.Maps(idx);
		end
	end
end