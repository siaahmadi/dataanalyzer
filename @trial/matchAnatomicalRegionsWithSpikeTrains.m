function anatReg = matchAnatomicalRegionsWithSpikeTrains(ratNo, tFileList, ttLocateFunc)

if ~exist('ttLocateFunc', 'var') || isempty(ttLocateFunc)
% 	ttLocateFunc = @lineartrackABBA.ttLocate;
	error('DataAnalyzer:TrialConstruction:ttLocateFunctionNotProvided', 'The function to locate anatomical region of the tetrodes is not provided.');
end

ttList = cellfun(@(x) str2double(x(3:end)), regexp(tFileList, 'TT\d{1,2}_*?', 'match', 'once'));

anatReg = repmat(struct('region', [], 'subregion', [], 'layer', []), size(ttList));
for i = 1:length(anatReg)
	[regionName, layerName, subregionName] = ttLocateFunc(ratNo, ttList(i));
	anatReg(i).region = regionName{1};
	anatReg(i).layer = layerName{1};
	anatReg(i).subregion = subregionName{1};
end