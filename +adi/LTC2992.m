classdef LTC2992
    properties
        uri
    end
    
    properties (Access = private)
        DevHandle
    end
    
    methods
        function obj = LTC2992(uri)
            obj.uri = uri;
            obj.DevHandle = raspi(obj.uri,'root','analog');
        end
        
        function res = getGPIO1(obj)
            res = obj.DevHandle.system('cat /sys/class/gpio/ltc2992-6a-GPIO1/value');
        end
        
        function res = getGPIO2(obj)
            res = obj.DevHandle.system('cat /sys/class/gpio/ltc2992-6a-GPIO2/value');
        end
        
        function res = getGPIO3(obj)
            res = obj.DevHandle.system('cat /sys/class/gpio/ltc2992-6a-GPIO3/value');
        end
        
        function res = getGPIO4(obj)
            res = obj.DevHandle.system('cat /sys/class/gpio/ltc2992-6a-GPIO4/value');
        end
    end
end