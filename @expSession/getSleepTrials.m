function tr = getSleepTrials(obj)

tr = obj.trials(~obj.isBeginTrial);