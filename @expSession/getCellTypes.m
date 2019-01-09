function cell_types = getCellTypes(obj)

allN = obj.getNeurons;
idx = firstone(cellfun(@(x) length(x), allN));

cell_types = cellfun(@(x) x.cellType(), allN(sub2ind(size(allN),1:size(allN, 1),idx')),'UniformOutput', false)';