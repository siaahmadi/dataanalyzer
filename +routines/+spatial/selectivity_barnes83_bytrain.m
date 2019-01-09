function selectivity = selectivity_barnes83_bytrain(trains, outoftrain, sessionIvl)
%SELECTIVITY_BARNES83_BYTRAIN Spatial selectivity of spike train as defined
%in Barnes, McNaughton, O'Keefe (1983) Neurobiol. Aging.
% Used with the train-based phase precession analysis method.
%
% si = SELECTIVITY_BARNES83_BYTRAIN(trains, outoftrain, sessionIvl)
%    Both arguments are required. |trains| is an array of structs
%    containing the trains extracted by @flStats.
%
%    |outoftrain| is the train of spikes not assigned to any train from the
%    same cell.
%
%   |sessionIvl| is an ivlset containing the valid trial/session intervals.
%
%	|selectivity| will be a value in interval [1, Inf].
%
% See also: dataanalyzer.routines.spatial.selectivity_skaggs96,
% dataanalyzer.routines.spatial.selectivity_barnes83

% some convenience pre-calc

intrain_rates = arrayfun(@(trains) arrayfun(@(tr) length(tr.s) ./ range(tr.t), trains), trains);
ttrains = arrayfun(@(trains) arrayfun(@(tr) range(tr.t), trains), trains);

[~, outoftrainSpikes] = sessionIvl.restrict(outoftrain, outoftrain);

avgRate_OutOfTrain = length(outoftrainSpikes) / (sessionIvl.duration - sum(ttrains));

selectivity = mean(intrain_rates) / avgRate_OutOfTrain;