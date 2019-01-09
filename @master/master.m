classdef (Abstract) master < handle & matlab.mixin.Copyable
	%DATAAANZLYER.MASTER The superclass of every dataanalyzer class
	
	% 12/26/2015
	properties
		Parent
		UserData
		namestring = '';
	end
	methods (Abstract)
% 		options = getMyOptions(obj)
% 		options = getOptions(obj)
% 		options = setOptions(obj, options)
% 		numel(obj)
% 		length(obj)
	end
	methods
		function obj = master()
			import dataanalyzer.figure
		end
	end
end