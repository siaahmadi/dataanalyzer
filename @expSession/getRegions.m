function regions = getRegions(obj)

n = obj.getNeurons();

firstValidIdx = cellfun(@(x) find(x, 1, 'first'), mat2cell(~cellfun(@isempty,n), ones(size(n, 1), 1), size(n, 2)));

subs = zeros(size(n, 1), 1);
for i = 1:length(subs)
	subs(i) = sub2ind(size(n), i, firstValidIdx(i));
end
neuronsBuffer = n(subs);

regions = cell(length(neuronsBuffer), 1);
for i = 1:length(neuronsBuffer)
	regions{i} = neuronsBuffer{i}.getRegion();
end