classdef mazerun < dataanalyzer.positiondata & dataanalyzer.neuralevent
% A mazerun is a continuous event: it cannot have "gaps". If masking the
% mazerun will produce gaps, the object is broken into continuous pieces.
	properties(SetAccess=protected, GetAccess=public)
		idx_pd = []; % the indices that will return the Run's X, Y, and TS from the wholemazepd object (this object's parent)
		idx_sp = [];
		
% 		timeStamps % inherited from dataanalyzer.positiondata
% 		X          % inherited from dataanalyzer.positiondata
% 		Y          % inherited from dataanalyzer.positiondata
		ts
		x
		y
		
% 		duration   % inherited from dataanalyzer.neuralevent
		
		distanceTraversed
		avgVelocity
		
		spikes
% 		numSpikes   % redundant --> deprecated
		
		field_elevation % the contour to which this run belongs, if the Parent object is a placefield
		field_rate % the rate of firing at each (x,y) coordinate of this run
		
		parentPD
		parentNeuron
% 		Ivls           % inherited from @neuralevent
	end
	
% 	properties(SetAccess=private, GetAccess=private)
% For an explanation for why the following line is commented out see
% @mazerun.update:T = getTopTSableParentTimeStamps(obj);
% 		unmaskedTrialTS
% 	end
	methods
		function obj = mazerun(parent, parentPD, parentNeuron, ivls)
			%MAZERUN A hybrid subset of positiondata and neuron objects
			%with the associated properties
			%
			% parent should be a placefield object??
			
			if nargin == 0
				return;
			end
			
			if exist('parentPD', 'var') && ~isa(parentPD, 'dataanalyzer.positiondata')
				error('DataAnalyzer:Mazerun:Constructor:ParentTypeMismatch', 'parentPD must be a positiondata object');
			end
			if exist('parentNeuron', 'var') && ~isa(parentNeuron, 'dataanalyzer.neuron')
				error('DataAnalyzer:Mazerun:Constructor:ParentTypeMismatch', 'parentNeuron must be a neuron object');
			end
			if exist('ivls', 'var') && ~isa(ivls, 'ivlset')
				error('DataAnalyzer:Mazerun:Constructor:ParentTypeMismatch', 'ivls must be a ivlset object');
			end
			
			obj.parentPD = parentPD;
			obj.parentNeuron = parentNeuron;
			obj.Ivls = ivls;
			
			obj.Parent = parent; % this would be a |placefield| object
% 			obj.setParentTrial(dataanalyzer.ancestor(parent, 'trial')); % this is a |trial| object
			
			if nargin == 1
				return;
			end
			
			if length(ivls) > 1 % more than 1 interval --> generate multiple mazerun objects
				runs = arrayfun(@(i) dataanalyzer.mazerun(parent, parentPD, parentNeuron, ivls.getInterval(i)), 1:length(ivls), 'un', 0);
				obj = cat(1, runs{:});
				
				return;
			end
			
			idx_pd = ivls.restrict(parentPD.getTS('unrestr'));
			idx_pd = idx_pd{1};
			
			if isempty(ivls)
				1;
			end
			idx_sp = ivls.restrict(parentNeuron.getSpikeTrain('unrestr'));
			idx_sp = idx_sp{1};

			obj.idx_pd = idx_pd;
			t = parentPD.getTS('unrestr');
			x = parentPD.getX('unrestr');
			y = parentPD.getY('unrestr');
			v = parentPD.getVelocity('unrestr');
			obj.stock(x(idx_pd), y(idx_pd), t(idx_pd), parentPD.videoFR);
			obj.resetToStock();
			
			obj.idx_sp = idx_sp;
			% discard the spikes that are not mine:
			clippedNeuron = parentNeuron.clip(ivls);
			obj.update();
			obj.spikes = dataanalyzer.spike(obj, clippedNeuron);
		end
		
		update(obj, varargin)
		hc = hardcopy(obj)
		
		[d, ph, h, regr] = phasedist(obj, varargin)
		
		lfp = getMyLFP(obj, ttNo)
		
		h = plot(obj, varargin)
		h = visualize(obj, varargin)
		
		function setParent(obj, parent) % TODO: check if a superclass already defines this as if so no overriding would be necessary
			obj.Parent = parent;
		end
		
		function set.ts(obj, val)
			obj.ts = val;
			obj.TS = val;
		end
		function set.x(obj, val)
			obj.x = val;
			obj.X = val;
		end
		function set.y(obj, val)
			obj.y = val;
			obj.Y = val;
		end
		
		function l = length(obj)
			if numel(obj) == 0
				l = [];
			else
				l = arrayfun(@(x) length(x.idx), obj);
			end
		end
	end
end