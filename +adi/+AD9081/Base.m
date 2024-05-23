classdef (Abstract) Base < ...
        adi.common.RxTx & ...
        adi.common.Attribute & ...
        adi.common.Channel & ...
        matlabshared.libiio.base
    %AD9081 Base Class
    
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
        % Dependent
        function value = get.SamplingRate(obj)
            if obj.ConnectedToDevice
                value = double(obj.getAttributeLongLong('voltage0_i','sampling_frequency',obj.isOutput,obj.iioDev));
            else
                value = NaN;
            end
        end
        %% Helpers
        function [num_coarse, num_fine, num_data, sr] = GetDataPathConfiguration(obj, isTx)
            if nargin < 2
                isTx = isa(obj,'adi.AD9081.Tx');
            end
            %% Connect to hardware if not yet
            if obj.ConnectedToDevice
                doNotCloseConnection = true;
            else
                % Setup LibIIO
                setupLib(obj);
                % Initialize the pointers
                initPointers(obj);
                getContext(obj);
                setContextTimeout(obj);
                % Get the device
                obj.iioDev = getDev(obj, obj.devName);                
                obj.needsTeardown = true;
                % Pre-calculate values to be used faster in stepImpl()
                obj.pIsInSimulink = coder.const(obj.isInSimulink);
                obj.ConnectedToDevice = true;
                if isTx
                    obj.phyDev = getDev(obj, obj.phyDevName);
                end
                doNotCloseConnection = false;
            end
            if isTx
                dev = obj.phyDev;
            else
                dev = obj.iioDev;
            end

            %% Parse data path configuration
            sr = obj.SamplingRate;
            numChannels = obj.iio_device_get_channels_count(dev);
            map = {};
            paths = {};
            for chanIdx = 1:numChannels
                chan = obj.iio_device_get_channel(dev,chanIdx-1);
                isOutputChan = obj.iio_channel_is_output(chan);
                if isOutputChan ~= isTx
                    continue;
                end
                chanName = obj.iio_channel_get_id(chan);

                numAttrs = obj.iio_channel_get_attrs_count(chan);
                for attrIdx = 1:numAttrs
                    attrName = obj.iio_channel_get_attr(chan,attrIdx-1);
                    if strcmp(attrName,'label')
                        [l,value] = obj.iio_channel_attr_read(chan,attrName,1024);
                        if l>0
                            map{end+1} = sprintf('%s:%s',chanName,value);
                            paths{end+1} = value;
                        end

                    end
                end
            end
            % Remove all q channels
            idx = contains(map,'q');
            map(idx) = [];
            % Pick out only unique paths
            paths = unique(paths);
            % Pick out items in map that have the specific paths and have the lowest channel number
            filteredMap = {};
            for k=1:length(paths)
                path = paths{k};
                idx = find(contains(map,path));
                [~,idx2] = min(idx);
                idx = idx(idx2);
                filteredMap{end+1} = map{idx};
            end
            % Count unique items with XDUCX 
            if isTx
                ss = 'U';
            else
                ss = 'D';
            end
            numFDUCX = 0; numCDUCX = 0;
            for DC = 0:7
                for k=1:length(filteredMap)
                    if contains(filteredMap{k},sprintf('FD%sC%d',ss,DC))
                        numFDUCX = numFDUCX + 1;
                    end
                    if contains(filteredMap{k},sprintf('CD%sC%d',ss,DC))
                        numCDUCX = numCDUCX + 1;
                    end
                end
            end
            num_coarse = numCDUCX; num_fine = numFDUCX; num_data = numFDUCX*2;
            if ~doNotCloseConnection
                obj.releaseImpl();
                if isTx
                    obj.phyDev = [];
                end
                obj.iioDev = [];
                obj.iioCtx = [];
            end    
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

        function attr = iio_channel_is_output(obj, chanPtr)
            % iio_channel_is_output(const struct iio_channel *chn)
            %
            % Get the attr of the given channel by index
            if useCalllib(obj)
                attr = calllib(obj.libName, 'iio_channel_is_output', chanPtr);
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

