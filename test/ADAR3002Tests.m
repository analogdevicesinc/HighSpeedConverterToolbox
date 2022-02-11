classdef ADAR3002Tests < HardwareTests
    
    properties
        uri = 'ip:10.72.162.61';
        author = 'ADI';
    end
    
    methods(TestClassSetup)
        % Check hardware connected
        function CheckForHardware(testCase)
            Device = @()adi.ADAR3002;
            testCase.CheckDevice('ip',Device,testCase.uri(4:end),false);
        end
    end
    
    methods (Static)
    end
    
    methods (Test)
        
        function testADAR3002ReadPhases(testCase)    
            % Test Reading phases
            bf = adi.ADAR3002('uri',testCase.uri);
            [valid] = bf();
            bf.release();
            testCase.verifyTrue(valid);
        end
                
    end
    
end

