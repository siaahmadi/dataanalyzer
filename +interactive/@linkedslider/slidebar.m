function [h_slider, linkedSister] = slidebar(obj, h_fig, sldPosition, initVal, linkedSister, notifyMe)
	if nargin == 0 || isempty(h_fig) || ~(ishandle(h_fig) && isvalid(h_fig))
		error('Provide a valid handle to a Figure')
	end
	if ~exist('sldPosition', 'var') || isempty(sldPosition)
		sldPosition = obj.DFLT_SLIDER_POSITION;
	end
	SLD_END_SCROLL_WIDTH = obj.SLD_END_SCROLL_WIDTH;
	
	h_fig.WindowButtonUpFcn = @mouseBtnUp;
	h_fig.WindowButtonDownFcn = @sldBtnDown;
	h_fig.SizeChangedFcn = @figureSizeChange;
	numAllSliders = numel(findobj(h_fig.Children, 'flat', 'type', 'uicontrol', '-and', 'style','slider'));
	obj.myID = 1 + numAllSliders;
	
	h_slider = uicontrol(h_fig, 'Style', 'slider', 'Position', sldPosition);
	h_slider.Tag = num2str(obj.myID);
	obj.slider = h_slider;
	obj.parent = notifyMe;
	
	if exist('initVal', 'var') && ~isempty(initVal)
		h_slider.Value = initVal;
	end
	
	if exist('linkedSister', 'var') && ~isempty(linkedSister) && isa(linkedSister, 'linkedslider')
		obj.sisterslider = linkedSister;
		linkedSister.sisterslider = obj;
% 		h_fig.UserData.sliderValue(str2double(sisterslider.Tag)) = sisterslider.Value; % unnecessary: see line 22
	elseif exist('linkedSister', 'var')
		warning('sisterslider provided is not a valid handle: setting sister to Null')
	end

	
	
	function sldCallback(src, callbackData)
		ensureIntervalValidity(obj)
		notify(obj.parent,'Updated')
	end
	function sldBtnDown(src, callbackData)
		if ~strcmpi(src.Type, 'Figure')
			return
		end
		src.WindowButtonUpFcn = @mouseBtnUp; % this must be the first thing done
											% it can't be moved into the if
											% withinBoundary statement
											% because even if so, mouse
											% might be released before this
											% callback realizes it has been
											% clicked in the right location
											% so it can set the release
											% callback
		mousePosition = src.CurrentPoint; % relative to the Figure
		sld = findobj(src.Children, 'flat', 'type', 'uicontrol', '-and', 'style','slider');
		
		function [r, sldTag] = withinBoundary(sld, mouse)
			tags = cellfun(@str2double, {sld.Tag});
			for sldTag = tags
				buffer = findobj(sld, 'tag', num2str(sldTag)); % could do with [~, tagIdx] = sort(tags); as well
				sldPos = buffer.Position;
				if sldPos(1) <= mouse(1) && mouse(1) <= sum(sldPos([1 3])) % x good
					if sldPos(2) <= mouse(2) && mouse(2) <= sum(sldPos([2 4])) % y good
						r = true;
						break;
					end
				end
				r = false;
			end
			if ~r
				sldTag = 0;
			end
			sldTag = num2str(sldTag);
		end
		[wb, ws] = withinBoundary(sld,mousePosition);
		if wb % if within the boundary of any slider -- ws contains the tag of the clicked slider
			% DO WHAT YOU LIKE
			src.UserData.focusedSliderTag = ws;
			src.WindowButtonMotionFcn = @mouseMotion;
		end
		src.UserData.status = 'BtnDownIsDone';
	end
	function mouseMotion(src,callbackData) %#ok<*INUSD>
		sld = findobj(src.Children, 'flat', 'type', 'uicontrol', '-and', 'style','slider', '-and', 'tag', src.UserData.focusedSliderTag);
		mousePos = src.CurrentPoint;
		sldLeftEnd = sld.Position(1) + SLD_END_SCROLL_WIDTH;
		sldRightEnd = sum(sld.Position([1 3])) - SLD_END_SCROLL_WIDTH;
		if mousePos(1) < sldLeftEnd
			mousePos(1) = sldLeftEnd;
		end
		if mousePos(1) > sldRightEnd
			mousePos(1) = sldRightEnd;
		end
		sldEffectiveWidth = (sld.Position(3) - 2 * SLD_END_SCROLL_WIDTH);
		mousePosRel = (mousePos(1) - sldLeftEnd) / sldEffectiveWidth;
		oldVal = sld.Value;
		sld.Value = mousePosRel;
		sldParent = src.UserData.linkedSliders{str2double(sld.Tag)}; % this
		% is because when linkedslider objects are created the figure's
		% callback functions utilized here
		% are set to that object's functions, therefore no matter which
		% linkedslider the user interacts with, |obj| will be the last
		% linkedslider object created, since the callback that brings the
		% program flow to this point is exactly one of that objects
		% functions. This line ensures that the appropriate object is sent
		% to ensureIntervalValidity.
		ensureIntervalValidity(sldParent, @iif, oldVal)
	end
	function mouseBtnUp(src,callbackData)
		while ~strcmpi(src.UserData.status, 'BtnDownIsDone')
			% waiting for BtnDown to do its thing...
		end
		src.WindowButtonMotionFcn = '';
	end
	function ensureIntervalValidity(src, validityFunc, oldVal) % validityFunc and oldVal are not implemented
		if ~isempty(src.sisterslider) && ishandle(src.sisterslider.slider) && isvalid(src.sisterslider.slider)
			% make sure it doesn't go past sister's value
			if src.myID == 1 % for now, I'll assume there are only two sliders, with 1 controlling begin and 2 controlling the end
				if src.slider.Value >= src.sisterslider.slider.Value
					src.slider.Value = src.sisterslider.slider.Value;
				end
% 				h_fig.UserData.sliderValue(1) = src.Value;
			elseif src.myID == 2
				if src.slider.Value <= src.sisterslider.slider.Value
					src.slider.Value = src.sisterslider.slider.Value;
				end
% 				h_fig.UserData.sliderValue(2) = src.Value;
			end
		end
		notify(obj.parent, 'Updated');
	end
	function figureSizeChange(src, ~)
		% make sure the sliders are resized as the Figure is resized
	end
end