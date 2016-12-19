classdef UDPNode
    
    properties
        host='';
        port=21;
        socket;
        timeout = 100;
        MAX_BUFFER_LENGTH =1024;
    end
    
    methods
        function obj=UDPNode(host, port, timeout)
            obj.host=host;
            obj.port=port;
            obj.timeout=timeout;
        end
        
        function result=submit(obj, data)
            import java.net.Socket
            import java.net.*
            import java.io.*
            import java.lang.String
            
            if(isa(data, 'uint8')==0)
                error('data must be uint8.');
            end
            try
                obj.socket = DatagramSocket(0);
                obj.socket.setSoTimeout(obj.timeout);% milliseconds
                hostInetAddr = InetAddress.getByName(obj.host);
                request = DatagramPacket(data, length(data), hostInetAddr , obj.port);
                response = DatagramPacket(zeros(1, obj.MAX_BUFFER_LENGTH, 'int8'), obj.MAX_BUFFER_LENGTH);
                obj.socket.send(request);
                obj.socket.receive(response);
                temp_result=response.getData();
                result=zeros(1, response.getLength(), 'int8');
                
                for i=1:response.getLength()
                    result(i)=temp_result(i);
                end
                result=typecast(result,'uint8');
                obj.socket.close();
                
            catch e
                if ~isempty(obj.socket)
                    obj.socket.close();
                end
                
                if(isa(e, 'matlab.exception.JavaException'))
                    ex=e.ExceptionObject;
                    assert(isjava(ex));
                    if(isa(ex, 'java.net.SocketTimeoutException'))
                        fprintf('Error: UDP timeout error\n');
                        result=zeros(1, 0, 'uint8');
                        %printUint8DataHex(result);
                    else
                        ex
                        error('unhandled exception. Please discuss with Yu-Jiu Wang.');
                    end
                else
                    e
                    error('unhandled exception. Please discuss with Yu-Jiu Wang.');
                end
            end
        end
    end 
end 

