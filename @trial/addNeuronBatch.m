function l = addNeuronBatch(obj, NeuronList) %#ok<STOUT,INUSL>
if ~(prod(isa(NeuronList, 'neuron')))
	error('Please input a list of objects, each of type ''neuron''')
end