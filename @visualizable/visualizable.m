classdef (Abstract) visualizable < dataanalyzer.master
	methods (Abstract)
		visualize(obj)
		getX(obj, mask)
		getY(obj, mask)
	end
end