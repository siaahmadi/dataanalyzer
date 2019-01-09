function fcn = adjustpathbatch_makeMazeResizeFcn(hFig)
fcn = @resizemaze;
    function resizemaze(pos)
        h = getappdata(hFig,'handles');        
        maze = fig8maze(pos(3),pos(4));
        cla(h.tempAxes);
        hold(h.tempAxes,'on');
        plot(h.tempAxes,maze.whole.locs(:,1)+pos(1),maze.whole.locs(:,2)+pos(2));
        hold(h.tempAxes,'off');
        set(h.xText,'String',num2str(pos(1)));
        set(h.yText,'String',num2str(pos(2)));
        set(h.widthText,'String',num2str(pos(3)));
        set(h.heightText,'String',num2str(pos(4)));
        adjustpathbatch_updateadj(hFig);
    end
end