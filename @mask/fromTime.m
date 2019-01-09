function obj = fromTime(obj, timeIvl, timeStampedObject)

if ~isa(timeIvl, 'ivlset')
	error('DataAnalyzer:Mask:NonIvlsetTime', 'To build a mask from time input "%s" must be an |ivlset| object.\n', inputname(2));
end

% if ~isa(timeStampedObject, 'dataanalyzer.tsable')
% 	error('DataAnalyzer:Mask:UnableToRetrieveTS', 'To build a mask from time input "%s" must have a |getTS()| method.\n', inputname(3));
% end
refTS = [];
if iscell(refTS) % passing 'unrestr' as an argument to timeStampedObject's getTS is not good as it need not accept it. I will assume the first entry of a maskable object is always the unmasked version.
	refTS = refTS{1};
end

p___setTs(obj, [], refTS, timeIvl);