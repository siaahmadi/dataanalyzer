function s = mksparse(neuronObjArray)

if isempty(neuronObjArray)
	s = [];
	return;
end

minDistinguishableDiff = 4e-4;

% convert neuronObjArray to a hardcopy
if iscell(neuronObjArray) && all(cellfun(@(x) isvector(x) && isa(x, 'double') || isempty(x), neuronObjArray)) % <-- GOOD
	y = neuronObjArray;
else
	y = arrayfun(@(x) x.getSpikeTrain(), neuronObjArray, 'UniformOutput', false); % assumes an array of |dataanalyzer.neuron|s
end
% z = cell2mat(cellfun(@(x) x', y, 'UniformOutput', false));
z = cat(1, y{:});
tsB = min(z); tsE = max(z);
m = size(y, 1);
n = ceil((tsE - tsB) / minDistinguishableDiff) + 1;
% end

j = floor((z - tsB) / minDistinguishableDiff + 1);

i = repelemPy(cellfun(@numel, y));

s = sparse(double(i)',j,1,m,n);


function result = repelemPy(n)
n = n(:)';
[~, ~, ~] = pyversion; % force load Python
sys = py.importlib.import_module('sys');
sys.path.append('Y:\Sia\scripts\py');
py.importlib.import_module('myutils');

pyIN = cellfun(@int32,num2cell(n),'uniformOutput', false);
pyOUT = py.myutils.repelem(pyIN);

result = cell2mat(cell(pyOUT));