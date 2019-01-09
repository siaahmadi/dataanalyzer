function linpath = linearizepath(x, y)
%LINPATH = LINEARIZEPATH(X, Y)
%
% Linearize path.
%
% Returns a vector of point to point displacements of the aninmal's path.
%
%
% INPUT:
%
% X
%	The X coordinate of the animal's path.
% 
% Y
%	The Y coordinate of the animal's path.
% 
% 
% OUTPUT:
% 
% LINPATH
%	The linear path. The i-th element is the displacement between the i-th
%	(x, y) coordinate and the (i+1)-st such coordinate.

% Siavash Ahmadi
% 10/3/15

linpath = eucldist(0, 0, diff(x), diff(y));

linpath = [[0; cumsum(linpath(:))], zeros(length(y), 1)];