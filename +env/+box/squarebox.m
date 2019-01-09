function box = squarebox(len)

if ~exist('len', 'var') || isempty(len)
	len = 100; % cm
end

box_base = [0 0; 0 1; 1 1; 1 0; 0 0];

% Scale the box
box = box_base .* len;

% Center the box
box = box - repmat(mean([min(box); max(box)]), size(box, 1), 1);