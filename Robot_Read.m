function [X, Y, Z, pitch, yaw] = Robot_Read(Tool)
%Modified by Y.W. Chen Sep. 7th, 2016
%%
%To tell whether X, Y and Z are available or not
if Tool(:) == 0
    fprintf('\nSome error happen when [X, Y, Z] =  Robot_ReadRect(Tool).\n');
end
%%
%Read X, Y, Z, pitch and yaw
%Commmand No. 0x75
Command = [89 69 82 67 32 00 00 00 03 01 00 00 00 00 00 00 57 57 57 57 57 57 57 57 117 00 101 00 00 01 00 00];  
robot=UDPNode('192.168.2.250',10040, 1000); %UDPNode(IP, server port #, timeout in milliseconds);
data=uint8(Command);
response = robot.submit(data);
%printUint8DataHexUnaligned(response);
if isempty(response) 
    fprintf('\nYou should check your connection with robot or contact the mechanics or YW Chen.\nerror on Robot_Read(Tool).\n');
    X = 9999;
    Y = 9999;
    Z = 9999;
    pitch = 9999;
    yaw   = 9999;
    return;
else
    Uint32_result = typecast(response,'uint32');
    if  Uint32_result(8) == 0   ||  Uint32_result(8) == 8208      % 0 or 0x2010
        %Rectangular
        Data = typecast(response(53:64),'int32');
        % These are the Tool position
        X_original = typecast(Tool(9:12),'int32');
        Y_original = typecast(Tool(13:16),'int32');
        Z_original = typecast(Tool(17:20),'int32');
        % These are the current position
        X_present = Data(1);
        Y_present = Data(2);
        Z_present = Data(3);
        % Difference between Tool and present position
        X = (X_present - X_original)/1000;      %in unit of 1 mm
        Y = (Y_present - Y_original)/1000;      %in unit of 1 mm
        Z = (Z_present - Z_original)/1000;      %in unit of 1 mm

        %Angular
        Data_angular = typecast(response(65:76),'int32');
        Tx = Data_angular(1)/10^2;          % 0.01  degree
        Ty = Data_angular(2)/10^2;          % 0.01  degree
        Tz = Data_angular(3)/10^2;          % 0.01  degree
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
        X = 9999;
        Y = 9999;
        Z = 9999;
        pitch = 9999;
        yaw   = 9999;
        fprintf('Some error happen while reading. Error on Robot_Read(Tool)');
        return;
    end
end
end