function I = isrestricted(obj)

I = length(obj.X) ~= length(obj.Mask(1).mask2idx) || ~all(obj.Mask(1).mask2idx);