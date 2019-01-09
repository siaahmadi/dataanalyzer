function ttpos = loadttpos(ttposdb)

% ttposdb = 'V:\Sia\PhD\LabProjects\phasePrecessionTakuya\MetaFiles\ttCA3_MEClesion.txt'; % temporary

ttpos = readtable(ttposdb, 'Delimiter', '\t');