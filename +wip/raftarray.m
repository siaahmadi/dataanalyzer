classdef raftarray < handle % this can be modified to inherit from queue
	properties
		raftIdx
	end
	methods
		function obj = raftarray(logicalArray)
			if islogical(logicalArray)
				idx = lau.raftidx(logicalArray);
			else
				idx = logicalArray;
			end
			if isempty(idx)
				obj.raftIdx = queue([]);
			end
			obj.raftIdx = queue(mat2cell(reshape(idx, 2, numel(idx)/2), 2, ones(1,numel(idx)/2)));
		end
		function [ai, bi] = next(obj)
			if nargout < 2
				ai = obj.raftIdx.next();
			elseif nargout == 2
				i = obj.raftIdx.next();
				ai = i(1);
				bi = i(2);
			end
		end
		function rewind(obj)
			obj.raftIdx.rewind();
		end
		function ef = eof(obj)
			ef = obj.raftIdx.eof();
		end
		function n = numel(obj)
			n = obj.raftIdx.numel();
		end
	end
end