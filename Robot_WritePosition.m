function Robot_WritePosition(Number,ToolNo,Position) 
%Modified by Y.W. Chen Sep. 7th, 2016

%Generate the Command Code
Head = uint8([89 69 82 67 32 00 56 00 03 01 00 00 00 00 00 00 57 57 57 57 57 57 57 57 07 03 Number 00 00 52 00 00]);    %Command No. 0x307
Num = typecast(uint32(1),'uint8');
Form = Position(5:8);
ToolNumber = typecast(uint32(ToolNo),'uint8');
DataType = typecast(uint32(18),'uint8');
Ext = typecast(uint32([1 0]),'uint8');
Posi = Position(9:32); 
Ax_78 = typecast(uint32([0 0]),'uint8');
Command = uint8([Head,Num,DataType,Form,ToolNumber,Ext,Posi,Ax_78]);

%UDPNode(IP, server port #, timeout in milliseconds);
robot=UDPNode('192.168.2.250',10040, 500);
data=uint8(Command);
response = robot.submit(data);
%printUint8DataHexUnaligned(response);
if isempty(response) 
    fprintf('\nYou should check your connection with robot or contact the mechanics or YW Chen.\nError on Robot_Hold()\n');
else
    Uint32_result = typecast(response,'uint32');
    if  Uint32_result(8) == 0
        fprintf('\nSuccessfully write the Position into Robot\n\n');
    else
        fprintf('\nPlease check the Robot_WritePosition has the correct parameter\n\n');
    end
end

end