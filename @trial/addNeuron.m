function n = addNeuron(obj, Neuron) %#ok<STOUT,INUSL>
if ~isa(Neuron, 'neuron')
	error('Please input a Neuron of type ''neuron''')
end