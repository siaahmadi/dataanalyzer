function intervalSet = int2intset(inArray, inverse, firstVal, lastVal)
% convert an array of integer pairs (called intervals) into a list of
% integers which fill the gap between the two ends of the intervals (called
% interval sets)
%
% This is the inverse function of @intset2int
%
% EXAMPLE: int2intset([2 3 7 11])
%          output: 2 3 7 8 9 10 11
%
% EXAMPLE: int2intset([2 3 7 11 13 15 20 22], true)
%          output: 4 5 6 12 16 17 18 19
%
% EXAMPLE: int2intset([2 3 7 11 13 15 20 22], true, -1, 25)
%          output: -1 0 1 4 5 6 12 16 17 18 19 23 24 25
%
% EXAMPLE: int2intset([2 3 7 11], false, -1, 13)
%          output: 2 3 7 8 9 10 11

if mod(inArray, 2)==1
	error('the input inArray must be of even length (because it is assumed to be in pairs).')
end
if size(inArray, 1)>1
	intervalSet = zeros(sum(inArray(2:2:end)-inArray(1:2:end))+length(inArray)/2, 1);
else
	intervalSet = zeros(1, sum(inArray(2:2:end)-inArray(1:2:end))+length(inArray)/2);
end
j = 1;
for i = 1:2:length(inArray)
	intervalSet(j:inArray(i+1)-inArray(i)+j) = (inArray(i):inArray(i+1))';
	j = inArray(i+1)-inArray(i)+j+1;
end
if nargin == 2
	if inverse == true
		intervalSet = setdiff(intervalSet(1):intervalSet(end), intervalSet);
	end
elseif nargin == 3
	error('firstVal and lastVal must be simultaneously present or absent')
elseif nargin > 3
	if inverse == true
		intervalSet = setdiff(firstVal:lastVal, intervalSet);
	end
end
if (size(inArray, 1) == 1 && size(intervalSet, 1)~=1) || (size(inArray, 2) == 1 && size(intervalSet, 2) ~= 1)
	intervalSet = intervalSet';
end