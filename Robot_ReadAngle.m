function [pitch, yaw] = Robot_ReadAngle()
%Modified by Y.W. Chen Sep. 7th, 2016
%Commmand No. 0x75
Command = [89 69 82 67 32 00 00 00 03 01 00 00 00 00 00 00 57 57 57 57 57 57 57 57 117 00 101 00 00 01 00 00];  

robot=UDPNode('192.168.2.250',10040, 500); %UDPNode(IP, server port #, timeout in milliseconds);
data=uint8(Command);
response = robot.submit(data);
%printUint8DataHexUnaligned(response);
if isempty(response) 
    fprintf('\nYou should check your connection with robot or contact the mechanics.\nError on Robot_ReadAngle()\n');
    pitch = 9999;
    yaw   = 9999;
    return;
else
    Uint32_result = typecast(response,'uint32');
    if  Uint32_result(8) == 0   ||  Uint32_result(8) == 8208      % 0 or 0x2010
        Data = typecast(response(65:76),'int32');
        Tx = Data(1)/10^2;          % 0.01  degree
        Ty = Data(2)/10^2;          % 0.01  degree
        Tz = Data(3)/10^2;          % 0.01  degree
        %pitch value
        if abs(Tz) <= abs(Tx)
            pitch = -(9000 + Ty);            %pitch < 0
        elseif abs(Tz) > abs(Tx)
            pitch = (9000 + Ty);           %pitch > 0
        end
        %yaw value
        if Tx >= 0 &&  Tx*Tz >= 0         %Tx >0 && Tz > 0
            Yaw_total = Tx + Tz;
            yaw = Yaw_total - 18000;
        elseif Tx< 0 && Tz >= 0          %Tx <0 && Tz > 0
            if abs(Tx) > abs(Tz)
                yaw = (18000 + Tz) - abs(Tx);
            else
                yaw = Tz -(18000 - Tx);
            end
        elseif Tx> 0 && Tz < 0          %Tx <0 && Tz > 0 
            if abs(Tz) > abs(Tx)
                yaw = Tx + (18000 - abs(Tz)); %%%%%Ke
            else
                yaw = -(18000 - Tx - Tz);%%%%Ke
            end
        elseif Tx < 0 && Tz < 0         %Tx < 0 Tz  < 0
            Yaw_total = Tx + Tz;
            yaw = Yaw_total + 18000;
        end
    else
        pitch = 9999;
        yaw   = 9999;
        fprintf('Some error happen while Robot_ReadAngle.');
        return
    end
end
end