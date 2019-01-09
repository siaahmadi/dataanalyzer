function ord = armorder(i, listOfArmNames)

ord = {'e', 'ne', 'n', 'nw', 'w', 'sw', 's', 'se'};

if nargin < 1
	return;
else
	ord = strcmpi(ord{i}, listOfArmNames);
end