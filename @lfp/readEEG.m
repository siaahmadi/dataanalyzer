function eeg = readEEG(obj, ttNo, save)

if ~exist('save', 'var') || isempty(save)
	save = false;
end

ttNo = full(ttNo);

[isthere, eegIdx] = findstruct(obj.eeg, 'ttNo', ttNo);
eegIdx = cat(1, eegIdx{:});
missing = ~isthere;
nonTsd = ~cellfun(@(x) isa(x, 'tsd'), {obj.eeg(eegIdx).tsd});
if isempty(nonTsd)
	nonTsd = false;
end

if any(missing) || any(nonTsd)
	for i = find(missing(:)' | nonTsd(:)')
		eeg = obj.Parent.readEEG(ttNo(i));

		if save
			eeg_struct = struct('ttNo', ttNo(i), 'tsd', eeg, 'hilbert', hilbertstruct(0, 1)); % hilbertstruct private method
			obj.eeg = [obj.eeg; eeg_struct];
		end
	end
% 	eeg = obj.readEEG(ttNo, save); % causes stack overflow
else
	if sum(eegIdx) > 1
		eeg = {obj.eeg(eegIdx).tsd}';
	else
		eeg = obj.eeg(eegIdx).tsd;
	end
end