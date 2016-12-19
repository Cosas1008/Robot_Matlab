function [X, Y, Z] = Robot_ReadRect(Tool)
%Modified by Y.W. Chen Sep. 6th, 2016
%Take the exception
if Tool(:) == 0
    X = 9999;
    Y = 9999;
    Z = 9999;
    fprintf('\nSome error happen when [X, Y, Z] =  Robot_ReadRect(Tool).\n');
    return
end
%Commmand No. 0x75
Command = [89 69 82 67 32 00 00 00 03 01 00 00 00 00 00 00 57 57 57 57 57 57 57 57 117 00 101 00 00 01 00 00];  
robot=UDPNode('192.168.2.250',10040, 500); %UDPNode(IP, server port #, timeout in milliseconds);
data=uint8(Command);
response = robot.submit(data);
%printUint8DataHexUnaligned(response);

if isempty(response) 
    fprintf('\nYou should check your connection with robot or contact the mechanics.\nError on Robot_ReadRect(Tool)\n');
else
    Uint32_result = typecast(response,'uint32');
    if  Uint32_result(8) == 0   ||  Uint32_result(8) == 8208      % 0 or 0x2010
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
    else
        X = 9999;
        Y = 9999;
        Z = 9999;
        fprintf('Some error happen while Robot_ReadRect(Tool).');
        return
    end
end

end