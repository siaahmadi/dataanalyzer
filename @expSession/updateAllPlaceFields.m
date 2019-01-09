function updateAllPlaceFields(obj) % shall be renamed updatePlaceMaps
% old version
% used "constraints" instead of "Masks"

error('Deprecated');

n = obj.getNeurons();
n = n(:, cellfun(@(x) isa(x, 'dataanalyzer.begintrial'), obj.trials));
nonEmptyNeurons = cellfun(@(x) ~isempty(x), n);
nl = firstone(nonEmptyNeurons);
n = n(nl>0, :); nl = nl(nl>0);


allNonEmptyBehaviorNeurons = n(sub2ind(size(n), 1:length(n), nl'))';

h = waitbar(0, 'Calculating Place Fields...');
for i = 1:length(allNonEmptyBehaviorNeurons)
% 	allNonEmptyBehaviorNeurons{i}.updatePlaceFields('constraints', obj.getOptions('UpdatePlaceFields').constraints);
	allNonEmptyBehaviorNeurons{i}.updatePlaceFields('constraints', obj.getMyOptions().constraints); % @author Sia @date 10/23/15 2:16 PM

	waitbar(i/length(allNonEmptyBehaviorNeurons), h, ['Calculating Place Fields... (' ...
		strrep(allNonEmptyBehaviorNeurons{i}.namestring, '_', '\_') ')']);
end
close(h)