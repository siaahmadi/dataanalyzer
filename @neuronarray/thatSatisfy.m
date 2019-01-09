function na = thatSatisfy(obj, attributeSelection)
% attributes must be defined and manipulations on them described,
% therefore, they cannot be arbitrarily requested by user unless defined

% can I make 'thatSatisfy' check some rules defined by 'attributeSelection'
% rather than requiring the user to modify the code in order to request a
% certain subset of objects to be returned?

selectIdx = zeros(obj.size(), 1);

%%% TO DO: check if requested field exists within this object
%%% if so, proceed doing:
for i = 1:length(selectIdx) % for each neuron
	selectIdx(i) = feval(attributeSelection.op, eval(['obj.getNeurons(i).' attributeSelection.field]), attributeSelection.val);
end

na = obj.getNeurons(find(selectIdx));

%%% otherwise, do this:

% make copies of neurons

%%% end