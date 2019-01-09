function maskNames = p___extractMaskNames(varargin)
%P___EXTRACTMASKNAMES validates strings, returns empty, char array, or cell
%strings
% If input is not skipped and is anything but strings terminates with error

if nargin == 1 && iscellstr(varargin{1})
	maskNames = varargin{1};
elseif iscellstr(varargin)
	maskNames = varargin;
elseif nargin == 0
	maskNames = '';
else
	error('Input not valid mask names.');
end