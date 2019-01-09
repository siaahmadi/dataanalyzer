function [xc, t] = xcorr(obj, anotherNeuron, corrInterval, temRes, options)
% Cross-correlation of the neuron with anotherNeuron
% 
% INPUT:
% 
% corrInterval (optional)
%		the maximum negative and positive temporal displacement
%		default: [-1000, 1000] milliseconds
%
% temRes (optional)
%		temporal resolution. specifies the spacing of temporal
%		displacements (in milliseconds).
%		default: 1ms
%
% OUTPUT:
%
% ac
%		the autocorrelation
%
% t
%		bin labels

% to do: timeUnit = obj.getTimeUnit();
timeUnit = 1e-3; % millisecond

if ~exist('anotherNeuron', 'var') || ~isa(anotherNeuron, 'dataanalyzer.neuron')
	error('Please pass a neuron object to get the cross correlation')
end

if nargin == 2
	temRes = 1; % ms
	corrInterval = [-1e3, 1e3];
	options = [];
end
if exist('corrInterval','var')
	if isempty(corrInterval)
		corrInterval = [-1e3, 1e3];
	end
end
if exist('temRes','var')
	if isempty(temRes)
		temRes = 1;
	end
end
if ~exist('options', 'var')
	options = [];
end

if ~isvector(corrInterval) || length(corrInterval) ~= 2 || ~issorted(corrInterval) || any(~isfinite(corrInterval))
	error('corrInterval must be a vector of two numbers, in ascending order')
end

if corrInterval(1) < 0
	s = zeros(1, (mod(floor(diff(corrInterval)/temRes), 2)==0)+floor(diff(corrInterval)/temRes));
	t = linspace(corrInterval(1)+mod(-corrInterval(1), temRes), corrInterval(2)-mod(corrInterval(2), temRes), length(s));
else
	t = corrInterval(1):temRes:corrInterval(2);
	s = zeros(1,length(t));
end

S1 = obj.getSpikeTrain();
if ~iscell(S1)
	S1 = {S1};
end
S2 = anotherNeuron.getSpikeTrain();
if ~iscell(S2)
	S2 = {S2};
end

[binc1, binc2] = cellfun(@(s1, s2) accFunc_bincounts(s1,s2,temRes,timeUnit), S1, S2, 'un', 0);
xc = cellfun(@(b1,b2)xcorr(full(b1), full(b2), round(max(corrInterval)/temRes), 'coeff'), binc1, binc2, 'un', 0);
for i = 1:length(xc)
	xc{i}(find(xc{i}==1) + 1 : end) = smooth(xc{i}(find(xc{i}==1) + 1 : end));
	xc{i}(1:find(xc{i}==1) - 1) = smooth(xc{i}(1:find(xc{i}==1) - 1));
	xc{i}(xc{i}>.999) = 0;
end
t = t-temRes/2;%, t(end)+temRes/2];

if ~isempty(options)
	if isfield(options, 'Display') && strcmp(options.Display, 'on')
		figure; hold on;
% 		h = cellfun(@(xc)bar(t,xc, 'histc'), xc, 'un', 0);
		h = cellfun(@(xc)stairs(t,xc), xc, 'un', 0);
		h = cat(1, h{:});
		xlim([min(t) max(t)])
		xlabel('Temporal Displacement (ms)')
		ylabel('Correlation')
		set(h, 'FaceColor', 'k', 'EdgeColor', 'k')
	end
end

function [binc1, binc2] = accFunc_bincounts(s1, s2, temRes, timeUnit)
if isempty(s1)
	binc1 = sparse(1, [], 1, 1, 0, 0);
end
if isempty(s1)
	binc2 = sparse(1, [], 1, 1, 0, 0);
end

startTime = min(min(s1), min(s2));
endTime = max(max(s1), max(s2));
steps = temRes * timeUnit;

bins1 = ceil((s1-startTime)/steps); if bins1(1)==0, bins1(1) = 1; end;
bins2 = ceil((s2-startTime)/steps); if bins2(1)==0, bins2(1) = 1; end;

len = ceil((endTime -startTime)/steps);

binc1 = sparse(1, bins1, 1, 1, len, length(bins1));
binc2 = sparse(1, bins2, 1, 1, len, length(bins2));
% binc = histcounts(s1, startTime:steps:endTime);