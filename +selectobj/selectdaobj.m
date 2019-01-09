function [selObj, idx] = selectdaobj(daObjs, cond)

cond = cond(:);

idx = cell(length(cond), 1);
for i = 1:length(cond)
	relation = getRelationFunction(cond(i).relation);
	prop = {daObjs.(cond(i).prop)};
	fprop = cond(i).func(prop);
	idx{i} = cellfun(@(fp) relation(fp, cond(i).value), fprop);
end

allIdx = cat(1, idx{:});
if isempty(allIdx)
	selObj = daObjs(2:-1);
	return;
end
idx = find(prod(allIdx) > 0);

selObj = daObjs(idx);

function rf = getRelationFunction(relation)
validrelations = dataanalyzer.selectobj.validrelations;

switch relation
	case validrelations{1} % >
		rf = @(x, y) x>y;		
	case validrelations{2} % <
		rf = @(x, y) x<y;
	case validrelations{3} % >=
		rf = @(x, y) x>=y;
	case validrelations{4} % <=
		rf = @(x, y) x<=y;
	case validrelations{5} % ==
		rf = @(x, y) isequal(x,y);
	case validrelations{6} % ~=
		rf = @(x, y) ~isequal(x,y);
end