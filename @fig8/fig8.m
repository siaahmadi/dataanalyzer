classdef fig8 < dataanalyzer.wholemazepd
	properties
		hdEpochsBinary
		movementEpochs
	end
	methods
		function obj = fig8(type, parent)
			if exist('parent', 'var')
				obj.Parent = parent;
			end
% 			obj.preprocess;
			% TODO: parse |type|
			
			if ~obj.isempty % when a position data object is only being initialized, it will be empty
				obj.update();
			end
		end
		
		[hdEpochsBinary, movementEpochs] = getEpochs(obj, options)
		traversals = getRoiTraversals(obj, target) % goal: return traversals of a region demarcated by target
		obj = update(obj)
		preprocess(obj)
		function obj = load(obj, loadFrom, fn_pd, parent)
			if isempty(fn_pd)
				fn_pd = dataanalyzer.constant('FileName_PathData_Session');
			end
			obj = load@dataanalyzer.positiondata(obj, loadFrom, fn_pd, parent);
		end
		
		hc = hardcopy(obj)
	end
	methods (Static)
		pathData = parse(pi, x, y, t, options)
	end
end