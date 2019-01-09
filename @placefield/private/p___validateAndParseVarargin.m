function opt = p___validateAndParseVarargin(obj, varargin)

contour = fieldnames(obj.dynProps);

passes = cat(1, obj.dynProps.(contour{1}).passes);
numPasses = numel(passes);

p = inputParser();
p.addParameter('contour', 'c50');
p.addParameter('passes', 'all');
p.addParameter('legend', 'on');
p.addParameter('chull', 'on');
p.addParameter('reference', 'on', @ischar);
p.addParameter('mazeoutline', 'on', @ischar);
p.addParameter('invertcolor', 'off');
p.addParameter('solidbg', 'off');
p.parse(varargin{:});


opt.contour = p.Results.contour;
if ischar(p.Results.passes)
	if strcmpi(p.Results.passes, 'none')
		opt.passes = [];
	elseif strcmpi(p.Results.passes, 'all')
		opt.passes = 1:numPasses;
	else
		warning('Ignoring the ''Passes'' parameter-value pair. The value "%s" is not recognized.', p.Results.passes);
		opt.passes = 1:numPasses;
	end
elseif isnumeric(p.Results.passes)
	goodidx = mod(p.Results.passes, 1) == 0 & (p.Results.passes > 0) & (p.Results.passes <= numPasses);
	opt.passes = p.Results.passes(goodidx);
else
	error('Invalid Parameter-Value pair: ''Passes'', can be {''all'', ''none''}, or indices to passes');
end


opt.legendRqstd = ~strcmpi(p.Results.legend, 'off');
opt.chull = ~strcmpi(p.Results.chull, 'off');
opt.mazeoutline = ~strcmpi(p.Results.reference, 'off') | ~strcmpi(p.Results.mazeoutline, 'off');
opt.invertcolor = double(strcmp(p.Results.invertcolor, 'on')) * ones(1, 3);
opt.solidbg = double(strcmp(p.Results.solidbg, 'on'));

availableContours = regexp(fieldnames(obj.fieldInfo.boundary), '^c\d{2}$', 'match', 'once');
availableContours = availableContours(cellfun(@(x) ~isempty(x), availableContours));
if isempty(availableContours) % This really shouldn't happen -- because otherwise, how was this place field computed in the first place???
	error('No Contours Available!');
end
if ~ismember({opt.contour}, availableContours)
	error(['Requested contour not found. Available: ' repmat('%s, ', 1, length(availableContours)-1), '%s.\n'], availableContours{:});
end