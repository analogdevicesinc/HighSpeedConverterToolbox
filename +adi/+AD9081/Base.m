classdef (Abstract) Base < matlabshared.libiio.base & ...
        matlab.system.mixin.CustomIcon & adi.common.Attribute
    %AD9081 Base Class
    
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
        dataTypeStr = 'int16';
        phyDevName = 'axi-ad9081-rx-hpc';
        max_num_data_channels = 4;
        max_num_coarse_attr_channels = 4;
        max_num_fine_attr_channels = 4;
    end
    
    properties (Abstract, Hidden, Constant)
       Type 
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
            icon = sprintf(['AD9081 ',obj.Type]);
        end
        
        function CheckAndUpdateHW(obj, value, name, attr, phy, output)
            if nargin < 6
                output = false;
            end
            if contains(attr,'channel_')
                N = obj.num_fine_attr_channels;
                stride = 1;
            elseif contains(attr,'main_')
                N = obj.num_coarse_attr_channels;
                stride = obj.num_fine_attr_channels/N;
            else
                error('Unknown attribute name');
            end
            tol = 100;
            s = size(value);
            c1 = s(1) == 1;
            c2 = s(2) <= N;
            assert(c1 && c2,...
                sprintf('%s expected to be at most size [1x%d]',name,N));
            if obj.ConnectedToDevice
                for k=1:N
                    id = sprintf('voltage%d_i',(k-1)*stride);
                    obj.setAttributeLongLong(id,attr,value(k),output, tol, phy);
                end
            end
        end
        
        function CheckAndUpdateHWFloat(obj, value, name, attr, phy, output)
            if nargin < 6
                output = false;
            end
            if contains(attr,'channel_')
                N = obj.num_fine_attr_channels;
                stride = 1;
            elseif contains(attr,'main_')
                N = obj.num_coarse_attr_channels;
                stride = obj.num_fine_attr_channels/N;
            else
                error('Unknown attribute name');
            end
            tol = 100;
            s = size(value);
            c1 = s(1) == 1;
            c2 = s(2) <= N;
            assert(c1 && c2,...
                sprintf('%s expected to be at most size [1x%d]',name,N));
            if obj.ConnectedToDevice
                for k=1:N
                    id = sprintf('voltage%d_i',(k-1)*stride);
                    obj.setAttributeDouble(id,attr,value(k),output, tol, phy);
                end
            end
        end
        
        function CheckAndUpdateHWBool(obj, value, name, attr, phy, output)
            if nargin < 6
                output = false;
            end
            if contains(attr,'channel_') || strcmpi(attr,'en')
                N = obj.num_fine_attr_channels;
                stride = 1;
            elseif contains(attr,'main_')
                N = obj.num_coarse_attr_channels;
                stride = obj.num_fine_attr_channels/N;
            else
                error('Unknown attribute name');
            end
            s = size(value);
            c1 = s(1) == 1;
            c2 = s(2) <= N;
            assert(c1 && c2,...
                sprintf('%s expected to be at most size [1x%d]',name,N));
            if obj.ConnectedToDevice
                for k=1:N
                    id = sprintf('voltage%d_i',(k-1)*stride);
                    obj.setAttributeBool(id,attr,value(k),output, phy);
                end
            end
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
            bName = 'AD9081';
        end
        
    end
end

