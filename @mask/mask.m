classdef mask < dataanalyzer.timeable
% Can be
% 	1) Spatial Mask (polygon)
% 	2) Time Mask (interval set of time ranges)
% 	3) Index Mask (integer/double array of indices)
% 	4) Logical true/false
% 		(if true, current restriction mask will be used)
% 	5) String 'restricted'
% 	6) Empty, or skipped. (Will be disregarded.)

	properties (GetAccess=protected, SetAccess=private)
		tIntervals		% 
		tEffectiveIvls	% 
		tSeq			% 
		tIdx			% 
% 		Ivls            % Inherited from dataanalyzer.timeable
	end
	properties
		name = '';
	end
	methods
		function obj = mask(buildingBlocks, parent, name)
			if nargin == 0
				buildingBlocks = [];
				parent = [];
			end
			% The following block commented out because parent should not
			% be the same as refTSable (TODO: refTSable should be introduced);
% 			if ~isempty(buildingBlocks) && ~isa(parent, 'dataanalyzer.tsable') % if parent doesn't have a getTS or getTimeStamps method
% 				error('Parent/Reference Object must have be dataanalyzer.tsable type.');
% 			end
			
			if ~exist('name', 'var')
				name = '';
			end
			
			if strcmp(name,'default')
				1; % for debugging
			end
			
			obj.Parent = parent;
			
			if ~exist('buildingBlocks', 'var') || isempty(buildingBlocks) % isempty for if |buildingBlocks| is not a double but is empty
				if isa(parent, 'dataanalyzer.visualizable')
					try
						x = parent.getX('unrestr');
						buildingBlocks = true(length(x), 1);
					catch
						1; % for debugging
					end
				else
					buildingBlocks = [];
				end
			end
			
			if isa(buildingBlocks, 'dataanalyzer.positiondata')
				obj.fromRestrictedPD(buildingBlocks);
			elseif isa(buildingBlocks, 'ivlset')
				istime = p___validateIvlset(buildingBlocks, obj.Parent);
				if istime
					obj.fromTime(buildingBlocks, obj.Parent);
				else
					error('DataAnalyzer:Mask:InvalidIvlSetBuildingBlocks', 'When buildingBlocks is an ivlset type it must contain valid time intervals with respect to the reference object.');
				end
			elseif isa(buildingBlocks, 'numeric') || isa(buildingBlocks, 'logical')
				if ~isempty(buildingBlocks)
					[ispolygon, X, Y]	= p___validatePolygon(buildingBlocks);
					[isidx, Idx]		= p___validateIndex(buildingBlocks, obj.Parent);

					if ispolygon
						obj.fromPolygon([X, Y], obj.Parent);
					elseif isidx
						if islogical(buildingBlocks)
							obj.fromLogical(buildingBlocks, obj.Parent);
						else
							t = obj.Parent.getTS();
							obj.fromIdx(Idx, t);
						end
					else
						error('DataAnalyzer:Mask:InvalidNumericBuildingBlocks', 'When buildingBlocks is a numeric type it must be a polygon or a valid index to the parent object.');
					end
				end
			elseif isa(buildingBlocks, 'char')
				if strcmpi(buildingBlocks, 'restricted') || strcmpi(buildingBlocks, 'restr')
					% todo...
				end
			else
				error('DataAnalyzer:Mask:InvalidBuildingBlocks', 'Valid building blocks include spatial, temporal, logical, string, or empty masks.');
			end
			
			if nargin > 2
				obj.name = name;
			end
		end
		
		function s = start(obj)
			error('todo');
		end
		
		function set.name(obj, val)
			if ~ischar(val)
				error('DataAnalyazer:Mask:NameNotChar', 'Object name must be a string.');
			end
			obj.name = val;
		end
		
		function set.tEffectiveIvls(obj, val)
			obj.Ivls = val;
			obj.tEffectiveIvls = val;
		end
		
		disp(obj)
		
		obj = fromIdx(obj, idx, timeStamps)
		obj = fromLogical(obj, lgcl, timeStampedObject)
		obj = fromPolygon(obj, plgn, pdObject)
		obj = fromRestrictedPD(obj, pdObject)
		obj = fromTime(obj, timeIvl, timeStampedObject)
		
		idx = mask2idx(obj)
		ivl = mask2ivl(obj)
		ivls = mask2ivlset(obj)
		
		[idx, varargout] = apply(obj, maskableObj, varargin) % Apply mask to timeable object
		
		I = isempty(obj)
% 		N = numel(obj)
		N = len(obj)
		
		visualize(obj)
		function varargout = char(obj, varargin)
			if nargin <= 1
				varargout{1} = arrayfun(@(obj) obj.name, obj, 'un', 0);
				if numel(varargout{1}) == 1
					varargout{1} = varargout{1}{1};
				end
			else
				varargout{1} = obj.name;
				varargout = [varargout, cellfun(@(obj) obj.name, varargin, 'un', 0)];
			end
		end
		
		function newObj = and(obj, obj2)
			newObj = p___logical('&', obj, obj2);
		end
		function newObj = or(obj, obj2)
			newObj = p___logical('|', obj, obj2);
		end
		function newObj = xor(obj, obj2)
			newObj = p___logical('^', obj, obj2);
		end
		function newObj = not(obj)
			newObj = p___logical('~', obj);
		end
		function newObj = minus(obj, obj2)
			newObj = obj & ~obj2;
		end
		function newObj = plus(obj, obj2)
			newObj = obj | obj2;
		end
	end
end