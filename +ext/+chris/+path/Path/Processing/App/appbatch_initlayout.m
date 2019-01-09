function appbatch_initlayout(src,~)
mainVBox = uiextras.VBox('Parent',src);
instructTxt = uicontrol('Parent',mainVBox,'style','text',...
    'String', 'Select sessions for which you would like to apply adjustments...');
tableHBox = uiextras.HBox('Parent',mainVBox);
uiextras.Empty('Parent',tableHBox);
h.appTable = appbatch_inittable(tableHBox);
uiextras.Empty('Parent',tableHBox);
btnBox = uiextras.HButtonBox('Parent',mainVBox);
h.okayBtn = uicontrol('Parent',btnBox,'Tag','okay','Style','pushbutton','String','Okay','Callback',{@appbatch_btnCallback,src});
h.quitBtn = uicontrol('Parent',btnBox,'Tag','quit','Style','pushbutton','String','Quit','Callback',{@appbatch_btnCallback,src});
set(mainVBox,'Sizes',[25 500 50]);
set(tableHBox,'Sizes',[-1 680 -1]);
setappdata(src,'handles',h);