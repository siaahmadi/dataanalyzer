classdef placefield < dataanalyzer.master
% A placefield object is essentially a dynamic polygon.

	properties(SetAccess='private')
		fieldInfo
		dynProps
		ParentMask
	end
	properties(Constant)
		requiredFieldNames = {'bins', 'boundary', 'binRangeX', 'binRangeY'};
	end
	methods
		function obj = placefield(parentPlaceMap, parentMask, map, fieldInfo)
			%PLACEFIELD Constructor of placefield class
			%
			% calls the @UPDATE method.
			%
			% all input arguments are required.
			
			if length(fieldInfo) ~= 1
				error('DataAnalyzer:PlaceField:InvalidFieldInfo', 'fieldInfo must be a 1x1 struct.');
			end
			
			obj.update(parentPlaceMap, parentMask, map, fieldInfo);
		end
		
		dynProps = cprops(obj, contour) % compute place field properties
		update(obj, parentPlaceMap, parentMask, map, fieldInfo)
		X = getX(obj, contour);
		Y = getY(obj, contour);
		hc = hardcopy(obj)
		cvxHull = convhull(obj, contour)
		diam = diameter(obj, contour)
		polyg = polygon(obj, contour)
		ctr = centerofmass(obj, contour)
		[r, finIdx] = rate(obj)
		a = area(obj, contour)
		[p, peakLoc] = peak(obj)
		
		sp = getSpikes(obj, passNo)
		
		h = plot(obj, varargin);
		
		h = visualize(obj, varargin);
		
		function I = isempty(obj)
			if length(obj) > 1
				I = arrayfun(@(x) x.isempty(), obj);
				return;
			end
			I = numel(obj) == 0 || isempty(obj.fieldInfo.bins);
		end
		
		function [d, ph, h, regr] = phasedist(obj, varargin)
			if numel(obj) > 1
				[d, ph, h, regr] = arrayfun(@(o) phasedist(o, varargin{:}), obj, 'UniformOutput', false);
				for i = 1:length(h)
					ax = ancestor(h{i}, 'Axes');
					ax.Title.String = ['Field #' num2str(i)];
				end
				return;
			end
			contour = 'c20';
			runs = obj.dynProps.(contour).passes;
			[d, ph, h, regr] = runs.phasedist(varargin{:});
		end
		
% 		PF = getFields(obj, fieldScope, pfInd)		% to be deleted (must move to @placemap)
% 		[rm, binX, binY] = getMaps(obj, mapScope)	% to be deleted (must move to @placemap)
	end
	methods (Static)
		[spikeTrainPerPass, passesWithSpikes] = extractSpikesPass(passes, spikeTrain)
	end
end