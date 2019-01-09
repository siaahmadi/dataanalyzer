function tr = getBeginTrials(obj)

tr = obj.trials(obj.isBeginTrial==1);
