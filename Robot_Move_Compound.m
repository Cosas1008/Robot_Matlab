function Robot_Move_Compound(X,Y,Z,phi_in,theta_in,Tool,speed)
%Modified by Y.W. Chen Sep. 7th, 2016
%%
%Parameters
%Header part 
Head = [89 69 82 67 32 00 104 00 03 01 00 00 00 00 00 00 57 57 57 57 57 57 57 57]; 
%Sub-header part
Suh = [138 00 03 00 01 02 00 00];
%Setting( Speed Coordinate)
Setting_rect = typecast(int32([1 0 1 speed*10 17]),'uint8');  
% Setting of Speed to 1 mm/s and cartesian Robot coordinate(17)
Setting_ang  = typecast(int32([1 0 2 speed*10 19]),'uint8');   
% Setting of Speed to 1 degree/s and cartesian Tool coordinate(19)
% Tool(Tool_no Form X Y Z Xr Yr Zr)
Reserv  =   typecast(int32(0),'uint8');
ToolNo  =   Tool(1:4);
Type    =   Tool(5:8);
Ex      =   typecast(int32(0),'uint8');
Coor    =   typecast(int32(1),'uint8');
Ext     =   typecast(int32([0 0 0 0 0 0 0 0 0 0]),'uint8');
%%
%Check whether there are placement first
%if there are changes in placement, the function will stop after change the
%placement rather than move angular, you would have to call the function
%again
if X ~=0 || Y ~=0 || Z ~=0
    %Move to the place first    
    [X_pre, Y_pre, Z_pre] = Robot_ReadRect(Tool);
    if X_pre == 9999 && Y_pre == 9999 && Z_pre == 9999
        fprintf('\nThe Error occur when read angle! Please check the error manually.\n');
        return;         %break the function here
    else
        %Know the difference / placement in unit of 1 mm
        X_diff = (X_axis - X)*1000;     %in unit of 1 mm
        Y_diff = (Y_axis - Y)*1000;     %in unit of 1 mm
        Z_diff = (Z_axis - Z)*1000;     %in unit of 1 mm
        
        %Transform the data to u-int8
        Xpluse = typecast(X_diff,'uint8');
        Ypluse = typecast(Y_diff,'uint8');
        Zpluse = typecast(Z_diff,'uint8');

        %Generate the command and send it to Robot
        Axis    = [Xpluse, Ypluse, Zpluse, 0,0,0];
        Command = [Head, Suh, Setting_rect,Axis, Reserv, Type, Ex, ToolNo, Coor, Ext];
        Robot_Hold(2);                      %Hold OFF
        Robot_Servo(1);
        robot=UDPNode('192.168.2.250',10040, 2000);
        response = robot.submit(Command);
    end
    %Debug part
    if isempty(response) 
        fprintf('\nYou should check your connection with robot or contact the mechanics or YW Chen.\nError on Robot_Move_Compound(X,Y,Z,phi_in,theta_in,Tool,speed).\n');
        return;
    else
        Uint32_result = typecast(response,'uint32');
        if  Uint32_result(8) == 0   ||  Uint32_result(8) == 8208      %0 or 0x2010
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
%     %*************************IMPORTANT************************%
%     return;         %break the function here
end

%Move angular
[pitch_read, yaw_read] = Robot_ReadAngle();%get data in unit of 0.01 degree
if pitch_read == 9999 && yaw_read == 9999
    fprintf('The Error occur when read angle! Please check the error manually.');
    return;         %break the function here
else
    %Difference between the original and assigned values
    diff_phi = phi_in - pitch_read;                                     %pitch    
    diff_theta = theta_in - yaw_read;                                   %yaw
    if abs(diff_theta) > 100
        %Pitch set to 0
        loopcnt = 0;                                            %Reset the count
        while (abs(pitch_read) >= 100)
            loopcnt = loopcnt + 1;
            [pitch_read, yaw_read] = Robot_ReadAngle();%get data in unit of 0.01 degree
            if pitch_read == 9999 && yaw_read == 9999 || loopcnt  > 100             %Loop count more than 100
                 if loopcnt > 100
                     fprintf('The Loop is over 100 cycle.');
                 else
                     fprintf('The Error occur when read angle! Please check the error manually.');
                 end
                 return;         %break the function here
            else
                Robot_Hold(2);                                          %Hold OFF
                diff_phi = phi_in - pitch_read;                         %pitch    
                diff_theta = theta_in - yaw_read;                       %yaw
                Tx     = typecast(int32(0),'uint8');                    %yaw     
                Ty     = typecast(int32(-pitch_read*100),'uint8');      %pitch
                Axis    = [0,0,0,Tx,Ty,0];
                Command = [Head,Suh,Setting_ang,Axis, Reserv, Type, Ex, ToolNo, Coor, Ext];
                robot=UDPNode('192.168.2.250',10040, 500);
                robot.submit(Command);
                pause(abs(pitch_read/100)/speed+0.02);
            end
        end
        %Yaw set to assigned value
        loopcnt = 0;                                            %Reset the count
        while (abs(diff_theta) > 100)
            loopcnt = loopcnt + 1;
            [pitch_read, yaw_read] = Robot_ReadAngle();%get data in unit of 0.01 degree
            if pitch_read == 9999 && yaw_read == 9999 || loopcnt  > 100             %Loop count more than 100
                 if loopcnt > 100
                     fprintf('The Loop is over 100 cycle.');
                 else
                     fprintf('The Error occur when read angle! Please check the error manually.');
                 end
                 return;         %break the function here
            else
                Robot_Hold(2); 
                diff_phi = phi_in - pitch_read;                         %pitch    
                diff_theta = theta_in - yaw_read;                       %yaw
                Tx     = typecast(int32(diff_theta*100),'uint8');       %yaw
                Ty     = typecast(int32(0),'uint8');                    %pitch
                Axis    = [0,0,0,Tx,Ty,0];
                Command = [Head,Suh,Setting_ang,Axis, Reserv, Type, Ex, ToolNo, Coor, Ext];
                robot=UDPNode('192.168.2.250',10040, 500);
                robot.submit(Command);
                pause(abs(diff_theta/100)/speed+0.02);
            end
        end
        %Pitch set to assigned value
        loopcnt = 0;                                            %Reset the count
        while (abs(diff_phi) > 100)
            loopcnt = loopcnt + 1;
            [pitch_read, yaw_read] = Robot_ReadAngle();%get data in unit of 0.01 degree
            if pitch_read == 9999 && yaw_read == 9999 || loopcnt  > 100             %Loop count more than 100
                 if loopcnt > 100
                     fprintf('The Loop is over 100 cycle.');
                 else
                     fprintf('The Error occur when read angle! Please check the error manually.');
                 end
                 return;         %break the function here
            else
                Robot_Hold(2); 
                diff_phi = phi_in - pitch_read;                         %pitch    
                diff_theta = theta_in - yaw_read;                       %yaw
                Tx     = typecast(int32(0),'uint8');                    %yaw
                Ty     = typecast(int32(diff_phi*100),'uint8');         %pitch
                Axis    = [0,0,0,Tx,Ty,0];
                Command = [Head,Suh,Setting_ang,Axis, Reserv, Type, Ex, ToolNo, Coor, Ext];
                robot=UDPNode('192.168.2.250',10040, 500);
                robot.submit(Command);
                pause(abs(diff_phi/100)/speed+0.02);
            end
        end
        Tx     = typecast(int32(diff_theta*100),'uint8');                    %yaw
        Ty     = typecast(int32(diff_phi*100),'uint8');             %pitch
        Axis    = [0,0,0,Tx,Ty,0];
        Command = [Head,Suh,Setting_ang,Axis, Reserv, Type, Ex, ToolNo, Coor, Ext];
        robot=UDPNode('192.168.2.250',10040, 500);
        response = robot.submit(Command);
    else
        %Pitch set to assigned value directly
        loopcnt = 0;                                            %Reset the count
        while (abs(diff_phi) > 100)
            loopcnt = loopcnt + 1;
            [pitch_read, yaw_read] = Robot_ReadAngle();%get data in unit of 0.01 degree
            if pitch_read == 9999 && yaw_read == 9999 || loopcnt  > 100             %Loop count more than 100
                 if loopcnt > 100
                     fprintf('The Loop is over 100 cycle.');
                 else
                     fprintf('The Error occur when read angle! Please check the error manually.');
                 end
                 return;         %break the function here
            else
                Robot_Hold(2); 
                [pitch_read, yaw_read] = Robot_ReadAngle();%get data in unit of 0.01 degree
                diff_phi = phi_in - pitch_read;                         %pitch    
                diff_theta = theta_in - yaw_read;                       %yaw
                Tx     = typecast(int32(0),'uint8');                    %yaw
                Ty     = typecast(int32(diff_phi*100),'uint8');         %pitch
                Axis    = [0,0,0,Tx,Ty,0];
                Command = [Head,Suh,Setting_ang,Axis, Reserv, Type, Ex, ToolNo, Coor, Ext];
                robot=UDPNode('192.168.2.250',10040, 500);
                robot.submit(Command);
                Robot_Alarm(2);
                pause(abs(diff_phi/100)/speed+0.02);
            end
         end
        Tx     = typecast(int32(diff_theta*100),'uint8');               %yaw
        Ty     = typecast(int32(diff_phi*100),'uint8');                 %pitch
        Axis    = [0,0,0,Tx,Ty,0];
        Command = [Head,Suh,Setting_ang,Axis, Reserv, Type, Ex, ToolNo, Coor, Ext];
        robot=UDPNode('192.168.2.250',10040, 500);
        Robot_Alarm(2);
        response = robot.submit(Command);
    end
end
%Debug part
if isempty(response) 
    fprintf('\nYou should check your connection with robot or contact the mechanics or YW Chen.\n\n');
    return;
else
    Uint32_result = typecast(response,'uint32');
    if  Uint32_result(8) == 0   ||  Uint32_result(8) == 8208      % 0 or 0x2010
        pause(0.01);
        a = Robot_Alarm(1);
        if a == 0
            pitch = pitch_read + diff_phi;
            yaw = yaw_read + diff_theta;
            fprintf('\nSuccessfully Move the Robot. The pitch is %d degrees and the yaw is %d degrees.\n\n', (pitch/100), (yaw/100));
        else
            fprintf('There are some Alarms.\n');
            Robot_Servo(2);
        end
    elseif Uint32_result(8) == 8320         %(0x2080) in hex
        fprintf('\nIncorrect mode, please change to "Remote Mode."\n\n');
    elseif Uint32_result(8) == 8304         %(0x2070) in hex
        Robot_Servo(2);                     %Robot Servo OFF
        fprintf('\nServo OFF, Please try to turn on the servo.\n');
    elseif Uint32_result(8) == 45070         %(0xB00E) in hex
        Robot_Servo(2);                     %Robot Servo OFF
        fprintf('\nThe User No. setting error.\n');
    else
        fprintf('\nUnsuccessfully move the robot, please check.');
        Robot_Alarm(1);
        Robot_Hold(1);                      %Robot Hold ON
        Robot_Servo(2);
    end
end
end