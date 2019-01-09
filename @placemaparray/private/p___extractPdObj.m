function [pdparent, masks] = p___extractPdObj(varargin)

pdparent = [];
i = 1;
while isa(varargin{i}, 'dataanalyzer.positiondata')
	pdparent{i, 1} = varargin{i};
	i = i + 1;
end
masks = varargin(i:end);