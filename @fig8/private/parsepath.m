function pp = parsepath(pathdata, parsetemplate)

zones = {parsetemplate.zone}';

IN = cell(1, length(zones));
for z = 1:length(zones)
	IN{z} = arrayfun(@(pd) inpolygon(pd.x, pd.y, parsetemplate(z).x, parsetemplate(z).y), pathdata, 'un', 0);
end

pp = cellfun(@accFunc_makestruct, IN{:}, 'un', 0);

pp = cat(1, pp{:});

	function str = accFunc_makestruct(varargin)

	args = cell(length(varargin)*2, 1);
	args(1:2:end) = zones;
	args(2:2:end) = varargin;

	str = struct(args{:});

	end
end