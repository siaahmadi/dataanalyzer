function linkToParentViaListener(obj, parent)
addlistener(parent,'PleaseRearrangeYourNeurons',@(parent, event) obj.rearrangeNeurons(event));
obj.parentSession = parent;
obj.Parent = parent;