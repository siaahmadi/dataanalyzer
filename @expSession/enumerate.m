function l = enumerate(obj, whatToList)

if nargin == 1
	whatToList = 'name';
end

if strcmp(whatToList, 'tt')
	neuronList = obj.sessionNeuronList;
	
	l = regexp(neuronList, 'TT\d{1,2}', 'match', 'once');
	l = cellfun(@(x) str2double(x(3:end)), l);
end

if strcmp(whatToList, 'name')
	l = obj.sessionNeuronList;
end