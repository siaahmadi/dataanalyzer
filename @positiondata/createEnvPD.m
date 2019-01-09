function pdObj = createEnvPD(spatialEnvironment, parent)
%pdObj = createEnvPD(spatialEnvironment)
%
% Create a positiondata object specifically suited for the
% spatialEnvironment

if strcmp(spatialEnvironment, 'linear')
	pdObj = dataanalyzer.linearpd();
elseif strcmp(spatialEnvironment, 'rad8')
	pdObj = dataanalyzer.rad8pd();
elseif strncmp(spatialEnvironment, 'fig8', 4)
	pdObj = dataanalyzer.fig8(spatialEnvironment, parent);
elseif isempty(spatialEnvironment)
	pdObj = [];
else
	error('DataAnalyzer:PositionData:UnrecognizedSpatialEnvironment', 'Spatial environment not defined!');
end