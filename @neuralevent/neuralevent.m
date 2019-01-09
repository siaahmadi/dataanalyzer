classdef (Abstract) neuralevent < dataanalyzer.master & dataanalyzer.timeable
	properties (SetAccess=protected)
% 		Ivls % inherited from timeable
		inField = false;
		displacement = struct(... % displacement is air-distance
					'fromField', Inf, ...
					'fromBorder', Inf, ...
					'fromReward', Inf);
		distance = struct(...     % distance is traveled distance
					'fromField', ...
							struct('prospective', ...
								struct('cm', Inf, 'second', Inf, 'normalized', NaN), ...
							'retrospective', ...
								struct('cm', Inf, 'second', Inf, 'normalized', NaN), ...
							'contour', 0), ...
					'fromBorder', Inf, ...
					'fromReward', Inf);
		duration
	end
	methods
		function itvl = nev2interval(obj)
			itvl = obj.Ivls.toIvl();
		end
		function [x, y] = locatein(obj, pd, into)
			%LOCATEIN Find the spatial location of the neuralevent object
			%with respect to a positiondata object
			
			if ~exist('into', 'var') || isempty(into)
				into = 0;
			end
			
			t = obj.getT(into);
			ts = pd.getTS();
			idx = spike2ind(ts, t);
			X = pd.getX();
			Y = pd.getY();
			x = X(idx);
			y = Y(idx);
		end
	end
	methods (Abstract)
		length(obj) % number of events
	end
end