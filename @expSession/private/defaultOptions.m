function options = defaultOptions(envType)


if strcmpi(envType, 'lineartrack') % default options:
	polyRoi = [-20 20 20 -20 -20; 35 35 -50 -50 35]; % for rat 692
	
	inEdge = 1;
	outEdge = 3;
	
	% TODO: definteDirectionalConstratins()
	directionalConstraints = [struct('spatialMask', struct('delimiter', polyRoi, 'trajectory', struct('entranceEdge', inEdge, 'exitEdge', outEdge)), 'name', 'leftbound');
		struct('spatialMask', struct('delimiter', polyRoi, 'trajectory', struct('entranceEdge', outEdge, 'exitEdge', inEdge)), 'name', 'rightbound')];
	
	warning off MATLAB:warn_r14_stucture_assignment
	options.UpdateAllPlaceFields.UpdatePlaceFields.constraints = directionalConstraints;
	warning on MATLAB:warn_r14_stucture_assignment  % for post MATLAB R14SP2 releases
elseif strcmpi(envType, 'rad8')
	options.ttLocateFunc = @dataanalyzer.env.rad8.ttLocate;
% 	options.polyRoi = [-100 100 100 -100 -100; 100 100 -100 -100 100];
% 	options.inEdge = 1;
% 	options.outEdge = 3;
% 	error('DataAnalyzer:OptionDefinition:NotDefined', 'Set options: polyRoi, inEdge, outEdge, directionalConstraints');
elseif strncmpi(envType, 'fig8', 4)
	options.ttLocateFunc = @dataanalyzer.env.rad8.ttLocate;
else
	error('DataAnalyzer:OptionDefinition:NotDefined', 'Set of default options requested for unrecognized environment')
end