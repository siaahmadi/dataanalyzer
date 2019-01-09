function releaseroi(obj)

if ~isempty(obj.releaseX)
	obj.X = obj.releaseX;
	obj.Y = obj.releaseY;
	obj.timeStamps = obj.releaseTS;
	
	obj.releaseX = [];
	obj.releaseY = [];
	obj.releaseTS = [];
end