function disp(obj)

if numel(obj) > 1
	arrayfun(@(x) x.disp, obj);
	return;
end
nonempty = arrayfun(@(x) ~isempty(x), obj.tEffectiveIvls);
tInt = obj.tEffectiveIvls;
if nonempty
	tIvlValues = num2str(tInt.toIvl);
	X = num2str(length(find(obj.tIdx)));
	X = '???';
	tIvlNums = ['Including ' X ' time stamps from ' num2str(length(tInt)) ' interval(s).'];
else
	tIvlValues = 'Empty mask object.';
	tIvlNums = '';
end

buffer = row2cell(tIvlValues);
nIvl = size(buffer, 1);
if nIvl > 10
	buffer = buffer(1:10, :);
	tooManyIvlsMsg = {['And ' num2str(nIvl - 10), ' more.']};
else
	tooManyIvlsMsg = {'---'};
end
formatted_right = stralign([{obj.name}, {' '}, buffer(:)', {' '}, tooManyIvlsMsg, {' '}, {tIvlNums}], 0, 'left');

filler = repmat({' '}, 1, length(formatted_right)-3); % empty lines for any additional intervals in excess of 1.
if length(formatted_right) > 1
	formatted_left = stralign([{'Mask Name'}, {'Intervals'}, filler, {'Interval Count'}], 4);
	formatted_center = [': '; ': '; repmat('  ', length(formatted_left)-3, 1); ': '];
else
	formatted_left = stralign({'Mask Name', 'Intervals', 'Interval Count'}, 4);
	formatted_center = repmat(': ', length(formatted_left), 1);
end
message = [cat(1, formatted_left{:}), formatted_center, cat(1, formatted_right{:})];
message = mat2cell(message, ones(1, size(message, 1)), size(message, 2));
fprintf([repmat('%s\n', 1, length(message)) '\n'], message{:});