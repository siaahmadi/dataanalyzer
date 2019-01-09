function lblSeq = fillSeqHole(lblSeq)
idx = strcmpi(lblSeq, '');
idx(1) = false; idx(end) = false; % for the first and last indices we can never be sure what the previous location of the animal has been (unless we look at the videoData)

for i = find(idx(:)')
	lblSeq{i} = ['N', setdiff(intersect(lblSeq{i-1}, lblSeq{i+1}), 'A')];
end