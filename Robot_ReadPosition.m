function [Tool] = Robot_ReadPosition()
%Modified by Y.W. Chen Sep. 7th, 2016
%Commmand No. 0x75
Command = [89 69 82 67 32 00 00 00 03 01 00 00 00 00 00 00 57 57 57 57 57 57 57 57 117 00 101 00 00 01 00 00];  
%UDPNode(IP, server port #, timeout in milliseconds);
robot=UDPNode('192.168.2.250',10040, 1000);
data=uint8(Command);
response = robot.submit(data);
%printUint8DataHexUnaligned(response);

if isempty(response) 
    fprintf('\nYou should check your connection with robot or contact the mechanics or YW Chen.\nError on Robot_ReadPosition()\n');
    Tool = typecast(zeros(1,4),'uint8');        %Generate 1x32 uint8 zeros array
    return;
else
    for i=0:12
        temp = response(33+i*4:36+i*4);
        switch i
            case 1
                Form = temp;
            case 2
                Tool = temp;
            case 5
                X = temp;
            case 6
                Y = temp;
            case 7
                Z = temp;
            case 8
                Xr = temp;
            case 9
                Yr = temp;
            case 10
                Zr = temp;
        end        
    end
    % Transfer the values to the understandable numerical values
    Tool_no = typecast(Tool,'int32');
    Form = typecast(Form,'int32');
    X = typecast(X,'int32');
    Y = typecast(Y,'int32');
    Z = typecast(Z,'int32');
    Xr = typecast(Xr,'int32');
    Yr = typecast(Yr,'int32');
    Zr = typecast(Zr,'int32');
    % print out the value
    fprintf('\nFor Tool Number %d \n-----------------------\nX is \t\t %d\nY is\t\t %d\nZ is \t\t %d\nXr is \t\t %d\nYr is \t\t %d\nZr is \t\t %d\n',Tool,X,Y,Z,Xr,Yr,Zr);
    Assemble_Data = [Tool_no,Form,X,Y,Z,Xr,Yr,Zr]; %Assemble the wanted values to output:Data
    Tool = typecast(Assemble_Data,'uint8');
    %printUint8DataHexUnaligned(Data); % Data = [Tool,Form,X,Y,Z,Xr,Yr,Zr];
    %Tool 4 bytes/ Form 4 bytes X,Y,Z,Xr,Yr,Zr 4 bytes
end 
end