function options = getMyOptions(obj)

[ST, I] = dbstack('-completenames');
caller = ST(I+1).name;

options = obj.getOptions(caller);