function [hdEpochsBinary, movementEpochs] = getEpochs(x, y, parentTrialFullPath, options)


if ~isfield(options, 'hdOptions')
	hdOptions.wedge = pi/20; hdOptions.threshold = 30; hdOptions.tolerance = 9;
else
	if ~isfield(options.hdOptions, 'wedge')
		hdOptions.wedge = pi/20;
	else
		hdOptions.wedge = options.hdOptions.wedge;
	end
	if ~isfield(options.hdOptions, 'threshold')
		hdOptions.threshold = 30;
	else
		hdOptions.threshold = options.hdOptions.threshold;
	end
	if ~isfield(options.hdOptions, 'tolerance')
		hdOptions.tolerance = 9;
	else
		hdOptions.tolerance = options.hdOptions.tolerance;
	end
end

[~, hdEpochs] = getHeadingDirection(x,y, hdOptions);
[~, ~, movementEpochs, ~] = ...
	velocityEstimate(parentTrialFullPath);
hdEpochsBinary = {zeros(size(x))==1, zeros(size(x))==1};
hdEpochsBinary{1}(hdEpochs{1}) = true;
hdEpochsBinary{2}(hdEpochs{2}) = true;
movementEpochs = [false; false; false; false; false; movementEpochs;...
	false; false; false; false];