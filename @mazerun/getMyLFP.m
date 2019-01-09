function lfp = getMyLFP(obj, ttNo)

if numel(obj) > 1
	lfp = arrayfun(@(x) x.getMyLFP(ttNo), obj, 'un', 0);
	if all(cellfun(@accFunc_issame, lfp(1:end-1), lfp(2:end)))
		lfp = lfp{1};
	else
		lfp = cat(1, lfp{:});
	end
	return;
end

lfp_cousin = dataanalyzer.ancestor(obj, 'expSession').lfp; % TODO: change to dataanalyzer.cousin(obj, 'lfp');

eeg = lfp_cousin.readEEG(lfp_cousin.ttMapping(ttNo));

[lfp.t, R] = restr(TimeStampsOf(eeg), obj.ts_begin, obj.ts_end);
lfp.raw = elem(Data(eeg), R);
R = find(R);
orig_R = R;
Fs = round(EEG.Fs(eeg));
AddToLeft = [];
if length(R) < Fs * 5 % run less than 5 seconds
	RoomToLeft = R(1)-1;
	RoomToRight = length(eeg) - R(end);
	LengthR = length(R);
	m = min(RoomToLeft, RoomToRight);
	if m < 5 * Fs - LengthR
		error('Todo...');
	else
		AddToLeft = R(1)-round((Fs * 5 - LengthR)/2):R(1)-1;
		AddToRight = R(end)+1:R(end)+round((Fs * 5 - LengthR)/2);
		R = [AddToLeft(:); R(:); AddToRight(:)];
	end
end
lfp.theta = XX_Filter(elem(Data(eeg), R), Fs, 6, 10);
lfp.theta = lfp.theta(length(AddToLeft)+1:length(AddToLeft)+length(orig_R));


phase = lfp_cousin.getPhase(ttNo);
[~, idx] = findstruct(phase, 'band', 'theta');
phase = phase(idx{1}).phase;
phase = phase(orig_R);

[~, locs] = findpeaks(-phase);

lfp.phase0 = lfp.t(locs);

function I = accFunc_issame(x, y)

I = isequal(x.t, y.t) & isequal(x.raw, y.raw);