function [scale, I] = p___getMaxDist(x,y)
D = zeros(size(x));

for i = 1:length(x)
	for j = 1:length(y) % or x
		D(i,j) = eucldist(x(i), y(i), x(j), y(j));
	end
end

[scale, I] = max(D(:));
d = zeros(1,2);
[d(1), d(2)] = ind2sub(size(D), I);
I = d;