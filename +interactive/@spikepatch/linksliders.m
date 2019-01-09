function linksliders(obj,hs1, hs2)
% link hs1, hs2 to obj
hs1.slider.SliderStep = [1/length(obj.x) 60/length(obj.x)];
hs2.slider.SliderStep = [1/length(obj.x) 60/length(obj.x)];
obj.lkdSliders = {hs1;hs2};
numCLH = length(obj.clh);
obj.clh{numCLH+1} = addlistener(hs1.slider, 'ContinuousValueChange', @(src, evnt) updateEverything(obj, hs1, hs2, @comp));
obj.clh{numCLH+2} = addlistener(hs2.slider, 'ContinuousValueChange', @(src, evnt) updateEverything(obj, hs2, hs1, @comp));

function updateEverything(obj, me, sister, compFunc)
compFunc(me.slider, sister.slider, sister.lkdSliderMinDiff);
obj.update()

function comp(x,y, minDiff)
if str2double(x.Tag) < str2double(y.Tag) && x.Value > y.Value - minDiff
	if x.Value + minDiff <= y.Max
		y.Value = x.Value + minDiff;
	else
		x.Value = y.Max - minDiff;
		y.Value = y.Max;
	end
	return
elseif str2double(x.Tag) > str2double(y.Tag) && x.Value < y.Value + minDiff
	if x.Value - minDiff >= y.Min
		y.Value = x.Value - minDiff;
	else
		x.Value = y.Min + minDiff;
		y.Value = y.Min;
	end
	return
end