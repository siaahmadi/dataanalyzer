function ts = getTS(obj, ttNo, mask)

% TODO: apply mask

[isthere, ~, idx] = findstruct(obj.eeg, 'ttNo', full(obj.ttMapping(ttNo)));

if isthere
	ts = Range(obj.eeg(idx).tsd) * 1e-4;
end