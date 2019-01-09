classdef (Abstract) wholemazepd < dataanalyzer.positiondata
	properties
		parsedComponents
	end
	methods (Abstract)
		obj = loadParsedData(obj, parsedVisits)
		obj = runsFromParsedData(obj, parsedVisits)
		[comp, x, y, t, idx] = getParsedComp(obj, whatToGet, N, superCompNum)
		[comps, x, y, t, idx] = getNextParsedComp(obj, whatToGet, superCompNum);
		[runs, x, y, t, idx] = getRun(obj, N, superCompNum)
		[run, x, y, t, idx] = getNextRun(obj, superCompNum);
		
		N = getNumRuns(obj)
		N = getNumParsedComp(obj, whatToGet)
	end
end