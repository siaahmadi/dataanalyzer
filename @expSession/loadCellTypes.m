function loadCellTypes(obj)

h = waitbar(0, 'Loading cell types...');
a = obj.getNeurons;b = [a{:}]';for i = 1:numel(b), b(i).cellType(); waitbar(i/numel(b), h);end
close(h)