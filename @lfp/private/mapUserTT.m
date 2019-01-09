function mapped = mapUserTT(obj, ttNo)

mapped = obj.ttMapping(ttNo); % read mapping
unmapped = find(~mapped);
if ~isempty(unmapped) % some tetrodes weren't mapped
	warning('Some tetrodes have not been mapped. Using the originals.');
	mapped(mapped==0) = ttNo(unmapped);
end

mapped = full(mapped);