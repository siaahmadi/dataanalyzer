function selectivity = selectivity_skaggs96_bytrain(trains, outoftrain, sessionIvl)
%SELECTIVITY_SKAGGS96_BYTRAIN Spatial selectivity of spike train as defined
%in Skaggs, McNaughton, Wilson, and Barnes (1996) Hippocampus. Adapted for
%trains.
%
%"The selectivity measure is equal to the spatial maximum
%firing rate divided by the mean firing rate of the cell.
%The more tightly concentrated the cell’s activity, the
%higher the selectivity. A cell with no spatial tuning at
%all will have a selectivity of 1; there is in principle
%no upper limit."
%
%
% selectivity = SELECTIVITY_SKAGGS96_BYTRAIN(trains, outoftrain, sessionIvl)
%    All arguments are required. |trains| is an array of structs
%    containing the trains extracted by @flStats.
%
%    |outoftrain| is the train of spikes not assigned to any train from the
%    same cell.
%
%   |sessionIvl| is an ivlset containing the valid trial/session intervals.
%
%	|selectivity| will be a value in interval [1, Inf].
%
% From Skaggs et al., (1996):
% "A similar measure was used by Barnes et al. (1983),
% except that the “out-of-field” firing rate was used
% instead of the mean rate. The present definition is
% preferable because it does not depend on identifying
% a “place field,” and because it is much less sensitive
% to noise."
%
% See also: dataanalyzer.routines.spatial.selectivity_barnes83_bytrain


% some convenience pre-calc

rates = arrayfun(@(trains) arrayfun(@(tr) length(tr.s) ./ range(tr.t), trains), trains);

[~, outoftrainIdx] = sessionIvl.restrict(outoftrain, outoftrain);
n_spikes_total = sum(arrayfun(@(trains) arrayfun(@(tr) length(tr.s), trains), trains)) + length(outoftrainIdx);

avgRate = n_spikes_total / sessionIvl.duration;

selectivity = mean(rates) / avgRate;