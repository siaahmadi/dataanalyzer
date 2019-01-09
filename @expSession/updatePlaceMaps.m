function updatePlaceMaps(obj, options)
%UPDATEPLACEMAPS Create place maps based on Masks and Parsed Components

mask = obj.positionData.createMaskFromParsedComponents(options.useParsedComponents);

select = true(size(obj.neurons.neuronArray));
if isfield(options, 'selectNeurons')
	select = options.selectNeurons;
end

obj.neurons.getNeurons(select).updatePlaceMaps(mask);