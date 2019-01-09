classdef (Abstract) timeable < dataanalyzer.master
	properties
		Ivls
	end
	methods (Abstract)
% 		T = getT(obj) % return ivlset of times
% 		D = getDuration(obj) % return time duration of object
		S = start(obj)
	end
	methods
		function T = getT(obj, into) % return ivlset of times
			T = obj.Ivls; % if function calling this expects T to be a m-by-2 matrix, fix positiondata.visualize 4/26/2017
			if exist('into', 'var')
				T = T.toIvl();
				if ~isscalar(into) || ~(0 <= into && into <=1)
					error('wrong |into|');
				end
				dur = diff(T, [], 2);
				T = (dur * into) + T(:, 1);
			end
		end
	end
end