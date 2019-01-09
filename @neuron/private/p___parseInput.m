function [parent, s, phases, tFileName, anatomy, sp_path, namestring] = p___parseInput(varargin)

p = inputParser();
p.addParameter('parent', @(x) isa(x, 'dataanalyzer.master'), 'PartialMatchPriority', 1);
p.addParameter('spikes', [], @(x) validateattributes(x, {'numeric'}, {'2d', 'increasing', 'positive', 'real', 'finite'}));
p.addParameter('phases', [], @(x) validateattributes(x, {'numeric'}, {'2d', 'real'}), 'PartialMatchPriority', 2); % , 'finite' --> preprocessing introduces NaN phases (todo)
p.addParameter('tfilename', {''}, @(x) validateattributes(x, {'char', 'string'}, {'vector'}));
p.addParameter('anatomy', dataanalyzer.anatomy(), @(x) validateattributes(x, {'dataanalyzer.anatomy'}, {'vector'}));
p.addParameter('spikespath', '', @(x) validateattributes(x, {'char'}, {}));
p.addParameter('namestring', '', @(x) validateattributes(x, {'char'}, {}));

p.parse(varargin{:});

parent = p.Results.parent;
s = p.Results.spikes;
phases = p.Results.phases;
tFileName = p.Results.tfilename;
anatomy = p.Results.anatomy;
sp_path = p.Results.spikespath;
namestring = p.Results.namestring;

if ~isequal(size(s), size(phases))
	error('Mismatch between ''spikes'' and ''phases'' input sizes.');
end