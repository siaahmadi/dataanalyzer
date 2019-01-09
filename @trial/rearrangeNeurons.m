function rearrangeNeurons(obj, evntData)			
rearrangementReference = evntData.parentRequestData.rearrangementReference;
if numel(rearrangementReference) == 0
	display(['Unable to perform rearrangement for ' obj.namestring '.'])
	return;
end

thisObjNeurons = obj.getNeuronList();

if ~isempty(thisObjNeurons)
	newArrangement = cellfun(@(n) matchstr(rearrangementReference, n), thisObjNeurons, 'UniformOutput', false);
	newArrangement = sum(cell2mat(newArrangement'), 2)==1;
else
	newArrangement = false(size(rearrangementReference));
end

newList = cell(size(newArrangement));
if sum(newArrangement) > 0
	newList(newArrangement) = thisObjNeurons;
end
obj.neuronList = newList;
obj.neurons.rearrange(newArrangement);

display(['Neuron rearrangement for ' obj.namestring ' done.'])