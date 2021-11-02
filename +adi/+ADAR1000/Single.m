classdef Single < adi.common.Attribute & ...
        adi.common.DebugAttribute & adi.common.Rx & ...
        matlabshared.libiio.base
    
    properties (Constant)
        BIAS_CODE_TO_VOLTAGE_SCALE = -0.018824
    end
    
    properties
        %ChipID Chip ID
        %   String identifying desired chip select option of 
        %   ADAR100. This is based on the jumper configuration
        %   if the EVAL-ADAR100 is used. This string is the label
        %   coinciding with each chip select and is typically in the
        %   form csb*_chip*, e.g., csb1_chip1. When an ADAR1000 array
        %   is instantiated, the array class will handle the instantiation 
        %   of individual adar1000 handles.
        ChipID = 'csb1_chip1';
        ArrayElementMap = [1 2 3 4];
        ChannelElementMap = [2 1 4 3];
    end
    
    properties (Dependent)
        NumADAR1000s
    end
    
    properties
        ElementR
        ElementC
    end
    
    properties
        Channels
        BeamMemEnable
    end
    
    properties(Nontunable, Hidden)
%         Timeout = Inf;
        kernelBuffersCount = 0;
        dataTypeStr = 'int16';
%         phyDevName = 'adar1000';
        % Name of driver instance in device tree
        iioDriverName = 'adar1000';
%         iioDevPHY
        devName = 'adar1000';
        SamplesPerFrame = 0;
    end
    
    properties (Hidden)
        ChipIDHandle
    end
    
    properties (Hidden, Constant, Logical)
        ComplexData = false;
    end
    
    properties(Nontunable, Hidden, Constant)
        Type = 'Rx';
%         channel_names = {''};
    end
    
    properties (Hidden, Nontunable, Access = protected)
        isOutput = false;
    end
    
    %% API Functions
    methods
        %% Constructor
        function obj = Single(varargin)
            coder.allowpcode('plain');
            obj = obj@matlabshared.libiio.base(varargin{:});  
        end
        % Destructor
        function delete(obj)
        end
    end
    
    methods
        function res = get.NumADAR1000s(obj)
            res = numel(obj.ChipID);
        end
    end
    
    methods (Hidden, Access = protected)
        function setChipID(obj)
            numDevs = obj.iio_context_get_devices_count(obj.iioCtx);
            obj.ChipIDHandle = {};
            for ChipIDIndx = 1:obj.NumADAR1000s
                found = false;
                for k = 1:numDevs
                    devPtr = obj.iio_context_get_device(obj.iioCtx, k-1);                    
                    attrCount = obj.iio_device_get_attrs_count(devPtr);
                    name = obj.iio_device_get_name(devPtr);
                    if contains(name,obj.iioDriverName)
                        for i = 1:attrCount
                            attr = obj.iio_device_get_attr(devPtr,i-1);
                            if strcmpi(attr,'label')
                                val = obj.getDeviceAttributeRAW(attr,128,devPtr);
                                if contains(obj.ChipID{ChipIDIndx},val)
                                    obj.ChipIDHandle = [obj.ChipIDHandle(:)', {devPtr}];
                                    found = true;
                                end
                            end
                        end
                    end
                end            
                if ~found
                    error('Unable to locate %s in context',obj.ChipID{ChipIDIndx});
                end
            end
        end
        
        function setupImpl(obj)
            % Setup LibIIO
            setupLib(obj);
            
            % Initialize the pointers
            initPointers(obj);
            
            getContext(obj);
            
            setContextTimeout(obj);
            
            obj.needsTeardown = true;
            
            % Pre-calculate values to be used faster in stepImpl()
%             obj.pIsInSimulink = coder.const(obj.isInSimulink);
%             obj.pNumBufferBytes = coder.const(obj.numBufferBytes);
            
            obj.ConnectedToDevice = true;
            setupInit(obj);
        end
        
        function [data,valid] = stepImpl(~)
            data = 0;
            valid = false;
        end
        
        function setupInit(obj)
            % Do writes directly to hardware without using set methods.
            % This is required since Simulink support doesn't support
            % modification to nontunable variables at SetupImpl
            
            % Check ArrayElementMap and ChannelElementMap have the same
            % elements
            if (numel(intersect(obj.ArrayElementMap, obj.ChannelElementMap)) ~= ...
                    numel(obj.ChannelElementMap))
                error('ChannelElementMap needs to contain the same elements as ArrayElementMap');
            end
            % Check dimensions of arrays
            %{
            rows = length(obj.ChipID);
            assert(isequal(size(obj.RxPhases),[rows,4]), 'RxPhases must be of size 4 x length(ChipID)');
            assert(isequal(size(obj.TxPhases),[rows,4]), 'TxPhases must be of size 4 x length(ChipID)');
            assert(isequal(size(obj.RxGains),[rows,4]), 'RxGains must be of size 4 x length(ChipID)');
            assert(isequal(size(obj.TxGains),[rows,4]), 'TxGains must be of size 4 x length(ChipID)');
            %}
            % Get devices based on beam arrangement
            obj.setChipID();
            
            % Get element indices in 2D, i.e., row and column numbers
            obj.ElementR = zeros(numel(obj.ArrayElementMap), 1);
            obj.ElementC = zeros(numel(obj.ArrayElementMap), 1);
            for ii = 1:numel(obj.ChannelElementMap)
                [obj.ElementR(ii), obj.ElementC(ii)] = ...
                    find(obj.ChannelElementMap(ii) == obj.ArrayElementMap);
            end
            
            % Create channel vector
            obj.Channels = adi.ADAR1000.Channel.empty(numel(obj.ArrayElementMap), 0);
            for ii = 1:numel(obj.ChannelElementMap)
                obj.Channels(ii) = adi.ADAR1000.Channel(obj, ii, ...
                    obj.ChannelElementMap(ii), obj.ElementR(ii), obj.ElementC(ii));
            end
            x = 1;
            %{
            % Set attributes in hardware
            obj.setAllDevs(obj.RxPhases,'phase',false)
            obj.setAllDevs(obj.TxPhases,'phase',true)
            obj.setAllDevs(obj.RxGains,'hardwaregain',false)
            obj.setAllDevs(obj.TxGains,'hardwaregain',true)
            %}
        end
    end
    
    methods
        function res = getDeviceAttribute(obj, DevAttrName)
            attrCount = obj.iio_device_get_attrs_count(devPtr);
            for i = 1:attrCount
                attr = obj.iio_device_get_attr(devPtr,i-1);
                if strcmpi(attr,'label')
                end
            end
            
        end
        %{
        function res = get.BeamMemEnable(obj)
            res = obj.getAttributeLongLong(sprintf('voltage%d',obj.ADARChannel), 'pa_bias_off', true);
            attrCount = obj.iio_device_get_attrs_count(devPtr);
            for i = 1:attrCount
                attr = obj.iio_device_get_attr(devPtr,i-1);
                if strcmpi(attr,'label')
                end
            end
        end
        
        function set.BeamMemEnable(obj, value)
            dac_code = int(value / obj.BIAS_CODE_TO_VOLTAGE_SCALE);
            obj.ADARParent.setAttributeBool(sprintf('voltage%d',obj.ADARChannel), 'pa_bias_off', true, dac_code);
        end
        %}
    end
end