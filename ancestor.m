function a = ancestor(h, type, strict)
% Get dataanalyzer-wise ancestor of h, of type |type|
%
% Ignores the string 'dataanalyzer.' at the beginning of |type|

if ~exist('type', 'var')
	type = '';
end
if ~exist('strict', 'var')
	strict = false;
end

if numel(h) > 1
	a = arrayfun(@(x) dataanalyzer.ancestor(x, type), h, 'un', 0);
	if all(cellfun(@isequal, a(2:end), a(1:end-1)))
		a = a{1};
	end
	return;
end

if strict %only parent and higher
	currObj = h.Parent;
else % can be object itself
	currObj = h;
end
while ~isa(currObj, ['dataanalyzer.', regexp(type,'\<(?!dataanalyzer\.).*$|(?<=dataanalyzer\.).*', 'match', 'once')]) % removes initial |dataanalyzer.| from type
	% if it is desired to capture whatever that's after the first time
	% 'dataanalyzer.' appears, use the pattern '\<(?!dataanalyzer\.)\w*$|(?<=dataanalyzer\.).*'
	%                                           spot the difference ^^
	if numel(currObj.Parent) == 0
		break;
	end
	currObj = currObj.Parent;
end
a = currObj;