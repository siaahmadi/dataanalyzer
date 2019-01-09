function [spikeTrainPerPass, passesWithSpikes] = extractSpikesPass(passes, spikeTrain)
% there's no point in having this. This is an entirely ad hoc function that
% used to get called by cprops() with the output of getPassesThroughPolygon
% as its input but now is copied inside getPassesThroughPolygon

% OBSOLETE
% TO BE REMOVED
error('OBSOLETE. TO BE REMOVED. See documentation for more information.');

spikeTrainPerPass = repmat(struct('s', [], 'numSpikes', []), numel(passes), 1);
passesWithSpikes = passes;

for i = 1:length(passes)
	s = restr(spikeTrain, passes(i).ts_begin, passes(i).ts_end);
	
	spikeTrainPerPass(i).s = s;
	spikeTrainPerPass(i).numSpikes = length(s);
	
	passesWithSpikes(i).s = s;
	passesWithSpikes(i).numSpikes = length(s);
end