function [spikeTrainPerPass, passesWithSpikes] = extractSpikesPass(passes, spikeTrain)

spikeTrainPerPass = repmat(struct('s', [], 'numSpikes', []), numel(passes), 1);
passesWithSpikes = passes;

for i = 1:length(passes)
	s = Restrict(spikeTrain, passes(i).ts_begin, passes(i).ts_end);
	
	spikeTrainPerPass(i).s = s;
	spikeTrainPerPass(i).numSpikes = length(s);
	
	passesWithSpikes(i).s = s;
	passesWithSpikes(i).numSpikes = length(s);
end