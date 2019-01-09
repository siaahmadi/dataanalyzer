function obj = load(obj, loadFrom, fn_pd, parentTrial)
%LOAD called when a trial's position data is being loaded.'
%
% obj = LOAD(obj, loadFrom, fn_pd, parentTrial)
%
% expects a .mat file located at fullfile(loadfrom, fn_pd) with the
% following structure:
% the .mat file contains a variable PathData as a struct with fields:
%   - t
%   - x
%   - y
%   - v
%   - w_rho
%   - w_theta
%   - subtrials
%   - assignment
%
% By choosing the .mat file from an arbitrary location one can load
% different types of position data, namely original, idealized, or
% linearized.

if exist('parentTrial', 'var') && isa(parentTrial, 'dataanalyzer.master')
	obj.setParentTrial(parentTrial);
elseif exist('parentTrial', 'var') && ~isa(parentTrial, 'dataanalyzer.master')
	warning('Ignoring the non-dataanalyzer object as Parent.');
end

import dataanalyzer.ext.chris.*

% fn_pd = dataanalyzer.constant('FileName_PathData_Session');

opt = dataanalyzer.options(dataanalyzer.ancestor(parentTrial).projectname);

if exist(fullfile(loadFrom, fn_pd), 'file') ~= 2
	warning('Cannot complete loading path data. Path data file non existent. Try running preprocessing first.');
	return;
end

pd = load(fullfile(loadFrom, fn_pd));
if isa(pd, 'table') 
	pd_trials = pd.Properties.VariableNames;
	pd = table2struct(pd);
elseif isa(pd, 'struct')
	pd_trials = setdiff(fieldnames(pd.assignment), 'unassigned', 'stable');
end

masks = cellfun(@(pd_trials) dataanalyzer.mask(ivlset(minmax(pd.t(pd.subtrial==pd.assignment.(pd_trials))')), obj, pd_trials), pd_trials, 'un', 0);
obj.Mask = dataanalyzer.maskarray(cat(1, masks{:}), obj);

if istable(pd)
	obj.timeStamps = pd(1);
	obj.stockX = pd(2);
	obj.stockY = pd(3);
	obj.V = pd(4);
elseif isstruct(pd)
	obj.timeStamps = pd.t;
	obj.stockX = pd.x;
	obj.stockY = pd.y;
	obj.V = pd.v;
end
obj.videoFR = 30; % must be moved to Constants

obj.trialBeginTS = pd.t(1);
obj.trialEndTS = pd.t(end);

obj.resetToStock;