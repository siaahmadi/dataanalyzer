classdef placemap < dataanalyzer.master
	properties
		PFields
		RMap
		SpatialTuningMeasures
		
		RefMask
		RefPD
		RefNeuron
		
		Dim = 2;
		mapOpt = []
	end
	methods
		function obj = placemap(parent, refPD, refMask, refNeuron, mapOpt)
			obj.Parent = parent;
			
			obj.update(refPD, refMask, refNeuron, mapOpt);
		end
		
		update(obj, refPD, refMask, refNeuron, mapOpt)
		hc = hardcopy(obj)
        
		function mp = getField(obj)
			% TODO
			mp = obj;
		end
		
		function set(obj, varargin)
			%SET Set placemap object's reference fields (i.e. positiondata,
			%neuron, mask)
			
			[refPD, refMask, refNeuron, opt] = p___validateAndParseVarargin(varargin{:});
			
			obj.RefPD = refPD;
			obj.RefMask = refMask;
			obj.RefNeuron = refNeuron;
			obj.mapOpt = opt;
			obj.Dim = obj.mapOpt.dimensionality;
		end
		
		fig_h = visualize(obj, varargin)
	end
	
	methods (Static)
		[rmap, binRangeX, binRangeY, occup, preRM, gaussFit] = MakeMap(projectname, x, y, t, s, validintervals, opt)
	end
end