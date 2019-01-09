function [velocity speed] = getVelocity(x0,y0,t0)
[t,~,~,vx,vy,ax,ay] = trajectory_kalman_filter(x0,y0,t0,1);
%instantaneous velocity
velocity{ii,kk} = [t' sqrt(vx.*vx + vy.*vy)];
%mean velocity
speed(ii,kk) = mean(velocity{ii,kk}(:,2));
disp('speed'); disp(speed);