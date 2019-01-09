classdef expSession < dataanalyzer.master & dataanalyzer.tsable & dataanalyzer.maskable
	properties (SetAccess='protected', GetAccess='protected')
		activeNeuronList
		neuronMixAndMatchLookupTable
		trialSeqInd % 1, 2, etc depending on begin1, begin2, etc
		
		sessionNeuronList = []; % Cell array of the file names of all the neurons recorded in the session
        trialList
		isBeginTrial % logical array of equal size to trials indicating whether the corresponding index in trials is a begin trial. 1 if begintrial, 0 if sleeptrial.
		spatialEnvironment % linear or arena? (1D or 2D?)
		functionOptions
		paramOptions
	end
	properties (SetAccess = protected, GetAccess=public)
		trialDirs
		residencePath
		fullPath
		ratNo
		trials = {};
		timeUnit = 1;
		contextOrder
		projectname
		thetaRatiosFileName
		
		% added on 12/05/2015 motivated by pooled pass phase precession analysis:
		sessionSpikeTrains	% Raw .t file spike time stamps
		neurons			% dataanalyzer.neuron objects
		positionData
		lfp
% 		Mask
		NlxEvents
		beginTS
		endTS
		
		constructMode = 'preprocess+load';
	end
	properties
		contextFile = dataanalyzer.constant('expSession_contextFile');
	end
	properties(Constant)
		NlxOverFlowConstant = 3.2e8; % not sure about this
		NlxVideoTrackerXcenter = 323.5; % obtained from Rat 692, 2014-08-24_12-29-05, begin1
		NlxVideoTrackerYcenter = 273.35;% obtained from Rat 692, 2014-08-24_12-29-05, begin1
	end

	methods
		function obj = expSession(projectname, fullPath, allOptions)
			% In the most recent version, paramOptions contains the
			% parameters of the object. This used to be stored in
			% individual fields of obj, but now is consolidated in one
			% place. Similarly, the options for how the functions should
			% behave are consolidated in funcOptions.
			% 5/9/2018
			
			import dataanalyzer.*
			
			obj.lfp = dataanalyzer.lfp(obj);
			
			if nargin>0
				obj.projectname = projectname;
				prj_opt = dataanalyzer.options(obj.projectname);
				obj.thetaRatiosFileName = prj_opt.theta_pwr_ratio_filename;
				if ~exist('allOptions', 'var') || isempty(allOptions)
					allOptions = 'defaultOptions:lineartrack';
				end
				
				fprintf('\nInitializing...\n\n');
				obj.initialize(fullPath, allOptions); % sets environment and parsing options, incl. 'constructmode' in paramOptions
				
				obj.loadSessionNlxEvents();
				
				if strcmpi(obj.getOptions('constructMode'), 'preprocess-only')
					doProcess = obj.getOptions('doProcess');
					obj.preprocess(doProcess);
					return;
				elseif strcmpi(obj.getOptions('constructMode'), 'preprocess+load')
					doProcess = obj.getOptions('doProcess');
					obj.preprocess(doProcess);
				elseif strcmpi(obj.getOptions('constructMode'), 'load-only')
					% pass
				else
					error('Unrecognized constructMode.');
				end
				
				
				% For session wide maps:
				obj.loadSessionPD;
% 				obj.loadTrials; % load all trials
				obj.loadSessionNeurons;
				obj.requestRearrangementOfNeuronsByChildTrials();
				
				tL = cell(size(obj.trials));
				for i = 1:numel(obj.trials)
					tL{i} = obj.trials{i}.namestring;
				end
				obj.trialList = tL;
				
				obj.contextOrder = categorical(num2cell(cell2mat(obj.readContextFile())), {'B', 'W'}, {'black', 'white'});
			end
		end
		initialize(obj, fullPath, spatialEnvironment, allOptions)
		preprocess(obj, doProcess)
		
		[obj, trialObj] = loadTrial(obj, trialName)
		loadTrialBatch(obj, trialList)
		obj = loadTrials(obj, bgnStr, slpStr)
		obj = loadSpikesFromSessionDir(obj, trials)
		obj = loadSessionNeurons(obj)
		obj = loadSessionPD(obj)
		addPD(obj, pd)
		rmPD(obj, pd)
		I = haspd(obj, pd)
		evnt = loadSessionNlxEvents(obj)
		trials = appendTrials(obj, TrialList, TrialTypes)
		loadCellTypes(obj)
		cxt = readContextFile(obj)
		
		[eeg, ts, Fs] = readEEG(obj, ttNo, convertToDouble)
		writeLFPThetaPwrRatioToDirectory(obj)
		ratios = loadThetaRatiosFile(obj)
		
		[tr, trt] = getTrials(obj, whichTrials)
		tr = getBeginTrials(obj)
		tr = getSleepTrials(obj)
		s = size2(obj)
		[l, beginTS, endTS] = getDuration(obj, whichTrials)
		wtIdx = selectTrials(obj, whichTrials)
		regions = getRegions(obj)
		neurons = getNeurons(obj, varargin) % in varargin, specify property-value pairs (e.g. 'region', 'CA2')
		l = getNeuronList(obj)
		l = enumerate(obj, whatToList)
		sortTrialsByTemporalOrder(obj)
		updateAllPlaceFields(obj)
		updatePlaceMaps(obj, options)
		all_rates = getRates(obj, order)
		cell_types = getCellTypes(obj)
		ts = getTS(obj, restriction)
		
		function masks = getMask(obj, select)
			masks = obj.Mask;
		end
		function newObj = clip(obj, ivls) % TO BE EDITED
			newObj = [];
		end
		
		hc = hardcopy(obj, unit, zeroAnchored)
		restrict(obj, varargin)
		release(obj, releaseWhat)
		options = getOptions(obj, whichFunctionsOptions)
		options = getMyOptions(obj)
		options = setOptions(obj, options)
		options = setFunctionOptions(obj, funcOptions)
		options = setParamOptions(obj, paramOptions)
		
		requestRearrangementOfNeuronsByChildTrials(obj)
	end
	events
		PleaseRearrangeYourNeurons
	end
end