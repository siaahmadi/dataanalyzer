classdef linkedslider < handle
	properties
		slider				% isa UIControl
		sisterslider = [];	% isa linkedslider
		myID				% = slider.Tag
		satelliteData		% = slider.UserData
		parent
	end
	properties (SetAccess=private)
		lhFigResize
		lkdSliderMinDiff = .003;
	end
	properties (Constant)
		SLD_END_SCROLL_WIDTH = 35;
		DFLT_SLIDER_POSITION = [20 20 525 20];
	end
	methods
		function obj = linkedslider(h_fig, sisterSlider, notifyMe, sldPosition, initVal)
			[myslider, sister] = obj.slidebar(h_fig, sldPosition, initVal, sisterSlider, notifyMe);
			obj.slider = myslider;
			obj.sisterslider = sister;
			h_fig.UserData.linkedSliders{obj.myID} = obj;
			obj.lhFigResize = addlistener(h_fig, 'SizeChanged', @(src, evnt) windowResizeCallback(obj,src));
		end
		
		[slider, sister] = slidebar(obj,h_fig, sldPosition, initVal, sisterSlider, notifyMe)
	end
	events
		Updated
	end
end