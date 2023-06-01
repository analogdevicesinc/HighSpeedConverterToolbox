classdef Rx < adi.AD9213.Rx
    % adi.DualAD9213.Rx Receive data from the DualAD9213 high speed ADC
    %   The adi.DualAD9213.Rx System object is a signal source that can receive
    %   complex data from the DualAD9213.
    %
    %   rx = adi.DualAD9213.Rx;
    %   rx = adi.DualAD9213.Rx('uri','ip:192.168.2.1');
    %
    %   <a href="http://www.analog.com/media/en/technical-documentation/data-sheets/AD9213.pdf">AD9213 Datasheet</a>
    %
    %   See also adi.DAQ2.Rx
           
    properties (Nontunable, Hidden)
        phyDevNameChipB = 'ad9213_1';
    end

    methods
        %% Constructor
        function obj = Rx(varargin)
            % Returns the matlabshared.libiio.base object
            coder.allowpcode('plain');
            obj = obj@adi.AD9213.Rx(varargin{:});
            obj.phyDevName = 'ad9213_0';
            obj.channel_names = {'voltage0','voltage1'};
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
            bName = 'Dual-AD9213';
        end
        
    end
end

