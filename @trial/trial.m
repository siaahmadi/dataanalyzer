classdef trial < dataanalyzer.master & dataanalyzer.timeable & dataanalyzer.maskable
	
% NOTICE: TRIAL IS NOT NECESSARILY VISUALIZABLE (cf. @begintrial is.).

	properties (SetAccess='protected', GetAccess='protected')
		activeNeuronList
		neuronMixAndMatchLookupTable
		trialSeqInd % 1, 2, etc depending on begin1, begin2, etc
	end
	properties (SetAccess = protected)
		ratNo
		residencePath
		fullPath
		neuronList
		duration = [];
		beginTS = [];
		endTS = [];
		neurons = dataanalyzer.neuronarray();
		lfp
% 		Mask
		
		timeUnit = 1;
		isEmpty = true;
		parentSession
	end

	methods
		function obj = trial(residencePath, nameString, spatialEnvironment, loadAllNeurons, parent)
			import dataanalyzer.*
			
			obj.lfp = dataanalyzer.lfp(obj);

			if nargin>0
				if ischar(residencePath)
					obj.initialize(residencePath, nameString, spatialEnvironment);
					if loadAllNeurons
						obj.loadNeurons
					end
					obj.takeCareOfOverflow();
				end
				if nargin > 3
					obj.linkToParentViaListener(parent)
				end
				obj.isEmpty = false;
			end
		end
		
		function T = getT(obj)
			T = [obj.beginTS; obj.endTS];
		end
		
		initialize(obj, residencePath, nameString, spatialEnvironment)
		obj = loadNeuron(obj, tFileName)
		S = loadNeuronBatch(obj, tFileList_or_spikeTrains, tFileList)
		[obj, status] = loadNeurons(obj)
		[eeg, ts, Fs] = readEEG(obj, ttNo, convertToDouble)
		
		n = addNeuron(obj, Neuron)
		l = addNeuronBatch(obj, NeuronList)
		na = getNeurons(obj, idx)
		s = size(obj)
		l = getNeuronList(obj)
		[l, beginTS, endTS] = getDuration(obj)
		rearrangeNeurons(obj, evntData)
		linkToParentViaListener(obj, parent)
		hc = hardcopy(obj, unit, zeroAnchored)
		plot(obj)
		function masks = getMask(obj, select)
			masks = obj.Mask;
		end
		function s = start(obj)
			s = obj.beginTS;
		end
		function obj = clip(obj, ref)
			if ~isa(ref, 'ivlset') && ~isa(ref, 'dataanalyzer.mask')
				error('Input 1, ref (%s), must be an ivlset or mask object', inputname(2));
			end
			error('todo');
		end
	end
	methods (Static)
		anatReg = matchAnatomicalRegionsWithSpikeTrains(ratNo, tFileList, ttLocateFunc)
		I = isbegin(objOrStr)
		I = issleep(objOrStr)
	end
	events
		PleaseUpdateYourPlaceFields
		PleaseConvertYourUnit
		UpdateYourParent
		HereIsYourFixedSpikeTrain
		PleaseCheckSpikeTrainOverflow
	end
end