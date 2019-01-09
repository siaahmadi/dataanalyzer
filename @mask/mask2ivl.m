function ivl = mask2ivl(obj)

ivl = cellfun(@toIvl, {obj.tEffectiveIvls}, 'un', 0);
ivl = cat(1, ivl{:});