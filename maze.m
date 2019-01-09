function m = maze(spatialEnvironment)
%MAZE Extract standardized maze type from spatial environment string
%
% fig8rat, fig8mouse, fig8 --> fig8
% radial8, --> rad8pd
% lineartrack --> linear

type.fig8 = 'fig8';
type.fig8rat = 'fig8';
type.fig8mouse = 'fig8';
type.radial8 = 'rad8pd';
type.rad8 = 'rad8pd';
type.lineartrack = 'linear';

try
	m = type.(spatialEnvironment);
catch
	error('Unrecognized maze.');
end