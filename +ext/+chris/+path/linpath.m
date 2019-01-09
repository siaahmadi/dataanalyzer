function zi = linterp2(x,y,z,xi,yi)
% 2-d linear interpolation??
% @cmtAuthor: Sia @date 9/15/15 12:57 PM

n = length(xi);
zi = nan(n,1);
for i = 1:n
    R =  arrayfun(@(j)norm([xi(i)-x(j) yi(i)-y(j)]),1:length(x));
    c1 = find(R==min(R));
    R(c1) = nan;
    c2 = find(R==min(R));
    c = sort([c1,c2]);
    m = [x(c) y(c)]\z(c);
    zi(i) = xi(i)*m(1) + yi(i)*m(2);
end