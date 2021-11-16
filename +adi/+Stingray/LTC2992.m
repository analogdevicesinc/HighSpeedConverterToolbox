classdef LTC2992
    properties
        uri
    end
    
    properties (Access = private)
        GPIOExposed = false
        DevHandle
    end
    
    methods
        function obj = LTC2992(uri)
            obj.uri = uri;
            obj.DevHandle = raspi(obj.uri(4:end), 'root', 'analog');
            dirs = strsplit(obj.DevHandle.system('ls /sys/class/gpio'));
            for ii = 1:numel(dirs)
                if contains(dirs(ii), 'ltc2992')
                    obj.GPIOExposed = true;
                end
            end
            
            if ~obj.GPIOExposed
                obj.DevHandle.system('echo 476 > /sys/class/gpio/export');
                obj.DevHandle.system('echo 477 > /sys/class/gpio/export');
                obj.DevHandle.system('echo 478 > /sys/class/gpio/export');
                obj.DevHandle.system('echo 479 > /sys/class/gpio/export');
                obj.DevHandle.system('echo 0 > /sys/class/gpio/ltc2992-6a-GPIO1/value');
                obj.DevHandle.system('echo 0 > /sys/class/gpio/ltc2992-6a-GPIO2/value');
                obj.DevHandle.system('echo 0 > /sys/class/gpio/ltc2992-6a-GPIO3/value');
                obj.DevHandle.system('echo 0 > /sys/class/gpio/ltc2992-6a-GPIO4/value');
            end
        end
        
        function result = Ch1Voltage(obj)
            % Read the voltage for Channel 1
            result = str2double(strtrim(obj.DevHandle.system('cat /sys/class/hwmon/hwmon20/in0_input')))/1000;            
        end
        
        function result = Ch2Current(obj)
            % Read the current for Channel 2
            result = str2double(strtrim(obj.DevHandle.system('cat /sys/class/hwmon/hwmon20/curr2_input')))/1000;
        end
        
        function result = getGPIO1(obj)
            result = logical(str2double(obj.DevHandle.system('cat /sys/class/gpio/ltc2992-6a-GPIO1/value')));
        end
        
        function result = getGPIO2(obj)
            result = logical(str2double(obj.DevHandle.system('cat /sys/class/gpio/ltc2992-6a-GPIO2/value')));
        end
        
        function result = getGPIO3(obj)
            result = logical(str2double(obj.DevHandle.system('cat /sys/class/gpio/ltc2992-6a-GPIO3/value')));
        end
        
        function result = getGPIO4(obj)
            result = logical(str2double(obj.DevHandle.system('cat /sys/class/gpio/ltc2992-6a-GPIO4/value')));
        end
    end
end