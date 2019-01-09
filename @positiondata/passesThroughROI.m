function passes = passesThroughROI(obj, ROI, mask, parentNeuron)
%GETPASSESTHROUGHPOLYGON Computer unbroken passes through a given polygon
%
% pf can be a polygon or a placefield object

% Siavash Ahmadi
% 2/22/2015 12:12 PM

if ~exist('mask','var') || isempty(mask)
	mask = dataanalyzer.mask();
end
if ~exist('parentNeuron','var')
	parentNeuron = dataanalyzer.neuron();
end

x = obj.getX(mask); x = x{1};
y = obj.getY(mask); y = y{1};
t = obj.getTS(mask);t = t{1};
X = obj.getX('unrestr');
Y = obj.getY('unrestr');
T = obj.getTS('unrestr');

if isa(ROI, 'dataanalyzer.placefield')
	[xroi, yroi] = poly2cw(ROI.getX('c20'), ROI.getY('c20'));
else
	[xroi, yroi] = poly2cw(ROI(1, :), ROI(2, :));
end

[off2on, on2off] = dataanalyzer.positiondata.computeEntranceDeparture(X, Y, [xroi(:),yroi(:)]');

runsUnbound = ivlset(T(off2on), T(on2off));
maskIvls = mask.mask2ivlset;
warning off IvlSet:EmptySetCollapsed
passesIvls = runsUnbound .^ maskIvls; % unrestricted runs through field wholly contained in mask
warning on IvlSet:EmptySetCollapsed

if iscell(off2on) % discontiguous intervals due to mask
	passes = cellfun(@(x,y,t,off2on,on2off)auxFunc_makeRunForChunk(obj,x,y,t,off2on,on2off,parentNeuron), x, y, t, off2on, on2off, 'UniformOutput', false);
	passes = cat(1, passes{:});
else
	passes = dataanalyzer.mazerun(ROI,obj,parentNeuron, passesIvls);
end

function [spikeTrainPerPass, passesWithSpikes] = extractSpikesPass(passes, spikeTrain) % to be moved to mazerun

spikeTrainPerPass = repmat(struct('s', [], 'numSpikes', []), numel(passes), 1);
passesWithSpikes = passes;

for i = 1:length(passes)
	s = restr(spikeTrain, passes(i).ts_begin, passes(i).ts_end);
	
	spikeTrainPerPass(i).s = s;
	spikeTrainPerPass(i).numSpikes = length(s);
	
	passesWithSpikes(i).s = s;
	passesWithSpikes(i).numSpikes = length(s);
end

function a = auxFunc_makeRunForChunk(obj,x,y,t,off2on,on2off,S)
a = arrayfun(@(off2on, on2off) dataanalyzer.mazerun(obj,x,y,t,off2on:on2off,S), off2on, on2off, 'UniformOutput', false);

a = makecolumn(extractcell(a));