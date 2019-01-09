classdef begintrial < dataanalyzer.trial & dataanalyzer.visualizable & dataanalyzer.tsable
	properties (SetAccess=protected)
		positionData % Initially, this is a copy of the stock position
					% data. If trimming or manipulating the position
					% data is to be done, it can be done on this. If
					% an error is discovered, positionData can be
					% easily reverted back to stock by calling
					% resetPositionData.
	end
	methods
		function obj = begintrial(residencePath, nameString, spatialEnvironment, loadAllNeurons, loadPositionData, parent)
			if exist('parent', 'var')
				obj.linkToParentViaListener(parent);
			end
			
			if nargin < 1
				obj.initialize('', '', '');
			else
				obj.initialize(residencePath, nameString, spatialEnvironment);
				if loadAllNeurons
					[~, neuron_load_status] = obj.loadNeurons();
				end
				if loadPositionData
					obj.loadPositionData();
				end
			end
			obj.Mask = dataanalyzer.maskarray(dataanalyzer.mask(ivlset(obj.beginTS, obj.endTS), obj, 'default'), obj);
		end
		function initialize(obj, residencePath, nameString, spatialEnvironment)
			initialize@dataanalyzer.trial(obj, residencePath, nameString, spatialEnvironment);
			obj.positionData = dataanalyzer.positiondata.createEnvPD(spatialEnvironment);
		end
		function resetPositionData(obj)
			if numel(obj) > 1
				arrayfun(@(x) x.resetPositionData, obj);
				return;
			end
			if ~obj.positionData.isempty()
				obj.positionData.resetToStock;
			else
				obj.loadPositionData();
			end
		end
		function obj = loadPositionData(obj)
			obj.positionData.load(obj.fullPath, obj);
			try
				obj.positionData.update(); % this used to be inside the if block below. Don't know why. 11/9/2015
			catch err
				warning('DataAnalyzer:LoadTrial:PDParseError', ['Cannot parse ' obj.namestring]);
			end
			if isa(obj.positionData, 'dataanalyzer.linearpd')
			end
		end
		
		% Inhertied from dataanalyzer.visualizable
		function X = getX(obj, restr)
			X = [];
			if nargin < 2
				restr = 'restr';
			end
			if ~isempty(obj.positionData)
				X = obj.positionData.getX(restr);
			end
		end
		function Y = getY(obj, restr)
			Y = [];
			if nargin < 2
				restr = 'restr';
			end
			if ~isempty(obj.positionData)
				Y = obj.positionData.getY(restr);
			end
		end
		function TS = getTS(obj, restr)
			TS = [];
			if nargin < 2
				restr = 'restr';
			end
			if ~isempty(obj.positionData)
				TS = obj.positionData.getTS(restr);
			end
		end
		function visualize(obj)
			figure;
			error('Todo...');
			plot(obj.getX('unrestr'), getY('unrestr'));
		end
	end
end