clc;
clear;
close all;

uri = 'ip:192.168.1.111';
FreqMxFE = 3e9;
FreqSRay = 10e9;

% Setup MxFE
rx = adi.AD9081.Rx;
rx.uri = uri;
rx.EnabledChannels = 1;
rx.kernelBuffersCount = 1;
rx.SamplesPerFrame = 1000;
rx.MainNCOFrequencies(1) = FreqMxFE;

% Setup Stingray
sray = adi.Stingray.Stingray(uri);
sray.Frequency = FreqSRay;
try
    sray.Configure();
    while true
        output = rx();
        pwelch(output);
        close all;
    end
catch ME
    sray.PowerDown();
end


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