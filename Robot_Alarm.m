function [result] = Robot_Alarm(var)
%Modified by Y.W. Chen Sep. 7th, 2016
%var = 1; ===  Read the Alarm
%var = 2; ===  Reset the alarm

if var == 1
    Command = [89 69 82 67 32 00 00 00 03 01 00 00 00 00 00 00 57 57 57 57 57 57 57 57 112 00 01 00 00 01 00 00];
    robot=UDPNode('192.168.2.250',10040, 2000); %UDPNode(IP, server port #, timeout in milliseconds);
    data=uint8(Command);
    response = robot.submit(data);
    %printUint8DataHexUnaligned(response);
    if isempty(response) 
        fprintf('\nYou should check your connection with robot or contact the mechanics or YW Chen.\n\n');
    else
        Uint32_res = typecast(response,'uint32');
        if Uint32_res(9) ~= 0
            Time = char(typecast(Uint32_res(12:15),'uint8'));
            Alart = char(typecast(Uint32_res(16:21),'uint8'));
            Str_temp = [ Alart,'is happended on ', Time,' .'];
            fprintf(Str_temp);
            result = 1;             %there are some alarm happened
        else
            result = 0;             %no alarm
        end
    end
elseif var == 2
    Command = [89 69 82 67 32 00 04 00 03 01 00 00 00 00 00 00 57 57 57 57 57 57 57 57 130 00 01 00 01 16 00 00 01 00 00 00];
    robot=UDPNode('192.168.2.250',10040, 2000); %UDPNode(IP, server port #, timeout in milliseconds);
    data=uint8(Command);
    response = robot.submit(data);
    if isempty(response) 
        fprintf('\nYou should check your connection with robot or contact the mechanics or YW Chen.\n\n');
    else
        Uint32_res = typecast(response,'uint32');
        if Uint32_res(7) == 144
            fprintf('\nAlarm Reset Successfully!!!!\n');
            result = 3;                         %other responses
        else
            fprintf('\n(Alarm Reset)respond abnormally, please contact the mechanics.\n');
            result = 3;                         %other responses
        end
    end
else 
    fprintf('You should enter a variable(1 or 2), 1: read alarm / 2: reset alarm');
    result = 3;                                 %other responses
end

end