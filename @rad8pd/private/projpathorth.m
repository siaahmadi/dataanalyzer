function prjpath = projpathorth(x, y, sector)

x = x(:);
y = y(:);

spine = phaprec.parsemz.rad8.mazespine();
armOrder = @phaprec.parsemz.rad8.armorder;
prjpath = zeros(length(x), 2);

for i = unique(sector(:)')
	thisSpine = diff(spine(armOrder(i, {spine.name})).coord);
	unitSpine = thisSpine ./ norm(thisSpine);
	
	[X, Y] = pol2cart((i-1)*pi/4, dot([x(sector==i), y(sector==i)]', repmat(unitSpine(:), 1, sum(sector==i))));
	prjpath(sector==i, :) = [X(:), Y(:)];
end