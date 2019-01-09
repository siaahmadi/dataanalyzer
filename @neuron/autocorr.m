function [ac, t] = autocorr(obj, varargin)
% Autocorrelation of the neuron
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

timeUnit = 1e-3; % that is, millisecond

p = inputParser();
p.addParameter('corrInterval', [-1e3, 1e3]);
p.addParameter('temporalResolution', 1);
p.KeepUnmatched = true;
p.parse(varargin{:});

corrInterval = p.Results.corrInterval;
temRes = p.Results.temporalResolution;
options = p.Unmatched;

if isempty(obj.autocorrelation)
	Masks = dataanalyzer.ancestor(obj, 'trial').Mask.List;
	maskNames = {Masks.name}';
	
	[ac, t] = obj.xcorr(obj, corrInterval, temRes, options);
	for i = 1:length(ac)
		obj.autocorrelation.corr.(maskNames{i}) = ac{i};
	end
	obj.autocorrelation.t = t;
end

ac = obj.autocorrelation.corr;
t = obj.autocorrelation.t;