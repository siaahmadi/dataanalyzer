function obj = setParentTrial(obj, parentTrial)

obj.parentTrial = parentTrial;
obj.Parent = parentTrial;
obj.convertTimeUnit(parentTrial.timeUnit);