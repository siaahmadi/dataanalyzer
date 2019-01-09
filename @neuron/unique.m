function u = unique(obj, varargin)
%UNIQUE Unique neuron objects in a set
%
% u = UNIQUE(obj, varargin)
%
% Unique neuron objects are found based on the full path and neuron name

if nargin > 1
	I = cellfun(@(x) isa(x, 'dataanalyzer.neuron'), varargin);
	if ~all(I)
		error('invalid input: since %s is a dataanzlyer.neuron object, all subsequent inputs must also be of type dataanalyzer.neuron.', input(1));
	end
	obj = cat(1, obj(:), varargin{:});
end

hasParent = arrayfun(@(n) isa(n.Parent, 'dataanalyzer.master'), obj);
fullPathOfParent = cell(size(hasParent));
fullPathOfParent(hasParent) = arrayfun(@(n) n.Parent.fullPath, obj(hasParent), 'un', 0);
fullPathOfParent(~hasParent) = {''};
neuronNames = arrayfun(@(n) n.namestring, obj, 'un', 0);

fullIdentifier = cellfun(@strcat, fullPathOfParent, neuronNames, 'un', 0);

[~, ia] = unique(fullIdentifier, 'stable');
u = obj(ia);