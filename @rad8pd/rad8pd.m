classdef rad8pd < dataanalyzer.wholemazepd
	properties
% 		parsedComponents    % inherited from @dataanalyzer.wholemazepd
		
		hdEpochsBinary
		movementEpochs
	end
	methods
		function obj = rad8pd()
			if ~obj.isempty % when a position data object is only being initialized, it will be empty
				obj.preprocess;
				obj.update();
			end
		end
				
		[hdEpochsBinary, movementEpochs] = getEpochs(obj, options)
		traversals = getRoiTraversals(obj, target) % goal: return traversals of a region demarcated by target
		obj = update(obj)
		
		hc = hardcopy(obj)
	end
	methods (Static)
		pathData = parse(t, x, y, options)
	end
end