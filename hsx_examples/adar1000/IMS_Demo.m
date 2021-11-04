clc;
clear;
close all;

sdut = adi.Stingray;
sdut.uri = 'ip:192.168.1.111';
%{
classdef IMS_Demo
    properties
        % IP address
        uri = 'ip:192.168.1.111';

        stingray
        mxfe
    end
    
    methods
        function obj = IMS_Demo(uri, CSBs)
            obj.stingray = adi.Stingray(uri, CSBs);
            obj.mxfe = adi.AD9081.Rx;
            obj.mxfe.uri = uri;
            
            try
                obj.Configure(10e9, 3e9);
                obj.Run();
            catch ME
                obj.PowerDown();
            end
        end
        
        function obj = Configure(StingrayFreq, MxFEFreq)
            % obj.ConfigureMxFE(MxFEFreq);
            obj.ConfigureStingray(StingrayFreq);
        end
        
        function obj = Run()
        end
    end
    
    methods (Access = private)
        function obj = ConfigureMxFE(MxFEFreq)
        end
        
        function obj = ConfigureStingray(StingrayFreq)
            % obj.stingray.frequency = StingrayFreq;            
            obj.stingray.PowerUp(false);
        end
    end
end


% configure MxFE

% configure Stingray
%}