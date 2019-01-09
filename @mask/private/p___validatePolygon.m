function [I, X, Y] = p___validatePolygon(buildingBlocks)

X = [];
Y = [];
I = false;

if size(buildingBlocks, 1) == 2 || size(buildingBlocks, 2) == 2% polygon buildingBlocks(:, 1) == X, buildingBlocks(:, 2) == Y
	if size(buildingBlocks, 1) == 2 % horizontal
		buildingBlocks = buildingBlocks';
	end
	X = buildingBlocks(:, 1);
	Y = buildingBlocks(:, 2);

	try
		if ~ispolycw(X, Y)
			[X, Y] = poly2cw(X, Y);
		end
	catch err
		if ~isempty(regexp(err.identifier, '(?<=map:\w:)inconsistentXY', 'once'))
			I = false;
			return;
		end
	end
	I = true;
end

