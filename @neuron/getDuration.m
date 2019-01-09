function d = getDuration(obj, whatDuration)

if numel(obj) > 1
	if exist('whatDuration', 'var')
		d = arrayfun(@(x) x.getDuration(whatDuration), obj, 'UniformOutput', false);
	else
		d = arrayfun(@(x) x.getDuration, obj, 'UniformOutput', false);
	end
	
	return
end

currRecogCommands = {{'trial'}, {'restricted'; 'restriction'; 'restr'; 'restrict'}, {'spikes'; 'sp'}};

if ~exist('whatDuration', 'var')
	fprintf(2, 'Returning Trial Duration\0');
	d = obj.getDuration('trial');
elseif any(matchstr(currRecogCommands{1}, whatDuration, 'exact')) % trial
	if ~obj.parentTrial.isEmpty
		d = obj.parentTrial.getDuration();
		obj.trialDuration = d;
	else
		d = obj.trialDuration;
	end
elseif any(matchstr(currRecogCommands{2}, whatDuration, 'exact')) % restriction
	if ~isempty(obj.selectionFlag.spikes.duration)
		d = obj.selectionFlag.spikes.duration;
	else
		warning('The neuron is not restricted')
		return
	end
elseif any(matchstr(currRecogCommands{3}, whatDuration, 'exact')) % spikes
	% TODO
else
	recComm = cat(1,currRecogCommands{:});
	recCommTxt = sprintf(repmat('%s, ', 1, numel(recComm)), recComm{:});
	recCommTxt = recCommTxt(1:end-2);
	fprintf(2, 'Unknown Request\0');
	error(['Currently recognized commands are: ' recCommTxt]);
end