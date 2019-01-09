function windowResizeCallback(obj, src)

obj.slider.Position(3) = max(src.Position(3)-35, 10);

hls2 = obj.parent.lkdSliders{2}.slider;
hsld = sum(hls2.Position([2 4]));
h_fig = ancestor(obj.parent.h_spikes,'Figure');
hsld_rel = (hsld+30)/h_fig.Position(4);
buffer = obj.parent.ax.Position(2);
obj.parent.ax.Position(2) = hsld_rel;
obj.parent.ax.Position(4) = obj.parent.ax.Position(4) - (hsld_rel - buffer);