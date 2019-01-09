function [obj, status] = loadNeurons(obj) % = load all neurons
	% get list of all .t files
	try
		tFileList = dataanalyzer.neuron.getTFileList(obj.fullPath);
	catch err
		if strcmp(err.identifier, 'DataAnalyzer:Neuron:NoTFiles')
			warning('DataAnalyzer:ConstructingTrialObj:NoTFilesInTrialDirectory', ...
				['No .t files found in current trial''s directory: ' strrep(obj.fullPath, '\', '\\')]); % can't be filesep --> only \ must be \\, not /
			status = 'DataAnalyzer:ConstructingTrialObj:NoTFilesInTrialDirectory';
			obj.neurons.load_status.message = status;
			obj.neurons.load_status.signedby = 'DataAnalyzer:Trial:LoadNeurons';
			return;
		else
			rethrow(err);
		end
	end

	obj.loadNeuronBatch(tFileList);
	status = 'tFilesInTrialDirectory:Success';
	obj.neurons.load_status.message = status;
	obj.neurons.load_status.signedby = 'DataAnalyzer:Trial:LoadNeurons';

	tFileNames = containers.Map;
	tFileNamesInv = containers.Map;
	for i = 1:length(tFileList)
		tFileNames(tFileList{i}) = i;
		tFileNamesInv(num2str(i)) = tFileList{i};
	end
	obj.neuronMixAndMatchLookupTable.tFileNames = tFileNames;
	obj.neuronMixAndMatchLookupTable.tFileNamesInv = tFileNamesInv;
end