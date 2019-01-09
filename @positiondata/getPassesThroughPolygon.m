function passes = getPassesThroughPolygon(obj, polygROI, mask, parentNeuron)
% DEPRECATED version of passesThroughROI

% Siavash Ahmadi
% 2/22/2015 12:12 PM


error('Deprecated. Use @passesThroughROI instead.');

if nargin < 3
	mask = 'unrestr';
end
x = obj.getX(mask); x = x{1};
y = obj.getY(mask); y = y{1};
t = obj.getTS(mask);t = t{1};
X = obj.getX('unrestr');
Y = obj.getY('unrestr');
T = obj.getTS('unrestr');

[xroi, yroi] = poly2cw(polygROI(1,:), polygROI(2,:));

[off2on, on2off] = dataanalyzer.positiondata.computeEntranceDeparture(X, Y, [xroi;yroi]); % this only handles unmasked data: once masked, there will be gaps in x, y, and ts. This is not handled right now 11/25/2015

runsUnbound = ivlset(T(off2on), T(on2off));
maskIvls = mask.mask2ivlset;
passesIvls = runsUnbound .^ maskIvls; % unrestricted runs through field wholly contained in mask

if iscell(off2on) % discontiguous intervals due to mask
	passes = cellfun(@(x,y,t,off2on,on2off)auxFunc_makeRunForChunk(obj,x,y,t,off2on,on2off,parentNeuron), x, y, t, off2on, on2off, 'UniformOutput', false);
	passes = cat(1, passes{:});
else
	passes = makecolumn(extractcell(arrayfun(@(off2on, on2off) dataanalyzer.mazerun(obj,obj,parentNeuron, passesIvls), off2on, on2off, 'UniformOutput', false)));
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