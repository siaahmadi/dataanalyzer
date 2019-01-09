function modifypatch(obj, modification)
h = obj.h_spikes;
if ~(exist('h', 'var') && strcmpi(h.Type, 'Patch') && exist('modification', 'var') && isa(modification, 'struct'))
	return
end

% [x, y, scale, color, shape, transparency] = p___getAttrOfInterest(h); %#ok<ASGLU>

x = obj.px;
y = obj.py;
scale = obj.scale;
color = obj.color;
shape = obj.shape;
transparency = obj.transparency;

if isfield(modification, 'x')
	x = modification.x; %#ok<*NASGU>
end
if isfield(modification, 'y')
	y = modification.y;
end
if isfield(modification, 'scale')
	scale = modification.scale;
end
if isfield(modification, 'color')
	color = modification.color;
end
if isfield(modification, 'shape')
	shape = modification.shape;
end
if isfield(modification, 'transparency')
	transparency = modification.transparency;
end

[X,Y] = p___xy2vertex(x,y,shape,scale);
try
	h.Vertices = [X(:), Y(:)];
	h.Faces = reshape(1:numel(X), numel(X)/size(X, 2), size(X, 2))';
end
h.FaceAlpha = transparency;

obj.px = mean(X);
obj.py = mean(Y);
obj.shape = shape;
obj.scale = scale;
obj.transparency = transparency;