function Robot_Move(Tool,speed)
%Modified by Y.W. Chen Sep. 7th, 2016
%Command No. 0x8a
Head = [89 69 82 67 32 00 104 00 01 01 00 00 00 00 00 00 57 57 57 57 57 57 57 57]; %Header part(Command No. 0x8A)
Suh = [138 00 01 00 01 02 00 00];       %Sub-header part
Setting = typecast(uint32([1 0 1 speed*10 17]),'uint8');   
% Setting of Speed to 1 mm/s and cartesian Robot coordinate(17)
% Setting of Speed to 1 degree/s and cartesian Robot coordinate(17)
ToolNo  = Tool(1:4);                            %Tool Number
Type    = Tool(5:8);                            %Form
Axis    = Tool(9:32);                           % X, Y, Z, TX, TY, TZ
Reserv  = typecast(uint32(0),'uint8');
Ex      = typecast(uint32(0),'uint8');
Coor    = typecast(uint32(3),'uint8');
Ext     = typecast(uint32([0 0 0 0 0 0 0 0 0 0]),'uint8');
Command = [ Head,Suh, Setting, Axis, Reserv, Type, Ex, ToolNo, Coor, Ext];
%printUint8DataHexUnaligned(Command);
Robot_Hold(2);                      %Robot Hold OFF
Robot_Servo(1);                     %Robot Servo ON

robot=UDPNode('192.168.2.250',10040, 500);
response=robot.submit(Command);
%printUint8DataHexUnaligned(response);
if isempty(response) 
    fprintf('\nYou should check your connection with robot or contact the mechanics or YW Chen.\nError on Robot_Move(Tool,speed)\n');
else
    Uint32_result = typecast(response,'uint32');
    if  Uint32_result(8) == 0
        fprintf('\nSuccessfully Move the Robot\n\n');
    elseif Uint32_result(8) == 8320         %(0x2080) in hex
        fprintf('\nIncorrect mode, please change to "Remote Mode."\n\n');
    elseif Uint32_result(8) == 8304         %(0x2070) in hex
        Robot_Servo(2);                     %Robot Servo OFF
        fprintf('\nServo OFF, Please try to turn on the servo.\n');
    elseif Uint32_result(8) == 45070         %(0xB00E) in hex
        Robot_Servo(2);                     %Robot Servo OFF
        fprintf('\nThe User No. setting error.\n');
    elseif Uint32_result(8) == 45067        %(0xB00B) in hex
        fprintf('\nThe Operation Coordinate error.');
        Robot_Hold(1);                      %Robot Hold ON
        Robot_Servo(2);                     %Robot Servo OFF
    else
        fprintf('\nUnsuccessfully move the robot, please check.');
        Robot_Alarm(1);
        Robot_Hold(1);                      %Robot Hold ON
        Robot_Servo(2);
    end
end
end