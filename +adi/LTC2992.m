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
            obj.DevHandle = raspi(obj.uri, 'root', 'analog');
            
            obj.DevHandle.system('echo 476 > /sys/class/gpio/export');
            obj.DevHandle.system('echo 477 > /sys/class/gpio/export');
            obj.DevHandle.system('echo 478 > /sys/class/gpio/export');
            obj.DevHandle.system('echo 479 > /sys/class/gpio/export');            
            obj.DevHandle.system('echo 0 > /sys/class/gpio/ltc2992-6a-GPIO1/value');
            obj.DevHandle.system('echo 0 > /sys/class/gpio/ltc2992-6a-GPIO2/value');
            obj.DevHandle.system('echo 0 > /sys/class/gpio/ltc2992-6a-GPIO3/value');
            obj.DevHandle.system('echo 0 > /sys/class/gpio/ltc2992-6a-GPIO4/value');
        end
        
        function result = Ch1Voltage(obj)
            % Read the voltage for Channel 1
            result = obj.DevHandle.system('cat /sys/class/hwmon/hwmon20/in0_input');
            result = result/1000;
        end
        
        function result = Ch2Current(obj)
            % Read the current for Channel 2
            result = obj.DevHandle.system('cat /sys/class/hwmon/hwmon20/curr2_input');
            result = result/1000;
        end
        
        function result = getGPIO1(obj)
            result = obj.DevHandle.system('cat /sys/class/gpio/ltc2992-6a-GPIO1/value');
        end
        
        function result = getGPIO2(obj)
            result = obj.DevHandle.system('cat /sys/class/gpio/ltc2992-6a-GPIO2/value');
        end
        
        function result = getGPIO3(obj)
            result = obj.DevHandle.system('cat /sys/class/gpio/ltc2992-6a-GPIO3/value');
        end
        
        function result = getGPIO4(obj)
            result = obj.DevHandle.system('cat /sys/class/gpio/ltc2992-6a-GPIO4/value');
        end
    end
end