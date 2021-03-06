%% Use adjustpath
function [indata,used_parameters] = processPositionData(original_indata,id,squares,circles,target)

n_sessions = length(original_indata);
%rotationDegree = 0;
switch id
    case 'squarecircle' %one room, rotation corrections enabled, allows for more than one segment
        % Set shape
        % 1st value specifies whether the environment is a square or circle shaped box. 1 = square, 2 = circle
        % 2nd value sets the side length of the square box in cm or the diameter of the circle in cm.
        [indata used_parameters] = adjust_coordinates(original_indata,squares,[1:n_sessions],target,0,1);
        
    case 'squarecircle_shift' %one room, rotation corrections enabled, allows for more than one segment
        % Set shape
        % 1st value specifies whether the environment is a square or circle shaped box. 1 = square, 2 = circle
        % 2nd value sets the side length of the square box in cm or the diameter of the circle in cm.
        [indata used_parameters] = adjust_coordinates(original_indata,squares,[1:n_sessions],target,0,1);
        [indata used_parameters] = adjust_coordinates(indata,circles,[circles 6],0,0,0); %setting target to 0 omits scaling; no forced rotation; rotation correction off
        
    case 'ampmsquarecircle' %one room, rotation corrections enabled, allows for more than one segment
        % Set shape
        % 1st value specifies whether the environment is a square or circle shaped box. 1 = square, 2 = circle
        % 2nd value sets the side length of the square box in cm or the
        % diameter of the circle in cm.
        [indata used_parameters] = adjust_coordinates(original_indata,squares,[1:n_sessions],target,0,1);
        
    case 'all_circles' %one room, rotation corrections disabled, allows for more than one segment
        
        [indata used_parameters] = adjust_coordinates(original_indata,squares,[1:n_sessions],target,0,0);
        
    case 'all_squares' %one room, rotation corrections enabled, allows for more than one segment
        [indata used_parameters] = adjust_coordinates(original_indata,squares,[1:n_sessions],target,0,1);
    case 'trackAdaptive'
        useAdaptiveBounds = 1;
        [indata used_parameters] = adjust_coordinates_LT(original_indata,useAdaptiveBounds,target,100);
    case 'track80'
    useAdaptiveBounds = 0;
    [indata used_parameters] = adjust_coordinates_LT(original_indata,useAdaptiveBounds,target,100*80/target);
    otherwise
        disp('case not defined');
        return
end % end switch
