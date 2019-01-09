classdef (Abstract) maskable < dataanalyzer.timeable
	properties (SetAccess=public, GetAccess=public)
		Mask = dataanalyzer.mask(ivlset([-Inf, Inf]), [], 'default'); % Masks?
	end
	methods
		function I = hasmask(obj, mask)
			I = obj.Mask.hasmask(mask);
		end
		function masks = getMask(obj, select) % to be improved later
			masks = obj.Mask(select);
		end
	end
	methods (Abstract)
		newObj = clip(obj, ref)
	end
end