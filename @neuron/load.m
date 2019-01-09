function obj = load(obj, pathToNeuron, parentTrial)
	if nargin < 2
		parentTrial = dataanalyzer.trial();
	end

	[parentPath, tFileName] = sa_subStringTillLastSeparator(pathToNeuron);
	spT = da_LoadSpikes({tFileName}, parentPath, '');
	obj.spikeTrain = (spT{1});

	obj.orphan(isempty(parentTrial), parentTrial);
end