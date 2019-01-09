function args = p___parseInputArgs(varargin)

ST = dbstack('-completenames');

function_name = ST(2).name; % caller function's name

if strcmp(function_name, 'phasedist')
	if ~isparamvalue(varargin{:})
		error('Expecting ''Param'', ''Value'' pairs.');
	end

	definedParameters = {'update', 'regress', 'legend', 'plot', 'heat', 'duplicate', 'highlight'};

	params = varargin(1:2:end);
	vals = varargin(2:2:end);

	buffer = repmat(definedParameters, 1, 2);
	buffer(1:2:end) = definedParameters;
	buffer(2:2:end) = repmat({false}, 1, length(buffer)/2);
	args = struct(buffer{:}); % default
	args.ts = NaN;

	for p = 1:length(params)
		param = params{p};
		val = vals{p};

		validatestring(param, definedParameters);


		if strcmpi(param, 'ts')
			args.ts = val;
		else % on-off parameters
			args.(param) = validateOnOff(val);
		end
	end
elseif strcmp(function_name, 'spike.spike')
	definedParameters = {'ts', 'phase', 'refNeuron'}; % for later
	
	args.ts = [];
	args.phase = [];
	if nargin == 0
		return;
	end
	if isa(varargin{1}, 'dataanalyzer.neuron')
		args.ts = varargin{1}.getTS();
		args.phase = varargin{1}.phases;
		
		args.ts = args.ts(:);
		args.phase = args.phase(:);
		args.refNeuron = varargin{1};
	elseif isparamvalue(varargin{:})
		args = parseParamValue_Update(varargin{:});
	else
		error('Todo');
	end

	if ~isequal(size(args.ts), size(args.phase))
		error('Invalid inputs to dataanalyzer.spike(). ts and phase must have the same number of elements');
	end
elseif strcmp(function_name, 'update')
	args = parseParamValue_Update(varargin{:}); % doesn't need the size check like spike.spike above; because it has been parsed once by spike.spike
end


function val = validateOnOff(val)
if ~islogical(val)
	validatestring(val, {'on', 'off'});
	val = strcmpi(val, 'on');
else
	validateattributes(val, {'logical'}, {'size', [1, 1]});
end

function I = isparamvalue(varargin)
len = mod(nargin, 2) == 0;
type = all(cellfun(@ischar, varargin(1:2:end)));

I = len & type;

function args = parseParamValue_Update(varargin)

p = inputParser();
p.addParameter('ts', [], @(x) validateattributes(x, {'numeric'}, {'increasing'}));
p.addParameter('phase', [], @(x) validateattributes(x, {'numeric'}, {}));
p.addParameter('refNeuron', dataanalyzer.neuron(), @(x) isa(x, 'dataanalyzer.neuron'));
p.parse(varargin{:});

args.ts = p.Results.ts(:);
args.phase = p.Results.phase(:);
args.refNeuron = p.Results.refNeuron(:);