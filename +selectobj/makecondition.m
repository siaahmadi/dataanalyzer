function cond = makecondition(prop, func, relation, value, objClass)

if ~ischar(objClass)
	error('objClass must be a string.');
end

if ischar(prop)
	prop = {prop};
	func = {func};
	relation = {relation};
end

sz_p = size(prop);
sz_f = size(func);
sz_r = size(relation);
sz_v = size(value);


validateattributes(prop, {'cell'}, {'size', sz_f});
cellfun(@(p) validatestring(p, properties(['dataanalyzer.', objClass])), prop, 'un', 0);

validateattributes(func, {'cell'}, {'size', sz_r});
func = cellfun(@(f) helper_func(f), func, 'un', 0);
cellfun(@(f) validateattributes(f, {'function_handle'}, {}), func, 'un', 0);

validateattributes(relation, {'cell'}, {'size', sz_v});
cellfun(@(r) validatestring(r, {'gt', 'lt', 'ge', 'le', 'eq', 'ne'}), relation, 'un', 0);

validateattributes(value, {'numeric'}, {'size', sz_p});


cond = repmat(struct('prop', '', 'func', @(x) x, 'relation', '', 'value', []), sz_p);

for i = 1:numel(cond)
	cond(i).prop = prop{i};
	cond(i).func = func{i};
	cond(i).relation = relation{i};
	cond(i).value = value(i);
end


function f = helper_func(f)
if isempty(f)
	f = @(x) x;
else
	f = @(c) cellfun(@(x) f(x), c, 'un', 0);
end