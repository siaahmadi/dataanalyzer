function takeCareOfOverflow(obj)

for i = 1:obj.neurons.size()
	if ~isempty(obj.neurons.getNeuron(i))
		addlistener(obj.neurons.getNeuron(i),...
			'PleaseFixMyOverflowedSpikeTrain',@(parent, event) whichNeuronsHaveOverflowed(obj, event));
	% please fix my train (this is done here rather
	% than in loadNeuronBatch() to ensure parents are
	% set correctly by all neurons and a listener for
	% this followign notification
	% (PleaseCheckSpikeTrainOverflow) has been added
	end
end
notify(obj, 'PleaseCheckSpikeTrainOverflow');% after this some neurons will say they have over flowed
% at this point, whichNeuronsHaveOverflowed will have
% identified all those who signaled so
passData = fixChildrensSpiketrainOverflow();
% passData will hold the corrected spiketrains for
% every neuron in one place
notify(obj, 'HereIsYourFixedSpikeTrain', dataanalyzer.ParentRequestEventData(passData));
% by this point, each neuron will have checked its own
% chunk of passData to find its corrected spiketrain
% ready to use