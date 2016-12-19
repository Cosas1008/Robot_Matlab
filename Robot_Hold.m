function Robot_Hold(i)
%Modified by Y.W. Chen Sep. 7th, 2016
if i == 1
    k = 1;      %Hold ON
elseif i ==2
    k = 2;      %Hold OFF
else
    fprintf('You should Enter(1:ON / 2:OFF)\nPlease Try again.\n\n')
    return;
end
Command = [89 69 82 67 32 00 04 00 03 01 00 00 00 00 00 00 57 57 57 57 57 57 57 57 131 00 01 00 01 16 00 00 k 00 00 00];
%UDPNode(IP, server port #, timeout in milliseconds);
robot=UDPNode('192.168.2.250',10040, 500);

data=uint8(Command);
%printUint8DataHexUnaligned(data);
response = robot.submit(data);
%printUint8DataHexUnaligned(response);
if isempty(response) 
    fprintf('\nYou should check your connection with robot or contact the mechanics or YW Chen.\nError on Robot_Hold()\n');
else
    Uint32_res = typecast(response,'uint32');
    if Uint32_res(7) == 144 && i == 1
        fprintf('\nSuccessfully Hold ON\n\n');
    elseif Uint32_res(7) == 144 && i == 2
        fprintf('\nSuccessfully Hold OFF\n\n');
    else
        fprintf('\nHold disfunction, Please check the ALARM sign or the DOOR issue.\n\n');
    end
end
end
