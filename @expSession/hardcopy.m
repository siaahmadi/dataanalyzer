function hc = hardcopy(obj, unit, zeroAnchored)
	hc = cell(numel(obj.sessionNeuronList), obj.size());
	for i = 1:obj.size()
		thisTrial = obj.getTrials(i);
		if nargin > 2
			hc(:, i) = thisTrial.hardcopy(unit, zeroAnchored);
			continue;
		elseif nargin > 1
			hc(:, i) = thisTrial.hardcopy(unit);
			continue;
		else
			hc(:, i) = thisTrial.hardcopy();
			continue;
		end
	end
end