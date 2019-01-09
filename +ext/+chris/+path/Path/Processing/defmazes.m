function mazes = defmazes()
mazes = struct([]);
i = 0;

i = i+1;
mazes(i).name = 'Figure 8';
mazes(i).type = 'fig8';
mazes(i).w = (40+5/8)*2.54;
mazes(i).h = (5*12)*2.54;

i = i+1;
mazes(i).name = 'Square100';
mazes(i).type = 'square';
mazes(i).w = 100;
mazes(i).h = 100;

i = i+1;
mazes(i).name = 'Square80';
mazes(i).type = 'square';
mazes(i).w = 80;
mazes(i).h = 80;

i = i+1;
mazes(i).name = 'Circle100';
mazes(i).type = 'circle';
mazes(i).w = 100;
mazes(i).h = 100;

i = i+1;
mazes(i).name = 'Circle80';
mazes(i).type = 'circle';
mazes(i).w = 80;
mazes(i).h = 80;
