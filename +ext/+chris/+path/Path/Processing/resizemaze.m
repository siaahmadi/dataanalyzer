function resizemaze(pos)
% stretch figure-8 maze from right
%
% assumes maze origin (bottom left) at (0, 0)
%
% @cmtAuthor: Sia @date 9/15/15 12:57 PM

maze = fig8maze(pos(3),pos(4));
parts = fields(maze);
hold on;
for p = 1:length(parts)
    plot(maze.(parts{p})(:,1)+pos(1),maze.(parts{p})(:,2)+pos(2));
end
hold off;