classdef neuron < dataanalyzer.master & dataanalyzer.tsable & dataanalyzer.maskable
    properties (SetAccess='private')
		parentTrial = dataanalyzer.trial();
		ID % randomly generated identifier; for GUI selection

        residencePath
		parentResidencePath % this would be useful for calling the Duration static method of 'trial'
		isOrphan % if included by a 'trial' object
		isZeroAnchored
		trialDuration
		isRestricted = false;
	end
	properties (SetAccess=private, GetObservable)
		% NOTE: the following properties were under GetAccess=public
		% They were moved in order for them to be set to correct value before
		% findobj accesses them
		% @author=Sia
		% @date=04-04-2015
		%
		% NOTE: the following properties were under GetAccess=private
		% They were moved in order to let findobj access them
		% @author=Sia
		% @date=03-23-2015
        spikeTrain
		overFlowedSpikeTrain
% 		placeFields % array of placefield objects (DEPRECATED)
		anatomicalRegion = dataanalyzer.anatomy(); % where the neuron was recorded from
		autocorrelation = [];
		spatialinformation = [];
		type = '';
		avgFiringRate = [];
		peakFiringRate = [];
		bursts = [];
		phases
		rtfun
		
		placeMaps % of type dataanalyzer.placemaparray -- replaces placeFields
	end
	properties (SetAccess=private, GetAccess=private)
		history = {''}; % history of operations since last reset
		selectionFlag = struct('spikes', struct('lowerBound', [], 'upperBound', [], 'duration', [])...
			, 'placefields', [], 'passes', []); % which subobjects to return by thatSatisfy()
		updatePlaceFieldListenerHandle
	end
	properties
	end
	
	methods (Static = true)
		tFileList = getTFileList(fullPath)
		S = da_LoadSpikes(tfilelist, path, NaFile)
		findBursts(obj, criteria) % TODO
		determineCellType(obj, criteria) % TODO
		
		function pregetPropHandler(src, evnt)
			if strcmpi(evnt.EventName, 'PreGet')
				switch src.Name
					case 'type'
						if strcmp(evnt.AffectedObject.type, src.DefaultValue)
% 							evnt.AffectedObject.cellType();
						end
					case 'placeMaps'
						if numel(evnt.AffectedObject.placeMaps) == 0
% 							evnt.AffectedObject.updatePlaceMaps();
						end
				end
			end
		end
	end
	
	methods
		function obj = neuron(varargin)
			[parent, s, phases, tFileName, anatomy, sp_path, namestring] = p___parseInput(varargin{:}); %#ok<ASGLU>
			% varargin: 'spikes', 'anatomy', 'parent', 'namestring', 12/05/2015
			% 'phases', 'sp_path', 'tFileName' (same as namestring), (updated: 4/17/2017)
			obj.phases = phases;
			
			if isempty(s) && exist(sp_path, 'file')
				obj.load(sp_path);
			elseif ~isempty(s) && exist(sp_path, 'file')
				error('Ambinguous input. Exactly one of ''spikes'' or ''spikespath'' should be valid. Set one to empty.');
			else
				obj.spikeTrain = s;
			end

			obj.setParent(parent);
			if isa(parent, 'dataanalyzer.trial') % UpdateYourParent defined in trial only 12/05/2015
				addlistener(parent,...
					'UpdateYourParent',@(parent, event) updateParent(obj, event));
			end
			obj.namestring = namestring; % same thing as tFileName
			obj.setRegion(anatomy);

			if isa(obj.Parent, 'dataanalyzer.master')
				obj.avgFiringRate = length(s) / (obj.Parent.endTS - obj.Parent.beginTS);
			end
			addlistener(obj, 'type', 'PreGet', @dataanalyzer.neuron.pregetPropHandler);
			addlistener(obj, 'placeMaps', 'PreGet', @dataanalyzer.neuron.pregetPropHandler);
		end
		
		% handle methods
		orphan(obj, isOrphan, parentTrial)
		obj = load(obj, pathToNeuron, parentTrial)
		setRegion(obj, anatReg)
		setSpikeTrainUnit(obj, multiplyBy) % for unit conversion
		breakParent(obj)
		d = getDuration(obj, whatDuration)
		newObj = restrict(obj, ref)
		newObj = clip(obj, ivls)
		s = release(obj, whatToRelease)
		pf = updatePlaceMaps(obj, varargin)
		pf = setPlaceFields(obj, sessionMap, fieldBins, boundaryStruct, binRangeX, binRangeY)
		% handle methods: TODO
		initialize(obj)
		satisfyingObjects = thatSatisfy(obj, varargin)
		updateParent(obj, evnt)
		u = unique(obj, varargin)
		function masks = getMask(obj, masks)
			if ~exist('masks', 'var')
				masks = obj.Mask;
			else
				error('todo');
			end
		end
		
		% value methods
		S = getSpikeTrain(obj, restriction)
		ts = getTS(obj, restriction)
		hc = hardcopy(obj, unit, zeroAnchored, legacy)
		[region, subregion, layer] = getRegion(obj)
		raster(obj) % Plot a raster of neuron's spike train.
		h = visualize(obj, varargin)
		numS = len(obj)
		f = ratefun(obj, forceStock, kernel, params) % return function f(t) whose values are instantaneous firing rate of neuron at t
		p = peakRate(obj, spatialOrTemporal, returnStock) % peak rate (supremum of ratefun() over [0, lenTrial)
		m = meanRate(obj, returnStock) % average rate (average of ratefun() over [0, lenTrial)
		I = isempty(obj)
		[ac, t] = autocorr(obj, corrInterval, temRes) % autocorrelation
		[xc, t] = xcorr(obj, anotherNeuron, corrInterval, temRes, options) % cross correlat
		% value methods: TODO
		ct = cellType(obj) % principal cell or interneuron?
		pf = getPlaceFields(obj) % array of place fieldsion
		b = getBursts(obj) % array of burst times
		burstStats = getBurstInfo(obj, varargin)
		si = spatinfo(obj) % spatial information
		[pval, ph, rl, phdistro] = phaselock(obj, varargin)
		pfm = getPlaceMap(obj)
		[trialWiseMaps, binRangeX, binRangeY, gaussFit2, constraintedRateMaps] = computeTrialWisePlaceMap(obj, constraints, options)
		function lbl = char(obj)
			anat = 'unknownAnatomy';
			if ~isempty(obj.anatomicalRegion.region)
				anat = strcat(obj.anatomicalRegion.region, obj.anatomicalRegion.subregion);
				if ~isempty(obj.anatomicalRegion.layer)
					anat = strcat(anat, '_', obj.anatomicalRegion.layer);
				end
			end
			tFileName = obj.namestring;
			if isempty(obj.residencePath)
				anc = dataanalyzer.ancestor(obj, 'expSession');
				residence = anc.namestring;
			else
				residence = obj.residencePath;
			end
			
			lbl = strcat(tFileName, '___', residence, '___', anat);
		end
	end
	events
		PleaseFixMyOverflowedSpikeTrain
	end
end