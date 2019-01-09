function obj = fromLogical(obj, L, referenceObj)

if ~islogical(L)
	error('DataAnalyzer:Mask:FromLogical:InvalidInput', 'Input not logical');
end
if ~isa(referenceObj, 'dataanalyzer.tsable')
	error('DataAnalyzer:Mask:FromLogical:InvalidInput', 'Reference object must be dataanalyzer.tsable type.');
end

obj.fromIdx(L, referenceObj);