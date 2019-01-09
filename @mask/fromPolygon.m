function obj = fromPolygon(obj, plgn, pdObject)
% External calls: ivlset(), lau.rt()

if ~exist('pdObject', 'var') || isempty(pdObject)
	pdObject = obj.Parent;	% This will run when the user is manually running
							% the routine and hasn't provided a |pdObject|.
							% If Parent is empty |pdObject| will be empty as
							% well and this will produce an error later.
end

if isempty(pdObject) % this works regardless of whether the object has a parent or not
	error('DataAnalyzer:Mask:EmptyReferencePolygon', 'The reference position data object is empty. Cannot continue building %s.\n', mfilename);
end

if ~isa(pdObject, 'dataanalyzer.positiondata')
	error('DataAnalyzer:Mask:InvalidReferencePolygon', 'Reference is not a position data object. Cannot continue building %s.\n', mfilename);
end

[ispolygon, X, Y] = p___validatePolygon(plgn);

if ~ispolygon
	error('DataAnalyzer:Mask:BuildingBlockNotPolygon', 'The input argument |%s| contents do not constitute a valid polygon.\n', inputname(2));
end

x = pdObject.getX();
y = pdObject.getY();
t = pdObject.getTS();

IN = inpolygon(X, Y, x, y);


obj.tIdx = IN;

T = t(lau.rt(IN));
T = reshape(T, length(T)/2, 2);
obj.tIntervals = ivlset(T);