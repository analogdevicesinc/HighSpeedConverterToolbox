classdef (Abstract) Base < ...
        adi.common.RxTx & ...
        adi.common.Attribute & ...
        matlabshared.libiio.base
    %AD9088 Base Class

    properties (Dependent)
        %SamplingRate Sampling Rate
        %   Baseband sampling rate in Hz, specified as a scalar
        %   in samples per second. This value is only readable once
        %   connected to hardware
        SamplingRate
    end

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
        % The AD9088 shares the Apollo driver and devicetree node names
        % with the AD9084, so the control device is axi-ad9084-rx-hpc
        phyDevName = 'axi-ad9084-rx-hpc';
        max_num_data_channels = 4;
        max_num_coarse_attr_channels = 8;
        max_num_fine_attr_channels = 8;
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
        % Dependent
        function value = get.SamplingRate(obj)
            if obj.ConnectedToDevice
                value = double(obj.getAttributeLongLong('voltage0_i','sampling_frequency',obj.isOutput));
            else
                value = NaN;
            end
        end
    end

    %% API Functions
    methods (Hidden, Access = protected)

        function icon = getIconImpl(obj)
            icon = sprintf(['AD9088 ',obj.Type]);
        end

        function N = getAttrChannelCount(obj, attr)
            % On the Apollo driver every attribute channel exposes both
            % channel_* (FDDC/FDUC) and main_* (CDDC/CDUC) attributes for
            % its own datapath, so both are written with a stride of 1
            if contains(attr,'channel_') || strcmpi(attr,'en')
                N = obj.num_fine_attr_channels;
            elseif contains(attr,'main_')
                N = obj.num_coarse_attr_channels;
            else
                error('Unknown attribute name');
            end
        end

        function CheckAndUpdateHW(obj, value, name, attr, phy, output)
            if nargin < 6
                output = false;
            end
            N = obj.getAttrChannelCount(attr);
            tol = 100;
            s = size(value);
            c1 = s(1) == 1;
            c2 = s(2) <= N;
            assert(c1 && c2,...
                sprintf('%s expected to be at most size [1x%d]',name,N));
            if obj.ConnectedToDevice
                for k=1:s(2)
                    id = sprintf('voltage%d_i',k-1);
                    obj.setAttributeLongLong(id,attr,value(k),output, tol, phy);
                end
            end
        end

        function CheckAndUpdateHWFloat(obj, value, name, attr, phy, output)
            if nargin < 6
                output = false;
            end
            N = obj.getAttrChannelCount(attr);
            tol = 100;
            s = size(value);
            c1 = s(1) == 1;
            c2 = s(2) <= N;
            assert(c1 && c2,...
                sprintf('%s expected to be at most size [1x%d]',name,N));
            if obj.ConnectedToDevice
                for k=1:s(2)
                    id = sprintf('voltage%d_i',k-1);
                    obj.setAttributeDouble(id,attr,value(k),output, tol, phy);
                end
            end
        end

        function CheckAndUpdateHWBool(obj, value, name, attr, phy, output)
            if nargin < 6
                output = false;
            end
            N = obj.getAttrChannelCount(attr);
            s = size(value);
            c1 = s(1) == 1;
            c2 = s(2) <= N;
            assert(c1 && c2,...
                sprintf('%s expected to be at most size [1x%d]',name,N));
            if obj.ConnectedToDevice
                for k=1:s(2)
                    id = sprintf('voltage%d_i',k-1);
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
            bName = 'AD9088';
        end

    end
end
