function obj = update(obj)
	options = dataanalyzer.options('phaprecTakuya');
	
	centerParams.xCenter = options.xCenter;
	centerParams.yCenter = options.yCenter;
	scaleParams.xScale = options.xScale;
	scaleParams.yScale = options.yScale;
	rotationParam = options.rotation;

	obj.tidy();
	centerParams = getCtrParamsCorr(obj, options); % private function
	obj.center(centerParams);
	obj.scale(scaleParams);
	obj.rotate(rotationParam);

	% I think the following was because of my confusion about the function
	% of obj.getX() and obj.getY(). I thought these would return the
	% restricted versions of X and Y. Apparently they don't since the
	% restriction is performed on |restrictIN| logical array. To get the
	% restricted X and Y, though, I can't remember which functions should
	% be called. Is it |getRestrictedTraversals|? @date 10/27/2015
	%
	% UPDATE (11/9/2015): I have since worked out how the restriction
	% should be enforced. As of now, getX, getY, and getTS accept
	% additional arguments that specify which version, restricted or
	% otherwise, should be returned. As observed previously, parsing
	% cannot be performed on restricted data. @author: Sia
	
	% UPDATE (11/23/2015): I have now removed the lines where the user was
	% asked if it was okay to proceed with the unrestricted versions of x
	% and y coordinates. As of now, a trial always carries a mask array,
	% the first mask of which is the default, whole-maze, version. There
	% can be addditional masks listed. Parsing will be performed on the
	% unmasked version.

	x = obj.getX('unrestr');
	y = obj.getY('unrestr');
	t = obj.getTS('unrestr');
	[t, x, y, beginsGlobalIdx, trNameStrings] = p___restrictToBegins(dataanalyzer.ancestor(obj).NlxEvents, t, x, y);
	options.trNameStrings = trNameStrings;
	try
		parsedData = parse(x, y, t, options);
	catch err
		error('DataAnalyzer:PositionDataParser:ParseFailure', 'Position data parsing parameters not appropriate');
	end
	
	obj.loadParsedData(cat(1, parsedData.visits), beginsGlobalIdx);
end