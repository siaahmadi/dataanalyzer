function tFileList = getTFileList(fullPath)

fList = dir(fullfile(fullPath, '*.t'));
if isempty(fList)
	error('DataAnalyzer:Neuron:NoTFiles', 'No .t files found in current trial''s directory');
end

tFileList = cell(length(fList), 1);
for i = 1:length(tFileList)
	tFileList{i} = fList(i).name;
end