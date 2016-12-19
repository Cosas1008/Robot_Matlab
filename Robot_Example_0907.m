%%
%Modified by Y.W. Chen Sep. 7th, 2016
%Initialize
%***********************IMPORTANT**************************%
%This function will executed once and for all position you are about to use
Tool = Robot_ReadPosition();     %Set the original position as X, Y ,Z all = 0
[X, Y, Z] = Robot_ReadRect(Tool);
if X ==9999 && Y ==9999 && Z ==9999 
    fprintf('\n You do not get the Tool Position.\n');
else
    fprintf('Now the position set to \nX= %d\nY= %d\nZ= %d.\n',X,Y,Z);
end
[pitch, yaw] = Robot_ReadAngle();
if pitch == 9999 && yaw == 9999
    fprintf('\nYou do not get the pitch and yaw values.\n');
else
    fprintf('\nNow the angular position set to pitch = %d\nyaw = %d\n',pitch,yaw);
end
%%
%Correlation
speed = 100;         %Speed in unit of 1 mm/s / 1 degree/s
Robot_Move(Tool,speed);
%%
%Move X, Y and Z 

X = 150;               %in unit of 1 mm %move forward
Y = 100;               %in unit of 1 mm %move left
Z = 100;               %in unit of 1 mm $move up
speed = 100;             %in unit of 1 mm/s

Robot_Move_Rectangular(X,Y,Z,Tool,speed);

%%
%Reset position
Robot_Move(Tool,10);        %Speed in unit of 1 mm/s / 1 degree/s
%%
%Move X,Y,Z, pitch and yaw at the same time

X = 0;              %in unit of 1 mm
Y = 0;              %in unit of 1 mm
Z = 0;              %in unit of 1 mm
pitch = 0;          %in unit of 0.01 degree 
yaw = 0;            %in unit of 0.01 degree 
speed = 10;         %in unit of 1 mm/s 1 degree/s
Robot_Move_Compound(X,Y,Z,pitch,yaw,Tool,speed);
%%
%Loop Example one
%Move X,Y,Z, pitch and yaw at the same time

%Initialize all the value
X = 0;              %in unit of 1 mm
Y = 0;              %in unit of 1 mm
Z = 0;              %in unit of 1 mm
pitch = 0;          %in unit of 0.01 degree 
yaw = 0;            %in unit of 0.01 degree 
speed = 10;         %in unit of 1 mm/s 1 degree/s
% Robot current position
[Xread, Yread, Zread, Pitchread, Yawread] = Robot_Read(Tool);

for i = 1: 2
    switch i
        case 1
            X = 100;              %in unit of 1 mm
            Y = 100;              %in unit of 1 mm
            Z = 100;              %in unit of 1 mm
        case 2
            X = -100;              %in unit of 1 mm
            Y = -100;              %in unit of 1 mm
            Z = -100;              %in unit of 1 mm
    end
    loopcnt = 0;                   %initial the count
    Robot_Move_Rectangular(X, Y, Z, Tool, speed);
    while (abs(X)-abs(Xread)) >= 1 && (abs(Y)-abs(Yread)) >= 1 && (abs(Z)-abs(Zread)) >= 1 
        [Xread, Yread, Zread] = Robot_ReadRect(Tool);
        loopcnt = loopcnt + 1;     %Count the loop
        pause(loopcnt * 0.01);
    end
    disp(['Read ' num2str(loopcnt) ' times.']);
end
        
