function videoTS = getTS(obj, varargin)
%GETTS Return time stamps of position data
%
% USAGE:
%	videoTS = getTS()
%		Return the runs due to the current mask array.
%
%		Output videoTS will be a cell array of the same length as the number
%		of masks in the mask array. Each entry of videoTS will be determined
%		as follows:
%			+ a cell array
%				- if the corresponding mask consists of more than one run
%			+ or an array of doubles 
%				- if the corresponding mask consists of a single run
%
%	videoTS = getTS(idx)
%		Return the runs due to the mask array at mask indices specified
%		by |idx|.
%
%	videoTS = getTS(standaloneMask)
%		Return the cell array of runs due to |standaloneMask|.
%		
%	videoTS = getTS(restriction)
%		|restriction| can take on case-insenstive values specified in the
%		static field |validRestriction| of class |dataanalyzer.positiondata|.
%		These include 'restricted', 'unrestricted', 'restr', or 'unrestr'.
%
%		If a masked version is requested (DEFAULT), results will be the
%		same as calling getTS() with no arguments.
%		
%		If an unmasked version is requested, the output will contain
%		the entire time stamp array of position data.
%		
%	videoTS = getTS(idx, restriction)
%		If an unmasked version is requested, |idx| will be applied to the
%		entire time stamp array.
%
%		If a masked versions is requested, |idx| will be applied to the
%		mask array.

% Siavash Ahmadi
% 12/11/2015
% Modified 11/4/2015
% Modified 11/19/2015	Changing pd-level mask to trial-level mask
% TODO: implement maskarray instead of mask

videoTS = obj.getTrackingData('timeStamps', varargin{:});