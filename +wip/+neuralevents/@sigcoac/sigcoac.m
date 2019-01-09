classdef sigcoac < dataanalyzer.wip.neuralevents.neuralevent % significant coactivation object
	properties (SetAccess = private)
% 		beginTS	%	<-- intherited from superclass
% 		endTS	%		<-- intherited from superclass
% 		numSubEvents	% <-- intherited from superclass
		
		activeCells
		firstIdx
		firstTS
		medianIdx
		medianTS
		numActiveCells
		sortedCellsFirst
		sortedCellsMedian
		spikeCounts
	end
	
	methods
		function obj = sigcoac(eventInterval, eventInfo, parent)
% 			addlistener(obj, 'beginTS', 'PostSet', @(src, evnt) testCallback);
			
			obj.beginTS = eventInterval(1);
			obj.endTS = eventInterval(2);
			
			if nargin > 1
				obj.activeCells = eventInfo.activeCells;
				obj.firstIdx = eventInfo.firstIdx;
				obj.firstTS = eventInfo.firstTS;
				obj.medianIdx = eventInfo.medianIdx;
				obj.medianTS = eventInfo.medianTS;
				obj.numActiveCells = eventInfo.numActiveCells;
				obj.sortedCellsFirst = eventInfo.sortedCellsFirst;
				obj.sortedCellsMedian = eventInfo.sortedCellsMedian;
				obj.spikeCounts = eventInfo.spikeCounts;


				obj.numSubEvents = obj.activeCells; % <-- could be spikeCounts as well
			end
			
			if exist('parent', 'var') && ~isempty(parent)
				obj.Parent = parent;
			end
		end
		
		function d = length(obj) % duration
			if numel(obj) > 1 % |length()| has been passed an array of |..sigcoac|'s
				d = 0;
				for i = 1:numel(obj)
					d = d + length(obj(i));
				end
				return
			end
			d = obj.endTS - obj.beginTS;
		end
% 		function testCallback(obj)
% 			1;
% 		end
		
		% Abstract methods inherited
		function obj2 = plus(obj, objORnum)
			obj2 = arrayfun(@(x) feval(class(x), [x.beginTS, x.endTS]), obj, 'UniformOutput', false);
			obj2 = [obj2{:}];
			if isnumeric(objORnum)
				obj2 = arrayfun(@(x) auxFunc(x,objORnum(1), objORnum(1)), obj2, 'UniformOutput', false);
			elseif isa(objORnum, class(obj))
				obj2 = arrayfun(@(x) auxFunc(x,objORnum.beginTS, objORnum.endTS), obj2, 'UniformOutput', false);
			else
				error('Cannot perform operation because of type incompatibility');
			end
			obj2 = [obj2{:}];
			
			function x = auxFunc(x,y,z)
				x.beginTS = x.beginTS + y;
				x.endTS = x.endTS + z;
			end
		end
		function obj2 = minus(obj, objORnum)
			obj2 = feval(class(obj), [obj.beginTS, obj.endTS]);
			if isnumeric(objORnum)
				obj2.beginTS = obj2.beginTS - objORnum;
				obj2.endTS = obj2.endTS - objORnum;
			elseif isa(objORnum, class(obj))
				obj2.beginTS = obj2.beginTS - objORnum.beginTS;
				obj2.endTS = obj2.endTS - objORnum.endTS;
			else
				error('Cannot perform operation because of type incompatibility');
			end
		end
		function l = mpower(obj, objORnum) % contains?
			if isnumeric(objORnum) || isa(objORnum, class(obj))
				l = objORnum <= obj & objORnum >= obj;
			else
				error('Cannot perform operation because of type incompatibility');
			end			
		end
		function l = lt(obj, objORnum)
			if isnumeric(objORnum)
				l = [obj.endTS] < objORnum;
			elseif isa(objORnum, class(obj))
				l = [obj.endTS] < objORnum.beginTS;
			else
				error('Cannot perform operation because of type incompatibility');
			end
		end
		function l = gt(obj, objORnum)
			if isnumeric(objORnum)
				l = [obj.beginTS] > objORnum;
			elseif isa(objORnum, class(obj))
				l = [obj.beginTS] > objORnum.endTS;
			else
				error('Cannot perform operation because of type incompatibility');
			end
		end
		function l = le(obj, objORnum)
			if isnumeric(objORnum)
				l = [obj.endTS] < objORnum;
			elseif isa(objORnum, class(obj))
				l = [obj.endTS] < objORnum.endTS;
			else
				error('Cannot perform operation because of type incompatibility');
			end
		end
		function l = ge(obj, objORnum)
			if isnumeric(objORnum)
				l = [obj.beginTS] > objORnum;
			elseif isa(objORnum, class(obj))
				l = [obj.beginTS] > objORnum.beginTS;
			else
				error('Cannot perform operation because of type incompatibility');
			end
		end
		function l = ne(obj, objORnum)
			if isnumeric(objORnum) && numel(objORnum) == 2
				l = [obj.beginTS] ~= objORnum(1) | obj.endTS ~= objORnum(2);
			elseif isa(objORnum, class(obj))
				l = [obj.beginTS] ~= objORnum.beginTS | obj.endTS ~= objORnum.endTS;
			else
				error('Cannot perform operation because of type incompatibility');
			end
		end
		function l = eq(obj, objORnum)
			if isnumeric(objORnum) && numel(objORnum) == 2
				l = [obj.beginTS] == objORnum(1) & obj.endTS == objORnum(2);
			elseif isa(objORnum, class(obj))
				l = [obj.beginTS] == objORnum.beginTS & obj.endTS == objORnum.endTS;
			else
				error('Cannot perform operation because of type incompatibility');
			end
		end
		function obj2 = and(obj, objORnum)
			obj2 = feval(class(obj), [obj.beginTS, obj.endTS]);
			if isnumeric(objORnum) && numel(objORnum) == 2
				if obj.beginTS < objORnum(1)
					obj2.beginTS = objORnum(1);
				else
					obj2.beginTS = obj.beginTS;
				end
				if obj.endTS < objORnum(2)
					obj2.endTS = obj.endTS;
				else
					obj2.endTS = objORnum(2);
				end
				if obj2.endTS < obj2.beginTS
					obj2.beginTS = NaN;
					obj2.endTS = NaN;
				end
			elseif isa(objORnum, class(obj))
				if obj.beginTS < objORnum.beginTS
					obj2.beginTS = objORnum.beginTS;
				else
					obj2.beginTS = obj.beginTS;
				end
				if obj.endTS < objORnum.endTS
					obj2.endTS = obj.endTS;
				else
					obj2.endTS = objORnum.endTS;
				end
				if obj2.endTS < obj2.beginTS
					obj2.beginTS = NaN;
					obj2.endTS = NaN;
				end
			else
				error('Cannot perform operation because of type incompatibility');
			end
		end
		function obj2 = or(obj, objORnum)
			obj2 = feval(class(obj), [obj.beginTS, obj.endTS]);
			if isnumeric(objORnum) && numel(objORnum) == 2
				if obj.beginTS < objORnum(1)
					obj2.beginTS = obj.beginTS;
				else
					obj2.beginTS = objORnum(1);
				end
				if obj.endTS < objORnum(2)
					obj2.endTS = objORnum(2);
				else
					obj2.endTS = obj.endTS;
				end
				if obj2.endTS < obj2.beginTS
					obj2.beginTS = NaN;
					obj2.endTS = NaN;
				end
			elseif isnumeric(objORnum) && numel(objORnum) == 1 % extend
				if objORnum > obj.endTS
					obj.endTS = objORnum;
				end
				if objORnum < obj.beginTS
					obj.beginTS = objORnum;
				end
			elseif isa(objORnum, class(obj))
				if obj.beginTS < objORnum.beginTS
					obj2.beginTS = obj.beginTS;
				else
					obj2.beginTS = objORnum.beginTS;
				end
				if obj.endTS < objORnum.endTS
					obj2.endTS = objORnum.endTS;
				else
					obj2.endTS = obj.endTS;
				end
				if obj2.endTS < obj2.beginTS
					obj2.beginTS = NaN;
					obj2.endTS = NaN;
				end
			else
				error('Cannot perform operation because of type incompatibility');
			end
		end
% 		subsref(obj, objORnum)
% 		subsasgn(obj, objORnum)
% 		subsindex(obj, objORnum)
% 		END Abstract methods inherited
	end
	
	methods (Static) % NOTE: uncomment when |findSignificantCoactivations| has officially graduated from dataanalyzer.wip into @sigcoac
% 		[significantCoactivations, raftBndrIdxQ, isolatedEvents, participationCDF] = findSignificantCoactivations(x, eventLength, eventSeparation, alpha)
	end
end