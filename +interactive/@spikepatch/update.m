function update(obj)

t = obj.t;
x = obj.x;
y = obj.y;
s = obj.s;
sld1 = obj.lkdSliders{1}.slider;
sld2 = obj.lkdSliders{2}.slider;

ind1 = closestPoint(t, 1:length(t), t(1)+(t(end)-t(1))*sld1.Value);
ind2 = closestPoint(t, 1:length(t), t(1)+(t(end)-t(1))*sld2.Value);

obj.displayIdx(:) = false;
obj.displayIdx(ind1:ind2) = true;

obj.h_path.XData = x(obj.displayIdx);
obj.h_path.YData = y(obj.displayIdx);

modification.x = x(spike2ind(Restrict(s, t(ind1), t(ind2)), t));
modification.y = y(spike2ind(Restrict(s, t(ind1), t(ind2)), t));
obj.modifypatch(modification);