function Robot_Move_Rectangular(X_axis, Y_axis, Z_axis, Tool, speed)
%Modified by Y.W. Chen Sep. 7th, 2016
%%
%Header part/ Straight increment value operation
Head = [89 69 82 67 32 00 104 00 03 01 00 00 00 00 00 00 57 57 57 57 57 57 57 57]; 
%Sub-header part
Suh = [138 00 03 00 01 02 00 00];   
% Setting of Speed to 0.1 mm/s and cartesian Robot coordinate(17)
Setting = typecast(int32([1 0 1 speed*10 17]),'uint8');    

Tx       =   typecast(int32(0),'uint8');                %in unit of 10^-4
Ty       =   typecast(int32(0),'uint8'); 
Tz       =   typecast(int32(0),'uint8');

Reserv  =   typecast(int32(0),'uint8');
Type    =   Tool(5:8);
Ex      =   typecast(int32(0),'uint8');
ToolNo  =   Tool(1:4);
Coor    =   typecast(int32(1),'uint8');
Ext     =   typecast(int32([0 0 0 0 0 0 0 0 0 0]),'uint8');

%%
%Read the original coordinate values in Tool
[X, Y, Z] = Robot_ReadRect(Tool);
if X == 9999 && Y == 9999 && Z == 9999
    fprintf('\nThe Error occur when read angle! Please check the error manually.\n');
    return;
else
    %Know the difference
    X_diff = (X_axis - X)*1000;     %in unit of mm
    Y_diff = (Y_axis - Y)*1000;     %in unit of mm
    Z_diff = (Z_axis - Z)*1000;     %in unit of mm

    %Transform the data to u-int8
    Xpluse = typecast(X_diff,'uint8');
    Ypluse = typecast(Y_diff,'uint8');
    Zpluse = typecast(Z_diff,'uint8');

    %Generate the command and send it to Robot
    Axis    = [Xpluse, Ypluse, Zpluse, Tx, Ty, Tz];
    Command = [Head,Suh,Setting,Axis, Reserv, Type, Ex, ToolNo, Coor, Ext];
    Robot_Hold(2);                      %Hold OFF
    Robot_Servo(1);
    robot=UDPNode('192.168.2.250',10040, 2000);
    response = robot.submit(Command);
    %Debug part
    if isempty(response) 
        fprintf('\nYou should check your connection with robot or contact the mechanics or YW Chen.\nError on Robot_Move_Rectangular()\n');
    else
        Uint32_result = typecast(response,'uint32');
        if  Uint32_result(8) == 0   ||  Uint32_result(8) == 8208      % 0 or 0x2010
            pause(0.01);
            a = Robot_Alarm(1);
            if a ~= 0
                fprintf('There are some Alarms.\n');
                Robot_Servo(2);
            end
        elseif Uint32_result(8) == 8320         %(0x2080) in hex
            Robot_Hold(1);                      %Robot Hold ON
            fprintf('\nIncorrect mode, please change to "Remote Mode."\n\n');
        elseif Uint32_result(8) == 8304         %(0x2070) in hex
            Robot_Hold(1);                      %Robot Hold ON
            fprintf('\nServo OFF, Please try to turn on the servo.\n');   
        elseif Uint32_result(8) == 45070         %(0xB00E) in hex
            Robot_Hold(1);                      %Robot Hold ON
            fprintf('\nThe User No. setting error.\n'); 
        else
            fprintf('\nNot recorded Error, Unsuccessfully move the robot, please check.');
            Robot_Hold(1);                      %Robot Hold ON
        end
    end
end
end