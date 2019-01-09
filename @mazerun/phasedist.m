function [d, ph, h, regr] = phasedist(obj, varargin)

% Options to be implemented:
% 'return' : 'cell', 'mat' WHETHER d, ph SHOULD BE CELL ARRAY OF EACH
% MAZERUN OR A VECTOR OF ALL SPIKES
% 'highlight' : 'on', 'off' GROUP EACH PASS'S SPIKES BY COLOR?

import dataanalyzer.figure

p = inputParser();
p.addParameter('visualizeRun', 'none', @accFunc_validate)
p.KeepUnmatched = true;
p.parse(varargin{:});

opt.lfp = false;
opt.spikelfp = false;

if strcmp(p.Results.visualizeRun, 'lfp')
	opt.lfp = true;
elseif strcmp(p.Results.visualizeRun, 'spike')
	opt.spikelfp = true;
elseif strcmp(p.Results.visualizeRun, 'spikelfp')
	opt.lfp = true;
	opt.spikelfp = true;
end

all_my_spikes = cat(1, obj.spikes);

if numel(all_my_spikes) < 1 % this/these run(s) has/have no spikes
	d = [];
	ph = [];
	h = [];
	regr = [];
	return;
end

neurAncestor = dataanalyzer.ancestor(obj, 'neuron');
if numel(neurAncestor) == 1
	ttNo = str2double(regexp(neurAncestor.namestring, '(?<=^TT)\d{1,2}', 'match', 'once'));
	h_spikelfp = visualizeMyNeuralData(obj, ttNo, all_my_spikes, opt); % all_my_spikes won't be empty as this was checked earlier in this function
end

args = unmatchToArg(p.Unmatched);

[d, ph, h_phasedist, regr] = all_my_spikes.phasedist(args{:});

h = [h_phasedist; h_spikelfp];


function accFunc_validate(x) % cannot use this in-line for some strange reason
validatestring(x, {'none', 'lfp', 'spike', 'spikelfp'});