classdef (Abstract) Base < ...
        adi.common.RxTx & ...
        matlabshared.libiio.base 
    %AD3552R Base Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Nontunable)
        %SamplesPerFrame Samples Per Frame
        %   Number of samples per frame, specified as an even positive
        %   integer from 2 to 16,777,216. Using values less than 3660 can
        %   yield poor performance.
        SamplesPerFrame = 2^15;
    end
    
    properties(Nontunable, Hidden)
        Timeout = Inf;
        kernelBuffersCount = 2;
        dataTypeStr = 'uint16';
    end
    
    properties (Abstract, Hidden, Constant)
       Type 
    end
    
    properties (Hidden, Constant)
        ComplexData = false;
    end
    
    methods
        %% Constructor
        function obj = Base(varargin)
            % Returns the matlabshared.libiio.base object
            coder.allowpcode('plain');
            obj = obj@matlabshared.libiio.base(varargin{:});
        end
        % Check SamplesPerFrame
        function set.SamplesPerFrame(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'positive','scalar', 'finite', 'nonnan', 'nonempty','integer','>',0,'<',2^20+1}, ...
                '', 'SamplesPerFrame');
            obj.SamplesPerFrame = value;
        end
    end
    
    %% API Functions
    methods (Hidden, Access = protected)
                
        function icon = getIconImpl(obj)
            icon = sprintf(['AD3552R',obj.Type]);
        end
        
        function setupInit(~)
            % Unused
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
            bName = 'AD3552R';
        end
        
    end
end

