function S = loadNeuronBatch(obj, tFileList_or_spikeTrains, tFileList)
if iscell(tFileList_or_spikeTrains) && all(cellfun(@isnumeric, tFileList_or_spikeTrains))
	S = tFileList_or_spikeTrains;
else
	tFileList = tFileList_or_spikeTrains;
	S = dataanalyzer.neuron.da_LoadSpikes(tFileList, obj.fullPath, '');
end

anc = dataanalyzer.ancestor(obj, 'expSession');
ttLocateFunc = anc.getOptions('ttLocateFunc');
anatReg = dataanalyzer.trial.matchAnatomicalRegionsWithSpikeTrains(obj.ratNo, tFileList, ttLocateFunc);

neuronList = cell(size(S));
for i = 1:length(S)
% 	neuronList{i} = dataanalyzer.neuron(S{i}, anatReg(i), obj, tFileList{i});
	neuronList{i} = dataanalyzer.neuron(S{i}, ttLocateFunc, obj, tFileList{i});
end
obj.neurons = dataanalyzer.neuronarray(neuronList);
obj.neuronList = tFileList;

% The following I have to do as I couldn't set the parent directly from
% neuron()'s constructor. It's enormously baffling why that doesn't work
% and I must take this route instead...
passData.parent = obj;
notify(obj, 'UpdateYourParent', dataanalyzer.ParentRequestEventData(passData));