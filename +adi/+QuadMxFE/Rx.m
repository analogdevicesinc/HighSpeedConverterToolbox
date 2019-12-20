classdef Rx < adi.QuadMxFE.Base & adi.common.Rx
    % adi.QuadMxFE.Rx Receive data from the Quad MxFE evaluation board
    %   The adi.QuadMxFE.Rx System object is a signal source that can receive
    %   complex data from the Quad MxFE.
    %
    %   rx = adi.QuadMxFE.Rx;
    %   rx = adi.QuadMxFE.Rx('uri','192.168.2.1');
    %
    %   <a href="http://www.analog.com/media/en/technical-documentation/data-sheets/AD9081.pdf">AD9081 Datasheet</a>
    %
    %   See also adi.AD9081.Rx
    
    properties (Constant)
        %SamplingRate Sampling Rate
        %   Baseband sampling rate in Hz, specified as a scalar
        %   in samples per second. This value is constant
        SamplingRate = 1e9;
    end
    properties (Hidden, Nontunable, Access = protected)
        isOutput = false;
    end
    
    properties(Nontunable, Hidden, Constant)
        Type = 'Rx';
        channel_names = {'voltage0_i','voltage0_q',...
            'voltage1_i','voltage1_q',...
            'voltage2_i','voltage2_q',...
            'voltage3_i','voltage3_q',...
            'voltage4_i','voltage4_q',...
            'voltage5_i','voltage5_q',...
            'voltage6_i','voltage6_q',...
            'voltage7_i','voltage7_q',...
            'voltage8_i','voltage8_q',...
            'voltage9_i','voltage9_q',...
            'voltage10_i','voltage10_q',...
            'voltage11_i','voltage11_q',...
            'voltage12_i','voltage12_q',...
            'voltage13_i','voltage13_q',...
            'voltage14_i','voltage14_q',...
            'voltage15_i','voltage15_q'};
    end
    
    properties (Nontunable, Hidden)
        devName = 'axi-ad9081-rx-3';
    end
    
    methods
        %% Constructor
        function obj = Rx(varargin)
            % Returns the matlabshared.libiio.base object
            coder.allowpcode('plain');
            obj = obj@adi.QuadMxFE.Base(varargin{:});
        end
    end   
    
    %% External Dependency Methods
    methods (Hidden, Static)
        
        function tf = isSupportedContext(bldCfg)
            tf = matlabshared.libiio.ExternalDependency.isSupportedContext(bldCfg);
        end
        
        function updateBuildInfo(buildInfo, bldCfg)
            % Call the matlabshared.libiio.method first
            matlabshared.libiio.ExternalDependency.updateBuildInfo(buildInfo, bldCfg);
        end
        
        function bName = getDescriptiveName(~)
            bName = 'Quad MxFE';
        end
        
    end
end

