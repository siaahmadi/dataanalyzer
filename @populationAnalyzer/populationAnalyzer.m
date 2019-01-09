classdef populationAnalyzer < dataanalyzer.master
	properties (SetAccess='private', GetAccess='private')
		specialty % neuron analyzer, trial analyzer, session analyzer, or rat analyzer
	end
	methods
		function obj = populationAnalyzer(specialty) % constructor
			obj.specialty = specialty;
		end
	end
end