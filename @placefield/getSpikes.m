function sp = getSpikes(obj, passNo)

if nargin < 2
	passNo = 1:numel(obj.dynProps.passes);
end

sp = {obj.dynProps.passes(passNo).spikes};
sp = sp(:);