function obj = loadParsedData(obj, parsedData)
% Loads everything from parsedVisits


if exist('parsedData', 'var')
	fn = dataanalyzer.constant('FileName_ParseData_Session');

	pi = load(fullfile(obj.Parent.fullPath, fn), 'idx');
	obj.parsedComponents = pi.idx;
else
	obj.parsedComponents = parsedData;
end