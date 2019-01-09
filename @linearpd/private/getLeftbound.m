function Left = getLeftbound(obj)

if obj.Left.isempty()
	obj.parseLeftRight();
end

Left = obj.Left;