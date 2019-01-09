function [pd, mask, neuron, opt, pf] = p___validateAndParseVarargin(varargin)

if mod(length(varargin), 2) == 1
	error('Input arguments must be in the ''Parameter'', ''Value'' pairs format.');
end

% varargout = cell(size(varargin));

dft_opt = dataanalyzer.constant('makeMap2D');

p = inputParser();
p.addParameter('PD', dataanalyzer.positiondata(), @(x) isa(x, 'dataanalyzer.positiondata'));
p.addParameter('Mask', dataanalyzer.mask([], [], ''), @(x) isa(x, 'dataanalyzer.mask'));
p.addParameter('Neuron', dataanalyzer.neuron(), @(x) (isnumeric(x) && issorted(x) && isvector(x)) || isa(x, 'dataanalyzer.neuron'));
p.addParameter('Opt', dft_opt, @(x) validateattributes(x, {'struct'}, {}));
p.addParameter('pf', 'off', @(val) validatestring(val, {'on', 'off'}));

p.parse(varargin{:});

pd = p.Results.PD;
mask = p.Results.Mask;
neuron = p.Results.Neuron;
if isnumeric(neuron) % convert to dataanalyzer.neuron
	neuron = dataanalyzer.neuron('spikes', neuron);
end
opt = p.Results.Opt;
pf = p.Results.pf;
