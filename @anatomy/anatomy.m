classdef anatomy
	properties
		region = '';
		layer = '';
		subregion = '';
	end
	
	methods
		function obj = anatomy(region, layer, subregion)
			if exist('region', 'var') && ~isempty(region)
				if ~ischar(region)
					error('region must be a string.');
				end
				obj.region = region;
			end
			if exist('layer', 'var') && ~isempty(layer)
				if ~ischar(layer)
					error('layer must be a string.');
				end
				obj.layer = layer;
			end
			if exist('subregion', 'var') && ~isempty(subregion)
				if ~ischar(subregion)
					error('subregion must be a string.');
				end
				obj.subregion = subregion;
			end
		end
		function I = eq(obj, val)
			if ischar(val)
				I = strcmpi(obj.region, val);
			elseif isa(val, 'dataanalyzer.anatomy')
				I = isequal(struct(obj), struct(val));
			else
			end
		end
		function I = isequal(obj, val)
			I = eq(obj, val); % for some reason the obj == val syntax doesn't work for MATLAB's built-in @findobj
		end
	end
end