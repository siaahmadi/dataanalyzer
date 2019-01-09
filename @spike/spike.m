classdef spike < dataanalyzer.neuralevent & dataanalyzer.tsable & dataanalyzer.visualizable
% Defines an individual spike. (Motivation: @mazerun; but also works for @neuron, @placefield)

% Siavash Ahmadi
% 11/25/2015

	properties (SetAccess=private, SetObservable) % setObservable: to ensure class methods write it as a struct of frequency band names
		phase = lfpphase(); % may be extended to include other bands
	end
	properties(SetAccess=protected)
		% Inherited:
% 		Ivls
% 		inField = false;
% 		displacement	% struct, with Nx1 "fromField" substruct where N == numFields of ancestor placemap
% 		distance		% struct, , with Nx1 "fromField" substruct where N == numFields of ancestor placemap
% 		duration

		% New:
		ts
		x
		y
		v
		refNeuron
		% phase is defined as SetAccess=private
	end
	methods
		function obj = spike(parent, varargin)
% 			validateattributes(parent, {'dataanalyzer.neuron', 'dataanalyzer.placefield', 'dataanalyzer.mazerun'}, {}, '@spike', 'parent', 1);
			
			if nargin == 0
				return;
			end

			args = p___parseInputArgs(varargin{:});

			if length(args.ts) > 1
				sp_obj = arrayfun(@(ts,phase) dataanalyzer.spike(parent, 'ts', ts, 'phase', phase, 'refneuron', args.refNeuron), args.ts, args.phase, 'un', 0);
				obj = cat(1, sp_obj{:});
				obj.update();
				return;
			else
				obj.ts = args.ts;
% 				obj.phase = args.phase;
				obj.phase = lfpphase('theta', args.phase);
				obj.refNeuron = args.refNeuron;
			end
			
			obj.Parent = parent;
			
			obj.duration = 0; % always 0, by definition
			
			ST = dbstack('-completenames');
			if length(ST) > 1 && ~strcmp(ST(2).name, '@(ts,phase)dataanalyzer.spike(parent,''ts'',ts,''phase'',phase)')
				obj.update(varargin{:});
			end
		end
		
		update(obj, varargin)
		phaseStruct = getPhaseLFP(obj)
		d = getDisplacement(obj)
		d = getDistance(obj)
		
		[d, ph, h, regress_results] = phasedist(obj, varargin);
		
		function newObj = clip(obj, ivls)
			newObj = copy(obj);

			idx_ts = ivls.restrict(newObj.getTS());
			idx_ts = sum(cat(2, idx_ts{:}), 2) > 0;

			newObj.spikeTrain = newObj.ts(idx_ts);
			newObj.phase = newObj.phase(idx_ts);
			newObj.x = newObj.x(idx_ts);
			newObj.y = newObj.y(idx_ts);
			newObj.Parent = obj;   % Not sure about whether to do this or not at this time 4/19/2017
		end
		
		function l = length(obj)
			if numel(obj) > 1
				l = arrayfun(@(x) x.length, obj);
				return;
			end
			if isfinite(obj.ts)
				l = 1;
			else
				l = 0;
			end
		end
		function I = isempty(obj)
			I = obj.length() == 0;
		end
		function [restricted, I] = restr(obj, low, high)
			t = arrayfun(@getTS, obj);
			[restricted, I] = restr(t, low, high);
		end
		function d = getDuration(~)
			d = 0; % dirac's delta
		end
		function t = getT(obj)
			t = obj.Ivls;
		end
		function ts = getTS(obj)
			ts = cat(1, obj.ts);
		end		
		function X = getX(obj)
			X = cat(1, obj.x);
		end
		function Y = getY(obj)
			Y = cat(1, obj.y);
		end
		function visualize(obj)
			figure;
			obj.plot;
		end
		function plot(obj)
			% numel(obj) may be > 1, hence the []
			scatter([obj.x], [obj.y], 49, 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'w', 'LineWidth', 1);
		end
		function hc = hardcopy(obj)
			D = arrayfun(@(o) o.distance.fromField.retrospective.normalized, obj);
			X = cat(1, obj.x);
			Y = cat(1, obj.y);
			t = cat(1, obj.ts);
			p = cat(1, obj.phase);
			hc = arrayfun(@(x,y,t,p,d) struct('t', t, 'x', x, 'y', y, 'p', p, 'd', d), X,Y,t,p,D,'un',0);
			hc = cat(1, hc{:});
		end
	end
end