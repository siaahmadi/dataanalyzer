function ratios = loadThetaRatiosFile(obj)

fn = fullfile(obj.fullPath, obj.thetaRatiosFileName);

if exist(fn, 'file') == 2
	theta = load(fn, 'ratios');
	ratios = theta.ratios;
else
% 	answer = questdlg('Theta ratios file not found. Generate?', 'Theta ratio computation', 'Yes', 'No', 'Yes');
	answer = 'Yes';
	if strcmp(answer, 'Yes')
		obj.writeLFPThetaPwrRatioToDirectory();
		ratios = obj.loadThetaRatiosFile();
	else
		ratios = [];
	end
end