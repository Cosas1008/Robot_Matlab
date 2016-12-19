function Robot_Move_Yaw(phi_in,theta_in,Tool,speed)
%Modified by Y.W. Chen Sep. 7th, 2016
%%
%Header part/ Straight increment value operation
Head = [89 69 82 67 32 00 104 00 03 01 00 00 00 00 00 00 57 57 57 57 57 57 57 57]; 
%Sub-header part
Suh = [138 00 03 00 01 02 00 00];   
% Setting of Speed to 1 degree/s and cartesian tool coordinate(19)
Setting = typecast(int32([1 0 2 speed*10 19]),'uint8');   

X       =   typecast(int32(0),'uint8');                %in unit of 10^-3
Y       =   typecast(int32(0),'uint8'); 
Z       =   typecast(int32(0),'uint8');
Tz      =   typecast(int32(0),'uint8');                %Tz increment    
Reserv  =   typecast(int32(0),'uint8');
ToolNo  =   Tool(1:4);
Type    =   Tool(5:8);
Ex      =   typecast(int32(0),'uint8');
Coor    =   typecast(int32(1),'uint8');
Ext     =   typecast(int32([0 0 0 0 0 0 0 0 0 0]),'uint8');

%%
%phi_in, theta_in in unit of 0.01 degree, speed in unit of 1 degree/s
%Get the original pitch and yaw value
[pitch_read, yaw_read] = Robot_ReadAngle();%get data in unit of 0.01 degree
if pitch_read == 9999 && yaw_read == 9999
    fprintf('The Error occur when read angle! Please check the error manually.');
    return;
else
    %Difference between the original and assigned values
    diff_phi = phi_in - pitch_read;                         %pitch    
    diff_theta = theta_in - yaw_read;                       %yaw

    if abs(diff_theta) > 100
        %pitch set to 0
        loopcnt = 0;
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
                Robot_Hold(2);                      %Hold OFF
                diff_phi = phi_in - pitch_read;                         %pitch    
                diff_theta = theta_in - yaw_read;                       %yaw
                Tx     = typecast(int32(0),'uint8');                    %yaw     
                Ty     = typecast(int32(-pitch_read*100),'uint8');      %pitch
                Axis    = [X,Y,Z,Tx,Ty,Tz];
                Command = [Head,Suh,Setting,Axis, Reserv, Type, Ex, ToolNo, Coor, Ext];
                robot=UDPNode('192.168.2.250',10040, 500);
                robot.submit(Command);
                pause(abs(pitch_read/100)/speed+0.02);
            end
        end
        %move yaw
        loopcnt = 0;
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
                Axis    = [X,Y,Z,Tx,Ty,Tz];
                Command = [Head,Suh,Setting,Axis, Reserv, Type, Ex, ToolNo, Coor, Ext];
                robot=UDPNode('192.168.2.250',10040, 500);
                robot.submit(Command);
                pause(abs(diff_theta/100)/speed+0.02);
            end
        end    
        %move pitch
        loopcnt = 0;
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
                Axis    = [X,Y,Z,Tx,Ty,Tz];
                Command = [Head,Suh,Setting,Axis, Reserv, Type, Ex, ToolNo, Coor, Ext];
                robot=UDPNode('192.168.2.250',10040, 500);
                robot.submit(Command);
                pause(abs(diff_phi/100)/speed+0.02);
            end
        end
        Tx     = typecast(int32(diff_theta*100),'uint8');                    %yaw
        Ty     = typecast(int32(diff_phi*100),'uint8');             %pitch
        Axis    = [X,Y,Z,Tx,Ty,Tz];
        Command = [Head,Suh,Setting,Axis, Reserv, Type, Ex, ToolNo, Coor, Ext];
        robot=UDPNode('192.168.2.250',10040, 500);
        response = robot.submit(Command);
    else
        %move pitch
        loopcnt = 0;
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
                Axis    = [X,Y,Z,Tx,Ty,Tz];
                Command = [Head,Suh,Setting,Axis, Reserv, Type, Ex, ToolNo, Coor, Ext];
                robot=UDPNode('192.168.2.250',10040, 500);
                robot.submit(Command);
                Robot_Alarm(2);
                pause(abs(diff_phi/100)/speed+0.02);
            end
        end
        Tx     = typecast(int32(diff_theta*100),'uint8');                    %yaw
        Ty     = typecast(int32(diff_phi*100),'uint8');             %pitch
        Axis    = [X,Y,Z,Tx,Ty,Tz];
        Command = [Head,Suh,Setting,Axis, Reserv, Type, Ex, ToolNo, Coor, Ext];
        robot=UDPNode('192.168.2.250',10040, 500);
        Robot_Alarm(2);
        response = robot.submit(Command);
    end
    %Debug part
    Uint32_result = typecast(response,'uint32');
    if  Uint32_result(8) == 0   ||  Uint32_result(8) == 8208      % 0 or 0x2010
        pause(0.001);
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