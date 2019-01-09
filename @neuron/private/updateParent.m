function updateParent(obj, evntData)
parent = evntData.parentRequestData.parent;
obj.setParent(parent);
obj.parentResidencePath = parent.residencePath;
obj.residencePath = fullfile(parent.residencePath, parent.namestring);
obj.trialDuration = parent.getDuration();
obj.avgFiringRate = length(obj.spikeTrain) ./ obj.trialDuration;
obj.release('spikes');

if ~isempty(obj.spikeTrain) && obj.spikeTrain(1) > obj.parentTrial.endTS % assuming this is because of unit mismatch
	obj.spikeTrain = obj.spikeTrain * 1e-4;
end


addlistener(obj.parentTrial,'HereIsYourFixedSpikeTrain',...
	@(parent, event) fixSpikeTrainOverflow(obj, event));
notify(obj, 'PleaseFixMyOverflowedSpikeTrain')
% this will ask my parent to invoke my
% 'fixSpikeTrainOverflow()' with the corrected
% spiketrain