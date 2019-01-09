function [stats, ph, rl, phdistro] = phaselock(obj, varargin)
% determine preferred phase of spiking (ph) and its associated p-value (pval) with respect to the reference EEG (refEEG) or an array of phases (phases)

% To be redesigned. At the moment @neuron object doesn't lend itself to
% easy use of @spike objects. @getSpikeTrain is not well-written, and
% finding the @lfp object is not accurate (e.g. band must be specified).
% spikes should be able to select masks.

if numel(obj) > 1
	[stats, ph, rl, phdistro] = arrayfun(@(o) o.phaselock(varargin{:}), obj, 'un', 0);
	ph = cat(1, ph{:});
	rl = cat(1, rl{:});
	stats = cat(1, stats{:});
	return;
end

ttNo = dataanalyzer.utils.ns2tt(obj.namestring);
lfp = dataanalyzer.ancestor(obj, 'expSession').lfp;
allPhase = lfp.getPhase(ttNo);

spikes = obj.getSpikeTrain();
spikes = spikes{2};

ph = closestPoint(allPhase(1).ts, allPhase(1).phase, spikes);

if nargout >= 3
	phdistro = ph;
end

rl = circ_r(ph(:));
[stats.p, stats.z] = circ_rtest(ph(:));
ph = circ_mean(ph(:));