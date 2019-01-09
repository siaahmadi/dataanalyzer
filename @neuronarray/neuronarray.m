classdef neuronarray < dataanalyzer.master
	properties
		load_status = '';
	end
	properties (SetAccess=protected)
		neuronArray = {};
		placeMaps
	end
	
	methods
		function obj = neuronarray(neuronArray, anatomicalRegions)
			if nargin>1
				obj.appendNeuron(neuronArray, anatomicalRegions);
			elseif nargin > 0
				obj.appendNeuron(neuronArray);
			end
		end
		function obj = appendNeuron(obj, neuronArray, anatomicalRegions)
			if exist('neuronArray', 'var') && ~isempty(neuronArray)
				obj.Parent = neuronArray{1}.Parent;
			end
			presize = obj.length;
			obj.neuronArray = [obj.neuronArray; cell(length(neuronArray), 1)];
			for i = (1:length(neuronArray)) + presize
				if isa(neuronArray{i-presize}, 'dataanalyzer.neuron')
					obj.neuronArray{i} = neuronArray{i-presize};
				else
					if nargin > 2
						obj.neuronArray{i} = dataanalyzer.neuron(neuronArray{i-presize}, anatomicalRegions(i-presize));
					elseif nargin > 1
						obj.neuronArray{i} = dataanalyzer.neuron(neuronArray{i-presize});
					end
				end
			end
		end
		function n = getNeurons(obj,ind)
			if nargin == 1
				n = obj;
				return;
			end
			if length(ind) == 1
				n = obj.neuronArray{ind};
			else
				n = dataanalyzer.neuronarray(obj.neuronArray(ind));
			end
		end
		function n = getNeuron(obj,varargin)
			emptyForNotFound = true; % if true, return an empty @neuron object at the index where a query isn't found
			if nargin == 1
				n = makecolumn(extractcell(obj.neuronArray));
				return;
			elseif nargin == 2
				if ~ischar(varargin{1}) && ~iscellstr(varargin{1})
					error('Invalid input');
				elseif ischar(varargin{1})
					idx = varargin;
				else
					idx = varargin{1};
				end
			elseif nargin > 2
				idx = varargin(:);
			end
			idx = cellfun(@(x) find(obj.findNeuron(x), 1), idx, 'UniformOutput', false);
			emptyIdx = cellfun(@isempty, idx);
			emptyNeuron = repmat(dataanalyzer.neuron(), sum(emptyIdx), 1);
			n = makecolumn(extractcell(obj.neuronArray([idx{:}])));
			if emptyForNotFound
				nn = cat(1, n, emptyNeuron);
				if sum(emptyIdx) > 0
					nn(emptyIdx) = emptyNeuron;
				end
				if sum(~emptyIdx) > 0
					nn(~emptyIdx) = n;
				end
				n = nn;
			end
		end
		function idx = findNeuron(obj, id)
			if ischar(id)
				idx = cellfun(@(x) strcmp(x.namestring, id), obj.neuronArray);
			elseif iscellstr(id)
				idx = extractcell(cellfun(@(x) find(obj.findNeuron(x)), id, 'UniformOutput', false)); % if not found, will produce empty array []
				idx = idx2logic(idx, numel(obj.neuronArray));
			elseif isnumeric(id)
				validateIdx(id);
				idx = id;
			else
				error('DataAnalyzer:NeuronArray:FindNeuron:InvalidIdentifier', 'Invalid identifier to neurons.');
			end
		end
		function l = length(obj)
			l = numel(obj.neuronArray);
		end
		function I = isempty(obj)
			I = isempty(obj.neuronArray);
		end
		
		na = thatSatisfy(obj, attributeSelection);
		n = getSpikes(obj);
		regions = getRegions(obj, idx)
		
		function rearrange(obj, newArrangement)
			if sum(newArrangement) ~= length(obj.neuronArray)
				warning('Mismatch in the number of neurons and newArrangement.');
				return;
			end
			newArray = cell(size(newArrangement));
			newArray(newArrangement) = obj.neuronArray;
			newArray(~newArrangement) = repmat({dataanalyzer.neuron}, sum(~newArrangement), 1);
			obj.neuronArray = newArray;
		end
		function hc = hardcopy(obj, unit, zeroAnchored)
			if nargin == 1
				unit = 1; zeroAnchored = false;
			elseif nargin == 2
				zeroAnchored = false;
			end
			hc = cell(numel(obj.neuronArray), 1);
			for i = 1:length(hc)
				if ~isempty(obj.neuronArray{i})
					hc{i} = obj.neuronArray{i}.hardcopy(unit, zeroAnchored);
				end
			end
		end
		
		function M = getMap(obj, neuronName, maskName)
			
			if nargin == 2
				error('Enter both inputs, neuronName and maskName, or skip altogether. neuronName may be skipped by passing an empty array [].');
			end
			
			if ~exist('neuronName', 'var') || isempty(neuronName) % return the first placemap of every neuron
				neuronName = obj.list;
			end
			if ~exist('maskName', 'var') || isempty(maskName)
				maskName = 'default';
			end
			if iscellstr(neuronName) && length(neuronName) > 1 && iscellstr(maskName) && length(maskName) > 1
				if length(neuronName) ~= length(maskName) % if both have lengths of > 1 they must be the same length
					error('DataAnalyzer:NeuronArray:GetMap:InconsistentInputLengths', 'When asking for different masks for each neuron, the length of neuron list, ''neuronName'' and mask list, ''maskName'' must be the same.');
				end
			end
			if ischar(maskName)
				if iscell(neuronName)
					maskName = repmat({maskName}, length(neuronName), 1);
				elseif ischar(neuronName)
					maskName = {maskName};
				end
			end
			if ischar(neuronName)
				neuronName = repmat({neuronName}, length(maskName), 1);
			end
			
			% validate input args
			if ~iscellstr(maskName) || ~iscellstr(neuronName)
				error('');
			end
			
			neurons = num2cell(obj.getNeuron(neuronName));
			M = cellfun(@(n, m) n.placeMaps.getMap(m), neurons(:), maskName(:), 'UniformOutput', false); % must be cell, b/c user may request masks for a cell that doesn't exist. Order then will be messed up if this is turned inta an array
			% at the moment dataanalyzer.placemap doesn't produce empty
			% objects (it produces a 0x0 object which when {}-d will
			% produce {[]}. I should prolly fix this later @date 11/25/2015
			
			if length(neurons) == 1 && length(maskName) == 1
				M = extractcell(M);
			end
		end
		
		function updatePlaceMaps(obj, varargin)
			if isempty(obj)
				return;
			end
			na = extractcell(obj.neuronArray)';
			arrayfun(@(x) x.updatePlaceMaps(varargin{:}), na, 'UniformOutput', false);
			obj.placeMaps = cat(1, na.placeMaps); % this line is senseless
		end
		
		function l = list(obj)
			l = cellfun(@(x) x.namestring, obj.neuronArray, 'UniformOutput', false);
		end
	end
end