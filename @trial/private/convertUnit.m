function spikeTrain = convertUnit(spikeTrain, fromUnit, toUnit)


TENTH_OF_MILLISECOND = 1e-4;
MICROSECOND = 1e-6;

[thisTrialBeganAt, thisTrialEndedAt] = trialTimeStamps(pathToTrial);
if strcmpi(toUnit, 'default') || strcmpi(toUnit, 'tenth') || strcmpi(toUnit, '1e4')|| strcmpi(toUnit, 'ts')
	spikeTrain{i} = spikeTrain{i} - thisTrialBeganAt*1e-2; % st is in .1 milliseconds, thisTrialBeganAt is in microseconds
	toUnitFactor = 1e-2;
elseif strcmpi(toUnit, 'second') || strcmpi(toUnit, '1') || strcmpi(toUnit, 's')
	spikeTrain{i} = spikeTrain{i}*TENTH_OF_MILLISECOND - thisTrialBeganAt*MICROSECOND;
	toUnitFactor = MICROSECOND;
elseif strcmpi(toUnit, 'microsecond') || strcmpi(toUnit, '1e6') || strcmpi(toUnit, 'us')
	spikeTrain{i} = spikeTrain{i}/1e-2 - thisTrialBeganAt;
	toUnitFactor = 1;
	end

trialBeginEndTimeStamps.thisTrialBeganAt = thisTrialBeganAt*toUnitFactor;
trialBeginEndTimeStamps.thisTrialEndedAt = thisTrialEndedAt*toUnitFactor;
trialBeginEndTimeStamps.trialDuration = (thisTrialEndedAt - thisTrialBeganAt)*toUnitFactor;