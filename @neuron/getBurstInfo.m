function burstStats = getBurstInfo(obj, varargin)
% varargin takes in the options

burstCriterion = 9; % ms

S = obj.getSpikeTrain();
burstRafts = diff(S) < burstCriterion*1e-3;
burstRafts = [burstRafts(1) burstRafts];

Nb = lau.raftsize(burstRafts)+1;
Ns = lau.raftsize(~burstRafts)-1;
if burstRafts(1) % spiketrain starts with a burst
	Nb(1) = Nb(1) - 1;
end
if ~burstRafts(end) % spiketrain doesn't end in a burst
	Ns(end) = Ns(end) + 1;
end
spbCounts = zeros(1,length(Ns) + length(Nb) + burstRafts(1) + burstRafts(end));
spbCounts(2:2:end-1) = Nb(:);
% I want burstStats to always start with non-bursts and end in non-bursts
if burstRafts(1) && burstRafts(end)
	spbCounts(3:2:end-2) = Ns(:);
elseif ~burstRafts(1) && burstRafts(end)
	spbCounts(1:2:end-2) = Ns(:);
elseif ~burstRafts(1) && ~burstRafts(end)
	spbCounts(1:2:end) = Ns(:);
elseif burstRafts(1) && ~burstRafts(end)
	spbCounts(3:2:end) = Ns(:);
end

burstStats.burstProbability = sum(Nb)/(sum(Nb)+sum(Ns));
burstStats.counts.bursts = Nb;
burstStats.counts.spikes = Ns;
burstStats.counts.both = spbCounts;
burstRafts(lau.tron(burstRafts)) = true;
burstStats.idxOfSpikesParticipatingInBurst = burstRafts;

burstStats.burstPDF = @(burstSize,conditionalOnBurst) mypdf(burstSize,conditionalOnBurst,Nb,Ns);
burstStats.burstCDF = @(burstSize,conditionalOnBurst) sum(mypdf(2:max(burstSize),conditionalOnBurst,Nb,Ns));

[ac,t] = obj.autocorr();
idx_baseline = t>=40 & t<=50;
idx_burst = t>0 & t<=10;
burstAmplitude = max(ac(idx_burst)) - mean(ac(idx_baseline));
if burstAmplitude > 0
	burstIndex = burstAmplitude / max(ac(idx_burst));
elseif burstAmplitude < 0
	burstIndex = burstAmplitude / mean(ac(idx_baseline));
else
	burstIndex = 0;
end

if mean(ac(idx_baseline)) < 1e-10
	warning('Burst Index baseline is too small, perhaps due to small spike count. Interpret results with care.')
end
burstStats.burstIndex = burstIndex;

[~,idx_of_peak] = max(ac(1001:1050));
derivative_of_ac = diff(ac(1000:1000+idx_of_peak));
burstStats.refractoryPeriod = find(derivative_of_ac > std(derivative_of_ac), 1, 'first'); % millisecond

function [bpdf, bcnt] = mypdf(burstSize,conditionalOnBurst, Nb, Ns)

if ~exist('conditionalOnBurst', 'var')
	conditionalOnBurst = false;
elseif ~islogical(conditionalOnBurst)
	error('conditionalOnBurst must be a logical value')
end

idx = arrayfun(@(x) Nb==x, burstSize(:)', 'UniformOutput', false);
idx = idx(:);
if ~conditionalOnBurst
	bpdf = cellfun(@(x) sum(Nb(x))/(sum(Nb)+sum(Ns)), idx);
else
	bpdf = cellfun(@(x) sum(Nb(x))/sum(Nb), idx);
end
bcnt = cellfun(@(x) sum(Nb(x)), idx);