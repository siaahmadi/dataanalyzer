function Right = getRightbound(obj)

if obj.Right.isempty()
	obj.parseLeftRight();
end

Right = obj.Right;