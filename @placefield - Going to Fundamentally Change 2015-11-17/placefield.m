classdef placefield < dataanalyzer.master
	properties(SetAccess='private')
		parent
		fieldInfo = struct('session', struct('constrained', [], 'unconstrained', []), 'trial', struct('constrained', [], 'unconstrained', []));
	end
	properties(SetAccess='private', GetAccess = 'private')
		stuffToDraw = struct('session', struct('constrained', [], 'unconstrained', []), ... % session-wide boundaries
			'trial',  struct('constrained', [], 'unconstrained', [])); % trial-specific boundaries
		binRangeX
		binRangeY
	end
	methods
		function obj = placefield(parentNeuron, sessionRateMap, trialRateMap, fieldBins, boundaryStruct, binRangeX, binRangeY)
			obj.update(parentNeuron, sessionRateMap, trialRateMap, fieldBins, boundaryStruct, binRangeX, binRangeY);
		end
	end
	methods
		pfields = cprops(obj, rateMap, fieldBins, boundaryStruct, binRangeX, binRangeY, constraints)
		update(obj, parentNeuron, sessionRateMap, trialRateMap, fieldBins, boundaryStruct, binRangeX, binRangeY)
		PF = getFields(obj, fieldScope, pfInd)
		[rm, binX, binY] = getMaps(obj, mapScope)
	end
	methods (Static)
		[spikeTrainPerPass, passesWithSpikes] = extractSpikesPass(passes, spikeTrain)
	end
end