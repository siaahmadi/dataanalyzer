function ivls = mask2ivlset(obj)
%MASK2IVLSET Return the ivlset object of the mask
%
% ivls = MASK2IVLSET(obj)

ivls = ivlset(obj.mask2ivl);