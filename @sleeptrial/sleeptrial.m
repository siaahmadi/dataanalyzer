classdef sleeptrial < dataanalyzer.trial
	methods
		function obj = sleeptrial(residencePath, nameString, spatialEnvironment, loadAllNeurons, parent)
			if nargin < 1
				obj.initialize('', '', '');
			else
				obj.linkToParentViaListener(parent);

				obj.initialize(residencePath, nameString, spatialEnvironment);
				if loadAllNeurons
					obj.loadNeurons();
				end
			end
		end
	end
end