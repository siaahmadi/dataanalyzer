function I = p___validateInputArgs(varargin)

% Siavash Ahmadi
% 11/27/2015 12:30 PM

if ~mod(nargin, 2) == 0
	error('Invalid');
end

params = varargin(1:2:end);
vals = varargin(2:2:end);

for i = 1:length(params)
	param = params{i};
	val = vals{i};
	
	if strcmp(param, 'freqBand')
		I = validateFreqBand(val);
	else
		error('not defined yet');
	end
end

if ~I
	error('Something''s wrong');
end

I = true;


function I = validateFreqBand(val)

if numel(val) > 1
	I = all(arrayfun(@validateFreqBand, val));
	return;
end

I = false;

if isstruct(val) % todo: use validateattributes
	fn = fieldnames(val);
	if all(ismember(fn, 'name') | ismember(fn, 'cutoff_low') | ismember(fn, 'cutoff_high')) % has the required fields
		if ischar(val.name) && isnumeric(val.cutoff_low) && isnumeric(val.cutoff_high) % fields of correct type
			if val.cutoff_low >= 0 && val.cutoff_high > val.cutoff_low + 1 % values make sense
				I = true;
			end
		end
	end
end

if ~I
	error('Invalid freq band definition');
end