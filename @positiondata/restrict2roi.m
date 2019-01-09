function restrict2roi(obj, restrictLogic, varargin)

obj.releaseX = obj.getX();
obj.releaseY = obj.getY();
obj.releaseTS = obj.getTS();
X = obj.getX();
Y = obj.getY();
TS = obj.getTS();

if isempty(varargin)
	figure;plot(X,Y, '.');
	[xRoi,yRoi] = ginput;
else
	xRoi = varargin{1};
	yRoi = varargin{2};
end


IN = restrict(X,Y,TS, xRoi, yRoi);

if strcmpi(restrictLogic, 'and')
	obj.IN = obj.IN & IN;
elseif strcmpi(restrictLogic, 'or')
	obj.IN = obj.IN | IN;
elseif strmp(restrictLogic, 'xor')
	obj.IN = xor(obj.IN, IN);
elseif strcmpi(restrictLogic, 'not') || strcmpi(restrictLogic, 'minus') || strcmpi(restrictLogic, 'diff')
	obj.IN = obj.IN & ~IN;
else
	error('Unknown operation requested');
end

function IN = restrict(X,Y, xRoi, yRoi)

IN = inpolygon(X, Y, xRoi, yRoi);

% int2intset(IN, false, 1, length(IN));
