function [l, beginTS, endTS] = getDuration(obj, whichTrials)

l = zeros(obj.size(), 1);
beginTS = zeros(obj.size(), 1);
endTS = zeros(obj.size(), 1);
for i = 1:obj.size()
	thisTrial = obj.getTrials(i);
	if ~isempty(thisTrial.getDuration())
% 		warning('to fix: this conditional is not supposed to be here; also remember to fix hardcopy() of neuronarray')
		[l(i), beginTS(i), endTS(i)] = thisTrial.getDuration();
	end
end
if nargin > 1
	wtIdx = obj.selectTrials(whichTrials);
	l = l(wtIdx);
	beginTS = beginTS(wtIdx);
	endTS = endTS(wtIdx);
end