classdef raster < handle
	properties
		trialBeginTS
		trialEndTS
		trialLength
		s
		displayIdx
		demarcations = {};
		
		ax
		h_raster
		lkdSliders
		lhSliders
		xlims
	end
	properties(SetAccess=private)
		orderInv
		orderOp
	end
	methods
		function obj = raster(s, tsBegin, tsEnd)
			if isa(s, 'dataanalyzer.wip.neuralevents.neuralevent')
				s = [[s.beginTS]; [s.endTS]];
				s = s(:);
			end
			if ~iscell(s)
				s = {s};
			end
			if exist('tsBegin','var') && ~isempty(tsBegin) && tsBegin > 0
				obj.trialBeginTS = tsBegin;
			else
				obj.trialBeginTS = min(cellfun(@min, s));
			end
			if exist('tsEnd','var') && ~isempty(tsEnd) && tsEnd > 0
				obj.trialEndTS = tsEnd;
			else
				obj.trialEndTS = max(cellfun(@max, s));
			end
			if obj.trialEndTS < max(cellfun(@max, s)) || obj.trialBeginTS > min(cellfun(@min, s)) || obj.trialBeginTS == obj.trialEndTS
				error('Trial timestamps are not correct')
			end
			obj.s = s;
			obj.displayIdx = true(1,numel(s));
			
			obj.h_raster = obj.draw(); % <-- supports logical spikes too (Fs must be provided as well)
			obj.orderInv = 1:numel(obj.h_raster);
			obj.orderOp = 1:numel(obj.h_raster);
			addlistener(obj.h_raster(1), 'ObjectBeingDestroyed', @(src, evnt) ~isempty(obj.lhSliders) && delete([obj.lhSliders{:}])); % maybe I should delete myself (|obj|) too?
			
			obj.ax = ancestor(obj.h_raster(1), 'Axes');
			obj.xlims = obj.ax.XLim;
			
			obj.trialLength = obj.trialEndTS - obj.trialBeginTS;
		end
		function addEventDemarcation(obj, demarcation, tag, relativeOrAbsolute)
			if ~isa(demarcation, 'dataanalyzer.wip.neuralevents.neuralevent')
				error('Pass a |neuralevent|-type demarcation array');
			end
			
			if ~exist('tag', 'var')
				tag = size(obj.demarcations, 1) + 1;
			end
			
			if ~exist('relativeOrAbsolute', 'var') || strcmpi(relativeOrAbsolute, 'absolute')
				dmcRaster = dataanalyzer.interactive.raster(demarcation);
			elseif strcmpi(relativeOrAbsolute, 'relative')
				dmcRaster = dataanalyzer.interactive.raster(demarcation+obj.trialBeginTS);
			else
				error('relativeOrAbsolute can be either ''absolute'' or ''relative''')
			end
			dmcRaster.h_raster.YData(2:3:end) = numel(obj.h_raster);
			
			obj.demarcations = [obj.demarcations; {dmcRaster tag}];
		end
		function removeEventDemarcation(obj, tag) % doesn't change tags after removal of a demarcation
			dmcIdx = cellfun(@(x) x == tag, obj.demarcations(:, 2));
			delete(obj.demarcations(dmcIdx, 1));
			obj.demarcations(dmcIdx, :) = [];
		end
		function toggleDemarcation(obj, tag)
			if ~exist('tag', 'var')
				error('Please enter demarcation tag. (If tag wasn''t set when adding the demarcation, its tag is its numeric order).')
			end
			
			dmcIdx = cellfun(@(x) x == tag, obj.demarcations(:, 2));
			
			for i = find(dmcIdx)
				if strcmpi(obj.demarcations{i,1}.h_raster.Visible,'on')
					obj.demarcations{i,1}.h_raster.Visible = 'off';
				else
					obj.demarcations{i,1}.h_raster.Visible = 'on';
				end
			end
			if isempty(i)
				warning('No such tag found')
			end
		end
		function reorder(obj, newOrder)
			if ~isempty(setdiff(unique(newOrder), 1:numel(obj.h_raster))) % |newOrder| has senseless elements
				error(['|newOrder| must contain numbers from the integer set [1,..,' numel(obj.h_raster) '], as exactly ' numel(obj.h_raster) ' rasters exist.']);
			end
			
			a = 1:numel(obj.h_raster);
			a(unique(newOrder)) = newOrder;
			newOrder = a;
			obj.orderOp = obj.orderOp(newOrder);
			obj.orderInv = orderinv(obj, newOrder);
			
			obj.h_raster = obj.h_raster(newOrder);
						
			for i = 1:length(newOrder)
				j = newOrder(i);
				obj.h_raster(i).YData(1:3:end) = obj.h_raster(i).YData(1:3:end) - (j - i);
				obj.h_raster(i).YData(2:3:end) = obj.h_raster(i).YData(2:3:end) - (j - i);
			end
		end
		function defaultOrder(obj)
			obj.reorder(orderinv(obj, obj.orderOp));
		end
		function setRasterWidth(obj, newWidth)
			for i = 1:length(obj.h_raster)
				obj.h_raster(i).LineWidth = newWidth;
			end
		end
		function linksliders(obj, ls1, ls2)
			obj.lkdSliders = {ls1; ls2};
			
			obj.lhSliders{1} = addlistener(ls1.slider, 'ContinuousValueChange', @(src, evnt) updateEverything);
			obj.lhSliders{2} = addlistener(ls2.slider, 'ContinuousValueChange', @(src, evnt) updateEverything);
			obj.h_raster.Color = ls1.parent.color;
			
			function newVal = getNewVal()
				newVal = (obj.ax.XLim-obj.trialBeginTS)./obj.trialLength;
				newVal = iif(newVal(1)>=0 && newVal(2)<=1, newVal, [0,1]);
			end
			ls1.pushLH(addlistener(obj.ax, 'XLim', 'PostSet', @(src, evnt) ls1.update(getNewVal))); % TODO: take care of deleting the lh when I'm destroyed
			
			function updateEverything()
				low = obj.lkdSliders{1}.slider.Value;
				hi = obj.lkdSliders{2}.slider.Value;
				obj.update(low, hi);
				
				obj.redraw();
			end
		end
		function update(obj, low, hi)
			xlim_range = [low, hi];
			obj.xlims = (xlim_range .* obj.trialLength) + obj.trialBeginTS;
			obj.displayIdx(:) = false;
			[~, I] = cellfun(@(x) restr(x, obj.xlims(1), obj.xlims(2)),obj.s, 'UniformOutput', false);
			obj.displayIdx(cell2mat(I)) = true;
		end
		function redraw(obj)
			if all(size(obj.xlims) == [1,2]) && obj.xlims(2) > obj.xlims(1)
				obj.ax.XLim = obj.xlims;
			end
			% TODO: take care of |obj.h_raster|'s XData and YData based on
			% |obj.displayIdx|
		end
% 		function del(obj) % if the delete listener needed to become more complicated the callback function should be moved here
% 			delete([obj.lhSliders{:}]);
% 		end
	end
end