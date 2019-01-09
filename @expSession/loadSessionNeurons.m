function obj = loadSessionNeurons(obj)

if isempty(obj.sessionSpikeTrains)
	fn = dataanalyzer.constant('FileName_SpikeData_Session');
	load(fullfile(obj.fullPath, fn));
	tFileNames = {Spikes.id};
	[ts, phase] = sessionspikes(Spikes, Phases);

	anatomy = dataanalyzer.routines.anatomy.load(obj, tFileNames(:));
	n = cellfun(@(sp,anat,tfn,PH)...
		dataanalyzer.neuron('spikes', sp, 'anatomy', anat, 'parent', obj, 'namestring', tfn, 'phases', PH), ...
		ts(:), num2cell(anatomy), tFileNames(:), phase(:), 'un', 0);
	obj.neurons = dataanalyzer.neuronarray(n(:));
	
	sN = cellfun(@(s,phase,anat,fn) struct('ts', s, 'phase', phase, 'anatomy', anat, 'tFileName', fn), ts, phase, num2cell(anatomy), tFileNames(:), 'un', 0);
	obj.sessionSpikeTrains = cat(1, sN{:});
end

function [ts, varargout] = sessionspikes(Spikes, varargin)
Spikes = rmfield(Spikes, 'id');
Spikes = struct2cell(Spikes);
[ts, I] = cellfun(@(sprow) sort(cat(1, sprow{:})), column2cell(Spikes), 'un', 0);
ts = ts(:);

varargout = cell(size(varargin));
for i = 1:length(varargin)
	temp = rmfield(varargin{i}, 'id');
	temp = struct2cell(temp);
	temp = cellfun(@(sprow) cat(1, sprow{:}), column2cell(temp), 'un', 0);
	varargout{i} = cellfun(@(t,i) t(i), temp, I, 'un', 0);
	varargout{i} = varargout{i}(:);
end