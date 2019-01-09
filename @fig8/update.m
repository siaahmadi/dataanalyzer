function obj = update(obj)

anc_sess = dataanalyzer.ancestor(obj, 'expSession');

options = dataanalyzer.options(anc_sess.projectname);


x = obj.getX('restr');
y = obj.getY('restr');
t = obj.getTS('restr');
% [t, x, y, beginsGlobalIdx, trNameStrings] = p___restrictToBegins(dataanalyzer.ancestor(obj).NlxEvents, t, x, y);
% options.trNameStrings = {anc_sess.trialDirs.name}';

obj.loadParsedData();