classdef lfp < dataanalyzer.master & dataanalyzer.tsable
	properties(SetObservable)
		eeg = eegstruct();
		phase = phasestruct();
		envelope = envstruct();
	end
	properties(SetAccess=protected)
		ttMapping % contains a map indicating which CSC file should be read for each tetrode .t file.
				% By default, the tetrode number is extracted from the .t file's name and
				% the corresponding CSC file is read. If the user wishes to modify this behavior,
				% this matrix defines the map.
	end
	methods
		function obj = lfp(parent)
			MAXTT = dataanalyzer.constant('lfp_MAXTT');
			obj.ttMapping = sparse(1,1,0,double(intmax), 1, MAXTT);
			obj.update(parent);
			addlistener(obj, 'eeg', 'PostSet', @(src,evnt)dataanalyzer.lfp.handleSetProp(src,evnt));
			addlistener(obj, 'phase', 'PostSet', @(src,evnt)dataanalyzer.lfp.handleSetProp(src,evnt));
			addlistener(obj, 'envelope', 'PostSet', @(src,evnt)dataanalyzer.lfp.handleSetProp(src,evnt));
		end
		
		function obj = update(obj, parent)
			if ~isa(parent, 'dataanalyzer.trial') && ~isa(parent, 'dataanalyzer.expSession')
				error('Cannot use a non-trial or non-session object as parent of @lfp object');
			end
			obj.Parent = parent;
		end
		
		ts = getTS(obj, mask)
		
		eeg = readEEG(obj, ttNo, save)
		phaseStruct = getPhase(obj, ttNo, freqBandDefStruct)
		ivl = findBand(obj, ttNo, freqBandDefStruct)
		pwr = power(obj, ttNo, freqBandDefStruct)
		filt_lfp = filter(obj, ttNo, freqBandDefStruct)
		
		defineTetrodeMapping(obj, mapping)
		clear(obj)
		
		visualize(obj, ttNo)
		function newObj = clip(obj, ivls) % TO BE EDITED
			newObj = [];
		end
	end
	methods (Static)
		freqBandDefStruct = defineFreqBand(name, low, high);
		function handleSetProp(src,evnt)
			% TODO
			% make sure when obj.eeg has been written, there's a tsd object
			% in its .tsd field. If not, just remove the thing from obj.
		end
	end
end