classdef linearpd < dataanalyzer.wholemazepd
	properties
		hdEpochsBinary
		movementEpochs
	end
	methods
		function obj = linearpd()
			if ~obj.isempty
				obj.update();
			end
		end
		obj = parseLeftRight(obj)
		obj = getLeftbound(obj)
		obj = getRightbound(obj)
		flatten(obj)
		[hdEpochsBinary, movementEpochs] = getEpochs(obj, options)
		[traversals, leftboundPassesTS, rightboundPassesTS] = getTraversals(obj, target) % goal: return traversals of a region demarcated by target
		
		function obj = update(obj)
			obj.loadParsedData();
		end
		function obj = loadParsedData(obj)
			% Loads everything from parsedVisits
			error('Make sure this is compatible with rad8pd.loadParsedData');

			fn = dataanalyzer.constant('FileName_ParseData_Session');

			pi = load(fullfile(obj.Parent.fullPath, fn), 'idx');
			obj.parsedComponents = pi.idx;
		end
		
		function obj = load(obj, loadFrom, fn_pd, parent)
			if isempty(fn_pd)
				fn_pd = dataanalyzer.constant('FileName_PathData_Session');
			end
			obj = load@dataanalyzer.positiondata(obj, loadFrom, fn_pd, parent);
		end
		
		ax = plot(obj, varargin)
		
		% inhertied from abstract class dataanalyzer.wholemazepd
		function obj = runsFromParsedData(obj, parsedVisits)
		end
		function [comp, x, y, t, idx] = getParsedComp(obj, whatToGet, N, superCompNum)
		end
		function [comps, x, y, t, idx] = getNextParsedComp(obj, whatToGet, superCompNum);
		end
		function [runs, x, y, t, idx] = getRun(obj, N, superCompNum)
		end
		function [run, x, y, t, idx] = getNextRun(obj, superCompNum)
		end
		function N = getNumRuns(obj)
		end
		function N = getNumParsedComp(obj, whatToGet)
		end
	end
end