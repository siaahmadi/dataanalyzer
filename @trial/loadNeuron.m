function obj = loadNeuron(obj, tFileName)
warning('Not fully implemented: gotta implement neuron order thing in coordination with parent')
neuronToAdd = dataanalyzer.neuron(fullfile(obj.fullPath, tFileName));
obj.neurons.appendNeuron(neuronToAdd);