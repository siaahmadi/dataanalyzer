function prjpath = projpath(x, y, visits, prjType)
%PRJPATH = PROJPATH(X, Y, VISITS, PRJTYPE)
%
% Project the raw path input via |X| and |Y| onto the spine of the maze.
%
%
% INPUT
%
% X
%	The X coordinates of the path.
% 
% Y
%	The Y coordinates of the path.
% 
% VISITS
%	Array of length(x) containing the sector each point of the path falls
%	in.
%
% PRJTYPE
%	Projection method. One of the following:
%		- 'orthogonal' or 'orth'
%			Returns the dot product of path points onto their corresponding
%			spine of the maze.
% 
%		- 'hypb' (Deprecated)
%			Hyperbolic-like projection.
% 
%			Finds anchor points of the path defined as follows:
%				+ For each adjacent arm pair, find the farthest point, |p|.
%				+ Draw a line |l| perpendicular to vector |p|.
%				+ Find point |q|, the intersection of |l| and the bisector
%				  of the two adjacent arms. Call |q| the anchor point for
%				  the selected pair.
%			Projects each path point within a sector onto the corresponding
%			piece of the maze spine from its correspoinding anchor point.
%
%			(As of 10/3/15 this method is deemed unsuitable and
%			problematic. The orthogonal method seems to get the job done
%			well.)
%
% 
% OUTPUT:
% 
% PRJPATH
%	The projected path. Matrix of two columns containing the radial
%	distance of each projected point and its associated arm number in the
%	first and the second columns.

% Siavash Ahmadi
% 10/3/15


if strcmpi(prjType, 'hypb')
	prjpath = phaprec.parsemz.rad8.projpathhypb(x, y, visits);
elseif strcmpi(prjType, 'ortho') || strcmpi(prjType, 'orthogonal')
	prjpath = phaprec.parsemz.rad8.projpathorth(x, y, visits);
end