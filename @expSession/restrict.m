function restrict(obj, varargin)
error('restrict for expSession has not been implemented yet.')

[whatField, whatValue] = parseArgIn(varargin{:});

switch whatField % to be expanded
	case 'neurons.time'
		
	case 'neurons.type'
		
	case 'neurons.region'
		
	case 'trial.type'
		
end

function [whatField, whatValue] = parseArgIn(varargin)
% TODO