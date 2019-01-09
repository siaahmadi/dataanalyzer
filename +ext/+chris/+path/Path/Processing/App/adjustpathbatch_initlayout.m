function adjustpathbatch_initlayout(src,~)
h.fileMenu = uimenu('Parent',src,'Label','File');
h.saveFile = uimenu('Parent',h.fileMenu,'Tag','save','Label','Save','Accelerator','S','Callback',{@adjustpathbatch_saveMenu,src});
h.saveFileAs = uimenu('Parent',h.fileMenu,'Tag','saveas','Label','Save as...','Callback',{@adjustpathbatch_saveMenu,src});
h.applyAdj = uimenu('Parent',h.fileMenu,'Label','Apply adjustments...','Separator','on','Callback',{@adjustpathbatch_applyAdj,src});
h.quit = uimenu('Parent',h.fileMenu,'Label','Quit','Separator','on','Accelerator','Q','Callback',{@adjustpathbatch_quitMenu,src});

mainVBox = uiextras.VBox('Parent',src);


dispHBox = uiextras.HBox('Parent',mainVBox);
dispPanel = uiextras.Panel('Parent',dispHBox);
h.pathAxes = axes('Parent',dispPanel,'Position',[0 0 1 1],'Color',[1 1 1],'NextPlot','replaceChildren','XLimMode','manual','YLimMode','manual');
h.tempAxes = axes('Parent',dispPanel,'Position',[0 0 1 1],'Color','none','NextPlot','replaceChildren','XLimMode','manual','YLimMode','manual');
h.ctrlAxes = axes('Parent',dispPanel,'Position',[0 0 1 1],'Color','none','NextPlot','replaceChildren','XLimMode','manual','YLimMode','manual');
sideVBox = uiextras.VBox('Parent',dispHBox);
h.pathPanel = uiextras.BoxPanel('Parent',sideVBox,'Title','Paths');

% Adjustment panel
h.adjBoxPanel = uiextras.BoxPanel('Parent',sideVBox,'Title','Adjustments');
adjVBox = uiextras.VBox('Parent',h.adjBoxPanel,'Padding',5,'Spacing',2);
adjHeadHBox = uiextras.HBox('Parent',adjVBox);
locHBox = uiextras.HBox('Parent',adjHeadHBox,'Spacing',3);
h.sessText = uicontrol('Parent',locHBox,'style','text','String','Session: ','FontSize',8,'HorizontalAlignment','left');
h.sessMenu = uicontrol('Parent',locHBox,'style','popupmenu','String','-','BackgroundColor',[1 1 1],'Callback',{@adjustpathbatch_sessMenu,src});
h.prevSetBtn = uicontrol('Parent',locHBox,'Tag','prev','style','pushbutton','String','<','Callback',{@adjustpathbatch_nextPrevBtn,src});
h.nextSetBtn = uicontrol('Parent',locHBox,'Tag','next','style','pushbutton','String','>','Callback',{@adjustpathbatch_nextPrevBtn,src});
% refHBox = uiextras.HBox('Parent',adjHeadHBox);
% h.refText = uicontrol('Parent',refHBox,'style','text','String','Reference: ','FontSize',9,'HorizontalAlignment','left');
% h.refMenu = uicontrol('Parent',refHBox,'style','popupmenu','String','-','BackgroundColor',[1 1 1]);
set(locHBox,'Sizes',[60 60 20 20]);
% set(refHBox,'Sizes',[70 100]);
set(adjHeadHBox,'Sizes',[140]); % -1])

adjPanel = uiextras.Panel('Parent',adjVBox);
adjPanelVBox = uiextras.VBox('Parent',adjPanel,'Padding',10);
adjSetHBox = uiextras.HBox('Parent',adjPanelVBox,'Spacing',3);
h.adjSetText = uicontrol('Parent',adjSetHBox,'style','text','String', 'Adjustment','HorizontalAlignment','left');
h.adjSetMenu = uicontrol('Parent',adjSetHBox,'style','popupmenu','String',{'Custom'},'BackgroundColor',[1 1 1]);
h.adjSetBBox = uiextras.HButtonBox('Parent',adjSetHBox,'VerticalAlignment','top','HorizontalAlignment','center','Spacing',3);
h.adjSavePreset = uicontrol('Parent',h.adjSetBBox,'style','pushbutton','String','Save preset...');

adjSetVBox = uiextras.VBox('Parent',adjPanelVBox,'Padding',5,'Spacing',5);

rotHBox = uiextras.HBox('Parent',adjSetVBox,'Padding',0);
h.rotLabel = uicontrol('Parent',rotHBox,'style','text','String', 'Rotation (degrees)','HorizontalAlignment','left');
h.rotText = uicontrol('Parent',rotHBox,'style','edit','String','0','Enable','inactive','BackgroundColor',[1 1 1]);
h.rotCCW = uicontrol('Parent',rotHBox,'Tag','rotCCW','style','pushbutton','String','<','Callback',{@adjustpathbatch_rotate,src});
h.rotCW = uicontrol('Parent',rotHBox,'Tag','rowCW','style','pushbutton','String','>','Callback',{@adjustpathbatch_rotate,src});
set(rotHBox,'Sizes',[105 40 20 20]);

h.adjTablePanel = uiextras.Panel('Parent',adjSetVBox,'BorderType','none');
set(adjSetVBox,'Sizes',[22 -1]);


set(h.adjSetBBox,'ButtonSize',[90 25]);
set(adjSetHBox,'Sizes',[60 -1 90]);
set(adjPanelVBox,'Sizes',[30 -1]);

adjBBox = uiextras.HButtonBox('Parent',adjVBox,'HorizontalAlignment','right','VerticalAlignment','middle');
h.adjSaveBtn = uicontrol('Parent',adjBBox,'style','pushbutton','String','Save','Callback',{@adjustpathbatch_saveadjBtn,src});
h.adjRevertBtn = uicontrol('Parent',adjBBox,'style','pushbutton','String','Revert','Callback',{@adjustpathbatch_revertadjBtn,src});
set(adjBBox,'ButtonSize',[55 25]);

set(adjVBox,'Sizes',[25 -1 25]);

% Selection panel
selBoxPanel = uiextras.BoxPanel('Parent',sideVBox,'Title','Selection');
h.selGrid = uiextras.Grid('Parent',selBoxPanel,'Spacing',10,'Padding',5);
gEmpty = uiextras.Empty('Parent',h.selGrid);
gEmpty = uiextras.Empty('Parent',h.selGrid);
h.xLabel = uicontrol('Parent',h.selGrid,'style','text','String', 'x','HorizontalAlignment','left');
h.yLabel = uicontrol('Parent',h.selGrid,'style','text','String', 'y','HorizontalAlignment','left');
xCenterHBox = uiextras.HBox('Parent',h.selGrid,'Spacing',2);
h.xText = uicontrol('Parent',xCenterHBox,'style','edit','String','','HorizontalAlignment','right','BackgroundColor',[1 1 1]);
h.xCenterMinus = uicontrol('Parent',xCenterHBox,'style','pushbutton','String','-');
h.xCenterPlus = uicontrol('Parent',xCenterHBox,'style','pushbutton','String','+');
set(xCenterHBox,'Sizes',[-1 20 20]);
yCenterHBox = uiextras.HBox('Parent',h.selGrid,'Spacing',2);
h.yText = uicontrol('Parent',yCenterHBox,'style','edit','String','','HorizontalAlignment','right','BackgroundColor',[1 1 1]);
h.yCenterMinus = uicontrol('Parent',yCenterHBox,'style','pushbutton','String','-');
h.yCenterPlus = uicontrol('Parent',yCenterHBox,'style','pushbutton','String','+');
set(yCenterHBox,'Sizes',[-1 20 20]);
gEmpty = uiextras.Empty('Parent',h.selGrid);
gEmpty = uiextras.Empty('Parent',h.selGrid);
h.widthLabel = uicontrol('Parent',h.selGrid,'style','text','String', 'Width','HorizontalAlignment','left');
h.heightLabel = uicontrol('Parent',h.selGrid,'style','text','String', 'Height','HorizontalAlignment','left');

widthHBox = uiextras.HBox('Parent',h.selGrid,'Spacing',2);
h.widthText = uicontrol('Parent',widthHBox,'style','edit','String','','HorizontalAlignment','right','BackgroundColor',[1 1 1]);
h.widthMinus = uicontrol('Parent',widthHBox,'style','pushbutton','String','-');
h.widthPlus = uicontrol('Parent',widthHBox,'style','pushbutton','String','+');
set(widthHBox,'Sizes',[-1 20 20]);

heightHBox = uiextras.HBox('Parent',h.selGrid,'Spacing',2);
h.heightText = uicontrol('Parent',heightHBox,'style','edit','String','','HorizontalAlignment','right','BackgroundColor',[1 1 1]);
h.heightMinus = uicontrol('Parent',heightHBox,'style','pushbutton','String','-');
h.heightPlus = uicontrol('Parent',heightHBox,'style','pushbutton','String','+');
set(heightHBox,'Sizes',[-1 20 20]);
set(h.selGrid,'ColumnSizes',[15 10 95 15 30 95],'RowSizes',22*[1 1]);

set(locHBox,'Sizes',[65 60 25 25]);
set(h.adjSetBBox,'ButtonSize',[90 25]);
set(adjSetHBox,'Sizes',[60 -1 90]);
set(adjPanelVBox,'Sizes',[30 85]);

set(sideVBox,'Sizes',[-1 225 85]);

set(dispHBox,'Sizes',[-1 370]);

% setHBox = uiextras.HBox('Parent',mainVBox,'Padding',5);
% uiextras.Empty('Parent',setHBox);
% nextPrevPanel = uiextras.Panel('Parent',setHBox,'BorderType','line','Title','Session','ShadowColor',[0 0 0],'TitlePosition','centertop');
% nextPrevHBox = uiextras.HBox('Parent',nextPrevPanel,'Spacing',3,'Padding',3);
% h.prevSetBtn = uicontrol('Parent',nextPrevHBox,'Tag','prev','style','pushbutton','String','Prev','Callback',{@adjustpathbatch_nextPrevBtn,src});
% h.sessMenu = uicontrol('Parent',nextPrevHBox,'style','popupmenu','String','-','BackgroundColor',[1 1 1]);
% h.nextSetBtn = uicontrol('Parent',nextPrevHBox,'Tag','next','style','pushbutton','String','Next','Callback',{@adjustpathbatch_nextPrevBtn,src});
% uiextras.Empty('Parent',setHBox);
% set(nextPrevHBox,'Sizes',[-1 50 -1]);
% set(setHBox,'Sizes',[-1 150 -1]);

set(mainVBox,'Sizes',[-1]);
% 
setappdata(src,'handles',h);

