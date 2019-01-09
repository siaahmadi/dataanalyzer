function tooltipText = txtvalTooltip(src, event_obj, TextOrFunctionHandle, Value, formattingSeparation)
%tooltipText = txtvalTooltip(src, event_obj, TextOrFunctionHandle, Value, formattingSeparation)
% Callback for a data cursor tooltip, matching Text-Value pairs
% 
% If desired a function that extracts information from the event_obj
% object can be supplied in place of the thrid argument (where text would
% otherwise be supplied). The function must take one argument (|event_obj|)
% and return two output arguments, the first of which will be treated as
% Text and the second as Value.

src.FontName = 'Courier';

if nargin < 3
	TextOrFunctionHandle = {'Default Formatting?'};
	Value = true;
elseif nargin == 3 && isa(TextOrFunctionHandle, 'function_handle')
	[TextOrFunctionHandle, Value] = TextOrFunctionHandle(event_obj);
else
	if numel(Value) ~= numel(TextOrFunctionHandle)
		error('Text-Value pairs do not correspond')
	end
	if ~exist('formattingSeparation', 'var') || isempty(formattingSeparation)
		formattingSeparation = 4;
	end
end

Value = cellfun(@mynum2str, Value, 'UniformOutput', false);
tooltipText = formatTooltipText(TextOrFunctionHandle,Value, formattingSeparation);


function formattedText = formatTooltipText(Text,Value, distance)

maxTxtLen = max(cellfun(@numel, Text));
maxValLen = max(cellfun(@numel, Value));
totalLen = maxTxtLen + maxValLen + distance;

formattedText = cellfun(@(x,y) sprintf(['%s' repmat(' ', 1, totalLen - length(x) - length(y)) '%s'],x,y), Text(:), Value(:), 'UniformOutput', false);

function String = mynum2str(Numeric, varargin)
if islogical(Numeric)
	if Numeric
		String = 'true';
	else
		String = 'false';
	end
	return
else
	String = num2str(Numeric, varargin{:});
end