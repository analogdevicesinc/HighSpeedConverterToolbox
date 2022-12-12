classdef (Abstract) Tx < adi.common.Tx & adi.AD916x.Base & adi.common.DDS
    % adi.AD9162.Tx Transmit data to the AD9162 high speed DAC
    %
    %   tx = adi.AD9162.Tx;
    %   tx = adi.AD9162.Tx('uri','192.168.2.1');
    %
    %   <a href="http://www.analog.com/media/en/technical-documentation/data-sheets/AD9161-9162.pdf">AD9162 Datasheet</a>
    %
    %   See also adi.FMCOMMS11.Tx

    
    properties (Constant)
        %SamplingRate Sampling Rate
        %   Baseband sampling rate in Hz, specified as a scalar 
        %   in samples per second. This value is constant
        SamplingRate = 1e9;
    end
    
    properties (Hidden, Nontunable, Access = protected)
        isOutput = true;
    end
    
    properties(Nontunable, Hidden, Constant)
        Type = 'Tx';
    end
    
    methods
        %% Constructor
        function obj = Tx(varargin)
            % Returns the matlabshared.libiio.base object
            coder.allowpcode('plain');
            obj = obj@adi.AD916x.Base(varargin{:});
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
        
    end
end

