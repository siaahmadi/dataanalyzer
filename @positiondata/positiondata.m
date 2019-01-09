classdef positiondata < dataanalyzer.visualizable & dataanalyzer.tsable & dataanalyzer.maskable
	properties(SetAccess=private, GetAccess=protected)
		stockX
		stockY
		stockV % stockV used to be StockV; if error, check case
		timeStamps
		
		trialBeginTS
		trialEndTS
		timeUnit = 1;
		
		parentTrial
	end
	properties(SetAccess=protected, GetAccess=protected)
		TS
		X
		Y
		V
	end
	properties(SetAccess=protected, GetAccess=public)
		centerParams % used by @update of subclasses to save corr-based centering params
		
		addonX % for alternative position data (e.g. linearized, idealized, etc)
		addonY % for alternative position data (e.g. linearized, idealized, etc)
		addonV % for alternative position data (e.g. linearized, idealized, etc)
		addonPD% for alternative position data (e.g. linearized, idealized, etc)
	end	
	
	properties (Constant)
		stockTimeUnit = 1e-6;
		validRestriction = {'restricted', 'unrestricted', 'restr', 'unrestr'};
	end
	properties (SetAccess=private, GetAccess=public)
% 		Mask % defined in superclass
		maskIN % 11/09/2015 used to be called |restrictIN|. If error encountered, update the code to reflect this change.
	end
	properties
		videoFR
	end
	
	methods
		function obj = positiondata(parent, X, Y, timeStamps, videoFR)
			if nargin == 0
				obj = p___initialize(obj); % either empty obj, or construct with X, Y, timeStamps, ...
			elseif nargin == 1
				obj = p___initialize(obj, [], parent); % use parent as constructorObj
			else
				obj = p___initialize(obj, parent); % either empty obj, or construct with X, Y, timeStamps, ...
			end
			if nargin < 1
				return
			end
			if ~isequaln(numel(X), numel(Y), numel(timeStamps))
				error('syntax problem created by the addition of |parent| to positiondata constructor argument list.');
			end
			
			if nargin > 3
				obj.stock(X, Y, timeStamps, videoFR);
			elseif nargin > 1
				obj.stock(X, Y, timeStamps, obj.videoFR);
			elseif isa(X, 'dataanalyzer.positiondata')
				p___initialize(obj, X);
			else
				error('Unknown inputs.');
			end
			
			obj.resetToStock;
		end
		function obj = resetToStock(obj)
			obj.X = obj.stockX;
			obj.Y = obj.stockY;
			obj.V = obj.stockV;
		end
		
		function I = eq(obj, obj2)
			ts = isequaln(obj.timeStamps, obj2.getTS('unrestr'));
			x = isequaln(obj.stockX, obj2.stockX);
			y = isequaln(obj.stockY, obj2.stockY);
			v = isequaln(obj.stockV, obj2.stockV);
			p = isequaln(obj.Parent, obj2.Parent);
			o = isequaln(obj, obj2);
			
			I = ts & x & y & v & p;
		end
		
		function l = len(obj)
			l = length(obj.timeStamps);
		end
		
		td = getTrackingData(obj, resource, idx_Or_StandAloneMask, restriction)
		videoTS = getTS(obj, idx, restriction)
		videoX = getX(obj, idx, restriction)
		videoY = getY(obj, idx, restriction)
		[v, vBar] = getVelocity(obj, restriction)
		
		ax = plot(obj, varargin)
		function ax = visualize(obj, varargin)
			[ax, args] = axescheck(varargin{:});
			p = inputParser();
			p.KeepUnmatched = true;
			p.addParameter('pdOff', 'on', @(x) ismember(x, {'off', 'on'}));
			p.addParameter('vis', dataanalyzer.neuron(), @(x) isa(x, 'dataanalyzer.timeable'));
			p.parse(args{:});
			pdOff = p.Results.pdOff;
			if ~isempty(fieldnames(p.Unmatched))
				args = cell(length(fieldnames(p.Unmatched))*2, 1);
				args(1:2:end) = fieldnames(p.Unmatched);
				args(2:2:end) = struct2cell(p.Unmatched);
			else
				args = {};
			end
			timeableObj = p.Results.vis;
			idx = dataanalyzer.tsable.findRangeForTimeable(obj, timeableObj);
			
			if strcmp(pdOff, 'on')
				if isempty(ax)
					ax = obj.plot();
				else
					obj.plot(ax);
				end
			end
			ax.NextPlot = 'add';
			if isa(timeableObj, 'dataanalyzer.tsable')
				if length(args)<2
					obj.plot(ax, 'range', idx, 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerSize', 5);
				else
					obj.plot(ax, 'range', idx, 'Marker', 'o', 'MarkerSize', 5, args{:});
				end
			else
				obj.plot(ax, 'range', idx, 'LineWidth', 2, args{:});
			end
		end
		newObj = clip(obj, ivls) % new: produces a restricted version of the positiondata object
		
		mask = createMaskFromParsedComponents(obj, useParsedComponents)
		obj = load(obj, fullResidencePath, pdFileName, parentTrial)
		addPD(obj, pdObj);
		rmPD(obj, pdObj);
		tidy(obj)
		center(obj, centerParams)
		scale(obj, scaleFactor)
		I = convertTimeUnit(obj, newTimeUnit) % should I return the parent object instead of I?
		obj = setParentTrial(obj, parentTrial)
		I = isempty(obj)
% 		function pt = getParentTrial(obj)
% 			pt = obj.parentTrial;
% 		end

		hc = hardcopy(obj)

		restrict2roi(obj, restrictLogic, varargin) % restrict position data
		releaseroi(obj) % undo restrict
		I = isrestricted(obj);
		
		
		Runs = getPassesThroughPolygon(obj, polyg, mask, S) % DEPRECATED
		passes = passesThroughROI(obj, ROI, mask, parentNeuron)
	end
	methods (Access=protected)
		function stock(obj, X, Y, timeStamps, videoFR)
			%stock(obj, X, Y, timeStamps, videoFR) Stock position data object
			%with user input

			obj.stockX = X;
			obj.stockY = Y;
			obj.timeStamps = timeStamps;
			obj.videoFR = videoFR;
		end
	end
	methods (Static)
		[entranceEdges, departureEdges, off2on, on2off, sequenceOfEvents, edgeLabels] = computeEntranceDeparture(x, y, polygROI)
		ind = whichLinesegIntersect(roiEdgeStruct, testSegment)
		[roiSegmentsStruct, roiSegmentsArray] = extractSegmentsOfPolygon(polygROI)
		pdObj = createEnvPD(spatialEnvironment, parent)
		mzbw = layout2bw(mzlayout,res)
		centerParams = ctrposdat(rawX, rawY, mzTemplate, optORxScale, yScale, rotateBy)
	end
end