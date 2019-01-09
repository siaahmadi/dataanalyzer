function intervals = intset2int(inArray, mergeOffset, inverse, firstVal, lastVal)
% intervals = intset2int(inArray, mergeOffset, inverse, firstVal, lastVal)
%
% Convert an array of integers (type intervalset) into an array of pairs of
% integers denoting the boundaries of the intervals (type intervals)
% 
% This is the inverse function of @int2intset
% 
% inArray       input array
% mergeOffset   number of integers to ignore between subsequent intervals
% inverse       output intervals complementing inArray (true/false)
% firstVal      if inverse is true, this determines the lower bound of the
%               bigger interval in which inArray should be complemented
% lastVal       if inverse is true, the upper bound for the bigger interval
%
% a := [0 1 2 3 9 10 11 12 15 18 20 22 28 29 30];
% EXAMPLE       intset2int(a)
%               output:     0     3     9    12    15    15    18    18    20    20    22    22    28    30
%
% EXAMPLE       intset2int(a, 1)
%               output:     0     3     9    12    15    15    18    22    28    30
%
% EXAMPLE       intset2int(a, 1, true)
%               output:     4     8    13    17    23    27
%
% EXAMPLE       intset2int(a, 1, true, -10, 60)
%               output:     -10    -1     4     8    13    17    23    27    31    60

if isempty(inArray)
	intervals = [];
	return;
end
T = false;
if size(inArray, 2) == 1 && ~numel(inArray == 1)
	inArray = inArray';
	T = true;
end

if nargin == 1
	mergeOffset = 0;
	inverse = false;
elseif nargin == 4
	error('firstVal and lastVal must be simultaneously present or absent')
elseif nargin > 1 && mergeOffset == Inf
	mergeOffset = inArray(end)-inArray(1);
end
if nargin == 3
	firstVal = inArray(1);
	lastVal = inArray(end);
end
if (nargin==3 || nargin==5) && inverse
	if ~size(inArray, 1) == 1 && ~size(inArray, 2) == 1
		error('inArray must be a vector')
	end
	intervals = intset2int(...
					int2intset(...
						intset2int(inArray, mergeOffset, ~inverse, firstVal, lastVal),...
					inverse, firstVal, lastVal)...
				, mergeOffset, ~inverse, firstVal, lastVal);
	return
end

% detect singletons
diffArray = [mergeOffset+1 diff(inArray)-1 mergeOffset+1];
singletons = find((diffArray(1:end-1)>mergeOffset & diffArray(2:end)>mergeOffset)==true);
% now add duplicates of singletons to inArray
if ~isempty(singletons)
	inArray2 = [];
	prevInd = 1;
	for i = 1:length(singletons)
		try
		inArray2 = [inArray2 inArray(prevInd:singletons(i)) inArray(singletons(i))];
		prevInd = singletons(i)+1;
		catch
			continue;
		end
	end
	if singletons(end)~=length(inArray)  % last entry is not a singleton
		inArray2 = [inArray2 inArray(prevInd:end)];
	end
	inArray = inArray2;
	clear inArray2
end

% final stage
diffArray = abs(diff(inArray))>(mergeOffset+1);
diffArray = [1 find(diffArray==true) length(inArray)];
diffArray = union(diffArray(2:end), diffArray(2:end)+1);
intervals = [inArray(1) inArray(diffArray(1:end-1))];
if T
	intervals = intervals';
end