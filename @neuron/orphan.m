function orphan(obj, isOrphan, parentTrial)
	obj.isOrphan = isOrphan;
	if ~isOrphan
		if isa(parentTrial, 'dataanalyzer.trial')
			obj.parentTrial = parentTrial;
			obj.updatePlaceFieldListenerHandle = ...
				addlistener(parentTrial,'PleaseUpdateYourPlaceFields',...
				@(parent, event) obj.updatePlaceFields(event));
		end
	else
		obj.parentTrial = [];
		if exist(obj.updatePlaceFieldListenerHandle, 'var') && obj.updatePlaceFieldListenerHandle.isvalid
			obj.updatePlaceFieldListenerHandle.delete;
		else
			obj.updatePlaceFieldListenerHandle = [];
		end
	end
	obj.Parent = parentTrial;
end