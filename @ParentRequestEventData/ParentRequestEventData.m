classdef (ConstructOnLoad) ParentRequestEventData < event.EventData
	properties
		parentRequestData
	end
	methods
		function obj = ParentRequestEventData(data)
			obj.parentRequestData = data;
		end
	end
end