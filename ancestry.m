function A = ancestry(obj)

a = {};
np = 0;
parent = obj;
while ~isempty(parent)
	np = np + 1;
	buffer = class(parent);
	a{np} = regexp(buffer, '(?<=^dataanalyzer.).*', 'match', 'once');
	parent = parent.Parent;
end

a = flipud(a(:));

display(a); % to be modified to make pretty

if nargout > 0
	A = a;
end