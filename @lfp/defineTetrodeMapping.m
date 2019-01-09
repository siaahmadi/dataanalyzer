function defineTetrodeMapping(obj, mapping)
%DEFINETETRODEMAPPING Add table definition of tetrode mapping to lfp object
%
%	Useful for providing a reference tetrode for phase calculations
%	involving theta where tetrode with a very high power in the theta band
%	is desired.
%
%
% INPUT
%
% mapping
%	A 2xN or Nx2 matrix of the mappings. At each call of DEFINETETRODEMAPPING
%	no redefition of tetrodes is allowed. At subsequent calls, redefining a
%	previously defined mapping will overwrite the old definition.
%
%	A sparse matrix, ttMapping, in the object will carry the definitions.
%	As such, tetrode numbers can range from 1 to intmax (given by MATLAB's
%	builtin @intmax function). However, a total of 1024 (as of 12/09/2015)
%	tetrodes may be stored (this can be redefined in dataanalyzer's
%	constants database).

% Siavash Ahmadi
% 12/09/2015 9:21 PM

MAXTT = dataanalyzer.constant('lfp_MAXTT');


if ~size(mapping, 1) == 2 && ~size(mapping, 2) == 2
	error('Not defined yet for mapping definitions other than a matrix of size 2xN or Nx2.');
end

if size(mapping, 2) ~= 2 % not vertical
	mapping = mapping';
end

if size(mapping, 1) > MAXTT
	error('Cannot store more than %d mappings.', MAXTT);
end

if any(mod(mapping(:), 1)~=0)
	error('All mappings must be between positive integers.');
end

if any(mapping(:) < 1)
	error('No tetrode shall be called 0. Any other positive integer is allowed.');
end

[isValidMapping, repeatedTT, whichLines] = validateMapping(mapping);

if ~isValidMapping
	error('\nRedefining a mapping is not allowed. Tetrode %d has been mapped at least twice at rows %d and %d.\n', repeatedTT, whichLines)
end

mappingSp = sparse(mapping(:, 1), 1, mapping(:, 2), double(intmax), 1, MAXTT); % nzmax == 2^10 --> can store up to 1024 tetrodes max (realistically, though, this should be more in the ballpark of 2^4.)

if isempty(obj.ttMapping) % first time defintion (I could define this in @lfp class defition but I'd have to supply a MAXTT without being able to call @dataanalyzer.constant--maybe in constructor?)
	obj.ttMapping = mappingSp;
	return;
end


[~, alreadyDefined] = ismember(find(obj.ttMapping~=0), find(mappingSp));

% overwrite the definition:
obj.ttMapping(alreadyDefined) = 0;
obj.ttMapping = obj.ttMapping + mappingSp; % I have to do it this way to be able to preserve and enforce the MAXTT limit (MATLAB reallocates memory for C if C = a + b)



function [isValidMapping, repeatedTT, whichLines] = validateMapping(mapping)

[unq, ia] = unique(mapping(:, 1));

repeatedItemsIdx = setdiff(1:size(mapping, 1), ia);
if isempty(repeatedItemsIdx)
	isValidMapping = length(unq) == size(mapping, 1);
	repeatedTT = [];
	whichLines = [];
	return;
end
firstTime = find(mapping(:, 1) == mapping(repeatedItemsIdx, 1), 1);
whichLines = [firstTime, repeatedItemsIdx];
repeatedTT = mapping(repeatedItemsIdx);

isValidMapping = length(unq) == size(mapping, 1);