function h=keypressdemo

h.fig = figure ;

%// set up the timer
h.t = timer ;
h.t.Period = 1 ;
h.t.ExecutionMode = 'fixedRate' ;
h.t.TimerFcn = @timer_calback ;

%// set up the Key functions
set( h.fig , 'keyPressFcn'   , @keyPressFcn_calback ) ;
set( h.fig , 'keyReleaseFcn' , @keyReleaseFcn_calback ) ;

guidata( h.fig ,h)

function timer_calback(~,~)
    disp( rand(1) )

function keyPressFcn_calback(hobj,evt)
    if strcmp(evt.Key,'f')
        h = guidata(hobj) ;
        %// necessary to check if the timer is already running
        %// otherwise the automatic key repetition tries to start
        %// the timer multiple time, which produces an error
        if strcmp(h.t.Running,'off')
            start(h.t)
        end
    end

function keyReleaseFcn_calback(hobj,evt)
    if strcmp(evt.Key,'f')
        h = guidata(hobj) ;
        stop(h.t)
    end
