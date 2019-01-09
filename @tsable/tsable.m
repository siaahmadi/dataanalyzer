classdef (Abstract) tsable < dataanalyzer.timeable
	methods (Abstract)
		T = getTS(obj)
		
		newObj = clip(obj, ivls)
	end
	methods
		function t = getT(obj)
			t = obj.getTS();
			t = ivlset(t, t);
		end
		function s = start(obj)
			s = first(obj.getTS());
		end
	end
	methods (Static)
		function idx = findRangeForTimeable(tsableObj, timeableObj)
			ts = tsableObj.getTS();
			t = timeableObj.getT();
			[b, e] = t.toIvl;
			if isnan(b) % timeableObj of duration == 0
				idx = false(size(ts));
				return;
			end
			b = interp1(ts, 1:length(ts), b, 'nearest');
			e = interp1(ts, 1:length(ts), e, 'nearest');
			idx = arrayfun(@(b,e) sparse(b:e, 1, 1, length(ts), 1), b, e, 'un', 0);
			idx = full(sum(cat(2, idx{:}), 2) > 0);
		end
	end
end