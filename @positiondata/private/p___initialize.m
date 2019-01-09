function obj = p___initialize(obj, parent, constrObj)
%obj = p___initialize(obj) Initialize position data object to NULL values

obj.Parent = [];

if exist('constrObj', 'var') && isa(constrObj, 'dataanalyzer.positiondata')
	obj.stockX = constrObj.getX('unrestr');
	obj.stockY = constrObj.getY('unrestr');
	obj.timeStamps = constrObj.getTS('unrestr');
	obj.videoFR = constrObj.videoFR;
	obj.Parent = parent;
else
	obj.stockX = -Inf;
	obj.stockY = -Inf;
	obj.timeStamps = -Inf;
	% obj.Mask = dataanalyzer.mask([], obj); % 11/19/2015 (I have decided to move mask to the trial level)
	% obj.maskIN = obj.Mask.mask2idx;
	obj.videoFR = 30;
	if exist('parent', 'var')
		obj.Parent = parent;
	end
end

obj.Mask = dataanalyzer.mask(ivlset([-Inf, Inf]), obj.Parent, 'default');