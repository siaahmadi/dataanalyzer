function obj = fromIdx(obj, idx, timeStamps)

if isa(timeStamps, 'dataanalyzer.tsable')
	timeStamps = timeStamps.getTS();
	if iscell(timeStamps)
		timeStamps = timeStamps{1};
	end
end
isidx = validIdx(idx, timeStamps);
if ~isidx
	error('DataAnalyzer:Mask:FromIdx:InvalidIdx', 'Error constructing from index. idx not valid for the time stamps.');
end

timeStamps = timeStamps(:)';

if ~islogical(idx)
	rtIdx = false(size(timeStamps));
	rtIdx(idx) = true;
	idx = rtIdx;
end

rton = lau.rton(idx(:));
rtoff = lau.rtoff(idx(:));
T = [timeStamps(rton); timeStamps(rtoff)];
T = T'; % T is a m-by-2 matrix of intervals with its values taken from timeStamps

timeIvl = ivlset(T);
timeIvl = timeIvl.collapse('|');

p___setTs(obj, idx, timeStamps, timeIvl);

function isidx = validIdx(idx, timeStamps)
if islogical(idx) && length(idx) == length(timeStamps)
	isidx = true;
elseif isnumeric(idx) && ~isempty(idx) && min(idx) >= 1 && max(idx) <= length(timeStamps)
	isidx = true;
else
	isidx = false;
end